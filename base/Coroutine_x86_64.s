//
//  Coroutine_x86_64.s
//  coroutine
//
//  Created by Marcin Swiderski on 4/7/13.
//  Copyright (c) 2013 Marcin Świderski.
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

#ifdef COROUTINE_X86_64

	.section	__TEXT,__text,regular,pure_instructions

//----------------------------------------------------------------------------------------------------------------------
// int Coroutine::operator()()
//----------------------------------------------------------------------------------------------------------------------

	.globl	__ZN9CoroutineclEv
	.align	1, 0x90
__ZN9CoroutineclEv:

	// Move RSP to _stackBase, so the prolog can be saved directly to base of the coroutine stack.
	movq		%rsp, %rdx
	movq		COROUTINE_OFFSET_STACKBASE(%rdi), %rsp

	// Save all nonvolatile registers and original RSP register (currently in RDX).
	pushq		%rdx
	pushq		%rbp
	movq		%rsp, %rbp
	pushq		%rbx
	pushq		%r12
	pushq		%r13
	pushq		%r14
	pushq		%r15
	
	// Check if the call has already started.
	movq		COROUTINE_OFFSET_STATEFLAGS(%rdi), %rdx
	testq		$1, %rdx
	jz			L_FIRST

	// Move RSP to coroutine stack.
	movq		COROUTINE_OFFSET_STACKPOINTER(%rdi), %rsp

	// The coroutine is run after it yielded. Load coroutine context.
	popq		%r15
	popq		%r14
	popq		%r13
	popq		%r12
	popq		%rbx
	popq		%rbp

	// Return to coroutine.
	ret

	// The coroutine is run for the first time. Mark as started.
L_FIRST:
	orq			$1, %rdx
	movq		%rdx, COROUTINE_OFFSET_STATEFLAGS(%rdi)

	// Store 'this' pointer and add padding before calling coroutine.
	subq		$8, %rsp
	pushq		%rdi

	// Call run(), it is the second virtual function.
	movq		(%rdi), %rdx
	movq		COROUTINE_VTABLE_RUN(%rdx), %rdx
	call		*%rdx

#if COROUTINE_SAFE
	// Validate the coroutine.
	movq		(%rsp), %rdi
	movq		%rax, 8(%rsp)
	call		__ZNK9Coroutine8validateEv
	movq		8(%rsp), %rax
#endif

	// Restore 'this' pointer to RDI (RAX holds return value) and remove padding.
	popq		%rdi
	addq		$8, %rsp

	// Mark as finished.
	movq		COROUTINE_OFFSET_STATEFLAGS(%rdi), %rdx
	orq			$2, %rdx
	movq		%rdx, COROUTINE_OFFSET_STATEFLAGS(%rdi)

	// Restore all nonvolatile registers and original ESP.
	popq		%r15
	popq		%r14
	popq		%r13
	popq		%r12
	popq		%rbx
	popq		%rbp
	popq		%rdx
	movq		%rdx, %rsp

	// Return to caller.
	ret

//----------------------------------------------------------------------------------------------------------------------
// void Coroutine::yield(int ret)
//----------------------------------------------------------------------------------------------------------------------

	.globl	__ZN9Coroutine5yieldEi
	.align	1, 0x90
__ZN9Coroutine5yieldEi:

	// Load 'ret' to RAX.
	movq		%rsi, %rax

	// Save nonvolatile registers.
	pushq		%rbp
	movq		%rsp, %rbp
	pushq		%rbx
	pushq		%r12
	pushq		%r13
	pushq		%r14
	pushq		%r15

	// Save RSP to _stackPointer.
	movq		%rsp, COROUTINE_OFFSET_STACKPOINTER(%rdi)

#if COROUTINE_SAFE
	// Validate the coroutine.
	subq		$24, %rsp
	movq		%rax, 8(%rsp)
	movq		%rdi, (%rsp)
	call		__ZNK9Coroutine8validateEv
	movq		(%rsp), %rdi
	movq		8(%rsp), %rax
	addq		$24, %rsp
#endif

	// Move RSP to caller context near the base of the stack (_stackBase).
	movq		COROUTINE_OFFSET_STACKBASE(%rdi), %rsp
	subq		$56, %rsp

	// Restore original context and ESP.
	popq		%r15
	popq		%r14
	popq		%r13
	popq		%r12
	popq		%rbx
	popq		%rbp
	popq		%rdx
	movq		%rdx, %rsp

	// Return to caller.
	ret

#endif // COROUTINE_X86_64
