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

#import "ZGSearchResults.h"

@implementation ZGSearchResults

static ZGMemoryAddress _resultCount(NSArray<NSData *> *resultSets, ZGMemorySize stride)
{
	NSUInteger count = 0;
	for (NSData *result in resultSets)
	{
		count += result.length / stride;
	}
	return count;
}

+ (ZGMemorySize)indirectStrideWithMaxNumberOfLevels:(ZGMemorySize)numberOfLevels pointerSize:(ZGMemorySize)pointerSize
{
	//	Struct {
	//		uintptr_t baseAddress;
	//		uint16_t numLevels;
	//		uint16_t offsets[MAX_NUM_LEVELS];
	//		uint8_t padding[N];
	//	}
	
	ZGMemorySize minimumSize = pointerSize + sizeof(uint16_t) + numberOfLevels * sizeof(uint16_t);
	ZGMemorySize remainder = minimumSize % pointerSize;
	ZGMemorySize padding = (remainder == 0) ? 0 : (pointerSize - remainder);
	return minimumSize + padding;
}

- (id)initWithResultSets:(NSArray<NSData *> *)resultSets resultType:(ZGSearchResultType)resultType dataType:(ZGVariableType)dataType stride:(ZGMemorySize)stride unalignedAccess:(BOOL)unalignedAccess
{
	self = [super init];
	if (self != nil)
	{
		NSMutableArray<NSData *> *newResultSets = [NSMutableArray array];
		for (NSData *resultData in resultSets)
		{
			if (resultData.length > 0)
			{
				[newResultSets addObject:resultData];
			}
		}
		
		_resultSets = [newResultSets copy];
		_resultType = resultType;
		_dataType = dataType;
		_stride = stride;
		_count = _resultCount(newResultSets, stride);
		_unalignedAccess = unalignedAccess;
	}
	return self;
}

- (void)enumerateWithCount:(ZGMemorySize)count usingBlock:(zg_enumerate_search_results_t)addressCallback
{
	if (count == 0)
	{
		return;
	}
	
	NSMutableArray<NSData *> *newResultSets = [NSMutableArray array];

	ZGMemorySize stride = _stride;
	
	NSUInteger resultsProcessed = 0;
	
	BOOL shouldStopEnumerating = NO;
	NSUInteger resultSetIndex = 0;
	NSArray<NSData *> *resultSets = _resultSets;
	for (NSData *resultSet in resultSets)
	{
		const void *resultBytes = resultSet.bytes;
		ZGMemoryAddress resultSetLength = resultSet.length;
		for (ZGMemoryAddress offset = 0; offset < resultSetLength; offset += stride)
		{
			addressCallback((const void *)((const uint8_t *)resultBytes + offset), &shouldStopEnumerating);
			resultsProcessed++;
			
			if (resultsProcessed >= count || shouldStopEnumerating)
			{
				// Is there any left over data from current result set
				if (offset + stride < resultSetLength)
				{
					[newResultSets addObject:[resultSet subdataWithRange:NSMakeRange(offset + stride, resultSetLength - offset - stride)]];
				}
				
				// Grab the remaining result sets we haven't processed
				NSUInteger resultSetsCount = resultSets.count;
				if (resultSetIndex + 1 < resultSetsCount)
				{
					NSArray<NSData *> *remainingResultSets = [resultSets subarrayWithRange:NSMakeRange(resultSetIndex + 1, resultSetsCount - resultSetIndex - 1)];
					
					[newResultSets addObjectsFromArray:remainingResultSets];
				}
				
				goto FINISH_ENUMERATING;
			}
		}
		
		resultSetIndex++;
	}
	
FINISH_ENUMERATING:
	_resultSets = [newResultSets copy];
	_count = _resultCount(newResultSets, stride);
}

@end
