
/*
 * scheduler.s
 *
 * Created: 12.06.2021 12:32:17
 *  Author: Kofle
 */ 
 #include "scheduler_asm.h"

 .global scheduler_isr
 .global scheduler_init

 scheduler_init:
	//	R24				max_processes
	//	R23		(HIGH)	stack_size
	//	R22		(LOW)	stack_size

	//Push R31, R30, R29, R28, R27, R26, R25 to stack for buffering
	push r31
	push r30
	push r29
	push r28
	push r27
	push r26
	push r25

	//Set all process-status to 0 -> not created
	//R25 is counter
	ldi r25, 0x00
	//R26 is data = 0
	ldi r26, 0x00
	//Y holds the pointer
	ldi r29, hi8(addr_procstatus)
	ldi r28, lo8(addr_procstatus)
	//Add 1 to the pointer for decrementing when writing
	inc r28
	adc r29, r26
procstatus_loop:
	st -Y, r26
	inc r25
	cp r25, r24
	brne procstatus_loop

	//Set this process (PID=0) status to 3 (running -> currently executing this process)
	ldi r26, 0x03
	sts addr_procstatus, r26

	//Calculate start of process data (registers, PC, stackptr...)
	ldi r31, hi8(addr_procstatus)
	ldi r30, lo8(addr_procstatus)
	ldi r29, 0x00
	sub r30, r24
	sbc r31, r29
	sts addr_procdata, r30
	sts addr_procdata+1, r31

	//Calculate the start of the 1st stack
	ldi r28, size_proc
	mov r29, r24
	mul r28, r29
	lds r26, addr_procdata
	lds r27, addr_procdata+1
	sub r26, r0
	sbc r27, r1

	//X now points to the 1st stack
	//Store stacks start
	sts addr_stacks+1, r27
	sts addr_stacks, r26

	//Load the current stack pointer into Y
	lds r28, addr_stackptr
	lds r29, addr_stackptr+1

	//Store Z to the stack pointer -> stackpointer moved
	sts addr_stackptr, r26
	sts addr_stackptr+1, r27

	//Load Z with ramend to move the whole stack
	ldi r30, lo8(RAMEND+1)
	ldi r31, hi8(RAMEND+1)

	//Increment stack end one to make stack compatible
	ldi r25, 0x01
	add r28, r25
	ldi r25, 0x00
	adc r28, r25

//The loop in that we move the whole stack
moveloop:
	ld r25, -Z
	push r25
	cp r30, r28
	brne moveloop
	cp r31, r29
	brne moveloop
	//Finished moving stack

	//Store current PID = 0
	ldi r26, 0x00
	sts addr_curPID, r26
	inc r26
	sts addr_nextPID, r26

	//Store max processes = R24
	sts addr_maxProcesses, r24

	//Calculate next stack:
	sub r26, r22
	sbc r27, r23
	sts addr_nextStack, r26
	sts addr_nextStack+1, r27

	//Pop registers
	pop 25
	pop 26
	pop 27
	pop 28
	pop 29
	pop 30
	pop 31

	ret