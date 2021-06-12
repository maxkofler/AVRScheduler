/*
 * scheduler_asm.h
 *
 * Created: 12.06.2021 16:10:34
 *  Author: Kofle
 */ 


#ifndef SCHEDULER_ASM_H_
#define SCHEDULER_ASM_H_

#include <avr/io.h>

 .equ addr_maxProcesses, RAMEND
 .equ addr_curPID, RAMEND-1
 .equ addr_nextPID, RAMEND-2
 .equ addr_nextStack, RAMEND-4
 .equ addr_buf1, RAMEND-6
 .equ addr_buf2, RAMEND-8
 .equ addr_buf3, RAMEND-10
 .equ addr_jumpback, RAMEND-13

 //The start of the process informations
 .equ addr_procdata, RAMEND-15
 .equ addr_stacks, RAMEND-17
 .equ addr_procstatus, RAMEND-18
 .equ size_proc, 0x2A				//42 bytes for every process

 //Some addresses for usage
 .equ addr_stackptr, 0x005D

#endif /* SCHEDULER_ASM_H_ */