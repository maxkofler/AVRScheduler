
/*
 * scheduler_switch.s
 *
 * Created: 12.06.2021 20:02:16
 *  Author: Kofle
 */ 
 #include "scheduler_asm.h"
 .global scheduler_switch

 //R25 holds the origin of the call:
 //			0x01		interrupt		returns with reti
 //			0x00		normal call		returns with ret
 //Old R25 is on stack
 scheduler_switch:

	sts addr_buf1, r24

	lds r24, addr_buf1

	//Check if the call comes from C and has those stupid stack pushes
	//and extract jumpback and sreg from it
	cpi r25, 02
	breq pop_pc_gcc

	//If not, just pop the jumpback
	sts addr_buf3, r28
	pop r28
	sts addr_jumpback, r28
	pop r28
	sts addr_jumpback+1, r28
	pop r28
	sts addr_jumpback+2, r28
	lds r28, addr_buf3

	//Call SREG with an offset of 0x20(io memory area) and move it aside
	lds r28, SREG+0x20
	sts addr_sreg, r28

	jmp make_context_switch

	//////////////////////////////////////
pop_pc_gcc:
	//First of all unwind the stack for 6 bytes (5 from GCC and 1 for old R25)

	pop r25
	pop r29						//R29
	pop r28						//R28
	pop r0						//Sreg
	sts addr_sreg, r0
	pop r0
	pop r1

	//Now pop jumpback
	pop r28
	sts addr_jumpback+2, r28
	pop r28
	sts addr_jumpback+1, r28
	pop r28
	sts addr_jumpback, r28

	jmp make_context_switch

	//////////////////////////////////////

 make_context_switch:
	//Store the switch argument
	sts addr_switch_arg, r25
	pop r25

	//Move	R30, R31	->	buf4
	//		R28, R29	->	buf3
	//		R0, R1		->	buf2
	sts addr_buf4+1,	r31
	sts addr_buf4,		r30
	sts addr_buf3+1,	r29
	sts addr_buf3,		r28
	sts addr_buf2+1,	r1
	sts addr_buf2,		r0

	//Load current PID into R28 and processdata size into R29
	lds r28, addr_curPID
	ldi r29, size_proc

	//Load start of proc data into Z
	lds r30, addr_procdata
	lds r31, addr_procdata+1
	
	//Calculate start of data segment for current PID
	mul r28, r29
	ldi r29, 0x04		//
	add r0, r29			//
	ldi r29, 0x00		//
	adc r1, r29			//Skip stack_start and stack_end for now
	sub r30, r0
	sbc r31, r1

	//Load stackpointer into Y
	lds r28, addr_stackptr
	lds r29, addr_stackptr+1

	//'Abuse' stackpointer for pushing data
	sts addr_stackptr, r30
	sts addr_stackptr+1, r31

	//Now "push" the old stackpointer without jumpback address
	push r29
	push r28

	//push PC (first byte is 0)
	ldi r29, 0x00
	push r29
	lds r29, addr_jumpback+2
	push r29
	lds r29, addr_jumpback+1
	push r29
	lds r29, addr_jumpback
	push r29

	//Push R31, R30 from buf4
	lds r29, addr_buf4+1		//R31
	push r29
	lds r29, addr_buf4			//R30
	push r29

	//Push R29, R28 from buf3
	lds r29, addr_buf3+1		//R29
	push r29
	lds r29, addr_buf3			//R28
	push r29
	
	//Now push all other registers
	push r27
	push r26
	push r25
	push r24
	push r23
	push r22
	push r21
	push r20
	push r19
	push r18
	push r17
	push r16
	push r15
	push r14
	push r13
	push r12
	push r11
	push r10
	push r9
	push r8
	push r7
	push r6
	push r5
	push r4
	push r3
	push r2

	//Push R0, R1 from buf2
	lds r29, addr_buf2+1		//R1
	push r29
	lds r29, addr_buf2			//R0
	push r29

	//Push status register
	lds r29, addr_sreg
	push r29
	//Push switch argument
	lds r29, addr_switch_arg
	push r29

	//
	//Now all registers and information is stored, pop the information for the next process
	//

	//Calculate next process to run
	//Load the start of process statuses into Z
	ldi r31, hi8(addr_procstatus)
	ldi r30, lo8(addr_procstatus)
	//Get the current PID
	lds r28, addr_curPID
		//Set the current process to runnable
		ldi r29, 0x02
		st Z, r29

	ldi r29, 0x00
	sub r30, r28
	sbc r31, r29
	//Load maximum PIDs
	lds r29, addr_maxProcesses
nextPID_loop:
		//Increment current pid and Z
		inc r28
		sbiw Z, 1
		//Check if the PID is on maxPID if so, set it to 0
		cp r29, r28
		breq nextPID_loop_maxPID
		ld r27, Z
		cpi r27, 0x02
		breq nextPID_loop_end
		jmp nextPID_loop

nextPID_loop_maxPID:
			//Load 255 to r28 so it is 0 when incremented
			ldi r28, 0xFF
			ldi r31, hi8(addr_procstatus+1)
			ldi r30, lo8(addr_procstatus+1)
			jmp nextPID_loop

nextPID_loop_end:
	//Store the new PID
	sts addr_curPID, r28

	//Calculate end of new pid data field to pop all data
	inc r28
	lds r30, addr_procdata
	lds r31, addr_procdata+1
	ldi r29, size_proc
	mul r29, r28
	sub r30, r0
	sbc r31, r1
	dec r28

	//Store Z to stack pointer
	sts addr_stackptr, r30
	sts addr_stackptr+1, r31

	//Call switch argument
	pop r29
	sts addr_switch_arg, r29

	//Call status register
	pop r29
	sts addr_sreg, r29

	pop r0
	pop r1
	pop r2
	pop r3
	pop r4
	pop r5
	pop r6
	pop r7
	pop r8
	pop r9
	pop r10
	pop r11
	pop r12
	pop r13
	pop r14
	pop r15
	pop r16
	pop r17
	pop r18
	pop r19
	pop r20
	pop r21
	pop r22
	pop r23
	pop r24
	pop r25
	pop r26
	pop r27
	pop r28
	pop r29
	pop r30
	pop r31

	//Move	R30, R31	->	buf4
	//		R28, R29	->	buf3
	//		R0, R1		->	buf2
	sts addr_buf4+1,	r31
	sts addr_buf4,		r30
	sts addr_buf3+1,	r29
	sts addr_buf3,		r28
	sts addr_buf2+1,	r1
	sts addr_buf2,		r0

	//Pop program counter into jumpback
	pop r30
	sts addr_jumpback, r30
	pop r30
	sts addr_jumpback+1, r30
	pop r30
	sts addr_jumpback+2, r30
	pop r30

	//Pop stack pointer and store it
	pop r30
	pop r31
	sts addr_stackptr, r30
	sts addr_stackptr+1, r31

	//Restore SREG
	lds r29, addr_sreg
	sts SREG+0x20, r29

	lds r29, addr_jumpback 
	push r29
	lds r29, addr_jumpback+1
	push r29
	lds r29, addr_jumpback+2
	push r29
	//Restore old register values
	//Move	R30, R31	<-	buf4
	//		R28, R29	<-	buf3
	//		R0, R1		<-	buf2
	lds r0, addr_buf2
	lds r1, addr_buf2+1
	lds r28, addr_buf3
	lds r29, addr_buf3+1
	lds r30, addr_buf4
	lds r31, addr_buf4+1
	reti