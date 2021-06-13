
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

	//Move	R30, R31	->	buf4
	//		R28, R29	->	buf3
	//		R0, R1		->	buf2
	//		SP			->	buf1
	sts addr_buf4+1,	r31
	sts addr_buf4,		r30
	sts addr_buf3+1,	r29
	sts addr_buf3,		r28
	sts addr_buf2+1,	r1
	sts addr_buf2,		r0
	lds r30, addr_stackptr
	lds r31, addr_stackptr+1
	sts addr_buf1, r30
	sts addr_buf1+1, r31

	//Load next PID into R28
	lds r28, addr_nextPID
	inc r28
	sts addr_nextPID, r28
	dec r28

	//Set process status to runnable (0x02)
	ldi r31, hi8(addr_procstatus)
	ldi r30, lo8(addr_procstatus)
	sub r30, r28
	ldi r29, 0x00
	sbc r30, r29
	ldi r29, 0x02
	st Z, r29

	//Calculate start of process data for the new process
	lds r30, addr_procdata
	lds r31, addr_procdata+1
	ldi r29, size_proc
	mul r28, r29
	sub r30, r0
	sbc r31, r1
	sts addr_stackptr, r30
	sts addr_stackptr+1, r31

	//Load next stack start into Z and store it
	lds r30, addr_nextStack
	lds r31, addr_nextStack+1
	push r31
	push r30

	//Copy it to Y to calculate stack end and next stack
	mov r28, r30
	mov r29, r31
	sub r28, r22
	sbc r29, r23
	push r29
	push r28
	sts addr_nextStack, r28
	sts addr_nextStack+1, r29

	//Store new stack pointer
	push r31
	push r30
	
	//Push jumpback
	ldi r29, 0x00
	push r29
	push r29
	push r25		//High
	push r24		//Low

	lds r24, addr_nextPID
	dec r24

	//Restore old register values
	//Move	R30, R31	<-	buf4
	//		R28, R29	<-	buf3
	//		R0, R1		<-	buf2
	//		SP			<-	buf1
	lds r28, addr_buf1
	lds r29, addr_buf1+1
	sts addr_stackptr, r28
	sts addr_stackptr+1, r29
	lds r0, addr_buf2
	lds r1, addr_buf2+1
	lds r28, addr_buf3
	lds r29, addr_buf3+1
	lds r30, addr_buf4
	lds r31, addr_buf4+1

	ret