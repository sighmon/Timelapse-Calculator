//
//  MainViewController.m
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

//  Timelapse Calculator math based on Dan Thompson's code:
//  http://danthompsonsblog.blogspot.com/search/label/Timelapse
//  http://openmoco.org/node/295
//  Thanks Dan!
//

#import "MainViewController.h"


@implementation MainViewController

@synthesize intervalField, shotsField, fpsField;
@synthesize intervalSelectedImage;
@synthesize intervalToggle;
@synthesize shootingPicker, shootingDuration, shootingDays, shootingHours, shootingMinutes, shootingSeconds;
@synthesize playbackPicker, playbackDuration, playbackHours, playbackMinutes, playbackSeconds, playbackFrames;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
    // Set the interval toggle to NO
    intervalToggle = NO;
	
	// Shooting wheel setup
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *plistPath = [bundle pathForResource: @"shootingdictionary" ofType: @"plist"];
	
	NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile: plistPath];
	self.shootingDuration = dictionary;
	[dictionary release];

	NSArray *shootingSecondsArray = [shootingDuration objectForKey: @"Seconds"];
	self.shootingSeconds = shootingSecondsArray;
	
	NSArray *shootingMinutesArray = [shootingDuration objectForKey: @"Minutes"];
	self.shootingMinutes = shootingMinutesArray;
	
	NSArray *shootingHoursArray = [shootingDuration objectForKey: @"Hours"];
	self.shootingHours = shootingHoursArray;
	
	NSArray *shootingDaysArray = [shootingDuration objectForKey: @"Days"];
	self.shootingDays = shootingDaysArray;
	
	// Playback wheel setup
	
	NSString *plistPath2 = [bundle pathForResource: @"playbackdictionary" ofType: @"plist"];
	
	NSDictionary *dictionary2 = [[NSDictionary alloc] initWithContentsOfFile: plistPath2];
	self.playbackDuration = dictionary2;
	[dictionary2 release];
	
	NSArray *playbackFramesArray = [playbackDuration objectForKey: @"Frames"];
	self.playbackFrames = playbackFramesArray;
	
	NSArray *playbackSecondsArray = [playbackDuration objectForKey: @"Seconds"];
	self.playbackSeconds = playbackSecondsArray;
	
	NSArray *playbackMinutesArray = [playbackDuration objectForKey: @"Minutes"];
	self.playbackMinutes = playbackMinutesArray;
	
	NSArray *playbackHoursArray = [playbackDuration objectForKey: @"Hours"];
	self.playbackHours = playbackHoursArray;
	
	// Reset all values
	
	[self resetAll:self];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    // TODO: add an if intervalToggle statement here.
	[self updateSettingsScript];
	
	[sender resignFirstResponder];
}

- (IBAction)backgroundClick:(id)sender
{
	// TODO: add an if intervalToggle statement here.
	[self updateSettingsScript];
	
	[intervalField resignFirstResponder];
	[shotsField resignFirstResponder];
	[fpsField resignFirstResponder];
}

- (IBAction)resetAll:(id)sender
{
	// read default settings if this is the first run
    
    [self registerDefaultsFromSettingsBundle];
    intervalField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"interval"];
    shotsField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"shots"];
    fpsField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"fps"];
    
    // read the default settings & reset the fields
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	intervalField.text = [defaults objectForKey: kIntervalField];
	shotsField.text = [defaults objectForKey: kShotsField];
	fpsField.text = [defaults objectForKey: kFpsField];
	
	[self updateSettingsScript];
}

