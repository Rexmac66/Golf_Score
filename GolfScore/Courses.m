//
//  Courses.m
//  GolfScore
//
//  Created by Rex McIntosh on 25/08/15.
//
//

#import <Foundation/Foundation.h>
#import "Courses.h"

@interface Courses ()


@end

@implementation Courses

@synthesize delegate = _delegate;
//@synthesize courseList;

AppDelegate *appCDelegate;
NSArray *divisionsStrings;
NSArray *teesStrings;
// float  pickedNZCR;
int pickedNZCRInt;
int pickedNZCRFrac;

NSUInteger editCourse;
NSString *editedCourseName;
NSUInteger teesInDivision; // number of Tees in this division
NSUInteger pickedTees;     // picked tees (White/Yellow)
NSUInteger pickedCourseDivision;
NSUInteger pickedSlope;

NSString *savedCourseName; // save course name so we can revert to the course we had selected
NSString *revertCourseName; // keep name for delete or cancel

#pragma mark - Table

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return appCDelegate.courseNames.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    cellIdentifier = @"CoursesCell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleSubtitle
                    reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:25];    
    cell.textLabel.text = [appCDelegate.courseNames objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    editCourse = indexPath.row;
    [self editCourse];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self delegate]dissmissCourses:[appCDelegate.courseNames objectAtIndex:indexPath.row]];
}

#pragma mark - Pickers

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(double)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
      switch (pickerView.tag) {
          case 0:
              return 44.0;
              break;
          case 1:
              return 30.0;
              break;
          case 2:
              return 30.0;
              break;
          case 3:
              return 30.0;
              break;
          case 4:
              return 30.0;
              break;
        default:
              return 20.0;
              break;
              
      }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (pickerView.tag) {
        case 0:
            return 2;
            break;
        case 1:
            return teesInDivision;
            break;
        case 2:
            return 100;
            break;
        case 3:
            return 50;
            break;
        case 4:
            return 10;
            break;
        default:
            return 1;
            break;
    }
}

-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        tView.textColor = [UIColor whiteColor];
    }
    NSArray *teeColors;
//    NSAttributedString *attStringSYMBOL = [[NSAttributedString alloc] initWithString:[divisionsStrings objectAtIndex:row] attributes:@{
//                                                                             NSForegroundColorAttributeName:[UIColor whiteColor],
//                                                                             NSFontAttributeName:[UIFont fontWithName:@"Avenir-Book" size:40.0],
//                                                                             }];
    NSMutableAttributedString *attString;
    NSString *divisionString;
    UIFont *fontSymbol;
  //  UIFont *fontTitle;
    
    switch (pickerView.tag) {
        case 0:
           tView.font = [UIFont boldSystemFontOfSize:20.0];
            divisionString = [NSString stringWithFormat:@"%@ %@", [divisionsStrings objectAtIndex:row], [[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:row]    objectForKey:@"Title"]] ;
            attString = [[NSMutableAttributedString alloc]initWithString:divisionString];
            
            fontSymbol = [UIFont systemFontOfSize:40.0];
            [attString addAttribute:NSFontAttributeName value:fontSymbol range:NSMakeRange(0, 2)];
           // fontTitle =[UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
           // fontTitle = [UIFont systemFontOfSize:20.0];
           // [attString addAttribute:NSFontAttributeName value:fontSymbol range:NSMakeRange(3, 5)];
            
            
           // tView.text = [NSString stringWithFormat:@"%@ %@", [divisionsStrings objectAtIndex:row], [[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:row]    objectForKey:@"Title"]] ;
            tView.attributedText = attString;   //[divisionsStrings objectAtIndex:row ];
            break;
        case 1:
            tView.font = [UIFont boldSystemFontOfSize:20.0];
            tView.textAlignment = NSTextAlignmentCenter;
            tView.text = [teesStrings objectAtIndex:row ];
            teeColors = [[[[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedCourseDivision]
                           objectForKey:@"Tees"] objectAtIndex:row]
                         objectForKey:@"TeeColor"];
            
            tView.textColor = [UIColor colorWithRed:[[teeColors objectAtIndex:0]floatValue]
                                              green:[[teeColors objectAtIndex:1]floatValue]
                                               blue:[[teeColors objectAtIndex:2]floatValue]
                                              alpha:1.0];
            
            tView.text = [[[[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedCourseDivision]
                            objectForKey:@"Tees"] objectAtIndex:row]
                          objectForKey:@"Title"];
            break;
        case 2:   //Slope
            tView.font = [UIFont boldSystemFontOfSize:28.0];
            tView.textAlignment = NSTextAlignmentCenter;
            tView.text = [NSString stringWithFormat:@"%li",row+55];
            break;
        case 3:     // NZCR
            tView.font = [UIFont boldSystemFontOfSize:28.0];
            tView.textAlignment = NSTextAlignmentCenter;
            tView.text = [NSString stringWithFormat:@"%li  ",row + 50];
            break;
        case 4:     // NZCR Decimal
            tView.font = [UIFont boldSystemFontOfSize:28.0];
            tView.textAlignment = NSTextAlignmentLeft;
            tView.text = [NSString stringWithFormat:@"  .%li",row];
            break;
        default:

            break;
    }
    return tView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (pickerView.tag) {
        case 0:                 // 0 = Men / 1 = Women / 2 = Slope / 3 = NZCRInt / 4 = NZCRFrac
            pickedCourseDivision = row;
            teesInDivision = [[[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedCourseDivision] objectForKey:@"Tees"] count] ;
            [teesPicker reloadAllComponents];
            pickedTees = 0;
            [teesPicker selectRow:0 inComponent:0 animated:YES];
            [self getCurrentSlopeForDivisionAndTees];
            [self getNZCRForDivisionAndTees];
            [self getPar];
            break;
        case 1:                 // tees white/yellow
            pickedTees = row;
            [self getCurrentSlopeForDivisionAndTees];
            [self getNZCRForDivisionAndTees];
            [self getPar];
            break;
        case 2:                 // Slope
            pickedSlope = row + 55;
          //  NSLog(@"---+++ Picked Slope %i", pickedSlope);
            break;
        case 3:
            pickedNZCRInt = (int)row + 50;
            break;
        case 4:
            pickedNZCRFrac = (int)(row) ;
            break;
        default:
            break;
    }
    [slopePicker selectRow:pickedSlope - 55 inComponent:0 animated:YES];
    [nzcrPicker selectRow:(pickedNZCRInt - 50) inComponent:0 animated:YES];
    [nzcrDecimal selectRow:pickedNZCRFrac inComponent:0 animated:YES];

    [self SaveChanges];
}

