//
//  ViewController.h
//  GolfScore
//
//  Created by Rex McIntosh on 9/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@protocol swipes <NSObject>
@optional
-(void)swipeR:(int)playerViewNumber;
-(void)swipeL:(int)playerViewNumber;
-(void)swipeU:(int)playerViewNumber;
-(void)swipeD:(int)playerViewNumber;
-(void)nextHole;
-(void)setCustomHole:(int)newHoleNumber;
-(void)clearGameOptions:(int)options forPlayerNumber:(int)playerNumber;
-(void)reCalibratePinDistance:(int)options;
-(void)saveScoreTime;
-(void)listofPlayers;

@end

#import "AppDelegate.h"

@interface ViewController : UIViewController <UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    int score;
//    int holeNumber;
    NSMutableDictionary *playersGame;
    int playerNumber;
    IBOutlet UILabel *scoreLabel;
    
    IBOutlet UIButton *scoreBox;
    IBOutlet UIButton *decrementBox;
    IBOutlet UIButton *nextBox;
    
    IBOutlet UIButton *puttBox;
    IBOutlet UIButton *penaltyBox;
    

    IBOutlet UITextField *nameTextField;
    
    IBOutlet UIView *scoreViewGroup;
    IBOutlet UIView *puttPenaltyGroup;
    IBOutlet UIView *holesViewGroup;

    id <swipes> delegate;
    IBOutlet UIPickerView *holePicker;
    
    IBOutlet NSLayoutConstraint *scoreBoxConstraint;
    IBOutlet NSLayoutConstraint *puttPenaltyContraint;
    IBOutlet NSLayoutConstraint *HolesConstriant;
    
    IBOutlet NSLayoutConstraint *FrontTopConstraint;
    IBOutlet NSLayoutConstraint *FrontBottomConstraint;
    
    IBOutlet UIView *frontView;
    IBOutlet UIView *parStrokeOverlay;
    
    IBOutlet UIButton *pinDistance;
    IBOutlet UIButton *previousDistance;

    IBOutlet UILabel *Accuracy;
    
    __weak IBOutlet UILabel *stablefordBox;
    
    
    IBOutlet UILabel *holeName;
    IBOutlet UIButton *whiteStrokeNumber;
    IBOutlet UIButton *handicap;
    
    IBOutlet UIButton *overlayCancel;
    IBOutlet UIButton *overlayDone;

    IBOutlet UIPickerView *parPicker;
    IBOutlet UIPickerView *strokePicker;
    
    IBOutlet UILabel *thisStrokeLabel;
    
    CLLocation *currentLoc;
    CLLocation *lastStrokeLoc;
    CLLocation *holeLocation;  // set from App delegate
    
    CLLocationDistance strokeDistance;
    CLLocationDistance PreviousStrokeDistance;
    NSString *prevStrokeDistanceString;
    
    NSNumber *parNum;    // values loaded by NextHole
    NSNumber *strokeNum;
    
    NSNumber *parPicked;
    NSNumber *strokePicked;
    
    float courseHandicapInt;
  //  int stableford;
    
}

-(void)showScore;
-(void)nextHole:(int)holeNum;
-(void)updateLocation:(CLLocation*)latlon;
-(void)refreshPlayer;


@property (strong, nonatomic) IBOutlet UIButton *scoreButton;
@property int score;
//@property int holeNumber;
@property NSMutableDictionary* playersGame;
@property int playerNumber;
@property CLLocation *currentLoc;
@property CLLocation *lastStrokeLoc;
@property CLLocation *holeLocation;

@property CLLocationDistance strokeDistance;
@property CLLocationDistance PreviousStrokeDistance;
@property NSString *prevStrokeDistanceString;

@property (assign) id delegate;

@property (strong) NSNumber *parNum;
@property (strong) NSNumber *strokeNum;
@property (strong) NSNumber *parPicked;
@property (strong) NSNumber *strokePicked;
@property float courseHandicapInt;
//@property int stableford;




@end