- (IBAction)showInfo:(id)sender {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (NSString *)stringFromDays: (int) days andHours: (int) hrs andMinutes: (int) mins andSeconds: (int) secs andFrames: (int) frames
{
	NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
	BOOL comma = FALSE;
	
	if (days > 0) {
		[result appendFormat:@"%i day%@", days, days==1?@"":@"s"];
		comma = TRUE;
	}
	if (hrs > 0) {
		BOOL and = (mins==0 && secs==0 && frames==0);
		[result appendFormat:@"%@%i hour%@", comma?(and?@" and ":@", "):@"", hrs, hrs==1?@"":@"s"];
		comma = TRUE;
	}
	if (mins > 0) {
		BOOL and = (secs==0 && frames==0);
		[result appendFormat:@"%@%i minute%@", comma?(and?@" and ":@", "):@"", mins, mins==1?@"":@"s"];
		comma = TRUE;
	}
	if (secs > 0) {
		BOOL and = (frames==0);
		[result appendFormat:@"%@%i second%@", comma?(and?@" and ":@", "):@"", secs, secs==1?@"":@"s"];
		comma = TRUE;
	}	
	if (frames > 0) {
		BOOL and = TRUE;
		[result appendFormat:@"%@%i frame%@", comma?(and?@" and ":@", "):@"", frames, frames==1?@"":@"s"];
		comma = TRUE;
	}	
	return result;
}

- (IBAction)composeEmail:(id)sender
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Timelapse Calculations"];
	
	// Fill out the email body text
	NSString *emailBody = [[NSString alloc] initWithFormat: @"Shooting duration of %@ shots at an interval of %@ seconds will be %@. \n\nPlayback duration of %@ shots at %@ frames per second will be %@.", shotsField.text, intervalField.text, 
						   [self stringFromDays:[shootingPicker selectedRowInComponent:kShootingDays] andHours:[shootingPicker selectedRowInComponent:kShootingHours] andMinutes:[shootingPicker selectedRowInComponent:kShootingMinutes] andSeconds:[shootingPicker selectedRowInComponent:kShootingSeconds] andFrames:0], shotsField.text, fpsField.text, 
						   [self stringFromDays:0 andHours:[playbackPicker selectedRowInComponent:kPlaybackHours] andMinutes:[playbackPicker selectedRowInComponent:kPlaybackMinutes] andSeconds:[playbackPicker selectedRowInComponent:kPlaybackSeconds] andFrames:[playbackPicker selectedRowInComponent:kPlaybackFrames]]];
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
	[emailBody release];
}

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark The Calculation Math

- (void)calcRealTimeWithShots: (int) shots 
                  andInterval: (int) interval
{
	if (interval > 0)
	{
		int totalRealSeconds = shots * interval;
		int totalRealMinutes = totalRealSeconds / 60;
		int totalRealHours = totalRealMinutes / 60;
		int totalRealDays = totalRealHours / 24;
		int totalRealHoursRemainder = totalRealHours % 24;
		int totalRealMinutesRemainder = totalRealMinutes % 60;
		int totalRealSecondsRemainder = totalRealSeconds % 60;
		
		[shootingPicker selectRow:totalRealDays inComponent:kShootingDays animated:YES];
		[shootingPicker selectRow:totalRealHoursRemainder inComponent:kShootingHours animated:YES];
		[shootingPicker selectRow:totalRealMinutesRemainder inComponent:kShootingMinutes animated:YES];
		[shootingPicker selectRow:totalRealSecondsRemainder inComponent:kShootingSeconds animated:YES];
		
		[shootingPicker reloadComponent: kShootingSeconds];
		[shootingPicker reloadComponent: kShootingMinutes];
		[shootingPicker reloadComponent: kShootingHours];
		[shootingPicker reloadComponent: kShootingDays];
	}
		
}

- (void)calcPlaybackTimeWithShots: (int) shots 
                   andPlaybackFPS: (int) playbackFPS
{
	if (playbackFPS > 0)
	{
		int totalPlaybackSeconds = shots / playbackFPS;
		int totalPlaybackMinutes = totalPlaybackSeconds / 60;
		int totalPlaybackHours = totalPlaybackMinutes / 60;
		int totalPlaybackMinutesRemainder = totalPlaybackMinutes % 60;
		int totalPlaybackSecondsRemainder = totalPlaybackSeconds % 60;
		int totalPlaybackFrames = shots % playbackFPS;
		
		[playbackPicker selectRow:totalPlaybackHours inComponent:kPlaybackHours animated:YES];
		[playbackPicker selectRow:totalPlaybackMinutesRemainder inComponent:kPlaybackMinutes animated:YES];
		[playbackPicker selectRow:totalPlaybackSecondsRemainder inComponent:kPlaybackSeconds animated:YES];
		[playbackPicker selectRow:totalPlaybackFrames inComponent:kPlaybackFrames animated:YES];
		
		[playbackPicker reloadComponent: kPlaybackFrames];
		[playbackPicker reloadComponent: kPlaybackSeconds];
		[playbackPicker reloadComponent: kPlaybackMinutes];
		[playbackPicker reloadComponent: kPlaybackHours];
		
	}
}

