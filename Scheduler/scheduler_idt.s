
/*
 * scheduler_idt.s
 *
 * Created: 13.06.2021 18:20:04
 *  Author: Kofle
 */ 
  #include <avr/interrupt.h>

 .global scheduler_isr


 .org 0x001A
 .data
 rjmp scheduler_isr_jumper

 .text
 .org 0x0033
 scheduler_isr_jumper:
	jmp scheduler_isr