//
//  Courses.h
//  GolfScore
//
//  Created by Rex McIntosh on 25/08/15.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>


@protocol coursesActions <NSObject>
@optional
-(void)dissmissCourses:(NSString*)courseName;

@end

#import "AppDelegate.h"

@interface Courses : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
  //  NSArray *courseList;
    id <coursesActions> delegate;
    
     IBOutlet UITableView *courseTable;
     IBOutlet UIView *overlay;
    
     IBOutlet UIButton *cancelButton;
     IBOutlet UIButton *doneButton;
    
    __weak IBOutlet UITextView *helpTextBlock;
    
     IBOutlet UITextField *nameField;
    
     IBOutlet UIPickerView *divisionPicker;
     IBOutlet UIPickerView *teesPicker;
     IBOutlet UIPickerView *slopePicker;
    IBOutlet UIPickerView *nzcrPicker;
    IBOutlet UIPickerView *nzcrDecimal;
    __weak IBOutlet UIPickerView *parPicker;
    
    __weak IBOutlet UILabel *parTextBox;
}

@property (assign) id delegate;
//@property NSArray *courseList;

@end
