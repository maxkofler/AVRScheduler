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
 .equ addr_curPID, addr_maxProcesses-1
 .equ addr_nextPID, addr_curPID-1
 .equ addr_switch_arg, addr_nextPID-1
 .equ addr_remaining_runs, addr_switch_arg-1
 .equ addr_sreg, addr_remaining_runs-1
 .equ addr_nextStack, addr_sreg-2
 .equ addr_buf1, addr_nextStack-2
 .equ addr_buf2, addr_buf1-2
 .equ addr_buf3, addr_buf2-2
 .equ addr_buf4, addr_buf3-2
 .equ addr_jumpback, addr_buf4-3

 //The start of the process informations
 .equ addr_procdata, addr_jumpback-2
 .equ addr_stacks, addr_procdata-2
 .equ addr_procstatus, addr_stacks-1
 .equ size_proc, 0x2C				//44 bytes for every process

 //Some addresses for usage
 .equ addr_stackptr, 0x005D

#endif /* SCHEDULER_ASM_H_ */