//
//  Coroutine.h
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

#ifndef coroutine_Coroutine_h
#define coroutine_Coroutine_h

#include <stdint.h>

class Coroutine {
	enum {
		StateStarted	= 0x1,
		StateFinished	= 0x2
	};

	uint32_t		_stateFlags;
	uint8_t*		_stack;				// Heap allocated stack for coroutine.
	uint8_t*		_stackBase;			// Pointer to base of the coroutine stack.
	uint8_t*		_stackPointer;		// Coroutine stack pointer.
	
public:
	Coroutine();
	virtual ~Coroutine();
	
	int operator()() const;
	
	bool didFinish() const;
	
protected:
	virtual int run() = 0;
	
	void yield(int ret);
};

#endif

