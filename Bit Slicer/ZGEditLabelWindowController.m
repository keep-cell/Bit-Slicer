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
	IBOutlet NSTextField *_multipleSelectionExplanationTextField;
	IBOutlet NSButton *_cancelButton;
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

- (void)windowDidLoad
{
	if (_variables.count == 1)
	{
		[_multipleSelectionExplanationTextField removeFromSuperview];
		
		NSLayoutConstraint *layoutConstraint =
		[NSLayoutConstraint
		 constraintWithItem:_labelTextField
		 attribute:NSLayoutAttributeBottom
		 relatedBy:NSLayoutRelationEqual
		 toItem:_cancelButton
		 attribute:NSLayoutAttributeTop
		 multiplier:1.0
		 constant:-12.0];
		
		[self.window.contentView addConstraint:layoutConstraint];
	}
}

- (void)requestEditingLabelsFromVariables:(NSArray<ZGVariable *> *)variables attachedToWindow:(NSWindow *)parentWindow
{
	_variables = variables;
	
	NSWindow *window = ZGUnwrapNullableObject([self window]); // ensure window is loaded
	
	ZGVariable *firstVariable = [variables objectAtIndex:0];
	NSString *firstVariableLabel = firstVariable.label;
	
	NSString *labelStringValue;
	NSString *labelPlaceholderStringValue;
	
	if (variables.count > 1)
	{
		if (firstVariableLabel.length == 0)
		{
			labelStringValue = @"";
			labelPlaceholderStringValue = @"Foo_%n";
		}
		else
		{
			NSRange digitsRange = [firstVariableLabel rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet options:NSBackwardsSearch | NSLiteralSearch];
			
			if (digitsRange.location != NSNotFound)
			{
				labelStringValue = [NSString stringWithFormat:@"%@$n", [firstVariableLabel substringToIndex:digitsRange.location]];
			}
			else
			{
				labelStringValue = [NSString stringWithFormat:@"%@_$n", firstVariableLabel];
			}
			
			labelPlaceholderStringValue = @"";
		}
	}
	else
	{
		labelStringValue = firstVariableLabel;
		labelPlaceholderStringValue = @"";
	}
	
	_labelTextField.stringValue = labelStringValue;
	_labelTextField.placeholderString = labelPlaceholderStringValue;
	
	[_labelTextField selectText:nil];
	
	[parentWindow beginSheet:window completionHandler:^(NSModalResponse __unused returnCode) {
	}];
}

- (IBAction)editVariablesLabels:(id)__unused sender
{
	NSSet<NSString *> *usedLabels = _variableController.usedLabels;
	
	NSMutableArray<NSString *> *requestedLabels = [[NSMutableArray alloc] init];
	
	NSString *newRequestedLabel = _labelTextField.stringValue;
	
	NSRange ordinalRange = [newRequestedLabel rangeOfString:@"$n" options:NSBackwardsSearch | NSLiteralSearch];
	
	BOOL changedVariables = NO;
	NSUInteger variableCount = _variables.count;
	for (NSUInteger variableIndex = 0; variableIndex < variableCount; variableIndex++)
	{
		NSString *newLabel;
		if (ordinalRange.location != NSNotFound)
		{
			newLabel = [newRequestedLabel stringByReplacingCharactersInRange:ordinalRange withString:[NSString stringWithFormat:@"%lu", variableIndex]];
			
			[requestedLabels addObject:newLabel];
		}
		else
		{
			newLabel = newRequestedLabel;
		}
		
		if (![_variables[variableIndex].label isEqualToString:newLabel])
		{
			changedVariables = YES;
		}
		
		[requestedLabels addObject:newLabel];
	}
	
	if (!changedVariables)
	{
		// Nothing to change here
		NSWindow *window = ZGUnwrapNullableObject(self.window);
		[NSApp endSheet:window];
		[window close];
		
		return;
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
