//
//  Coroutine_i386.cpp
//  coroutine
//
//  Created by Marcin Świderski on 8/9/12.
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

#ifdef COROUTINE_I386

void Coroutine::alignStackBase() {
	// Align to 16 bytes.
	_stackBase = reinterpret_cast<uint8_t*>(reinterpret_cast<ptrdiff_t>(_stackBase) & 0xffffff00lu);
}

#endif // COROUTINE_I386