-(void)getPar
{
    int parTotal = 0;
    for (int i=0; i < 18; i++)
    {
       // NSLog(@"---+++ Tee List:\n%@",[[[[[[appCDelegate.courseData objectForKey:@"Holes"]objectAtIndex:i]objectForKey:@"Divisions"]objectAtIndex:pickedCourseDivision]objectAtIndex:pickedTees]objectForKey:@"Par"] );
        
        parTotal += [[[[[[[appCDelegate.courseData objectForKey:@"Holes"]
                    objectAtIndex:i]objectForKey:@"Divisions"]
                       objectAtIndex:pickedCourseDivision]
                      objectAtIndex:pickedTees]
                      objectForKey:@"Par"]intValue];
    }
    NSLog(@"---+++ Par Round: %i", parTotal);
    parTextBox.text = [NSString stringWithFormat:@"Par Calc:%i",parTotal];
}

-(void)SaveChanges  // save changed slope as we go, 'cause there are many facets -- cancel will reload the course
{
    NSString *pickedDivisionTitle = [NSString stringWithString:[[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedCourseDivision]    objectForKey:@"Title"]];
    NSString *pickedTeesName = [NSString stringWithString:[[[[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedCourseDivision]
                                                         objectForKey:@"Tees"] objectAtIndex:pickedTees]
                                                       objectForKey:@"Title"]];
    NSLog(@"---+++ Results to save: \n%@ \n Division: %lu %@\n Tees: %lu %@\n Slope: %lu ",editedCourseName, (unsigned long)pickedCourseDivision, pickedDivisionTitle, (unsigned long)pickedTees, pickedTeesName, (unsigned long)pickedSlope);
    
    [[[[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedCourseDivision]
        objectForKey:@"Tees"] objectAtIndex:pickedTees]
        setObject:[NSNumber numberWithInt:(int)pickedSlope] forKey:@"Slope"];
    float NZCRfloat = pickedNZCRInt + pickedNZCRFrac / 10.0;
    [[[[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedCourseDivision]
                      objectForKey:@"Tees"] objectAtIndex:pickedTees]
      setObject:[NSNumber numberWithFloat:NZCRfloat] forKey:@"NZCR"];
    
}


-(void)getCurrentSlopeForDivisionAndTees
{
    pickedSlope = [[[[[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedCourseDivision]
                      objectForKey:@"Tees"] objectAtIndex:pickedTees]
                    objectForKey:@"Slope"]integerValue];
}
-(void)getNZCRForDivisionAndTees
{
    float pickedNZCR = [[[[[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedCourseDivision]
                      objectForKey:@"Tees"] objectAtIndex:pickedTees]
                    objectForKey:@"NZCR"]floatValue];
    pickedNZCR = round(pickedNZCR * 10.0) ;
    //NSLog(@"---+++ Rounded: %f %f", pickedNZCR, pickedNZCR / 10.0);
    pickedNZCRInt = (int)pickedNZCR/10.0;
    pickedNZCRFrac = fmodf(pickedNZCR, 10.0);
    NSLog(@"---+++ NZCR:(%.2f)   %i.%i", pickedNZCR, pickedNZCRInt, pickedNZCRFrac);
}

#pragma mark - Edit Course

