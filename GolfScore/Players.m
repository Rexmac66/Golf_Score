//
//  Players.m
//  GolfScore
//
//  Created by Rex McIntosh on 23/09/15.
//
//

#import <Foundation/Foundation.h>
#import "Players.h"

@interface Players ()

@end

@implementation Players

@synthesize delegate = _delegate;
//@synthesize playerList;
@synthesize playerNumber;

AppDelegate *appPDelegate;
NSArray *sexStrings;
float pickedHandicap;
NSUInteger pickedDivision;
NSUInteger pickedPlayerTees;
NSString *editedName;


NSUInteger editPlayer;

- (IBAction)newPlayer:(id)sender
{
  //  NSLog(@"---+++ New player");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"OnePlayer" ofType:@"plist"];
    NSMutableDictionary *onePlayer = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    editPlayer = appPDelegate.playersArray.count; // the last one
    [appPDelegate.playersArray addObject:onePlayer];
    [playersTable reloadData];
    [self editPlayer];
    [[self delegate]writeAllPlayers];  // for the case of new player that is canceled
}

- (IBAction)donePlayers:(id)sender
{
    [[self delegate]dissmissPlayers:-1];
}

#pragma mark - Table

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return appPDelegate.playersArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    cellIdentifier = @"playerCell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:25];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:25];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //cell.textLabel.text = [NSString stringWithFormat:@"- Cell %li", (long)indexPath.row];
//    NSString *nameString;
//    switch ([[[appPDelegate.playersArray  objectAtIndex:indexPath.row]objectForKey:@"Division"]intValue]) {
//        case 0:
//            nameString = [NSString stringWithFormat:@"%@ %@", Male,[[appPDelegate.playersArray  objectAtIndex:indexPath.row]objectForKey:@"Name"]];
//            break;
//        case 1:
//             nameString = [NSString stringWithFormat:@"%@ %@", Female,[[appPDelegate.playersArray  objectAtIndex:indexPath.row]objectForKey:@"Name"]];
//            break;
//        default:
//            break;
//    }
    NSString *nameString = [[appPDelegate.playersArray  objectAtIndex:indexPath.row]objectForKey:@"Name"];
   // int nameStringLength = [[[appPDelegate.playersArray  objectAtIndex:indexPath.row]objectForKey:@"Name"] length];
    if (nameString.length > 10){
        nameString = [nameString substringToIndex:11];
        nameString = [nameString stringByAppendingString:@".."];
    }
    NSString *sexString = [sexStrings objectAtIndex:[[[appPDelegate.playersArray  objectAtIndex:indexPath.row]objectForKey:@"Division"]intValue]];
   // NSString *nameString = [[appPDelegate.playersArray  objectAtIndex:indexPath.row]objectForKey:@"Name"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", sexString, nameString];
    float hBarC = [[[appPDelegate.playersArray  objectAtIndex:indexPath.row]objectForKey:@"Handicap"]floatValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f", hBarC];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
//    UISwitch *switchObj = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 10.0, 10.0)];
//    switchObj.on = YES;
//    [switchObj addTarget:self action:@selector(editCell:) forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];
//    cell.accessoryView = switchObj;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    editPlayer = indexPath.row;
    [self editPlayer];
    
   // NSLog(@"---+++ edit Row %i", indexPath.row);
//    [editOverlay setFrame:CGRectMake(0, self.view.frame.size.height, editOverlay.frame.size.width, editOverlay.frame.size.height)];
//    editOverlay.hidden = NO;
//    
//    float slideValue = 150.0;
//    [UIView animateWithDuration:0.5
//                          delay:0.0
//                        options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
//                     animations:^{
//                         [editOverlay setFrame:CGRectMake(0, slideValue, editOverlay.frame.size.width, editOverlay.frame.size.height)];
//                     }
//                     completion:^(BOOL finished){
//                         int handicapInteger = [[[appPDelegate.playersArray  objectAtIndex:editPlayer]objectForKey:@"Handicap"]intValue];
//                         [handicapIntegerPicker selectRow:handicapInteger inComponent:0 animated:YES];
//                         int handicapFraction = [[[appPDelegate.playersArray  objectAtIndex:indexPath.row]objectForKey:@"Handicap"]floatValue] *10 ;
//                         handicapFraction = handicapFraction - handicapInteger * 10;
//                         [handicapDecimalPicker selectRow:handicapFraction inComponent:0 animated:YES];
//                     }];
//    
//    pickedDivision =  [[[appPDelegate.playersArray objectAtIndex:editPlayer]objectForKey: @"Division"]intValue];
//    pickedHandicap = [[[appPDelegate.playersArray objectAtIndex:editPlayer]objectForKey:@"Handicap"]floatValue];
//    editedName =  [[appPDelegate.playersArray objectAtIndex:editPlayer]objectForKey:@"Name"];
//    playersTable.userInteractionEnabled = NO;
//    
//    nameField.text = [[appPDelegate.playersArray  objectAtIndex:editPlayer]objectForKey:@"Name"];
//    [sexPicker selectRow:[[[appPDelegate.playersArray  objectAtIndex:editPlayer]objectForKey:@"Division"]intValue] inComponent:0 animated:NO];
//    int handicapInteger = [[[appPDelegate.playersArray  objectAtIndex:editPlayer]objectForKey:@"Handicap"]intValue];
//    [handicapIntegerPicker selectRow:handicapInteger inComponent:0 animated:YES];
//    int handicapFraction = [[[appPDelegate.playersArray  objectAtIndex:indexPath.row]objectForKey:@"Handicap"]floatValue] *10 ;
//    handicapFraction = handicapFraction - handicapInteger * 10;
//    [handicapDecimalPicker selectRow:handicapFraction inComponent:0 animated:YES];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   // NSLog(@"---+++ Selected %i", indexPath.row);
    [[self delegate]dissmissPlayers:(int)indexPath.row];
    
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (appPDelegate.playersArray.count > 1) {
        return YES;
    } else {
        return NO;  // can't delete last item you bloody fool!
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [appPDelegate.playersArray    removeObjectAtIndex:indexPath.row];
       // NSLog(@"---+++ Deleting index %i of %i", indexPath.row, appPDelegate.playersArray.count);
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[self delegate]writeAllPlayers];
    }
}

