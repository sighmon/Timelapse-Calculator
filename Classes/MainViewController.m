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
@synthesize shootingPicker, shootingDuration, shootingDays, shootingHours, shootingMinutes, shootingSeconds;
@synthesize playbackPicker, playbackDuration, playbackHours, playbackMinutes, playbackSeconds, playbackFrames;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
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
	[dictionary release];
	
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
	/*
	// Code to add the doneButton to the keypad
	// From: http://www.neoos.ch/news/46-development/54-uikeyboardtypenumberpad-and-the-missing-return-key
	// add observer for the respective notifications (depending on the os version)
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardDidShow:) 
													 name:UIKeyboardDidShowNotification 
												   object:nil];		
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillShow:) 
													 name:UIKeyboardWillShowNotification 
												   object:nil];
	}
	*/
}
/*
- (void)addButtonToKeyboard {
	
	// create custom button
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(0, 163, 106, 53);
	doneButton.adjustsImageWhenHighlighted = NO;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0) {
		[doneButton setImage:[UIImage imageNamed:@"DoneUp3.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"DoneDown3.png"] forState:UIControlStateHighlighted];
	} else {        
		[doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
	}
	[doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
	// locate keyboard view
	UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	UIView* keyboard;
	for(int i=0; i<[tempWindow.subviews count]; i++) {
		keyboard = [tempWindow.subviews objectAtIndex:i];
		// keyboard found, add the button
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
			if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
				[keyboard addSubview:doneButton];
		} else {
			if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
				[keyboard addSubview:doneButton];
		}
	}
}

- (void)keyboardWillShow:(NSNotification *)note {
	// if clause is just an additional precaution, you could also dismiss it
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 3.2) {
		[self addButtonToKeyboard];
	}
}

- (void)keyboardDidShow:(NSNotification *)note {
	// if clause is just an additional precaution, you could also dismiss it
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		[self addButtonToKeyboard];
    }
}

- (void)doneButton:(id)sender {
	
	[self updateSettingsScript];
	
    [intervalField resignFirstResponder];
	[shotsField resignFirstResponder];
	[fpsField resignFirstResponder];
}
*/

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)textFieldDoneEditing:(id)sender
{
	[self updateSettingsScript];
	
	[sender resignFirstResponder];
}

- (IBAction)backgroundClick:(id)sender
{	
	[self updateSettingsScript];
	
	[intervalField resignFirstResponder];
	[shotsField resignFirstResponder];
	[fpsField resignFirstResponder];
}

- (IBAction)resetAll:(id)sender
{
	// reset the fields to their default setting
	
	intervalField.text = @"60";
	shotsField.text = @"0";
	fpsField.text = @"25";
	
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
	
	
	// Set up recipients
	// NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
	
	// [picker setToRecipients:toRecipients];
	
	// Attach an image to the email
	// NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
	// NSData *myData = [NSData dataWithContentsOfFile:path];
	// [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
	
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


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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
	
    [super dealloc];
}

- (void)calcRealTimeWithShots: (int) shots andInterval: (int) interval
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

- (void)calcPlaybackTimeWithShots: (int) shots andPlaybackFPS: (int) playbackFPS
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

- (void)playbackCentricWithHours: (int) hrs andMinutes: (int) mins andSeconds: (int) secs 
					   andFrames: (int) frames andInterval: (int) interval andFPS: (int) fps
{
	int shots = (hrs * (60 * 60 * fps)) + (mins * (60*fps)) + (secs * fps) + frames;
	
	[self calcRealTimeWithShots: shots andInterval: interval];
	
	NSString *updatedShotsValue = [[NSString alloc] initWithFormat:@"%d", shots];
	shotsField.text = updatedShotsValue;
	[updatedShotsValue release];
}

- (void)shootCentricWithDays: (int) days andHours: (int) hrs andMinutes: (int) mins andSeconds: (int) secs 
				 andInterval: (int) interval andPlaybackFPS: (int) playbackFPS
{
	int seconds = (days * 24 * 60 * 60) + (hrs * 60 * 60) + (mins * 60) + secs;
	int shots = seconds / interval;
	
	[self calcPlaybackTimeWithShots:shots andPlaybackFPS:playbackFPS];
	
	NSString *updatedShotsValue = [[NSString alloc] initWithFormat:@"%d", shots];
	shotsField.text = updatedShotsValue;
	[updatedShotsValue release];
}

- (void)updateSettingsScript
{
	if ([intervalField.text intValue] > 0 || [fpsField.text intValue] > 0) {
		[self calcRealTimeWithShots:[shotsField.text intValue] andInterval:[intervalField.text intValue]];
		[self calcPlaybackTimeWithShots:[shotsField.text intValue] andPlaybackFPS:[fpsField.text intValue]];
		
		NSMutableArray *p = [[NSMutableArray alloc] init];
		for (int i = 0; i < [fpsField.text intValue]; ++i) {
			NSString *s = [[NSString alloc] initWithFormat:@"%d", i];
			[p addObject: s];
			[s release];
		}
		/*
		self.playbackFrames = [NSArray arrayWithArray:p];
		[p release];
		*/
		
		
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

// Custom pickerView to get the font to fit with double digits
/*
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    switch(component) {
			case 0: return 36;
			break;
			case 1: return 36;
			break;
			case 2: return 36;
			break;
			case 3: return 36;
			break;
        default: return 36;
			break;
    }
	
    //NOT REACHED
    return 36;
}
 */

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
#pragma mark Picker Math

-(void) pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component
{
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

#pragma mark -
#pragma mark orientation

// TODO: implement a landscape view

/*
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}
*/

@end
