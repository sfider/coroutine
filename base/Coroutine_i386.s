//
//  Coroutine_i386.s
//  coroutine
//
//  Created by Marcin Swiderski on 10/18/12.
//  Copyright (c) 2012 Marcin Świderski. All rights reserved.
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

#ifdef COROUTINE_I386

	.section	__TEXT,__text,regular,pure_instructions

//----------------------------------------------------------------------------------------------------------------------
// int Coroutine::operator()()
//----------------------------------------------------------------------------------------------------------------------

	.globl	__ZN9CoroutineclEv
	.align	1, 0x90
__ZN9CoroutineclEv:

	// Load 'this' to EAX.
	movl		4(%esp), %eax
	
	// Move ESP to _stackBase, so the prolog can be saved directly to base of the coroutine stack.
	movl		%esp, %edx
	movl		COROUTINE_OFFSET_STACKBASE(%eax), %esp
	
	// Save all nonvolatile registers and original ESP register (currently in EDX).
	pushl		%edx
	pushl		%ebp
	movl		%esp, %ebp
	pushl		%ebx
	pushl		%esi
	pushl		%edi
	
	// Check if the call has already started.
	movl		COROUTINE_OFFSET_STATEFLAGS(%eax), %edx
	testl		$1, %edx
	jz			L_FIRST
	
	// Move ESP to coroutine stack.
	movl		COROUTINE_OFFSET_STACKPOINTER(%eax), %esp
	
	// The coroutine is run after it yielded. Load coroutine context.
	popl		%edi
	popl		%esi
	popl		%ebx
	popl		%ebp
	
	// Return to coroutine.
	ret
	
	// The coroutine is run for the first time. Mark as started.
L_FIRST:
	orl			$1, %edx
	movl		%edx, COROUTINE_OFFSET_STATEFLAGS(%eax)
	
	// Store 'this' pointer and add padding before calling coroutine.
	subl		$8, %esp
	pushl		%eax
	
	// Call run(), it is the second virtual function.
	mov			(%eax), %edx
	mov			COROUTINE_VTABLE_RUN(%edx), %edx
	call		*%edx

#if COROUTINE_SAFE
	// Validate the coroutine.
	movl		%eax, 4(%esp)
	call		__ZNK9Coroutine8validateEv
	movl		4(%esp), %eax
#endif

	// Restore 'this' pointer to ECX (EAX holds return value) and remove padding.
	popl		%ecx
	addl		$8, %esp

	// Mark as finished.
	movl		COROUTINE_OFFSET_STATEFLAGS(%ecx), %edx
	orl			$2, %edx
	movl		%edx, COROUTINE_OFFSET_STATEFLAGS(%ecx)
	
	// Restore all nonvolatile registers and original ESP.
	popl		%edi
	popl		%esi
	popl		%ebx
	popl		%ebp
	popl		%edx
	movl		%edx, %esp
	
	// Return to caller.
	ret

//----------------------------------------------------------------------------------------------------------------------
// void Coroutine::yield(int ret)
//----------------------------------------------------------------------------------------------------------------------

	.globl	__ZN9Coroutine5yieldEi
	.align	1, 0x90
__ZN9Coroutine5yieldEi:

	// Load 'this' to EDX and 'ret' to EAX.
	movl		4(%esp), %edx
	movl		8(%esp), %eax
	
	// Save nonvolatile registers.
	pushl		%ebp
	movl		%esp, %ebp
	pushl		%ebx
	pushl		%esi
	pushl		%edi

	// Save ESP to _stackPointer.
	movl		%esp, COROUTINE_OFFSET_STACKPOINTER(%edx)

#if COROUTINE_SAFE
	// Validate the coroutine.
	subl		$12, %esp
	movl		%eax, 4(%esp)
	movl		%edx, (%esp)
	call		__ZNK9Coroutine8validateEv
	movl		(%esp), %edx
	movl		4(%esp), %eax
	addl		$12, %esp
#endif
	
	// Move ESP to caller context near the base of the stack (_stackBase).
	movl		COROUTINE_OFFSET_STACKBASE(%edx), %esp
	subl		$20, %esp
	
	// Restore original context and ESP.
	popl		%edi
	popl		%esi
	popl		%ebx
	popl		%ebp
	popl		%edx
	movl		%edx, %esp
	
	// Return to caller.
	ret

#endif // COROUTINE_I386
