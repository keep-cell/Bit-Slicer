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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (NSArrayAdditions)

typedef ObjectType _Nullable (^zg_array_flatmap_t)(ObjectType object);
typedef BOOL (^zg_array_filter_t)(ObjectType __unsafe_unretained object);

typedef NSComparisonResult (^zg_binary_search_t)(ObjectType __unsafe_unretained currentObject);
typedef id _Nonnull (^zg_map_t)(ObjectType __unsafe_unretained object);

- (NSArray *)zgFlatMapUsingBlock:(zg_array_flatmap_t)block;
- (NSArray<ObjectType> *)zgFilterUsingBlock:(zg_array_filter_t)shouldKeep;
- (NSArray *)zgMapUsingBlock:(zg_map_t)map;

- (nullable ObjectType)zgFirstObjectThatMatchesCondition:(zg_array_filter_t)matchingCondition;
- (BOOL)zgHasObjectMatchingCondition:(zg_array_filter_t)matchingCondition;
- (BOOL)zgAllObjectsMatchingCondition:(zg_array_filter_t)matchingCondition;

- (nullable ObjectType)zgBinarySearchUsingBlock:(zg_binary_search_t)comparator;
- (nullable ObjectType)zgBinarySearchUsingBlock:(zg_binary_search_t)comparator getIndex:(NSUInteger *)outIndex;

@end

NS_ASSUME_NONNULL_END
