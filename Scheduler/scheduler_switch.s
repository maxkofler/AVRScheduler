
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

	//Call SREG with an offset of 0x20(io memory area) and move it aside
	lds r24, SREG+0x20
	sts addr_sreg, r24

	lds r24, addr_buf1

	//Check if the call comes from C and has those stupid stack pushes
	cpi r25, 02
	breq gcc_pushes

	//If not, just pop the jumpback (2 bytes)
	sts addr_buf3, r28
	pop r28
	sts addr_jumpback, r28
	pop r28
	sts addr_jumpback+1, r28
	lds r28, addr_buf3

	jmp make_context_switch

	//////////////////////////////////////
gcc_pushes:
	//First of all unwind the stack for 5 bytes
	sts addr_buf1, r28

	pop r28
	sts addr_buf1+1, r28

	pop r28
	sts addr_buf2, r28
	pop r28
	sts addr_buf2+1, r28

	pop r28
	sts addr_buf3, r28
	pop r28
	sts addr_buf3, r28

	//Now pop jumpback (2 bytes for interrupt)
	pop r28
	sts addr_jumpback, r28
	pop r28
	sts addr_jumpback+1, r28

	//And rewind the stack
	lds r28, addr_buf3
	push r28
	lds r28, addr_buf3+1
	push r28

	lds r28, addr_buf2
	push r28
	lds r28, addr_buf2+1
	push r28

	lds r28, addr_buf1+1
	push r28

	lds r28, addr_buf1

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
	sub r0, r29			//
	ldi r29, 0x00		//
	sbc r1, r29			//Skip stack_start and stack_end for now
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
	push r29
	lds r29, addr_jumpback+1
	push r29
	lds r29, addr_jumpback
	push r29

	//Push R31, R30 from buf4
	lds r29, addr_buf4+1
	
	

	nop
	nop

	//TODO
	//Recall sreg
	//Push stack (with gcc calls)


	ret