- (void)playbackCentricWithHours: (int) hrs 
                      andMinutes: (int) mins 
                      andSeconds: (int) secs 
					   andFrames: (int) frames 
                     andInterval: (int) interval 
                          andFPS: (int) fps
{
	int shots = (hrs * (60 * 60 * fps)) + (mins * (60*fps)) + (secs * fps) + frames;
	
	[self calcRealTimeWithShots: shots andInterval: interval];
	
	NSString *updatedShotsValue = [[NSString alloc] initWithFormat:@"%d", shots];
	shotsField.text = updatedShotsValue;
	[updatedShotsValue release];
}

- (void)shootCentricWithDays: (int) days 
                    andHours: (int) hrs 
                  andMinutes: (int) mins 
                  andSeconds: (int) secs 
				 andInterval: (int) interval 
              andPlaybackFPS: (int) playbackFPS
{
	int seconds = (days * 24 * 60 * 60) + (hrs * 60 * 60) + (mins * 60) + secs;
	int shots = seconds / interval;
	
	[self calcPlaybackTimeWithShots:shots andPlaybackFPS:playbackFPS];
	
	NSString *updatedShotsValue = [[NSString alloc] initWithFormat:@"%d", shots];
	shotsField.text = updatedShotsValue;
	[updatedShotsValue release];
}

- (void)intervalCentricWithDays: (int) days 
                       andHours: (int) hrs 
                     andMinutes: (int) mins 
                     andSeconds: (int) secs 
                       andShots: (int) shots
{
    // TODO: check this is right before release
    int seconds = (days * 24 * 60 * 60) + (hrs * 60 * 60) + (mins * 60) + secs;
    int interval = seconds / shots;
    
    NSString *updatedIntervalValue = [[NSString alloc] initWithFormat:@"%d", interval];
    intervalField.text = updatedIntervalValue;
    [updatedIntervalValue release];
}

- (void)intervalCentricPlaybackWithHours:(int)hrs 
                              andMinutes:(int)mins 
                              andSeconds:(int)secs 
                               andFrames:(int)frames 
                                  andFPS:(int)fps
{
    // TODO: check this is right before release
    int totalPlaybackSeconds = (hrs * 60 * 60) + (mins * 60) + secs;
    int shots = totalPlaybackSeconds * fps;
    
    NSString *updatedShotsValue = [[NSString alloc] initWithFormat:@"%d", shots];
    shotsField.text = updatedShotsValue;
    [updatedShotsValue release];    
}

- (void)updateSettingsScript
{
	if ([intervalField.text intValue] > 0 || [fpsField.text intValue] > 0) {
		[self calcRealTimeWithShots:[shotsField.text intValue] 
                        andInterval:[intervalField.text intValue]];
		[self calcPlaybackTimeWithShots:[shotsField.text intValue] 
                         andPlaybackFPS:[fpsField.text intValue]];
		
		NSMutableArray *p = [[NSMutableArray alloc] init];
		for (int i = 0; i < [fpsField.text intValue]; ++i) {
			NSString *s = [[NSString alloc] initWithFormat:@"%d", i];
			[p addObject: s];
			[s release];
		}		
		
		NSArray *a = [[NSArray alloc] initWithArray:p];
		[p release];
		self.playbackFrames = a;
		[a release];
		
		[playbackPicker reloadComponent:kPlaybackFrames];
		 
	}
		
	if ([fpsField.text intValue] < 1) {
		[playbackPicker selectRow:0 inComponent:kPlaybackFrames animated:YES];
		[playbackPicker reloadComponent: kPlaybackFrames];
		[playbackPicker selectRow:0 inComponent:kPlaybackSeconds animated:YES];
		[playbackPicker reloadComponent: kPlaybackSeconds];
		[playbackPicker selectRow:0 inComponent:kPlaybackMinutes animated:YES];
		[playbackPicker reloadComponent: kPlaybackMinutes];
		[playbackPicker selectRow:0 inComponent:kPlaybackHours animated:YES];
		[playbackPicker reloadComponent: kPlaybackHours];
	}
			
	if ([intervalField.text intValue] < 1) {
		[shootingPicker selectRow:0 inComponent:kShootingSeconds animated:YES];
		[shootingPicker reloadComponent: kShootingSeconds];
		[shootingPicker selectRow:0 inComponent:kShootingMinutes animated:YES];
		[shootingPicker reloadComponent: kShootingMinutes];
		[shootingPicker selectRow:0 inComponent:kShootingHours animated:YES];
		[shootingPicker reloadComponent: kShootingHours];
		[shootingPicker selectRow:0 inComponent:kShootingDays animated:YES];
		[shootingPicker reloadComponent: kShootingDays];
	}
}

