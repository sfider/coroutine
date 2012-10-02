//
//  Coroutine.cpp
//  coroutine
//
//  Created by Marcin Świderski on 8/9/12.
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

#include "Coroutine.h"

static const unsigned long StackSize = 4096;

Coroutine::Coroutine()
	: _stateFlags(0)
	, _stack(new uint8_t[StackSize])
	, _stackBase(_stack + StackSize) {}

Coroutine::~Coroutine() {
	delete [] _stack;
}

void Coroutine::operator()() const {
	// Move SP to _stackBase, so the prolog can be saved directly to base of the coroutine stack.
	asm volatile (
		"\n	ldr			r1, [r0, #12]"
		"\n	mov			r2, sp"
		"\n	mov			sp, r1"
	);
	
	// Save all nonvolatile registers and original SP register (currently in r2).
	asm volatile (
		"\n	stmfd		sp!, {r2}"
		"\n	stmfd		sp!, {r4-r7, lr}"
		"\n	add			r7, sp, #12"
		"\n	stmfd		sp!, {r8, r10, r11}"
	);
	
	// Store 'this' pointer before calling coroutine.
	asm volatile (
		"\n	sub			sp, #4"
		"\n	str			r0, [sp]"
	);
	
	// Check if the call has already started.
	asm volatile (
		"\n	ldr			r1, [r0, #4]"
		"\n	tst			r1, #1"
		"\n	beq			L_FIRST"
	);
	
	// Move SP to coroutine stack.
	asm volatile (
		"\n	ldr			sp, [r0, #16]"
	);
	
	// The coroutine is run after it yielded. Load coroutine context.
	asm volatile (
		"\n	ldmfd		sp!, {r8, r10, r11}"
		"\n	ldmfd		sp!, {r4-r7, lr}"
	);
	
	// Return to coroutine.
	asm volatile (
		"\n	b			L_RETURN"
	);
	
	// The coroutine is run for the first time. Mark as started.
	asm volatile (
		"\nL_FIRST:"
		"\n	orr			r1, r1, #1"
		"\n	str			r1, [r0, #4]"
	);
	
	// Call run(), it is the second virtual function.
	asm volatile (
		"\n	ldr			r1, [r0]"
		"\n	ldr			r1, [r1, #8]"
		"\n	blx			r1"
	);
	
	// Restore 'this' pointer.
	asm volatile (
		"\n	ldr			r0, [sp]"
		"\n	add			sp, #4"
	);
	
	// Mark as finished.
	asm volatile (
		"\n	ldr			r1, [r0, #4]"
		"\n	orr			r1, r1, #2"
		"\n	str			r1, [r0, #4]"
	);
	
	// Restore all nonvolatile registers and original SP.
	asm volatile (
		"\n	ldmfd		sp!, {r8, r10, r11}"
		"\n	ldmfd		sp!, {r4-r7, lr}"
		"\n	ldmfd		sp!, {r2}"
		"\n	mov			sp, r2"
	);
	
	// Substitute for return statement. Solves the problem of any prolog added by compiler e.g. for debugging.
	asm volatile (
		"\nL_RETURN:"
	);
}

bool Coroutine::didFinish() const {
	return _stateFlags & StateFinished;
}

void Coroutine::yield() {
	// Save nonvolatile registers.
	asm volatile (
		"\n	stmfd		sp!, {r4-r7, lr}"
		"\n	stmfd		sp!, {r8, r10, r11}"
	);
	
	// Save SP to _stackPointer.
	asm volatile (
		"\n	str			sp, [r0, #16]"
	);
	
	// Move SP to caller context near the base of the stack (_stackBase).
	asm volatile (
		"\n	ldr			r1, [r0, #12]"
		"\n	sub			sp, r1, #36"
	);
	
	// Restore original context and SP.
	asm volatile (
		"\n	ldmfd		sp!, {r8, r10, r11}"
		"\n	ldmfd		sp!, {r4-r7, lr}"
		"\n	ldmfd		sp!, {r2}"
		"\n	mov			sp, r2"
	);
}