-(void)editCourse
{
    [appCDelegate getCourse:[appCDelegate.courseNames objectAtIndex:editCourse ]]; // course is now current course
    revertCourseName = [appCDelegate.courseNames objectAtIndex:editCourse ];
    NSLog(@"---+++ Editing Course: %@",revertCourseName);
   // NSLog(@"---+++ Course Data: \n%@", [appCDelegate.courseData objectForKey:@"Divisions"]);
    [overlay setFrame:CGRectMake(0, self.view.frame.size.height, overlay.frame.size.width, overlay.frame.size.height)];
    overlay.hidden = NO;
    float slideValue = 150.0;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
                     animations:^{
                         [self->overlay setFrame:CGRectMake(0, slideValue, self->overlay.frame.size.width, self->overlay.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         [self->divisionPicker selectRow:0 inComponent:0 animated:YES];
                         [self->teesPicker selectRow:0 inComponent:0 animated:YES];
                         [self getCurrentSlopeForDivisionAndTees];
                         [self->slopePicker selectRow:pickedSlope - 55 inComponent:0 animated:YES];
                         [self getNZCRForDivisionAndTees];
                         [self->nzcrPicker selectRow:(pickedNZCRInt - 50) inComponent:0 animated:YES];
                         [self->nzcrDecimal selectRow:(pickedNZCRFrac) inComponent:0 animated:YES];
                         [self getPar];
                     }];
    
    pickedCourseDivision = 0;
    teesInDivision = [[[[appCDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedCourseDivision] objectForKey:@"Tees"] count] ;
    pickedTees = 0;
    [teesPicker reloadAllComponents];
    editedCourseName =  [appCDelegate.courseData objectForKey:@"Name"];
    nameField.text = editedCourseName;
    courseTable.userInteractionEnabled = NO;
    courseTable.alpha = 0.5;

    //
    //    nameField.text = [[appPDelegate.playersArray  objectAtIndex:editPlayer]objectForKey:@"Name"];
    //    [sexPicker selectRow:[[[appPDelegate.playersArray  objectAtIndex:editPlayer]objectForKey:@"Division"]intValue] inComponent:0 animated:NO];
}


- (IBAction)nameEditTouchDown:(id)sender
{
    nameField.userInteractionEnabled = YES;
    [nameField becomeFirstResponder];
}

- (IBAction)nameEditDone:(id)sender
{
    // actualy save every char in case user hits Done button
    editedCourseName = nameField.text;
    [self SaveChanges];
}

- (IBAction)cancelButton:(id)sender
{
    [self dissmissCourseOvelay];
    courseTable.userInteractionEnabled = YES;
    courseTable.alpha = 1.0;
    [nameField resignFirstResponder];
    [appCDelegate getCourse:savedCourseName];
}

- (IBAction)doneButton:(id)sender
{
    [courseTable reloadData];
    courseTable.userInteractionEnabled = YES;
    courseTable.alpha = 1.0;
    [nameField resignFirstResponder];
    [self dissmissCourseOvelay];
    NSString *trimmedString = [editedCourseName stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    // this will write the course with new name - the old one is still there
    [appCDelegate.courseData setObject:trimmedString forKey:@"Name"];
    [appCDelegate writeCurrentCourse];
   // NSLog(@"---+++ %@ %@", trimmedString, revertCourseName);
    if (![trimmedString isEqualToString:revertCourseName]) {  // has name changed? - delete old one
        NSLog(@"---+++ Delete: %@", revertCourseName);
        [appCDelegate deleteCourse:revertCourseName];
    }
    [appCDelegate getAllCourses];   // in case name has changed, which it has, so save as new course
    [courseTable reloadData];
}

-(void)dissmissCourseOvelay
{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
                     animations:^{
                         [self->overlay setFrame:CGRectMake(0, 568, self->overlay.frame.size.width, self->overlay.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         self->overlay.hidden = YES;
                     }];
}





#pragma mark - View cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    appCDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    divisionsStrings = [NSArray arrayWithObjects:@"🚹", @"🚺", NULL];
   // teesStrings = [NSArray arrayWithObjects:@"White", @"Yellow", nil];
    teesInDivision = 1;   // starts with Men, which have just one set of tees
    
    helpTextBlock.layer.cornerRadius = 10.0;
    helpTextBlock.layer.borderWidth = 3.0;
    helpTextBlock.layer.masksToBounds = YES;
    helpTextBlock.layer.borderColor = [UIColor grayColor].CGColor;
    cancelButton.layer.cornerRadius = 6.0;
    cancelButton.layer.borderWidth = 2.0;
    cancelButton.layer.masksToBounds = YES;
    cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    doneButton.layer.cornerRadius = 6.0;
    doneButton.layer.borderWidth = 2.0;
    doneButton.layer.masksToBounds = YES;
    doneButton.layer.borderColor = [UIColor whiteColor].CGColor;
}

-(void)viewWillAppear:(BOOL)animated
{
    overlay.hidden = YES;
   // NSLog(@"---+++ Courses VC Courses %@", appCDelegate.courseNames);
    [courseTable reloadData];
    savedCourseName = [appCDelegate.courseData objectForKey:@"Name"];  // save current course in use for cancel ??
    // TODO when writing out course, will have to delete old course if name changed!
}


@end
