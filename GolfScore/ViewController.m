//
//  ViewController.m
//  GolfScore
//
//  Created by Rex McIntosh on 9/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
// #import "ScoreTable.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize score, scoreButton, playerNumber, playersGame;
@synthesize delegate = _delegate;
@synthesize currentLoc,lastStrokeLoc, holeLocation;
@synthesize strokeDistance, PreviousStrokeDistance, prevStrokeDistanceString;
@synthesize parNum, strokeNum, parPicked, strokePicked;    // values loaded by NextHole
@synthesize courseHandicapInt; //, stableford;

// ScoreTable *scoreTable;

UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
UISwipeGestureRecognizer *upSwipeGestureRecognizer;
UISwipeGestureRecognizer *downSwipeGestureRecognizer;

AppDelegate *appDelegate;

int viewHoleNumber;

NSTimer *nameTimer;
NSTimer *decrementButtonTimer;
NSTimer *nextHoleButtonTimer;
NSTimer *nextHoleDissmissTimer; // just delay to keep in view
NSTimer *sliderTimer;
NSTimer *pinDistanceTimer;
NSTimer *parStrokeTimer;
NSTimer *AccuracyFlasher;

UIActionSheet *clearOptions;
//UIActionSheet *reCalibrate;
UIAlertView *reCalibrate;

BOOL killNextHoleTouchUp; // if picker has been activated, but not moved, stay on same hole

const float nameEditTime = 1.5;

const float decrementStrokeTime = 1.5;

const float showHolePickerTime  = 1.3;
const float dissmissHolePickerStaticTime = 2.0;
const float dissmissHolePickerMovedTime = 1.2;
const float pinReCalibratetime = 1.5;

CLLocationDistance strokeDistance;
CLLocationDistance PreviousStrokeDistance;
NSString *prevStrokeDistanceString;

//float courseHandicapInt;
int stableford;
int totalStrokes;

int currentplay; // 0 strokes, 1 putting, 2 penalty
int backSlider;  // 0 hidden, 1 distances

NSArray *teeColors;

