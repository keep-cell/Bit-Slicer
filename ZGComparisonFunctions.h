/*
 * Created by Mayur Pawashe on 8/18/10.
 *
 * Copyright (c) 2012 zgcoder
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ZGVariable.h"
#import "ZGVirtualMemory.h"
#import "ZGSearchData.h"

#define COMPARISON_PARAMETERS ZGSearchData * __unsafe_unretained searchData, const void *variableValue, const void *compareValue, ZGMemorySize size
typedef BOOL (*comparison_function_t)(COMPARISON_PARAMETERS);

@class ZGSearchData;

typedef enum
{
	// Regular comparisons
	ZGEquals = 0,
	ZGNotEquals,
	ZGGreaterThan,
	ZGLessThan,
	// Stored comparisons
	ZGEqualsStored,
	ZGNotEqualsStored,
	ZGGreaterThanStored,
	ZGLessThanStored,
	// Special Stored comparisons
	ZGEqualsStoredPlus,
	ZGNotEqualsStoredPlus,
	
	ZGStoreAllValues,
} ZGFunctionType;

comparison_function_t getComparisonFunction(ZGFunctionType functionType, ZGVariableType dataType, BOOL is64Bit, ZGVariableQualifier qualifier);
