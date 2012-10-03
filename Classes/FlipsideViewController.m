//
//  FlipsideViewController.m
//  Timelapse
//
//  Created by Simon Loffler on 24/12/10.
//  Copyright 2010 sighmon.com. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "FlipsideViewController.h"
#import "MainViewController.h"


@implementation FlipsideViewController

@synthesize delegate, creditsView, intervalFieldSetting, shotsFieldSetting, fpsFieldSetting, intervalToggleSetting, versionNumber;


- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    // Load the default user settings
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    intervalFieldSetting.text = [defaults objectForKey:kIntervalField];
    shotsFieldSetting.text = [defaults objectForKey:kShotsField];
    fpsFieldSetting.text = [defaults objectForKey:kFpsField];
    if ([defaults boolForKey:kToggleField]) {
        [intervalToggleSetting setOn:YES animated:YES];
    } else {
        [intervalToggleSetting setOn:NO animated:YES];
    }
    // Calculate the version number from the bundle plist
    versionNumber.text = [NSString stringWithFormat:@"Version %@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

	
	// self.creditsView.scalesPageToFit = YES;
	creditsView.delegate = self;
	
	// Load the credits UIWebView now
	
	NSString *mainPath = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:mainPath];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"];
	NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
	
	NSString *htmlString = [[NSString alloc] initWithData: 
							[readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	creditsView.opaque = NO;
	creditsView.backgroundColor = [UIColor clearColor];
	[self.creditsView loadHTMLString:htmlString baseURL:baseURL];
	[htmlString release];
}


- (IBAction)done:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:intervalFieldSetting.text forKey:kIntervalField];
    [defaults setValue:shotsFieldSetting.text forKey:kShotsField];
    [defaults setValue:fpsFieldSetting.text forKey:kFpsField];
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (IBAction)intervalToggleChanged:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (intervalToggleSetting.on) {
        [defaults setBool:YES forKey:kToggleField];
    } else {
        [defaults setBool:NO forKey:kToggleField];
    }
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [intervalToggleSetting release];
    intervalToggleSetting = nil;
    [fpsFieldSetting release];
    fpsFieldSetting = nil;
    [shotsFieldSetting release];
    shotsFieldSetting = nil;
    [intervalFieldSetting release];
    intervalFieldSetting = nil;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// This makes the links in the info pages open up in Safari, instead of the UIWebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	
	return YES;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
	[creditsView release];
    [intervalFieldSetting release];
    [shotsFieldSetting release];
    [fpsFieldSetting release];
    [intervalToggleSetting release];
    [super dealloc];
}


@end