-(void)showScore // & Calculate total
{
   // holeNumberTextField.text = [NSString stringWithFormat:@"#%i", viewHoleNumber+1];
    [nextBox setTitle:[NSString stringWithFormat:@"#%i", viewHoleNumber+1] forState:UIControlStateNormal];
    int strokeNumber =  [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Strokes"]intValue];
    int puttNumber = [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Putts"]intValue];
    int penaltyNumber = [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Penalties"]intValue];
    totalStrokes = strokeNumber + puttNumber + penaltyNumber;
   // NSLog(@"---+++ Player: %i %@ Hole: %i Strokes:%i Putts:%i Penalties: %i Total:%i -- Currentplay %i", playerNumber, [playersGame objectForKey:@"Name"], viewHoleNumber+1, strokeNumber, puttNumber, penaltyNumber, totalStrokes, currentplay);
    [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]setObject:[NSNumber numberWithInt:totalStrokes] forKey:@"Total"];
    NSString *myscore = [NSString stringWithFormat:@"%i",totalStrokes];
    scoreLabel.text = myscore;

    if (puttNumber > 0) {
        [puttBox setTitle: [NSString stringWithFormat:@"Putts:%i",puttNumber] forState:UIControlStateNormal];
        puttBox.titleLabel.font = [UIFont systemFontOfSize:31];
    } else {
        [puttBox setTitle:[NSString stringWithFormat:@"Putt"] forState:UIControlStateNormal];
        puttBox.titleLabel.font = [UIFont systemFontOfSize:31];
    }
    if (penaltyNumber > 0) {
        [penaltyBox setTitle:[NSString stringWithFormat:@"Penalties:%i",penaltyNumber] forState:UIControlStateNormal];
        penaltyBox.titleLabel.font = [UIFont systemFontOfSize:25];
    } else {
        [penaltyBox setTitle:[NSString stringWithFormat:@"Penalty"] forState:UIControlStateNormal];
        penaltyBox.titleLabel.font = [UIFont systemFontOfSize:30];
    }
    [self showStableford];
}


-(void)showPar:(NSNumber*)parNumIn andStroke:(NSNumber*)strokeNumIn
{
    NSString *parString = [parNumIn stringValue];
    NSString *strokeString = [strokeNumIn stringValue];
    [whiteStrokeNumber setTitle:[NSString stringWithFormat:@" Stroke:%@ Par:%@",strokeString, parString  ] forState:UIControlStateNormal];

}


-(void)showHandicap: (float)handicapNum
{
   [handicap setTitle:[NSString stringWithFormat:@" H/C:%.0f",handicapNum] forState:UIControlStateNormal];
}

-(void)showStableford
{
    if (totalStrokes > 0) {
        stableford = [parNum intValue] + (int)courseHandicapInt  - totalStrokes + 2;
        if (stableford <= 0) stableford = 0;
        stablefordBox.text = [NSString stringWithFormat:@"Sf:%i",stableford];
    } else {
        stableford = 0;
        stablefordBox.text = [NSString stringWithFormat:@"Sf:-"];
    }
//    if (playerNumber == 0 || playerNumber == 1) {
//          NSLog(@"---+++ %@ Stableford  Calc: Par:%i H/C:%i Total:%i S/ford:%i", [playersGame objectForKey:@"Name"], [parNum intValue] , (int)courseHandicapInt, totalStrokes, stableford );
//    }
    [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]setObject:[NSNumber numberWithInt:stableford] forKey:@"Stableford"];
}


/*
-(void)calculateHandicapForHole
{
//    NSDictionary *parStrokeHandicap =  [appDelegate playersHandicapForHole:playerNumber];
//    NSLog(@"---+++ Player: %@ Dict\n%@", [playersGame objectForKey:@"Name"], parStrokeHandicap);
    float playersHandicapIndex =  [[playersGame objectForKey:@"Handicap"]floatValue];
    float slope = [[[[[[appDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                objectForKey:@"Tees"] objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
              objectForKey:@"Slope"]floatValue];
    float courseHandicap = roundf(playersHandicapIndex * (slope/113.0));
     courseHandicapInt  = floorf(courseHandicap /18.0);
    float handicapModulo = fmodf(courseHandicap, 18.0);

    if (handicapModulo >= [strokeNum floatValue]) {
        courseHandicapInt++ ;
    }

  //  if (playerNumber == 0)  NSLog(@"---+++ Hole:%i Handicap Modulo %.1f stroke %.1f  H/C %.1f", viewHoleNumber+1, handicapModulo, [strokeNum floatValue], courseHandicapInt);
    
   // NSLog(@"---+++ player:%i - Slope: %.1f course Handicap:%.2f", playerNumber, slope, courseHandicap);
//    float courseHandicapFrac = fmodf(courseHandicap / 18.0, 1.0);
//    courseHandicapFrac = roundf(courseHandicapFrac*1000.0)/1000.0;
//    float strokeFrac = ([strokeNum floatValue]-1) / 18.0;
//    strokeFrac = roundf(strokeFrac*1000.0)/1000.0;
//    if (strokeFrac < courseHandicapFrac ) {
//        courseHandicapInt++ ;
//    }

    [handicap setTitle:[NSString stringWithFormat:@" H/C:%.0f",courseHandicapInt] forState:UIControlStateNormal];
    
}
*/

#pragma mark - Next Hole!

-(void)nextHole:(int)holeNum // set up Hole and show score
{
    viewHoleNumber = holeNum;
    // holeNumberTextField.text = [NSString stringWithFormat:@"%i", viewHoleNumber+1];
   // [self showScore];
    
       //.coordinate  = [[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Lat"];
    NSString *courseName = [appDelegate.courseData objectForKey:@"Name"];
    NSString *holeNameX = [[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Title"];
    NSString *holeLength =  [[[[[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Divisions"]
                                                      objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                                                     objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
                                                    objectForKey:@"Length"];
   // NSLog(@"---+++ Hole name: %@", holeNameX);
    
   // NSString *strokeHoleWhite = [[[[[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Divisions"]objectAtIndex:// 0]objectAtIndex:0]objectForKey:@"Stroke"];
    
   // NSString *parHoleWhite = [[[[[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Divisions"]objectAtIndex:// 0]objectAtIndex:0]objectForKey:@"Par"];
    if ([holeNameX isEqualToString:@"Hole name"]) {
        holeNameX = [NSString stringWithFormat:@"%@ Hole:%i",courseName, viewHoleNumber+1];
    } else {
         holeNameX = [NSString stringWithFormat:@"%@ : %@ %@m",courseName, holeNameX, holeLength];
    }
    holeName.text = holeNameX;
   // [self getPlayersParAndStroke];
   // [self calculateHandicapForHole];
    NSDictionary *parStrokeHandicap = [appDelegate handicapForPlayer:playerNumber holeNumber:holeNum ];
    courseHandicapInt = [[parStrokeHandicap objectForKey:@"Handicap"]floatValue];
    strokeNum = [parStrokeHandicap objectForKey:@"Stroke"];
    parNum = [parStrokeHandicap objectForKey:@"Par"];
    [self showScore];
    [self showPar:parNum andStroke:strokeNum];
    [self showHandicap:courseHandicapInt];

    PreviousStrokeDistance = 0.0f ; // zero on hole chnage
    prevStrokeDistanceString = @"   ---";
  //  NSLog(@"---+++ View: %i Hole Num: %i", playerNumber, viewHoleNumber);
   // NSLog(@"---+++ Player:%i hole:%i, %@",playerNumber, viewHoleNumber, [[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Title"]);
}

/*
-(void)getPlayersParAndStroke
{
    parNum =  [[[[[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Divisions"]
                           objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                          objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
                         objectForKey:@"Par"];
    
    strokeNum =  [[[[[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Divisions"]
                           objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                          objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
                         objectForKey:@"Stroke"];
   // NSLog(@"---+++ Player %i par/Stroke %@/%@", playerNumber, parNum, strokeNum);
    
}
*/

- (IBAction)ScoreButton:(id)sender {
    // [self resetFrontView];
    // VLog(@"---+++ Score Button, Previous stroke %.3f", strokeDistance);
    int strokeNumber =  [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Strokes"]intValue];
    strokeNumber++ ;
    [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]setObject:[NSNumber numberWithInt:strokeNumber] forKey:@"Strokes"];
    currentplay = 0;
    [self showScore];
    [[self delegate]saveScoreTime];
    if (strokeNumber > 1) {
        PreviousStrokeDistance = strokeDistance;
        prevStrokeDistanceString = [NSString stringWithFormat:@" %.1f",strokeDistance];
    }
    lastStrokeLoc = currentLoc;
    [self reUpdateStrokeDistance];  // immediate update the Previous distance
    
   // NSLog(@"---+++ Stroke: %@ for Hole: %i", [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Total"], viewHoleNumber + 1 );
    
}
- (IBAction)scoreButtonDown:(id)sender {

//    scoreLabel.text = @" ";
//    score++;
}

- (IBAction)decrementButtonDown:(id)sender
{
 //  [self resetFrontView];
    decrementButtonTimer = [NSTimer scheduledTimerWithTimeInterval:decrementStrokeTime target:self selector:@selector(timerClearingAction) userInfo:nil repeats:NO];
}


- (IBAction)decrementButtonDragOut:(id)sender
{
    [decrementButtonTimer invalidate];
}

- (IBAction)showPreviousStrokeDistance:(id)sender
{
    [previousDistance setTitleColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0] forState:UIControlStateHighlighted]; // needed
    thisStrokeLabel.text = @"Previous";
    [previousDistance setTitle:prevStrokeDistanceString forState:UIControlStateHighlighted];
}

- (IBAction)showPreviousUp:(id)sender
{
    thisStrokeLabel.text = @"This Stroke";
}



- (IBAction)puttButton:(id)sender
{
  // [self resetFrontView];
    int puttNumber =  [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Putts"]intValue];
    puttNumber++ ;
    [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]setObject:[NSNumber numberWithInt:puttNumber] forKey:@"Putts"];
    currentplay = 1;
    [self showScore];
    [[self delegate]saveScoreTime];
}


- (IBAction)penaltyButton:(id)sender {
  //  [self resetFrontView];
    int penaltyNumber =  [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Penalties"]intValue];
    penaltyNumber++ ;
    [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]setObject:[NSNumber numberWithInt:penaltyNumber] forKey:@"Penalties"];
    currentplay = 2;
    [self showScore];
    [[self delegate]saveScoreTime];
}


-(void)timerClearingAction  // timer has not been canceled by touch up, so clear hole
{
    NSLog(@"---+++ Clear Hole!");
    [decrementButtonTimer invalidate];
    [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber] setObject:[NSNumber numberWithInt:0] forKey:@"Strokes"];
    [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber] setObject:[NSNumber numberWithInt:0] forKey:@"Putts"];
    [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber] setObject:[NSNumber numberWithInt:0] forKey: @"Penalties"];
    [self showScore];
    [[self delegate]saveScoreTime];

}

- (IBAction)gearButton:(id)sender
{
    clearOptions = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear This Game" otherButtonTitles:
                                   @"Clear this player",
                                   @"1 player",
                                   @"2 players",
                                   @"3 players",
                                   @"4 players",
                                    [appDelegate.courseData objectForKey:@"Name"],
                                            nil];
    
  //  [clearOptions showFromTabBar:self.tabBarController.tabBar];
    [clearOptions showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == clearOptions) {
        [[self delegate]clearGameOptions:(int)buttonIndex forPlayerNumber:playerNumber]; // used as data index
    } // else if (actionSheet == reCalibrate) {
      //  [[self delegate]reCalibratePinDistance:(int)buttonIndex];
    // }
    
}

-(void)alertView:(UIAlertView*)reCalibrate clickedButtonAtIndex:(NSInteger)buttonIndex
{
      [[self delegate]reCalibratePinDistance:(int)buttonIndex];
}


- (IBAction)decrementButton:(id)sender { // Touch UP -- timer has not timed out
    [decrementButtonTimer invalidate];
    int strokeNumber =  [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Strokes"]intValue];
    int puttNumber = [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Putts"]intValue];
    int penaltyNumber = [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Penalties"]intValue];
   // NSLog(@"---+++ Current play %i", currentplay);
    if (strokeNumber == 0) {  // the situation where 0 strokes but others have values 
        if (puttNumber > 0) {
            currentplay = 1;
        } else if (penaltyNumber > 0) {
            currentplay = 2;
        }
    }
    switch (currentplay) {
        case 0:  // stroke play
            if (strokeNumber > 0) {
                strokeNumber-- ;
                [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]setObject:[NSNumber numberWithInt:strokeNumber] forKey:@"Strokes"];
            }
            break;
        case 1:  //Putting
            if (puttNumber > 0 ) {
                puttNumber-- ;
                [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]setObject:[NSNumber numberWithInt:puttNumber] forKey:@"Putts"];
            }
            if (puttNumber == 0) {
                currentplay = 0;
            }
            break;
        case 2: // Penalty
            if (penaltyNumber > 0 ) {
                penaltyNumber-- ;
                [[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]setObject:[NSNumber numberWithInt:penaltyNumber] forKey:@"Penalties"];
            }
            if (penaltyNumber == 0) {
                currentplay = 0;
            }
            break;
        default:
            break;
    }
    [self showScore];
    [[self delegate]saveScoreTime];
}

- (IBAction)nextHoleButtonDown:(id)sender { // touch down
    [self resetFrontView];
    nextHoleButtonTimer = [NSTimer scheduledTimerWithTimeInterval:showHolePickerTime target:self selector:@selector(showHolePicker) userInfo:nil repeats:NO];
    killNextHoleTouchUp  = NO;
}


- (IBAction)nextHoleButton:(id)sender   // Touch Up
{
    if (killNextHoleTouchUp == NO) {
        [nextHoleButtonTimer invalidate];
        currentplay = 0;
        [[self delegate]nextHole];
    }
}

-(void)showHolePicker
{
    killNextHoleTouchUp = YES; // don't want to step to next hole if picker is not moved
    [holePicker selectRow:viewHoleNumber inComponent:0 animated:NO];
    holePicker.hidden = NO;
    nextHoleDissmissTimer = [NSTimer  scheduledTimerWithTimeInterval:dissmissHolePickerStaticTime target:self selector:@selector(pickerDissmiss) userInfo:nil repeats:NO]; // dissmiss if no picker movement after showing it
}

- (IBAction)nameChanged:(UITextField *)sender {
    
    [sender resignFirstResponder];
    nameTextField.userInteractionEnabled = NO;
    [playersGame setObject:nameTextField.text forKey:@"Name"];
}

- (IBAction)nameButtonDown {
    nameTimer = [NSTimer scheduledTimerWithTimeInterval:nameEditTime target:self selector:@selector(nameTimerTimedOut) userInfo:nil repeats:NO];
   //NSLog(@"---+++ Name Down %.1f", nameEditTime);
}


- (IBAction)nameButtonUp {
    [nameTimer invalidate];
   // NSLog(@"---+++ name Up");
}

-(void)nameTimerTimedOut
{
  // NSLog(@"---+++ name Timer out");
    [[self delegate]listofPlayers];
//    nameTextField.userInteractionEnabled = YES;
//    [nameTextField becomeFirstResponder];
}

#pragma mark - swipes

-(void)handleRSwipe: (UISwipeGestureRecognizer *)sender
{
    [decrementButtonTimer invalidate];
    [pinDistanceTimer invalidate];
    [parStrokeTimer invalidate];
    [[self delegate]swipeR:playerNumber];
}

-(void)handleLSwipe: (UISwipeGestureRecognizer *)sender
{
    [decrementButtonTimer invalidate];
    [pinDistanceTimer invalidate];
    [parStrokeTimer invalidate];
    [[self delegate]swipeL:playerNumber];
}

-(void)handleUSwipe: (UISwipeGestureRecognizer *)sender
{
//    scoreTable = [[ScoreTable alloc]initWithNibName:@"ScoreTable" bundle:nil];
//    [self.navigationController pushViewController:scoreTable animated:YES];
    [decrementButtonTimer invalidate];
    [pinDistanceTimer invalidate];
    [parStrokeTimer invalidate];
    [nameTimer invalidate];

    
//    [UIView animateWithDuration:0.5
//                          delay:0.0
//                        options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
//                     animations:^{
//                         [parStrokeOverlay setFrame:CGRectMake(0, 568, parStrokeOverlay.frame.size.width, parStrokeOverlay.frame.size.height)];
//                     }
//                     completion:^(BOOL finished){
//                       // parStrokeOverlay.hidden = YES;
//                     }];
    
    if (backSlider == 1 ){
        if (parStrokeOverlay.hidden != NO) {    // over must be dismissed
           // parStrokeOverlay.hidden = YES;
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
                             animations:^{
                                 [self->frontView setFrame:CGRectMake(0, 0, self->frontView.frame.size.width, self->frontView.frame.size.height)];
                             }
                             completion:^(BOOL finished){
                                 backSlider = 0;
                             }];

            FrontTopConstraint.constant = 0.0;
            FrontBottomConstraint.constant = 0.0;
        }
    } else {
        [[self delegate]swipeU:playerNumber]; // show scores tableView
     }
}


-(void)handleDSwipe: (UISwipeGestureRecognizer *)sender // show Extra hole info - distances etc
{
    [decrementButtonTimer invalidate];
    [nextHoleButtonTimer invalidate];
    [nameTimer invalidate];
    [pinDistanceTimer invalidate];
    [parStrokeTimer invalidate];
   // [[self delegate]swipeD:playerNumber]; // not used, still works tho
    float slideValue = 150.0;
    backSlider = 1;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
                     animations:^{
                         [self->frontView setFrame:CGRectMake(0, slideValue, self->frontView.frame.size.width, self->frontView.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                        // NSLog(@"---*** Animation DOWN Done!");
                     }];
    FrontTopConstraint.constant = slideValue;
    FrontBottomConstraint.constant = slideValue;
   // sliderTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerClearingAction) userInfo:nil repeats:NO];
}

#pragma mark - Update Location

-(void)updateLocation:(CLLocation *)latlon
{
    currentLoc = latlon;
    CLLocationDistance distanceToHole;
    int strokeNumber =  [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Strokes"]intValue];
    
    Accuracy.text = [NSString stringWithFormat:@" %.1f", latlon.horizontalAccuracy];
    Accuracy.textColor  = [UIColor redColor];
    AccuracyFlasher =  [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(AccuracyWhite) userInfo:nil repeats:NO];

    if (latlon.coordinate.longitude != 0 && latlon.coordinate.longitude != 0) {
        // NSLog(@"---+++ Valid loc %@", latlon);
        distanceToHole = [holeLocation distanceFromLocation:latlon];
        if (distanceToHole <= 1000.0) {
            [pinDistance setTitle:[NSString stringWithFormat:@" %.1f", distanceToHole] forState:UIControlStateNormal];
        } else {
            [pinDistance setTitle:@"   --- " forState:UIControlStateNormal];
        }
        strokeDistance = [lastStrokeLoc distanceFromLocation:latlon];
       // if (playerNumber == 0) NSLog(@"\n");
       // if (playerNumber == 0) VLog(@"---+++ Update stroke Distance %.1f %.1f", strokeDistance, PreviousStrokeDistance);
       // NSLog(@"---+++ Last Loc %i %.1f %.1f %.1f", playerNumber, lastStrokeLoc.coordinate.latitude, lastStrokeLoc.coordinate.longitude, strokeDistance);
        if ( strokeNumber > 0) { // strokeDistance <= 1000.0 &&
            [previousDistance setTitle:[NSString stringWithFormat:@" %.1f", strokeDistance] forState:UIControlStateNormal];
        } else {
            [previousDistance setTitle:@"   --- " forState:UIControlStateNormal];
        }
    } else {  // setting zero location for when location service not working
        [pinDistance setTitle:@"   ??? " forState:UIControlStateNormal];
        [previousDistance setTitle:@"   ??? " forState:UIControlStateNormal];
    }
    
}

-(void)reUpdateStrokeDistance   // just update the "Previous Stroke" Distance; used by score button
{
    int strokeNumber =  [[[[playersGame objectForKey:@"Scores"]objectAtIndex:viewHoleNumber]objectForKey:@"Strokes"]intValue];
    if (currentLoc.coordinate.longitude != 0 && currentLoc.coordinate.longitude != 0) {
        if ( strokeNumber > 0) { // strokeDistance <= 1000.0 &&
            [previousDistance setTitle:[NSString stringWithFormat:@" 0.0"] forState:UIControlStateNormal];
        } else {
            [previousDistance setTitle:@"   --- " forState:UIControlStateNormal];
            prevStrokeDistanceString = @"   --- ";
        }
    } else {  // setting zero location for when location service not working
        [pinDistance setTitle:@"   ??? " forState:UIControlStateNormal];
        [previousDistance setTitle:@"   ??? " forState:UIControlStateNormal];
        prevStrokeDistanceString = @"   ??? ";
    }
    
}


-(void)AccuracyWhite
{
    Accuracy.textColor = [UIColor whiteColor];
}

- (IBAction)pinDistanceTouchDown:(id)sender
{
    pinDistanceTimer = [NSTimer scheduledTimerWithTimeInterval:pinReCalibratetime target:self selector:@selector(pinReCalibrate) userInfo:nil repeats:NO];
}

- (IBAction)pinDistanceTouchUp:(id)sender
{
    [pinDistanceTimer invalidate];
}

- (IBAction)pinDistanceDragOut:(id)sender
{
    [pinDistanceTimer invalidate];
}

-(void)pinReCalibrate     // action sheet calls reCalibratePinDistance  in app delegte
{
    // reCalibrate = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Re-Calibrate" otherButtonTitles:
    //                                nil];
    // [reCalibrate showInView:self.view];
    
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Recalibrate This hole?"
                                                       message:@"Wait for stable reading then hit - OK"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK",
                             nil];
    [theAlert show];
    
    //  [clearOptions showFromTabBar:self.tabBarController.tabBar];
    
    
}

#pragma mark - Par/Stroke Calibrate

- (IBAction)parStrokeDown:(id)sender {
    parStrokeTimer =  [NSTimer scheduledTimerWithTimeInterval:pinReCalibratetime target:self selector:@selector(parStrokeCalibrate) userInfo:nil repeats:NO];}

- (IBAction)parStrokeDragOut:(id)sender {
    [parStrokeTimer invalidate];
}

- (IBAction)parStrokeTouchUp:(id)sender {
    [parStrokeTimer invalidate];
}

-(void)parStrokeCalibrate
{
    [parStrokeOverlay setFrame:CGRectMake(0, self.view.frame.size.height, parStrokeOverlay.frame.size.width, parStrokeOverlay.frame.size.height)];
    parStrokeOverlay.hidden = NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
                     animations:^{
                         [self->parStrokeOverlay setFrame:CGRectMake(0, 175, self->parStrokeOverlay.frame.size.width, self->parStrokeOverlay.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         // NSLog(@"---*** Animation UP Done!");
                     }];


    [parPicker selectRow: [@([parNum integerValue] - 3)integerValue] inComponent:0 animated:NO];
    parPicked = parNum;
    
   [strokePicker selectRow: [@([strokeNum integerValue] - 1)integerValue] inComponent:0 animated:NO];
    strokePicked = strokeNum;
    NSLog(@"---+++ Picking Par:%@, stroke:%@",parNum, strokeNum);
}

- (IBAction)parStrokeCancel:(id)sender {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
                     animations:^{
                         [self->parStrokeOverlay setFrame:CGRectMake(0, 568, self->parStrokeOverlay.frame.size.width, self->parStrokeOverlay.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         self->parStrokeOverlay.hidden = YES;
                         if ( sender == NULL)  {  // done call this method with NULL
                             [self showPar:self->parPicked  andStroke:self->strokePicked];
                            [[[[[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Divisions"]
                               objectAtIndex:[[self->playersGame objectForKey:@"Division"]intValue]]
                              objectAtIndex:[[self->playersGame objectForKey:@"Tees"]intValue]]
                             setObject:self->parPicked forKey:@"Par"] ;
                             
                            [[[[[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Divisions"]
                               objectAtIndex:[[self->playersGame objectForKey:@"Division"]intValue]]
                              objectAtIndex:[[self->playersGame objectForKey:@"Tees"]intValue]]
                             setObject:self->strokePicked forKey:@"Stroke"];
                             
                             [appDelegate writeCurrentCourse];
                         }
                     }];

}

- (IBAction)parStrokeDone:(id)sender {
    [self parStrokeCancel:NULL];
}





-(void)dismissTimers // timers may be waiting to initiate action, when user does something else
{
    [nameTimer invalidate];
    [decrementButtonTimer invalidate];
    [nextHoleButtonTimer invalidate];
    [pinDistanceTimer invalidate];
}

#pragma mark - Pickers 
// Tags: 0 is hole number, 1 is par, 2 is stroke

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1 ){
        return 3;
    } else {
        return 18;
    }
}



-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60.0;
}

//-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    NSString *title = [NSString stringWithFormat:@"%i", row+1];
//    return title;
//}
//-(NSAttributedString*)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    NSString *attText = [NSString stringWithFormat:@"%i",row + 1];
//    NSAttributedString *stringForRow = [[NSAttributedString alloc] initWithString:attText attributes:@{
//                            NSForegroundColorAttributeName:[UIColor whiteColor],
//                            NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0],
//                            }];
//    return stringForRow;
//    
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        tView.textColor = [UIColor whiteColor];
        //tView.font = [UIFont systemFontOfSize:50];
       // tView.font = [UIFont boldSystemFontOfSize:50.0];
       //tView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0];
    }
    // Fill the label text here
    switch (pickerView.tag) {
        case 0:
            tView.font = [UIFont boldSystemFontOfSize:50.0];
            tView.text = [NSString stringWithFormat:@" #%i",(int)row+1 ];
            break;
        case 1:
            tView.font = [UIFont boldSystemFontOfSize:30.0];
            tView.text = [NSString stringWithFormat:@"Par:%i",(int)row+3 ];
            break;
        case 2:
            tView.font = [UIFont boldSystemFontOfSize:30.0];
            tView.text = [NSString stringWithFormat:@"Stroke:%i",(int)row+1 ];
        default:
            break;
    }

    return tView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
   // NSLog(@"---+++ Picker row: %i", row);
    switch (pickerView.tag) {
    case 0:
        [[self delegate]setCustomHole:(int)row];
        [nextHoleDissmissTimer invalidate];
        nextHoleDissmissTimer = [NSTimer  scheduledTimerWithTimeInterval:dissmissHolePickerMovedTime target:self selector:@selector(pickerDissmiss) userInfo:nil repeats:NO]; // picker dissmisses too quickly - wait a while
        break;
        case 1:
            parPicked = @(row + 3) ;
            break;
        case 2:
            strokePicked =  @(row + 1);
            break;
    }
    
}

-(void)pickerDissmiss
{
    holePicker.hidden = YES;
}

#pragma mark - View Life cycle

-(void)refreshPlayer
{
    NSUInteger playerPointer = [[playersGame objectForKey:@"PlayerPointer"]intValue];
    if (playerPointer >= appDelegate.playersArray.count) {
        playerPointer = appDelegate.playersArray.count -1; // backup to last good iten -- we'll be in trouble if all items deleted - wait let's not delete last item!
    }
    NSString *refreshName =  [[appDelegate.playersArray objectAtIndex:playerPointer]objectForKey:@"Name"];
    [playersGame setObject:refreshName forKey:@"Name"];
    nameTextField.text = [playersGame objectForKey:@"Name"];
    NSNumber *refreshDivision = [[appDelegate.playersArray objectAtIndex:playerPointer]objectForKey:@"Division"];
    [playersGame setObject:refreshDivision forKey:@"Division"];
    NSNumber *refreshHandicap = [[appDelegate.playersArray objectAtIndex:playerPointer]objectForKey:@"Handicap"];
    [playersGame setObject:refreshHandicap forKey:@"Handicap"];
    
   // NSLog(@"---+++ Refresh Player %i, pointer %i %@", playerNumber, playerPointer, refreshName );
   // NSLog(@"---+++ Game:\n %@", playersGame);
  // [self getPlayersParAndStroke];
    NSDictionary *parStrokeHandicap = [appDelegate handicapForPlayer:playerNumber holeNumber:viewHoleNumber ];
    courseHandicapInt = [[parStrokeHandicap objectForKey:@"Handicap"]floatValue];
    strokeNum = [parStrokeHandicap objectForKey:@"Stroke"];
    parNum = [parStrokeHandicap objectForKey:@"Par"];
    [self showPar:parNum andStroke:strokeNum];
    [self showHandicap:courseHandicapInt];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
   // [swipeGesture setDelegate:self];
    leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLSwipe:)];
    rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRSwipe:)];
    upSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUSwipe:)];
    downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDSwipe:)];
    
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    upSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    [self.view addGestureRecognizer:upSwipeGestureRecognizer];
    [self.view addGestureRecognizer:downSwipeGestureRecognizer];
    
    scoreBox.layer.cornerRadius = 25.0;
    scoreBox.layer.borderWidth = 5.0;
    scoreBox.layer.masksToBounds = YES;
    
    decrementBox.layer.cornerRadius = 10.0;
    decrementBox.layer.borderWidth = 3.0;
    decrementBox.layer.masksToBounds = YES;
    
    puttBox.layer.cornerRadius = 10.0;
    puttBox.layer.borderWidth = 3.0;
    puttBox.layer.masksToBounds = YES;
    
    penaltyBox.layer.cornerRadius = 10.0;
    penaltyBox.layer.borderWidth = 3.0;
    penaltyBox.layer.masksToBounds = YES;
    
    nextBox.layer.cornerRadius = 10.0;
    nextBox.layer.borderWidth = 3.0;
    nextBox.layer.masksToBounds = YES;
    
    pinDistance.layer.cornerRadius = 10;
    pinDistance.layer.borderWidth = 2.0;
    pinDistance.layer.masksToBounds = YES;
    
    previousDistance.layer.cornerRadius = 10;
    previousDistance.layer.borderWidth = 2.0;
    previousDistance.layer.masksToBounds = YES;
    
    nameTextField.text = [playersGame objectForKey:@"Name"];
    
    [holePicker setDelegate:self];
    [holePicker setDataSource:self];
    [nameTextField setDelegate:self];
    [nameTextField setBorderStyle:UITextBorderStyleNone];

    whiteStrokeNumber.layer.cornerRadius = 10.0;
    whiteStrokeNumber.layer.borderWidth = 2.0;
    whiteStrokeNumber.layer.masksToBounds = YES;
   // whiteStrokeNumber.layer.borderColor = [UIColor whiteColor].CGColor;
    
    handicap.layer.cornerRadius = 10.0;
    handicap.layer.borderWidth = 2.0;
    handicap.layer.masksToBounds = YES;
   // yellowStrokeNumber.layer.borderColor = [UIColor yellowColor].CGColor;
    
    scoreBoxConstraint.constant = 00.0;
  
    [previousDistance setTitleColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0] forState:UIControlStateHighlighted];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float screenHeight = screenRect.size.height;
   // NSLog(@"---+++ Screen Height: %.1f   Screen Width: %.1f", screenHeight, screenRect.size.width);

    if (screenHeight <= 480.0) {  // 3.5" screen - customise -- get right in 'Inferred mode for 4"/ free form - then fix here for 3.5"
        scoreBoxConstraint.constant = 20;
        puttPenaltyContraint.constant = 35;
        HolesConstriant.constant = 29;
    }
   // float screenWidth = screenRect.size.width;
    
   // [[nameTextField layer]setBorderColor:[UIColor clearColor].CGColor];
   // [[nameTextField layer]setBorderWidth:5.0];
   // [[nameButton layer]setBorderColor:[UIColor clearColor].CGColor];
   // [[nameButton layer]setBorderWidth:5.0];
    
   // NSLog(@"---+++ Player %i game detail \n%@", playerNumber, playersGame);
   // [self setNeedsStatusBarAppearanceUpdate];

	// Do any additional setup after loading the view, typically from a nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(void)resetFrontView
{
    backSlider = 0;
    //[frontView setFrame:CGRectMake(0, 0, frontView.frame.size.width, frontView.frame.size.height)];
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
                     animations:^{
                         [self->frontView setFrame:CGRectMake(0, 0, self->frontView.frame.size.width, self->frontView.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                        //  NSLog(@"---*** Animation UP Done!");
                     }];
    FrontTopConstraint.constant = 0.0;
    FrontBottomConstraint.constant = 0.0;
}


-(void)viewWillAppear:(BOOL)animated
{

//   preferredStatusBarStyle
    NSArray *colors;
    
    parStrokeOverlay.hidden = YES;
    switch (playerNumber) {
        case 0:
            scoreBox.layer.borderColor = [UIColor redColor].CGColor;
            decrementBox.layer.borderColor = [UIColor redColor].CGColor;
            nextBox.layer.borderColor = [UIColor redColor].CGColor;
            puttBox.layer.borderColor = [UIColor redColor].CGColor;
            penaltyBox.layer.borderColor = [UIColor redColor].CGColor;
            pinDistance.layer.borderColor = [UIColor redColor].CGColor;
            previousDistance.layer.borderColor = [UIColor redColor].CGColor;
           //int colorNumber = [game] [ playersGame objectForKey:@"Divisions"][playersGame objectForKey:@"Tees"]integerValue]

            colors = [[[[[appDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                                                                objectForKey:@"Tees"] objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
                                                                objectForKey:@"TeeColor"];
            whiteStrokeNumber.layer.borderColor = [UIColor colorWithRed:[[colors objectAtIndex:0]floatValue]
                                                                  green:[[colors objectAtIndex:1]floatValue]
                                                                   blue:[[colors objectAtIndex:2]floatValue]
                                                                  alpha:1.0].CGColor;
            handicap.layer.borderColor = [UIColor colorWithRed:[[colors objectAtIndex:0]floatValue]
                                                         green:[[colors objectAtIndex:1]floatValue]
                                                          blue:[[colors objectAtIndex:2]floatValue]
                                                         alpha:1.0].CGColor;


            break;
        case 1:
            scoreBox.layer.borderColor = [UIColor orangeColor].CGColor;
            decrementBox.layer.borderColor = [UIColor orangeColor].CGColor;
            nextBox.layer.borderColor = [UIColor orangeColor].CGColor;
            puttBox.layer.borderColor = [UIColor orangeColor].CGColor;
            penaltyBox.layer.borderColor = [UIColor orangeColor].CGColor;
            pinDistance.layer.borderColor = [UIColor orangeColor].CGColor;
            previousDistance.layer.borderColor = [UIColor orangeColor].CGColor;
            
            colors = [[[[[appDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                              objectForKey:@"Tees"] objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
                            objectForKey:@"TeeColor"];
            whiteStrokeNumber.layer.borderColor = [UIColor colorWithRed:[[colors objectAtIndex:0]floatValue]
                                                                  green:[[colors objectAtIndex:1]floatValue]
                                                                   blue:[[colors objectAtIndex:2]floatValue]
                                                                  alpha:1.0].CGColor;
            handicap.layer.borderColor = [UIColor colorWithRed:[[colors objectAtIndex:0]floatValue]
                                                         green:[[colors objectAtIndex:1]floatValue]
                                                          blue:[[colors objectAtIndex:2]floatValue]
                                                         alpha:1.0].CGColor;
            

            
            break;
        case 2:
            scoreBox.layer.borderColor = [UIColor yellowColor].CGColor;
            decrementBox.layer.borderColor = [UIColor yellowColor].CGColor;
            nextBox.layer.borderColor = [UIColor yellowColor].CGColor;
            puttBox.layer.borderColor = [UIColor yellowColor].CGColor;
            penaltyBox.layer.borderColor = [UIColor yellowColor].CGColor;
            pinDistance.layer.borderColor = [UIColor yellowColor].CGColor;
            previousDistance.layer.borderColor = [UIColor yellowColor].CGColor;
            
            colors = [[[[[appDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                              objectForKey:@"Tees"] objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
                            objectForKey:@"TeeColor"];
            whiteStrokeNumber.layer.borderColor = [UIColor colorWithRed:[[colors objectAtIndex:0]floatValue]
                                                                  green:[[colors objectAtIndex:1]floatValue]
                                                                   blue:[[colors objectAtIndex:2]floatValue]
                                                                  alpha:1.0].CGColor;
            handicap.layer.borderColor = [UIColor colorWithRed:[[colors objectAtIndex:0]floatValue]
                                                         green:[[colors objectAtIndex:1]floatValue]
                                                          blue:[[colors objectAtIndex:2]floatValue]
                                                         alpha:1.0].CGColor;
            
            
            break;
        case 3:
            scoreBox.layer.borderColor = [UIColor greenColor].CGColor;
            decrementBox.layer.borderColor = [UIColor greenColor].CGColor;
            nextBox.layer.borderColor = [UIColor greenColor].CGColor;
            puttBox.layer.borderColor = [UIColor greenColor].CGColor;
            penaltyBox.layer.borderColor = [UIColor greenColor].CGColor;
            pinDistance.layer.borderColor = [UIColor greenColor].CGColor;
            previousDistance.layer.borderColor = [UIColor greenColor].CGColor;
            
            colors = [[[[[appDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                              objectForKey:@"Tees"] objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
                            objectForKey:@"TeeColor"];
            whiteStrokeNumber.layer.borderColor = [UIColor colorWithRed:[[colors objectAtIndex:0]floatValue]
                                                                  green:[[colors objectAtIndex:1]floatValue]
                                                                   blue:[[colors objectAtIndex:2]floatValue]
                                                                  alpha:1.0].CGColor;
            handicap.layer.borderColor = [UIColor colorWithRed:[[colors objectAtIndex:0]floatValue]
                                                         green:[[colors objectAtIndex:1]floatValue]
                                                          blue:[[colors objectAtIndex:2]floatValue]
                                                         alpha:1.0].CGColor;

            
            break;
        case 4:
            scoreBox.layer.borderColor = [UIColor blueColor].CGColor;
            decrementBox.layer.borderColor = [UIColor blueColor].CGColor;
            nextBox.layer.borderColor = [UIColor blueColor].CGColor;
            puttBox.layer.borderColor = [UIColor blueColor].CGColor;
            penaltyBox.layer.borderColor = [UIColor blueColor].CGColor;
            pinDistance.layer.borderColor = [UIColor blueColor].CGColor;
            previousDistance.layer.borderColor = [UIColor blueColor].CGColor;
            
            colors = [[[[[appDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                              objectForKey:@"Tees"] objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
                            objectForKey:@"TeeColor"];
            whiteStrokeNumber.layer.borderColor = [UIColor colorWithRed:[[colors objectAtIndex:0]floatValue]
                                                                  green:[[colors objectAtIndex:1]floatValue]
                                                                   blue:[[colors objectAtIndex:2]floatValue]
                                                                  alpha:1.0].CGColor;
            handicap.layer.borderColor = [UIColor colorWithRed:[[colors objectAtIndex:0]floatValue]
                                                         green:[[colors objectAtIndex:1]floatValue]
                                                          blue:[[colors objectAtIndex:2]floatValue]
                                                         alpha:1.0].CGColor;
            
            
            break;
        default:
            break;
    }
    holePicker.hidden = YES;
    currentplay = 0;
    [self showScore];
   // nameTextField.enabled = NO;
   // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   // NSLog(@"---+++ Bingo View! %@", [[[appDelegate.courseData objectForKey:@"Holes"]objectAtIndex:viewHoleNumber]objectForKey:@"Title"]);
    //and then access the variable by appDelegate.variable
}

-(void)viewWillDisappear:(BOOL)animated
{
    holePicker.hidden = YES;
    [self resetFrontView];
}


//- (void)viewDidUnload  // deprecated, never called now
//{
//    scoreLabel = nil;
//    [super viewDidUnload];
//}

// depricated
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return  (interfaceOrientation == UIDeviceOrientationPortrait);
//}

@end
