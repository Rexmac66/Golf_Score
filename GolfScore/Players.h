//
//  Players.h
//  GolfScore
//
//  Created by Rex McIntosh on 23/09/15.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>


@protocol playersActions <NSObject>
@optional
-(void)dissmissPlayers:(int)playerIndex;
-(void)writeAllPlayers;

@end

#import "AppDelegate.h"

@interface Players : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate >
{
    int playerNumber;
   // NSArray *playerList;  //use appDelegate.playersArray
    id <coursesActions> delegate;
    IBOutlet UIView *editOverlay;
    
    IBOutlet UIButton *editCancel;
    IBOutlet UIButton *editDone;
    
    IBOutlet UITextField *nameField;

    IBOutlet UITableView *playersTable;
    IBOutlet UIPickerView *sexPicker;
    
    IBOutlet UIPickerView *handicapIntegerPicker;
    
    IBOutlet UIPickerView *handicapDecimalPicker;
   
    IBOutlet UIButton *newPlayerButton;
    
    IBOutlet UIButton *doneButton;
    
    __weak IBOutlet UIPickerView *teesPicker;
    __weak IBOutlet UILabel *teesPickerLabel;
}

@property (assign) id delegate;
//@property NSArray *playerList;
@property int playerNumber;


@end
