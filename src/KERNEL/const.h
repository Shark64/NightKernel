/*
 *
 *              DOS PM
 *              A 32-bit Kernel Replacement for FreeDOS
 *
 *
 *              DESCRIPTION:  This file provides the general constants for
 *                            the kernel portion of DOS PM
 *
 *
 */

/* 
 * Define Intel specific functions here. If this operating system ports, 
 * this file will have to be modified to support the new processor
 *
 */
 
#define NR_REGS                11       /* number of registers in proc slot */
#define INIT_PSW           0x0200       /* initial processor status word */
#define INIT_SP     (int* )0x0010       /* initial sp: 3 words pushed by kernel */

#define REG_ES                  7       /* saved es register store in proc table */
#define REG_DS                  8
#define REG_CS                  9
#define REG_SS                 10

/* Interrupt vectors */

#define CLOCK_VECTOR          0x08      /* clock interrupt vector */
#define KEBYBOARD_VECTOR      0x09      /* keyboard interrupt vector */
#define FLOPPY_VECTOR         0x0E      /* floppy disk interrupt vector */
#define PRINTER_VECTOR        0x0F      /* printer interrupt vector */
#define SYS_VECTOR            0x20      /* system call vector */

/* Mask bits for the Intel 82C59 Interrupt Controller */

#define INT_CTL               0x20      /* PIC I/O port */
#define INT_CTLMSK            0x21      /* setting bits in this port
					 * disables the PIC, analogous to
					 * using cli in assembler
					 */
#define ENABLE                0x20      /* code used to re-enable after an
					 * interrupt
					 */
/* 
 * The following constants define default stack sizes
 * These values may be increased depending on the scope of the OS
 *
 */
 
#define TASK_STACK_BYTES      256       /* how many bytes for each task stack */
#define KRNL_STACK_BYTES      256       /* how many bytes for the kernel stack */

#define RET_REG                 0       /* system call return codes go in this register */
#define IDLE                -9999       /* this means nothing is running */

/* These are the scheduling queue constants */

#define NUM_QUEUES              3       /* number of scheduling queues */
#define TASK_QUEUE              0       /* tasks are sched. via queue 0 */
#define SERV_QUEUE              1       /* servers are sched. via queue 1 */
#define USER_QUEUE              2       /* users are sched. via queue 2 */
