//
//  Coroutine.cpp
//  coroutine
//
//  Created by Marcin Swiderski on 10/23/12.
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

#if COROUTINE_SAFE

void Coroutine::validate() {
	if (_stackPointer <= _stack) {
		COROUTINE_ON_OUT_OF_BOUNDS();
	
	} else if (*_stack != 0) {
		COROUTINE_ON_OUT_OF_BOUNDS();
	}
}

#endif // COROUTINE_SAFE
