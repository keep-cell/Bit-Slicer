/*
 * Copyright (c) 2014 Mayur Pawashe
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

#import "ZGUpdatePreferencesViewController.h"
#import "ZGAppUpdaterController.h"

@implementation ZGUpdatePreferencesViewController
{
	ZGAppUpdaterController * _Nonnull _appUpdaterController;
	
	IBOutlet NSButton *_checkForUpdatesButton;
	IBOutlet NSButton *_checkForAlphaUpdatesButton;
	IBOutlet NSButton *_sendProfileInfoButton;
}

- (id)initWithAppUpdaterController:(ZGAppUpdaterController *)appUpdaterController
{
	self = [super initWithNibName:@"Software Update View" bundle:nil];
	if (self != nil)
	{
		_appUpdaterController = appUpdaterController;
	}
	return self;
}

- (void)loadView
{
	[super loadView];
	
	// These states could change, for example, when the user has to make Sparkle pick between checking for automatic updates or not checking for them
	[self updateCheckingForUpdateButtons];
}

- (void)updateCheckingForUpdateButtons
{
	if (_appUpdaterController.checksForUpdates)
	{
		_checkForUpdatesButton.state = NSControlStateValueOn;
		
		_checkForAlphaUpdatesButton.enabled = YES;
		_checkForAlphaUpdatesButton.state = _appUpdaterController.checksForAlphaUpdates ? NSControlStateValueOn : NSControlStateValueOff;
		
		_sendProfileInfoButton.enabled = YES;
		_sendProfileInfoButton.state = _appUpdaterController.sendsAnonymousInfo ? NSControlStateValueOn : NSControlStateValueOff;
	}
	else
	{
		_checkForAlphaUpdatesButton.enabled = NO;
		_sendProfileInfoButton.enabled = NO;
		
		_checkForUpdatesButton.state = NSControlStateValueOff;
		_checkForAlphaUpdatesButton.state = NSControlStateValueOff;
		_sendProfileInfoButton.state = NSControlStateValueOff;
	}
}

- (IBAction)checkForUpdatesButton:(id)__unused sender
{
	if (_checkForUpdatesButton.state == NSControlStateValueOff)
	{
		_appUpdaterController.checksForAlphaUpdates = NO;
		_appUpdaterController.checksForUpdates = NO;
	}
	else
	{
		_appUpdaterController.checksForUpdates = YES;
		_appUpdaterController.checksForAlphaUpdates = [ZGAppUpdaterController runningAlpha];
	}
	
	[self updateCheckingForUpdateButtons];
}

- (IBAction)checkForAlphaUpdatesButton:(id)__unused sender
{
	_appUpdaterController.checksForAlphaUpdates = (_checkForAlphaUpdatesButton.state == NSControlStateValueOn);
	[self updateCheckingForUpdateButtons];
}

- (IBAction)changeSendProfileInformation:(id)__unused sender
{
	_appUpdaterController.sendsAnonymousInfo = (_sendProfileInfoButton.state == NSControlStateValueOn);
	[self updateCheckingForUpdateButtons];
}

@end
