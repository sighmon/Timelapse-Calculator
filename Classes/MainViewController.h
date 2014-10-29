//
//  MainViewController.h
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
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define kShootingDays		0
#define kShootingHours		1
#define kShootingMinutes	2
#define kShootingSeconds	3

#define kPlaybackHours		0
#define kPlaybackMinutes	1
#define kPlaybackSeconds	2
#define kPlaybackFrames		3

#define kIntervalField      @"interval"
#define kShotsField         @"shots"
#define kFpsField           @"fps"
#define kToggleField        @"defaultIntervalToggle"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate>
{
	IBOutlet UITextField *intervalField;
	IBOutlet UITextField *shotsField;
	IBOutlet UITextField *fpsField;
    IBOutlet UIView *intervalSelectedView;
    BOOL intervalToggle;
	
	IBOutlet UIPickerView *shootingPicker;
	IBOutlet UIPickerView *playbackPicker;
	
	NSDictionary *shootingDuration;
	NSArray *shootingDays;
	NSArray *shootingHours;
	NSArray *shootingMinutes;
	NSArray *shootingSeconds;
	
	NSDictionary *playbackDuration;
	NSArray *playbackHours;
	NSArray *playbackMinutes;
	NSArray *playbackSeconds;
	NSArray *playbackFrames;
}

@property (nonatomic, retain) UITextField *intervalField;
@property (nonatomic, retain) UITextField *shotsField;
@property (nonatomic, retain) UITextField *fpsField;
@property (nonatomic, retain) UIView *intervalSelectedView;
@property (nonatomic, assign) BOOL intervalToggle;

@property (nonatomic, retain) UIPickerView *shootingPicker;
@property (nonatomic, retain) NSDictionary *shootingDuration;
@property (nonatomic, retain) NSArray *shootingDays;
@property (nonatomic, retain) NSArray *shootingHours;
@property (nonatomic, retain) NSArray *shootingMinutes;
@property (nonatomic, retain) NSArray *shootingSeconds;

@property (nonatomic, retain) UIPickerView *playbackPicker;
@property (nonatomic, retain) NSDictionary *playbackDuration;
@property (nonatomic, retain) NSArray *playbackHours;
@property (nonatomic, retain) NSArray *playbackMinutes;
@property (nonatomic, retain) NSArray *playbackSeconds;
@property (nonatomic, retain) NSArray *playbackFrames;

- (IBAction)showInfo:(id)sender;
- (IBAction)resetAll:(id)sender;
- (IBAction)composeEmail:(id)sender;

- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)backgroundClick:(id)sender;

- (void)calcRealTimeWithShots: (int) shots 
                  andInterval: (int) interval;

- (void)calcPlaybackTimeWithShots: (int) shots 
                   andPlaybackFPS: (int) playbackFPS;

- (void)playbackCentricWithHours: (int) hrs 
                      andMinutes: (int) mins 
                      andSeconds: (int) secs 
					   andFrames: (int) frames 
                     andInterval: (int) interval 
                          andFPS: (int) fps;

- (void)shootCentricWithDays: (int) days 
                    andHours: (int) hrs 
                  andMinutes: (int) mins 
                  andSeconds: (int) secs 
				 andInterval: (int) interval 
              andPlaybackFPS: (int) playbackFPS;

- (void)intervalCentricWithDays: (int) days
                       andHours: (int) hrs
                     andMinutes: (int) mins
                     andSeconds: (int) secs
                       andShots: (int) shots;

- (void)intervalCentricPlaybackWithHours:(int)hrs
                              andMinutes:(int)mins
                              andSeconds:(int)secs
                               andFrames:(int)frames
                                  andFPS:(int)fps
                         andShootingDays:(int)shootDays
                        andShootingHours:(int)shootHrs
                      andShootingMinutes:(int)shootMins
                      andShootingSeconds:(int)shootSecs;

- (void)updateSettingsScript;
- (void)updatePlaybackScript;
- (void)updateShootingScript;
- (void)updateIntervalShootingScript;
- (void)updateIntervalPlaybackScript;

- (void)registerDefaultsFromSettingsBundle;

- (NSString *)stringFromDays: (int) days andHours: (int) hrs andMinutes: (int) mins andSeconds: (int) secs andFrames: (int) frames;

- (void)toggleIntervalSelected;
- (void)checkIntervalSelectedImage;

@end
