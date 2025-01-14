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

#import "ZGEditAddressWindowController.h"
#import "ZGVariableController.h"
#import "ZGVariable.h"
#import "ZGNullability.h"
#import "ZGRunAlertPanel.h"

#define ZGEditAddressLocalizableTable @"[Code] Edit Variable Address"

@implementation ZGEditAddressWindowController
{
	ZGVariableController * _Nonnull _variableController;
	ZGVariable * _Nullable _variable;
	
	IBOutlet NSTextField *_addressTextField;
}

- (NSString *)windowNibName
{
	return @"Edit Address Dialog";
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

- (void)requestEditingAddressFromVariable:(ZGVariable *)variable attachedToWindow:(NSWindow *)parentWindow
{
	NSWindow *window = ZGUnwrapNullableObject([self window]); // ensure window is loaded
	
	_variable = variable;
	_addressTextField.stringValue = variable.addressFormula;
	
	[_addressTextField selectText:nil];
	
	[parentWindow beginSheet:window completionHandler:^(NSModalResponse __unused returnCode) {
	}];
}

- (IBAction)editAddress:(id)__unused sender
{
	NSString *newAddressFormula = _addressTextField.stringValue;
	NSString *cycleInfo = nil;
	if (![_variableController editVariables:@[ZGUnwrapNullableObject(_variable)] addressFormulas:@[newAddressFormula] cycleInfo:&cycleInfo])
	{
		ZGRunAlertPanelWithOKButton(NSLocalizedStringFromTable(@"addressCycleAlertTitle", ZGEditAddressLocalizableTable, nil), [NSString stringWithFormat:NSLocalizedStringFromTable(@"addressCycleAlertMessageFormat", ZGEditAddressLocalizableTable, nil), newAddressFormula, cycleInfo]);
		return;
	}
	
	NSWindow *window = ZGUnwrapNullableObject([self window]);
	[NSApp endSheet:window];
	[window close];
	
	_variable = nil;
}

- (IBAction)cancelEditingAddress:(id)__unused sender
{
	NSWindow *window = ZGUnwrapNullableObject([self window]);
	[NSApp endSheet:window];
	[window close];
	
	_variable = nil;
}

@end