- (void)updatePlaybackScript
{
	if ([fpsField.text intValue] > 0) {
		[self playbackCentricWithHours:[playbackPicker selectedRowInComponent:kPlaybackHours] 
							andMinutes:[playbackPicker selectedRowInComponent:kPlaybackMinutes] 
							andSeconds:[playbackPicker selectedRowInComponent:kPlaybackSeconds] 
							 andFrames:[playbackPicker selectedRowInComponent:kPlaybackFrames] 
						   andInterval:[intervalField.text intValue] 
								andFPS:[fpsField.text intValue]];
	} else {
		[playbackPicker selectRow:0 inComponent:kPlaybackFrames animated:YES];
		[playbackPicker reloadComponent: kPlaybackFrames];
		[playbackPicker selectRow:0 inComponent:kPlaybackSeconds animated:YES];
		[playbackPicker reloadComponent: kPlaybackSeconds];
		[playbackPicker selectRow:0 inComponent:kPlaybackMinutes animated:YES];
		[playbackPicker reloadComponent: kPlaybackMinutes];
		[playbackPicker selectRow:0 inComponent:kPlaybackHours animated:YES];
		[playbackPicker reloadComponent: kPlaybackHours];
	}
}

- (void)updateShootingScript
{
	if ([intervalField.text intValue] > 0) {
		[self shootCentricWithDays:[shootingPicker selectedRowInComponent:kShootingDays] 
						  andHours:[shootingPicker selectedRowInComponent:kShootingHours] 
						andMinutes:[shootingPicker selectedRowInComponent:kShootingMinutes] 
						andSeconds:[shootingPicker selectedRowInComponent:kShootingSeconds] 
					   andInterval:[intervalField.text intValue] 
					andPlaybackFPS:[fpsField.text intValue]];
	} else {
		[shootingPicker selectRow:0 inComponent:kShootingSeconds animated:YES];
		[shootingPicker reloadComponent: kShootingSeconds];
		[shootingPicker selectRow:0 inComponent:kShootingMinutes animated:YES];
		[shootingPicker reloadComponent: kShootingMinutes];
		[shootingPicker selectRow:0 inComponent:kShootingHours animated:YES];
		[shootingPicker reloadComponent: kShootingHours];
		[shootingPicker selectRow:0 inComponent:kShootingDays animated:YES];
		[shootingPicker reloadComponent: kShootingDays];
	}
}

- (void)updateIntervalShootingScript 
{
    if ([shotsField.text intValue] > 0) {
        // TODO: check this is right before release
        [self intervalCentricWithDays:[shootingPicker selectedRowInComponent:kShootingDays] andHours:[shootingPicker selectedRowInComponent:kShootingHours] andMinutes:[shootingPicker selectedRowInComponent:kShootingMinutes] andSeconds:[shootingPicker selectedRowInComponent:kShootingSeconds] andShots:[shotsField.text intValue]];
    } else {
        intervalField.text = @"0";
    }
}

- (void)updateIntervalPlaybackScript
{
    if ([shotsField.text intValue] > 0) {
        // TODO: make an updateIntervalPlaybackScript
        [self intervalCentricPlaybackWithHours:[playbackPicker selectedRowInComponent:kPlaybackHours] andMinutes:[playbackPicker selectedRowInComponent:kPlaybackMinutes] andSeconds:[playbackPicker selectedRowInComponent:kPlaybackSeconds] andFrames:[playbackPicker selectedRowInComponent:kPlaybackFrames] andFPS:[fpsField.text intValue]];
    } else {
        intervalField.text = @"0";
    }
}

