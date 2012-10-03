//
//  FlipsideViewController.h
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

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController <UIWebViewDelegate> {
	id <FlipsideViewControllerDelegate> delegate;
	
	UIWebView *creditsView;
    IBOutlet UITextField *intervalFieldSetting;
    IBOutlet UITextField *shotsFieldSetting;
    IBOutlet UITextField *fpsFieldSetting;
    IBOutlet UISwitch *intervalToggleSetting;
    IBOutlet UILabel *versionNumber;
}

// TODO: implement fields updating default fields.

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIWebView *creditsView;
@property (nonatomic, retain) IBOutlet UITextField *intervalFieldSetting;
@property (nonatomic, retain) IBOutlet UITextField *shotsFieldSetting;
@property (nonatomic, retain) IBOutlet UITextField *fpsFieldSetting;
@property (nonatomic, retain) IBOutlet UISwitch *intervalToggleSetting;
@property (nonatomic, retain) IBOutlet UILabel *versionNumber;

- (IBAction)done:(id)sender;
- (IBAction)intervalToggleChanged:(id)sender;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

