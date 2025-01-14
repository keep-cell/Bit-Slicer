/*
 * Copyright (c) 2022 Mayur Pawashe
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
#import "ZGProcessTypes.h"
#import "ZGBreakPointDelegate.h"

@class ZGProcess;
@class ZGInstruction;
@class ZGBreakPointController;

NS_ASSUME_NONNULL_BEGIN

@interface ZGCodeInjectionHandler : NSObject <ZGBreakPointDelegate>

@property (nonatomic, readonly, nullable) ZGInstruction *toIslandInstruction;
@property (nonatomic, readonly, nullable) ZGInstruction *fromIslandInstruction;
@property (nonatomic, readonly) ZGMemoryAddress islandAddress;
@property (nonatomic, readonly, nullable) ZGProcess *process;
@property (nonatomic, readonly, weak) id owner;

- (BOOL)addBreakPointWithToIslandInstruction:(ZGInstruction *)toIslandInstruction fromIslandInstruction:(ZGInstruction *)fromIslandInstruction islandAddress:(ZGMemoryAddress)islandAddress process:(ZGProcess *)process processType:(ZGProcessType)processType breakPointController:(ZGBreakPointController *)breakPointController owner:(id)owner undoManager:(nullable NSUndoManager *)undoManager;

- (void)removeCodeInjection;

@end


NS_ASSUME_NONNULL_END
