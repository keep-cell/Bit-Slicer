/*
 * Copyright (c) 2013 Mayur Pawashe
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

#import <Foundation/Foundation.h>
#import "ZGMemoryTypes.h"
#import "ZGVariableTypes.h"
#import "ZGSearchProgressDelegate.h"
#import "ZGFunctionTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class ZGSearchData;
@class ZGSearchResults;

#ifdef __cplusplus
extern "C"
#endif
ZGSearchResults *ZGSearchForData(ZGMemoryMap processTask, ZGSearchData *searchData, id <ZGSearchProgressDelegate> _Nullable delegate, ZGVariableType dataType, ZGVariableQualifier integerQualifier, ZGFunctionType functionType);

#ifdef __cplusplus
extern "C"
#endif
ZGSearchResults *ZGNarrowSearchForData(ZGMemoryMap processTask, BOOL translated, ZGSearchData *searchData, id <ZGSearchProgressDelegate> _Nullable delegate, ZGVariableType dataType, ZGVariableQualifier integerQualifier, ZGFunctionType functionType, ZGSearchResults *firstSearchResults, ZGSearchResults * _Nullable laterSearchResults);

#ifdef __cplusplus
extern "C"
#endif
ZGSearchResults *ZGSearchForIndirectPointer(ZGMemoryMap processTask, ZGSearchData *searchData, id <ZGSearchProgressDelegate> delegate, uint16_t indirectMaxLevels, ZGVariableType indirectDataType, ZGSearchResults * _Nullable previousSearchResults);

#ifdef __cplusplus
extern "C"
#endif
ZGSearchResults *ZGNarrowIndirectSearchForData(ZGMemoryMap processTask, BOOL translated, ZGSearchData *searchData, id <ZGSearchProgressDelegate> _Nullable delegate, ZGVariableType dataType, ZGVariableQualifier integerQualifier, ZGFunctionType functionType, ZGSearchResults *indirectSearchResults);

NS_ASSUME_NONNULL_END