#pragma mark -
#pragma mark Picker Data Source Methods

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{	
	return 4;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger) component
{
	if ([pickerView isEqual:self.shootingPicker] && component == kShootingSeconds) {
		return [self.shootingSeconds count];
	}

	if ([pickerView isEqual:self.shootingPicker] && component == kShootingMinutes) {
		return [self.shootingMinutes count];
	}
	
	if ([pickerView isEqual:self.shootingPicker] && component == kShootingHours) {
		return [self.shootingHours count];
	}
	
	if ([pickerView isEqual:self.shootingPicker] && component == kShootingDays) {
		return [self.shootingDays count];
	}
	
	if ([pickerView isEqual:self.playbackPicker] && component == kPlaybackFrames) {
		return [self.playbackFrames count];
	}
	
	if ([pickerView isEqual:self.playbackPicker] && component == kPlaybackSeconds) {
		return [self.shootingSeconds count];
	}
	
	if ([pickerView isEqual:self.playbackPicker] && component == kPlaybackMinutes) {
		return [self.playbackMinutes count];
	}
	
	if ([pickerView isEqual:self.playbackPicker] && component == kPlaybackHours) {
		return [self.playbackHours count];
	}
	else return 0;
}

#pragma mark Picker Delegate Methods

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger) component
{	
	if ([pickerView isEqual:self.shootingPicker] && component == kShootingSeconds) {
		return [self.shootingSeconds objectAtIndex: row];
	}
	
	if ([pickerView isEqual:self.shootingPicker] && component == kShootingMinutes) {
		return [self.shootingMinutes objectAtIndex: row];
	}
	
	if ([pickerView isEqual:self.shootingPicker] && component == kShootingHours) {
		return [self.shootingHours objectAtIndex: row];
	}
	
	if ([pickerView isEqual:self.shootingPicker] && component == kShootingDays) {
		return [self.shootingDays objectAtIndex: row];
	}
	
	if ([pickerView isEqual:self.playbackPicker] && component == kPlaybackFrames) {
		return [self.playbackFrames objectAtIndex: row];
	}
	
	if ([pickerView isEqual:self.playbackPicker] && component == kPlaybackSeconds) {
		return [self.playbackSeconds objectAtIndex: row];
	}
	
	if ([pickerView isEqual:self.playbackPicker] && component == kPlaybackMinutes) {
		return [self.playbackMinutes objectAtIndex: row];
	}
	
	if ([pickerView isEqual:self.playbackPicker] && component == kPlaybackHours) {
		return [self.playbackHours objectAtIndex: row];
	}
	else return nil;
}

// Hack to get the number fonts to look nice on the pickers.

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *retval = (id)view;
	if (!retval) {
		retval= [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)] autorelease];
	}
	
	retval.text = [pickerView.delegate pickerView:pickerView titleForRow:row forComponent:component];
	retval.font = [UIFont boldSystemFontOfSize:18];
	// retval.adjustsFontSizeToFitWidth = YES;
	retval.textAlignment = UITextAlignmentCenter;
	retval.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	return retval;
}

#pragma mark -
#pragma mark Picker Update

-(void) pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component
{
    // TODO: Fix interval script
	if (intervalToggle == YES) {
        if (pickerView == playbackPicker) {
            [self updateIntervalPlaybackScript];
            [self updateSettingsScript];
        } else {
            if (pickerView == shootingPicker) {
                [self updateIntervalShootingScript];
                [self updateSettingsScript];
            } else {
                return;
            }
        }
    } else {
        if (pickerView == playbackPicker) {
            [self updatePlaybackScript];
        } else {
            if (pickerView == shootingPicker) {
                [self updateShootingScript];
            } else {
                return;
            }
        }
    }
}

#pragma mark -
#pragma mark orientation

// TODO: implement a landscape view

/*
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}
*/

#pragma mark -
#pragma mark Read settings first run

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
}

#pragma mark -
#pragma mark Tap Detection

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
	
	if (tapCount > 1) {
        
        // If more than one tap, then toogleIntervalSelected
        
        [self toggleIntervalSelected];
    }
    
}

- (void)toggleIntervalSelected {
    if (intervalToggle == NO) {
        // Change image
        intervalSelectedImage.image = [UIImage imageNamed:@"red-dot.png"];
        intervalToggle = YES;
    } else {
        intervalSelectedImage.image = [UIImage imageNamed:@"blank-dot.png"];
        intervalToggle = NO;
    }
}


#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    // [intervalSelectedImage release];
    // intervalSelectedImage = nil;
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)dealloc {
	
	[shootingPicker release];
	[shootingDuration release];
	[shootingDays release];
	[shootingHours release];
	[shootingMinutes release];
	[shootingSeconds release];
	
	[playbackPicker release];
	[playbackDuration release];
	[playbackHours release];
	[playbackMinutes release];
	[playbackSeconds release];
	[playbackFrames release];
	
    [intervalSelectedImage release];
    [super dealloc];
}

@end
