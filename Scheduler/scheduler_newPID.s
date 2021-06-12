
/*
 * Assembler1.s
 *
 * Created: 12.06.2021 16:12:26
 *  Author: Kofle
 */ 

 #include "scheduler_asm.h"

 .global scheduler_new_process

 scheduler_new_process:
	//R25	HIGH	Function pointer
	//R24	LOW		Function pointer
	//R23	HIGH	Stack size
	//R22	LOW		Stack size
	//Ret			New pid

	//Store R30, R31 in buf1, R29, R28 in buf2
	sts addr_buf1+1, R31
	sts addr_buf1, R30
	sts addr_buf2+1, R29
	sts addr_buf2, R28

	//Pop the jumpback address, will get stored as program counter in the process data later
	pop r28
	sts addr_jumpback+2, r28
	pop r28
	sts addr_jumpback+1, r28
	pop r28
	sts addr_jumpback, r28

	//Load current PID into R28
	lds r28, addr_curPID

	//Set the current PID to status 2 (runnable)
	ldi R31, hi8(addr_procstatus)
	ldi R30, lo8(addr_procstatus)
	ldi r29, 0x00
	sub r30, r28
	sbc r31, r29
	st Z, 2

	//Obtain new PID to R28
	lds r28, addr_nextPID
	inc r28
	sts addr_nextPID, r28
	dec r28

	//Set new PID to status 3 (running)
	ldi R31, hi8(addr_procstatus)
	ldi R30, lo8(addr_procstatus)
	ldi r29, 0x00
	sub r30, r28
	sbc r31, r29
	st Z, 2

	//
	//Now perform a "context switch"
	//

	//Store stack pointer in buf3
	lds r28, addr_stackptr
	lds r29, addr_stackptr+1
	sts addr_buf3, r28
	sts addr_buf3+1, r29

	//Now calculate a new "stack pointer", 'abuse' the stack pointer for filling the process data
	lds r28, addr_curPID
	lds r31, addr_procdata+1
	lds r30, addr_procdata
	ldi r29, size_proc
	mul r28, r29
	ldi r29, 0x04		//
	add r0, r29			//
	ldi r29, 0x00		//
	adc r1, r29			//	This is to skip stack_start and stack_end fields, no need to manipulate them on old process
	sub r30, r0
	sbc r31, r1
	//Store the new "stack pointer"
	sts addr_stackptr, r30
	sts addr_stackptr+1, r31

	//Store the old stack pointer	
	lds r28, addr_buf3+1
	push r28
	lds r28, addr_buf3
	push r28

	//Now store jumpback
	//First byte is 0
	ldi r28, 0x00
	push r28
	lds r28, addr_jumpback+2
	push r28
	lds r28, addr_jumpback+1
	push r28
	lds r28, addr_jumpback
	push r28

	//Recall R31, R30, R29, R28
	lds r31, addr_buf1+1
	lds r30, addr_buf1
	lds r29, addr_buf2+1
	lds r28, addr_buf2

	//Now push all registers
	push r31
	push r30
	push r29
	push r28
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
	push r1
	push r0

	//Now move "stack pointer" to the next data field
	lds r28, addr_nextPID
	dec r28
	lds r31, addr_procdata+1
	lds r30, addr_procdata
	ldi r29, size_proc
	mul r28, r29
	sub r30, r0
	sbc r31, r1

	//Load the next stack start into X
	lds r26, addr_nextStack
	lds r27, addr_nextStack+1
	//Push it
	push r27
	push r26
	//Move it aside to later load it into stack
	mov r28, r26
	mov r29, r27

	//Calculate next stack start and this end
	sub r26, r22
	sbc r27, r23
	//Push it
	push r27
	push r26
	//Store it as next stack start
	sts addr_nextStack, r26
	sts addr_nextStack+1, r27

	//Store new real stack pointer
	sts addr_stackptr, r28
	sts addr_stackptr+1, r29

	//Push "jumpback" -> new process entry point
	push r24
	push r25
	ldi r28, 0x00
	push r28

	//Set current PID
	lds r28, addr_nextPID
	dec r28
	sts addr_curPID, r28

	mov r24, r28
	ret