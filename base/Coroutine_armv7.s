//
//  Coroutine_armv7.s
//  coroutine
//
//  Created by Marcin Swiderski on 10/19/12.
//  Copyright (c) 2012 Marcin Świderski.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//  
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//  
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//

#define COROUTINE_ASM

#include "Coroutine.h"

#ifdef COROUTINE_ARMV7

	.syntax unified
	.section	__TEXT,__text,regular,pure_instructions

//----------------------------------------------------------------------------------------------------------------------
// int Coroutine::operator()()
//----------------------------------------------------------------------------------------------------------------------

	.globl	__ZN9CoroutineclEv
	.align	2
	.code	16
	.thumb_func	__ZN9CoroutineclEv
__ZN9CoroutineclEv:

	// Move SP to _stackBase, so the prolog can be saved directly to base of the coroutine stack.
	ldr			r1, [r0, #COROUTINE_OFFSET_STACKBASE]
	mov			r2, sp
	mov			sp, r1

	// Save all nonvolatile registers and original SP register (currently in r2).
	push		{r2, r4-r7, lr}
	add			r7, sp, #12
	push		{r8, r10, r11}
	vstmdb		sp!, {d8-d15}

	// Check if the call has already started.
	ldr			r1, [r0, #COROUTINE_OFFSET_STATEFLAGS]
	tst			r1, #1
	beq			L_FIRST

	// Move SP to coroutine stack.
	ldr			sp, [r0, #COROUTINE_OFFSET_STACKPOINTER]

	// The coroutine is run after it yielded. Load coroutine context.
	vldmia		sp!, {d8-d15}
	pop			{r8, r10, r11}
	pop			{r4-r7, lr}

	// Return to coroutine.
	bx			lr

	// The coroutine is run for the first time. Mark as started.
L_FIRST:
	orr			r1, r1, #1
	str			r1, [r0, #COROUTINE_OFFSET_STATEFLAGS]

	// Store 'this' pointer before calling coroutine.
	push		{r0}

	// Call run(), it is the second virtual function.
	ldr			r1, [r0]
	ldr			r1, [r1, #COROUTINE_VTABLE_RUN]
	blx			r1

	// Restore 'this' pointer to r2, r0 holds return value.
	pop			{r2}

#if COROUTINE_SAFE
	// Validate the coroutine.
	mov			r4, r0
	mov			r5, r2
	mov			r0, r2
	blx			__ZNK9Coroutine8validateEv
	mov			r2, r5
	mov			r0, r4
#endif

	// Mark as finished.
	ldr			r1, [r2, #COROUTINE_OFFSET_STATEFLAGS]
	orr			r1, r1, #2
	str			r1, [r2, #COROUTINE_OFFSET_STATEFLAGS]

	// Restore all nonvolatile registers and original SP.
	vldmia		sp!, {d8-d15}
	pop			{r8, r10, r11}
	pop			{r2, r4-r7, lr}
	mov			sp, r2

	// Return to caller.
	bx			lr

//----------------------------------------------------------------------------------------------------------------------
// void Coroutine::yield(int ret)
//----------------------------------------------------------------------------------------------------------------------

	.globl	__ZN9Coroutine5yieldEi
	.align	2
	.code	16
	.thumb_func	__ZN9Coroutine5yieldEi
__ZN9Coroutine5yieldEi:

	// Save nonvolatile registers.
	push		{r4-r7, lr}
	add			r7, sp, #12
	push		{r8, r10, r11}
	vstmdb		sp!, {d8-d15}

	// Save SP to _stackPointer.
	str			sp, [r0, #COROUTINE_OFFSET_STACKPOINTER]
	
#if COROUTINE_SAFE
	// Validate the coroutine.
	mov			r4, r0
	mov			r5, r1
	blx			__ZNK9Coroutine8validateEv
	mov			r1, r5
	mov			r0, r4
#endif

	// Move SP to caller context near the base of the stack (_stackBase).
	ldr			r2, [r0, #COROUTINE_OFFSET_STACKBASE]
	sub			sp, r2, #100
	
	// Move ret to result register.
	mov			r0, r1
	
	// Restore original context and SP.
	vldmia		sp!, {d8-d15}
	pop			{r8, r10, r11}
	pop			{r2, r4-r7, lr}
	mov			sp, r2

	// Return to caller.
	bx			lr

#endif // COROUTINE_ARMV7
