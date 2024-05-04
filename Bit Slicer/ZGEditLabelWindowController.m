/*
 * Copyright (c) 2024 Mayur Pawashe
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

#import "ZGEditLabelWindowController.h"
#import "ZGVariableController.h"
#import "ZGVariable.h"
#import "ZGNullability.h"
#import "ZGRunAlertPanel.h"

#define ZGEditLabelLocalizableTable @"[Code] Edit Variable Label"

@implementation ZGEditLabelWindowController
{
	ZGVariableController * _Nonnull _variableController;
	NSArray<ZGVariable *> * _Nullable _variables;
	
	IBOutlet NSTextField *_labelTextField;
}

- (NSString *)windowNibName
{
	return @"Edit Label Dialog";
}

- (id)initWithVariableController:(ZGVariableController *)variableController
{
	self = [super init];
	if (self != nil)
	{
		_variableController = variableController;
	}
	return self;
}

- (void)requestEditingLabelsFromVariables:(NSArray<ZGVariable *> *)variables attachedToWindow:(NSWindow *)parentWindow
{
	NSWindow *window = ZGUnwrapNullableObject([self window]); // ensure window is loaded
	
	ZGVariable *firstVariable = [variables objectAtIndex:0];
	
	_labelTextField.stringValue = firstVariable.label;
	[_labelTextField selectText:nil];
	
	_variables = variables;
	
	[parentWindow beginSheet:window completionHandler:^(NSModalResponse __unused returnCode) {
	}];
}

- (IBAction)editVariablesLabels:(id)__unused sender
{
	NSSet<NSString *> *usedLabels = _variableController.usedLabels;
	
	NSMutableArray<NSString *> *requestedLabels = [[NSMutableArray alloc] init];
	
	NSString *newLabel = _labelTextField.stringValue;
	
	NSUInteger variableIndex;
	NSUInteger variableCount = _variables.count;
	for (variableIndex = 0; variableIndex < variableCount; variableIndex++)
	{
		if (variableCount == 1)
		{
			[requestedLabels addObject:newLabel];
		}
		else
		{
			[requestedLabels addObject:[NSString stringWithFormat:@"%@_%lu", newLabel, variableIndex]];
		}
	}
	
	NSSet<NSString *> *requestedLabelsSet = [NSSet setWithArray:requestedLabels];
	if ([usedLabels intersectsSet:requestedLabelsSet])
	{
		ZGRunAlertPanelWithOKButton(NSLocalizedStringFromTable(@"alreadyUsedLabelAlertTitle", ZGEditLabelLocalizableTable, nil), NSLocalizedStringFromTable(@"alreadyUsedLabelAlertMessage", ZGEditLabelLocalizableTable, nil));
		
		return;
	}
	
	NSWindow *window = ZGUnwrapNullableObject(self.window);
	[NSApp endSheet:window];
	[window close];
	
	[_variableController editVariables:ZGUnwrapNullableObject(_variables) requestedLabels:requestedLabels];
	
	_variables = nil;
}

- (IBAction)cancelEditingVariablesLabels:(id)__unused sender
{
	NSWindow *window = ZGUnwrapNullableObject(self.window);
	[NSApp endSheet:window];
	[window close];
	
	_variables = nil;
}

@end