#pragma mark - Edit player


-(void)editPlayer
{
    [editOverlay setFrame:CGRectMake(0, self.view.frame.size.height, editOverlay.frame.size.width, editOverlay.frame.size.height)];
    editOverlay.hidden = NO;
    
    float slideValue = 150.0;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
                     animations:^{
                         [self->editOverlay setFrame:CGRectMake(0, slideValue, self->editOverlay.frame.size.width, self->editOverlay.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         int handicapInteger = [[[appPDelegate.playersArray  objectAtIndex:editPlayer]objectForKey:@"Handicap"]intValue];
                         [self->handicapIntegerPicker selectRow:handicapInteger inComponent:0 animated:YES];
                         int handicapFraction = [[[appPDelegate.playersArray  objectAtIndex:editPlayer]objectForKey:@"Handicap"]floatValue] *10 ;
                         handicapFraction = handicapFraction - handicapInteger * 10;
                         [self->handicapDecimalPicker selectRow:handicapFraction inComponent:0 animated:YES];
                         [self->teesPicker selectRow:pickedPlayerTees inComponent:0 animated:YES];       // only tees Index 0 currently
                     }];
   // NSLog(@"---+++ Edit player %@",[appPDelegate.playersArray objectAtIndex:editPlayer] );
    pickedDivision =  [[[appPDelegate.playersArray objectAtIndex:editPlayer]objectForKey: @"Division"]intValue];
    pickedHandicap = [[[appPDelegate.playersArray objectAtIndex:editPlayer]objectForKey:@"Handicap"]floatValue];
   // if more than tees for this course, set to zero
    pickedPlayerTees = [[[appPDelegate.playersArray objectAtIndex:editPlayer]objectForKey:@"Tees"]intValue];
    [teesPicker reloadAllComponents];
    editedName =  [[appPDelegate.playersArray objectAtIndex:editPlayer]objectForKey:@"Name"];
    playersTable.userInteractionEnabled = NO;
    playersTable.alpha = 0.5;
    doneButton.userInteractionEnabled = NO;
    doneButton.alpha = 0.5;
    newPlayerButton.userInteractionEnabled = NO;
    newPlayerButton.alpha = 0.5;
    
    nameField.text = [[appPDelegate.playersArray  objectAtIndex:editPlayer]objectForKey:@"Name"];
    [sexPicker selectRow:[[[appPDelegate.playersArray  objectAtIndex:editPlayer]objectForKey:@"Division"]intValue] inComponent:0 animated:NO];
}

-(void)dissmissEditOvelay
{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:  UIViewAnimationOptionCurveEaseOut  // UIViewAnimationCurveEaseOut
                     animations:^{
                         [self->editOverlay setFrame:CGRectMake(0, 568, self->editOverlay.frame.size.width, self->editOverlay.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         self->editOverlay .hidden = YES;
                     }];
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
        case 1:
        case 2:
            return 44;
            break;
        case 3:
            return 25;
        default:
            return 44;
            break;
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (pickerView.tag) {
        case 0:     // Divisions
            return 2;
            break;
        case 1:     // Handicap
            return 45;
            break;
        case 2:     // decimal of handicap
            return 10;
            break;
        case 3:     // Tees  // this will be for the Current Course
            return [[[[appPDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedDivision]
                    objectForKey:@"Tees"]count];
            break;
        default:
            return 1;
            break;
    }
}
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
//    NSString *leadingSpaces = @" ";
//    if (row <9) {
//        leadingSpaces = @"";
//    }
    // Fill the label text here
    NSArray *teePColors;
    
    switch (pickerView.tag) {
        case 0:
            tView.font = [UIFont boldSystemFontOfSize:40.0];
            tView.text = [sexStrings objectAtIndex:row ];
            break;
        case 1:
            tView.font = [UIFont boldSystemFontOfSize:40.0];
            tView.textAlignment = NSTextAlignmentRight;
            tView.text = [NSString stringWithFormat:@" %i", (int)row ];
            break;
        case 2:
            tView.font = [UIFont boldSystemFontOfSize:40.0];
            tView.text = [NSString stringWithFormat:@".%i",(int)row ];
            break;
        case 3:
          //  tView.font = [UIFont boldSystemFontOfSize:40.0];
            tView.font = [UIFont boldSystemFontOfSize:20.0];
            tView.textAlignment = NSTextAlignmentCenter;

            teePColors = [[[[[appPDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedDivision]
                           objectForKey:@"Tees"] objectAtIndex:row]
                         objectForKey:@"TeeColor"];
            
            tView.textColor = [UIColor colorWithRed:[[teePColors objectAtIndex:0]floatValue]
                                              green:[[teePColors objectAtIndex:1]floatValue]
                                               blue:[[teePColors objectAtIndex:2]floatValue]
                                              alpha:1.0];
            
            tView.text = [[[[[appPDelegate.courseData objectForKey:@"Divisions"] objectAtIndex:pickedDivision]
                            objectForKey:@"Tees"] objectAtIndex:row]
                          objectForKey:@"Title"];
            break;
        default:
            break;
    }
    
    return tView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    float fracPortion =  fmodf(pickedHandicap, 1.0);
    float intPortion = floorf(pickedHandicap);
    float pickedRow = row;
    switch (pickerView.tag) {
        case 0:  // division
            pickedDivision = row;
            [teesPicker reloadAllComponents];
            break;
        case 1:  // handicap
            pickedHandicap = row + fracPortion;
           // [[appPDelegate.playersArray objectAtIndex:editPlayer]setObject:[NSNumber numberWithFloat:pickedHandicap] forKey:@"Handicap"];
            break;
        case 2:  //handicap
            pickedHandicap = intPortion +  pickedRow/10;
            break;
        case 3: // Tees
            pickedPlayerTees = row;
            break;
    }

}

- (IBAction)nameTouchDown:(id)sender {
        nameField.userInteractionEnabled = YES;
        [nameField becomeFirstResponder];
}

- (IBAction)nameEditDone:(id)sender {  // actualy every char in case user hits Done
    editedName = nameField.text;

}


- (IBAction)editCancelButton:(id)sender
{
    [self dissmissEditOvelay];
    playersTable.userInteractionEnabled = YES;
    playersTable.alpha = 1.0;
    doneButton.userInteractionEnabled = YES;
    doneButton.alpha = 1.0;
    newPlayerButton.userInteractionEnabled = YES;
    newPlayerButton.alpha = 1.0;
    [nameField resignFirstResponder];
}

- (IBAction)editDoneButton:(id)sender
{
    [[appPDelegate.playersArray objectAtIndex:editPlayer]setObject:[NSNumber numberWithInteger:pickedDivision] forKey:@"Division"];
    [[appPDelegate.playersArray objectAtIndex:editPlayer]setObject:[NSNumber numberWithFloat:pickedHandicap] forKey:@"Handicap"];
    //[[appPDelegate.playersArray objectAtIndex:editPlayer]setObject:[NSNumber numberWithInt:pickedPlayerTees] forKey:@"Tees"];
    [[appPDelegate.playersArray objectAtIndex:editPlayer]setObject:[NSNumber numberWithInt:(int)pickedPlayerTees] forKey:@"Tees"];    if (editedName.length == 0) editedName = @"??";
    [[appPDelegate.playersArray objectAtIndex:editPlayer]setObject:editedName forKey:@"Name"];
    NSLog(@"---+++ Player Data: %@", [appPDelegate.playersArray objectAtIndex:editPlayer]);
    [playersTable reloadData];
    playersTable.userInteractionEnabled = YES;
    playersTable.alpha = 1.0;
    doneButton.userInteractionEnabled = YES;
    doneButton.alpha = 1.0;
    newPlayerButton.userInteractionEnabled = YES;
    newPlayerButton.alpha = 1.0;
    [nameField resignFirstResponder];
    [self dissmissEditOvelay];
    [[self delegate]writeAllPlayers];
}



#pragma mark - View cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    appPDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sexStrings = [NSArray arrayWithObjects:@"🚹", @"🚺", NULL];
    newPlayerButton.layer.cornerRadius = 6.0;
    newPlayerButton.layer.borderWidth = 2.0;
    newPlayerButton.layer.masksToBounds = YES;
    newPlayerButton.layer.borderColor = [UIColor whiteColor].CGColor;
    doneButton.layer.cornerRadius = 6.0;
    doneButton.layer.borderWidth = 2.0;
    doneButton.layer.masksToBounds = YES;
    doneButton.layer.borderColor = [UIColor whiteColor].CGColor;
    editDone.layer.cornerRadius = 6.0;
    editDone.layer.borderWidth = 2.0;
    editDone.layer.masksToBounds = YES;
    editDone.layer.borderColor = [UIColor whiteColor].CGColor;
    editCancel.layer.cornerRadius = 6.0;
    editCancel.layer.borderWidth = 2.0;
    editCancel.layer.masksToBounds = YES;
    editCancel.layer.borderColor = [UIColor whiteColor].CGColor;
    playersTable.allowsMultipleSelectionDuringEditing = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    editOverlay.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
   // NSLog(@"---+++ Getting player %i", playerNumber);
}



@end
