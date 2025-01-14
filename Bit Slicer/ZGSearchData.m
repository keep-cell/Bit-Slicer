/*
 * Copyright (c) 2012 Mayur Pawashe
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

#import "ZGSearchData.h"
#import "ZGDebugLogging.h"

@implementation ZGSearchData

- (id)init
{
	return [self initWithSearchValue:NULL dataSize:0 dataAlignment:1 pointerSize:0];
}

- (id)initWithSearchValue:(void *)searchValue dataSize:(ZGMemorySize)dataSize dataAlignment:(ZGMemorySize)dataAlignment pointerSize:(ZGMemorySize)pointerSize
{
	self = [super init];
	if (self != nil)
	{
		if (UCCreateCollator(NULL, 0, kUCCollateCaseInsensitiveMask, &_collator) != noErr)
		{
			ZG_LOG(@"Error: Failed to create Collator..");
		}
		
		_endAddress = MAX_MEMORY_ADDRESS;
		_protectionMode = ZGProtectionAll;
		_epsilon = DEFAULT_FLOATING_POINT_EPSILON;
		
		_dataSize = dataSize;
		_dataAlignment = dataAlignment;
		_pointerSize = pointerSize;
		
		_indirectStopAtStaticAddresses = YES;
		
		[self setSearchValue:searchValue];
	}
	return self;
}

- (void)dealloc
{
	UCDisposeCollator(&_collator);
	
	[self setRangeValue:NULL];
	[self setSwappedValue:NULL];
	[self setByteArrayFlags:NULL];
	[self setSearchValue:NULL];
	[self setSavedData:NULL];
	[self setAdditiveConstant:NULL];
}

- (void)setSearchValue:(void *)searchValue
{
	free(_searchValue);
	_searchValue = searchValue;
}

- (void)setSwappedValue:(void *)swappedValue
{
	free(_swappedValue);
	_swappedValue = swappedValue;
}

- (void)setRangeValue:(void *)newRangeValue
{
	free(_rangeValue);
	_rangeValue = newRangeValue;
}

- (void)setByteArrayFlags:(unsigned char *)newByteArrayFlags
{
	free(_byteArrayFlags);
	_byteArrayFlags = newByteArrayFlags;
}

- (void)setAdditiveConstant:(void *)additiveConstant
{
	free(_additiveConstant);
	_additiveConstant = additiveConstant;
}

- (void)setMultiplicativeConstant:(void *)multiplicativeConstant
{
	free(_multiplicativeConstant);
	_multiplicativeConstant = multiplicativeConstant;
}

@end
