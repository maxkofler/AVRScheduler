/*
 * IncFile1.h
 *
 * Created: 01.06.2021 20:01:50
 *  Author: Kofle
 */ 


#ifndef INCFILE1_H_
#define INCFILE1_H_

//	Needs to get called on the ABSOLUTE START of the program
//	Always call this on the beginning of the program, this moves stack pointer!
//	max_processes			The maximum amount of processes to reserve space for
//	stack_size				The maximum size of the main stack
extern "C" void scheduler_init(uint8_t max_processes, uint16_t stack_size);

//	Tells the scheduler to register a new process
//	entry_point				The function to enter: void ...();
//	return					The PID of the new process
extern "C" uint8_t scheduler_new_process(void* entry_point);

//	Switches to the specified pid to execute code
extern "C" void scheduler_switch(uint8_t pid);

#endif /* INCFILE1_H_ */