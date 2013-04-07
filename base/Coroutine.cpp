//
//  Coroutine.cpp
//  coroutine
//
//  Created by Marcin Swiderski on 10/23/12.
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

#include "Coroutine.h"

#include <cstring>

Coroutine::Coroutine()
	: _flags(StackOwned)
	, _stack(new uint8_t[COROUTINE_STACK_SIZE])
	, _stackBase(_stack + COROUTINE_STACK_SIZE)
	, _stackPointer(_stackBase) {

#if COROUTINE_SAFE
	memset(_stack, 0xFF, COROUTINE_STACK_SIZE);
#endif
	alignStackBase();
}

Coroutine::Coroutine(uint8_t* stack, uint8_t* stackBase, bool deleteStack)
	: _flags(deleteStack ? StackOwned : 0)
	, _stack(stack)
	, _stackBase(stackBase)
	, _stackPointer(stackBase) {
	

#if COROUTINE_SAFE
	if (isStackOwned()) {
		memset(_stack, 0xFF, _stackBase - _stack);
	}
#endif
	alignStackBase();
}

Coroutine::~Coroutine() {
	if (isStackOwned()) {
		delete [] _stack;
	}
}

#if COROUTINE_SAFE

size_t Coroutine::estimateUsedStackSize() const {
	size_t usedStackSize = _stackBase - _stack;
	
	if (!isStackOwned()) {
		// Don't estimate size of stack that is not owned.
		return usedStackSize;
	}
	
	for (uint8_t *p = _stack; p != _stackBase && *p == 0xFF; ++p) {
		--usedStackSize;
	}
	
	return usedStackSize;
}

void Coroutine::validate() const {
	if (!isStackOwned()) {
		// Don't validate stack that is not owned.
		return;
	}
	
	if (_stackPointer <= _stack) {
		COROUTINE_ON_OUT_OF_BOUNDS();
	
	} else if (*_stack != 0xFF) {
		COROUTINE_ON_OUT_OF_BOUNDS();
	}
}

#endif // COROUTINE_SAFE
