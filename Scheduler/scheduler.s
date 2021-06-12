
/*
 * scheduler.s
 *
 * Created: 12.06.2021 12:32:17
 *  Author: Kofle
 */ 
 #include <avr/io.h>

 .global scheduler_init

 .equ addr_maxProcesses, RAMEND
 .equ addr_curPID, RAMEND-1
 .equ addr_nextPID, RAMEND-2
 .equ addr_nextStack, RAMEND-4
 .equ addr_buf1, RAMEND-6
 .equ addr_buf2, RAMEND-8
 .equ addr_buf3, RAMEND-10
 .equ addr_jumpback, RAMEND-13

 //The start of the process informations
 .equ addr_procStart, RAMEND-14
 .equ size_proc, 0x2A				//42 bytes for every process

 //Some addresses for usage
 .equ addr_stackptr, 0x005D

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

	//Calculate the start of the 1st stack
	ldi r28, size_proc
	mov r29, r24
	mul r28, r29
	ldi r26, lo8(addr_procStart)
	ldi r27, hi8(addr_procStart)
	sub r26, r0
	sbc r27, r1
	//Z now points to the 1st stack

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

	//Store max processes = R24
	sts addr_maxProcesses, r24

	//Calculate next stack:
	sub r26, r22
	sbc r27, r23
	sts addr_nextStack, r26
	sts addr_nextStack, r27

	//Pop registers
	pop 25
	pop 26
	pop 27
	pop 28
	pop 29
	pop 30
	pop 31

	ret