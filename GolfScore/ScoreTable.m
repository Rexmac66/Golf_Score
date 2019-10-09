//
//  ScoreTable.m
//  GolfScore
//
//  Created by Rex McIntosh on 18/11/14.
//
//

#import <Foundation/Foundation.h>
#import "ScoreTable.h"


// #import "ViewController.h"

@interface ScoreTable  ()

@end

@implementation ScoreTable

int frontNineStrokes;
int frontNinePutts;
int frontNinePenalties;

int backNineStrokes;
int backNinePutts;
int backNinePenalties;

int doubleBogies;
int bogies;
int pars;
int birdies;
int eagles;

int frontNineStableford;
int backNineStableford;
int frontNineAdjGross;
int backNineAdjGross;
int gross;
//int adjGross;
int courseHandicap;
int handicapAccum;
int nettForHole;
int numberOfHolesPlayed;

@synthesize currentPlayer, playersGame, savedToCalendar;
@synthesize delegate = _delegate;


UISwipeGestureRecognizer *tableSwipeRightGesture;
UISwipeGestureRecognizer *tableSwipeLeftGesture;

UIRefreshControl *pullDown;

NSDictionary *scoresTotals;

AppDelegate *appSDelegate;

#pragma mark - table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (savedToCalendar ) {
       // NSLog(@"---+++ Don't show Save");
        return 23;
    } else {
       // NSLog(@"---+++ Show Save button");
        return 24;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *parStrokeHandicap;
    
    static NSString *CellIdentifier;
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"titleCell";
            break;
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:
        case 18:
            CellIdentifier = @"plainCell";
            break;
        case 19:
        case 20:
        case 21:
            CellIdentifier = @"borderCell";
            break;
        case 22:
            CellIdentifier = @"SatsCell"; // @"GrossCell";
            break;
        case 23:
            CellIdentifier = @"saveCell";
            break;
        default:
            break;
    }
  //  if (indexPath.row == 0){
  //       CellIdentifier = @"titleCell";
  //  } else if (indexPath.row >= 19) {
  //      CellIdentifier = @"borderCell";
  //  } else {
  //      CellIdentifier = @"plainCell";
  //  }
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        if (indexPath.row == 0 || indexPath.row == 23) { // Big type
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        } else {
            cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    if (indexPath.row == 23) { // save
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.row >= 19 && indexPath.row != 23 ){
        switch (currentPlayer) {
            case 0:
                cell.layer.borderColor = [UIColor redColor].CGColor;
                break;
            case 1:
                cell.layer.borderColor = [UIColor orangeColor].CGColor;
                break;
            case 2:
                cell.layer.borderColor = [UIColor yellowColor].CGColor;
                break;
            case 3:
                cell.layer.borderColor = [UIColor greenColor].CGColor;
                break;
            case 4:
                cell.layer.borderColor = [UIColor blueColor].CGColor;
                break;
            default:
                break;
        }
       //cell.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.layer.borderWidth = 2.0;
        cell.layer.cornerRadius = 10.0;
        cell.layer.masksToBounds = YES;
    }
    if (indexPath.row == 0) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:30];
        cell.textLabel.text = [playersGame objectForKey:@"Name"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    } else if (indexPath.row == 19) { //  Front 9
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.text = [NSString  stringWithFormat:@" Front 9:            %i(%i) strokes", frontNineStrokes, frontNineAdjGross];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        cell.detailTextLabel.text = [NSString  stringWithFormat:@" Putts: %i       Penalties: %i        S/ford: %i", frontNinePutts, frontNinePenalties, frontNineStableford ];
    } else if (indexPath.row == 20) {  // Back 9
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.text = [NSString  stringWithFormat:@" Back 9:           %i(%i) strokes", backNineStrokes, backNineAdjGross];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        cell.detailTextLabel.text = [NSString  stringWithFormat:@" Putts: %i       Penalties: %i        S/ford: %i", backNinePutts, backNinePenalties, backNineStableford];
    } else if (indexPath.row == 21){  // Round
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.text = [NSString  stringWithFormat:@" Round:           %i(%i) strokes", frontNineStrokes + backNineStrokes, frontNineAdjGross + backNineAdjGross];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        cell.detailTextLabel.text = [NSString  stringWithFormat:@" Putts: %i       Penalties: %i        S/ford: %i", backNinePutts+ frontNinePutts, backNinePenalties + frontNinePenalties, frontNineStableford + backNineStableford];
    } else if (indexPath.row == 22) {  // Gross  // stats Cell
       // UILabel *curlabel = cell.textLabel
        UILabel *statsLabel;
         statsLabel = (UILabel *)[cell viewWithTag:6];
        if (numberOfHolesPlayed < 18) {
            statsLabel.text =       [NSString stringWithFormat:@" Crse H/cap:%i (%i holes:%i)", courseHandicap, numberOfHolesPlayed, handicapAccum] ;
        } else {
            statsLabel.text =       [NSString stringWithFormat:@" Crse H/cap:%i", handicapAccum] ;
        }
        //cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
        statsLabel = (UILabel *)[cell viewWithTag:7];
        int Nett = gross - handicapAccum;
        int adjNett = frontNineAdjGross + backNineAdjGross - handicapAccum;
        statsLabel.text = [NSString stringWithFormat:@" Nett:%i(%i)", Nett, adjNett ];
        
        statsLabel = [cell viewWithTag:1];
        statsLabel.text = [NSString stringWithFormat:@"%i", eagles];
        statsLabel = [cell viewWithTag:2];
        statsLabel.text = [NSString stringWithFormat:@"%i", birdies];
        statsLabel = [cell viewWithTag:3];
        statsLabel.text = [NSString stringWithFormat:@"%i", pars];
        statsLabel = [cell viewWithTag:4];
        statsLabel.text = [NSString stringWithFormat:@"%i", bogies];
        statsLabel = [cell viewWithTag:5];
        statsLabel.text = [NSString stringWithFormat:@"%i", doubleBogies];
        statsLabel = (UILabel *)[cell viewWithTag:12];
        statsLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        statsLabel.layer.borderWidth = 1.0;
        
        NSLog(@"---+++ Course Handicap %i", courseHandicap);
       // NSLog(@"---+++ Eagles:%i, Birdies:%i, Pars:%i, Bogies:%i, DblBogies:%i", eagles, birdies, pars, bogies, doubleBogies);
    //[NSString stringWithFormat:@"Gross:%i, AdjGross: %i Handicap:%i \n Nett:%i Adjnett:%i", gross, adjGross, handicapAccum, gross - handicapAccum, adjGross - handicapAccum];
    } else if (indexPath.row == 23){   // Save
         cell.textLabel.font = [UIFont boldSystemFontOfSize:30];
        cell.textLabel.text = @"Save to Calendar";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    } else{
        
        int strokeNumber =  [[[[playersGame objectForKey:@"Scores"]objectAtIndex:indexPath.row-1]objectForKey:@"Strokes"]intValue];
        int puttNumber = [[[[playersGame objectForKey:@"Scores"]objectAtIndex:indexPath.row-1]objectForKey:@"Putts"]intValue];
        int penaltyNumber = [[[[playersGame objectForKey:@"Scores"]objectAtIndex:indexPath.row-1]objectForKey:@"Penalties"]intValue];
        int stablefordNumber = [[[[playersGame objectForKey:@"Scores"]objectAtIndex:indexPath.row-1]objectForKey:@"Stableford"]intValue];
        int totalStrokes = strokeNumber + puttNumber + penaltyNumber;

       parStrokeHandicap = [appSDelegate handicapForPlayer:currentPlayer holeNumber:(int)(indexPath.row-1)];
        
        int parForHole = [[parStrokeHandicap objectForKey:@"Par"]intValue];
      //  NSString *formated = [NSString stringWithFormat:@"    %i", indexPath.row];
      //  NSRange intRange = NSMakeRange(formated.length-3, 3);
        //NSLog(@" ---- #%@",[formated substringWithRange:intRange] );
      //  NSLog(@"---%3i", indexPath.row);
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
       cell.textLabel.text = [NSString  stringWithFormat:      @" #%2i    Par:%i              %2i strokes",(int)indexPath.row, parForHole, totalStrokes] ;
        // cell.textLabel.text = [NSString  stringWithFormat:      @" #%@                    %i strokes",[formated substringWithRange:intRange] , totalStrokes] ;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        cell.detailTextLabel.text = [NSString  stringWithFormat:@" Putts: %i       Penalties: %i       S/ford: %i", puttNumber, penaltyNumber, stablefordNumber];

        if (totalStrokes >0 ){
          //  NSLog(@"---+++ %i %i", indexPath.row, totalStrokes - parForHole);
            switch (totalStrokes - parForHole) {
                case -2:  // Eagle or better
                case -3:
                case -4:
                    cell.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
                    break;
                case -1:
                    cell.backgroundColor = [UIColor redColor];
                    break;
                case 0:  // Par
                    cell.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
                    break;
                case 1:  // Bogie
                    cell.backgroundColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.8 alpha:1.0];
                    break;
                default: // Double Bogie
                    cell.backgroundColor = [UIColor blackColor];
                    break;
            }
        }
    }
    return cell;

}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"---+++ Did scroll to top" );
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat theHeight;
    if (indexPath.row == 22) {
        theHeight = 120;
    } else {
        theHeight = 55;
    }
    return theHeight;
}

#pragma mark - View cycle

-(void)viewDidLoad
{
    appSDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    tableSwipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    tableSwipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [scoreTableView addGestureRecognizer:tableSwipeRightGesture];
    tableSwipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    tableSwipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [scoreTableView addGestureRecognizer:tableSwipeLeftGesture];
    
    // Initialize the refresh control.
    pullDown = [[UIRefreshControl alloc] init];
   // pullDown.backgroundColor = [UIColor purpleColor];
    pullDown.tintColor = [UIColor blackColor];
    pullDown.attributedTitle = [[NSAttributedString alloc] initWithString:@"Back"];
    [pullDown addTarget:self
                 action:@selector(pullDown:)
                  forControlEvents:UIControlEventValueChanged];
    [scoreTableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SatsCell"];// Load once iOS5

   // [scoreTableView addSubview:pullDown];
}

- (void)pullDown:(UIRefreshControl *)refreshControl {
    [pullDown endRefreshing];
    [[self delegate]tablePullDown];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"---+++ Did select row: %i", indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 23) {
        [[self delegate]addToCalendar];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scoreTableView.contentOffset.y < -75) {
        scoreTableView.contentOffset = CGPointMake(0.0, 0.0);
        [[self delegate]tablePullDown];
    }
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)sender
{
    NSLog(@"---+++ Swipe Right!");
   // [[self delegate]tablePullDown];
    
}
-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)sender
{
    NSLog(@"---+++ Swipe Left!");
    // [[self delegate]tablePullDown];
    
}

-(void)reloadTable
{
    [scoreTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:22 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [scoreTableView reloadData];

}

-(void)viewDidAppear:(BOOL)animated
{

    [scoreTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:21 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [scoreTableView setDelegate:self];
    [scoreTableView setDataSource:self];
    frontNineStrokes = 0;
    frontNinePutts = 0;
    frontNinePenalties = 0;
    backNineStrokes = 0;
    backNinePutts = 0;
    backNinePenalties = 0;
    frontNineStableford = 0;
    backNineStableford = 0;
    frontNineAdjGross = 0;
    backNineAdjGross = 0;
    doubleBogies = 0;
    bogies = 0;
    pars = 0;
    birdies = 0;
    eagles = 0;
    gross = 0;
    numberOfHolesPlayed = 0;
   // adjGross = 0;
    handicapAccum = 0;
    courseHandicap = 0;
    nettForHole = 0;
    NSDictionary *parStrokeHandicap; // = [appDelegate handicapForPlayer:playerNumber holeNumber:holeNum ];
   // courseHandicapInt = [[parStrokeHandicap objectForKey:@"Handicap"]floatValue];
   // strokeNum = [parStrokeHandicap objectForKey:@"Stroke"];
   // parNum = [parStrokeHandicap objectForKey:@"Par"];
    
    // NSLog(@"---+++ Game: %@",playersGame);
    
    for (int holeCtr = 0; holeCtr < 18; holeCtr++) {
        int strokeNumber =  [[[[playersGame objectForKey:@"Scores"]objectAtIndex:holeCtr]objectForKey:@"Strokes"]intValue];
        int puttNumber = [[[[playersGame objectForKey:@"Scores"]objectAtIndex:holeCtr]objectForKey:@"Putts"]intValue];
        int penaltyNumber = [[[[playersGame objectForKey:@"Scores"]objectAtIndex:holeCtr]objectForKey:@"Penalties"]intValue];
        int stablefordNumber = [[[[playersGame objectForKey:@"Scores"]objectAtIndex:holeCtr]objectForKey:@"Stableford"]intValue];
        int totalStrokes = strokeNumber + puttNumber + penaltyNumber;
        // NSLog(@"---+++ Hole: %i Stroke:%i", holeCtr, strokeNumber );
       
        int stableford;
        int handicapForHole;
        int parForHole;
        
        parStrokeHandicap = [appSDelegate handicapForPlayer:currentPlayer holeNumber:holeCtr];
        courseHandicap +=  [[parStrokeHandicap objectForKey:@"Handicap"]intValue];
        NSLog(@"---+++ Course Handicap:%i %@", courseHandicap, parStrokeHandicap);
        if (holeCtr <9) {
            frontNineStrokes += totalStrokes ;
            frontNinePutts   += puttNumber;
            frontNinePenalties  += penaltyNumber;
            frontNineStableford += stablefordNumber;
            if (strokeNumber > 0 ){
                // parStrokeHandicap = [appSDelegate handicapForPlayer:currentPlayer holeNumber:holeCtr];
                numberOfHolesPlayed ++;
                gross += totalStrokes;
                 handicapForHole = [[parStrokeHandicap objectForKey:@"Handicap"]intValue];
                 stableford = [[parStrokeHandicap objectForKey:@"Par"]intValue] + handicapForHole - totalStrokes + 2;
                 parForHole = [[parStrokeHandicap objectForKey:@"Par"]intValue];
                nettForHole = totalStrokes - handicapForHole;
                if (stableford <= 0) {
                    frontNineAdjGross += totalStrokes + stableford;
                } else {
                    frontNineAdjGross += totalStrokes;
                }
                handicapAccum += handicapForHole;
                switch (totalStrokes - parForHole) {
                    case -2:  // Eagle or better
                    case -3:
                    case -4:
                        eagles++ ;
                        break;
                    case -1:
                        birdies++ ;
                        break;
                    case 0:  // Par
                        pars++ ;
                        break;
                    case 1:  // Bogie
                        bogies++ ;
                        break;
                    default: // Double Bogie
                        doubleBogies ++;
                        break;
                }
                // NSLog(@"---+++ Hole: %i, handicap:%i netForHole:%i", holeCtr+1, handicapForHole, nettForHole);
            }
        } else {
            backNineStrokes = (backNineStrokes + strokeNumber + puttNumber + penaltyNumber);
            backNinePutts   += puttNumber;
            backNinePenalties  += penaltyNumber;
            backNineStableford  += stablefordNumber;
            if (strokeNumber > 0 ){
                // parStrokeHandicap = [appSDelegate handicapForPlayer:currentPlayer holeNumber:holeCtr];
                numberOfHolesPlayed ++;
                gross += totalStrokes;
                 handicapForHole = [[parStrokeHandicap objectForKey:@"Handicap"]intValue];
                 stableford = [[parStrokeHandicap objectForKey:@"Par"]intValue] + handicapForHole - totalStrokes + 2;
                 parForHole = [[parStrokeHandicap objectForKey:@"Par"]intValue];
                nettForHole = totalStrokes - handicapForHole;
                if (stableford <= 0) {
                    backNineAdjGross += totalStrokes + stableford;
                } else {
                    backNineAdjGross += totalStrokes;
                }
                handicapAccum += handicapForHole;
                switch (totalStrokes - parForHole) {
                    case -2:  // Eagle or better
                    case -3:
                    case -4:
                        eagles++ ;
                        break;
                    case -1:
                        birdies++ ;
                        break;
                    case 0:  // Par
                        pars++ ;
                        break;
                    case 1:  // Bogie
                        bogies++ ;
                        break;
                    default: // Double Bogie
                        doubleBogies ++;
                        break;
                }
                // NSLog(@"---+++ Hole: %i, handicap:%i netForHole:%i", holeCtr+1, handicapForHole, nettForHole);
            }
        }
        
        

        
//        if (strokeNumber > 0 ){
//           parStrokeHandicap = [appSDelegate handicapForPlayer:currentPlayer holeNumber:holeCtr];
//            numberOfHolesPlayed ++;
//            gross += totalStrokes;
//            int handicapForHole = [[parStrokeHandicap objectForKey:@"Handicap"]intValue];
//            int stableford = [[parStrokeHandicap objectForKey:@"Par"]intValue] + handicapForHole - totalStrokes + 2;
//            nettForHole = totalStrokes - handicapForHole;
//            if (stableford <= 0) {
//                adjGross += totalStrokes + stableford;
//            } else {
//                adjGross += totalStrokes;
//            
//            }
//            handicapAccum += handicapForHole;
//           // NSLog(@"---+++ Hole: %i, handicap:%i netForHole:%i", holeCtr+1, handicapForHole, nettForHole);
//        }
    }
   
    
   // NSLog(@"---+++  Gross:%i, AdjGross: %i Handicap:%i Nett:%i Adjnett:%i", gross, adjGross, stablefordAccum, gross - stablefordAccum, adjGross - stablefordAccum);
    
   // NSLog(@"---+++ Gross:%i, Handicap:%i, Nett:%i", adjGross, courseHandicapInt, adjGross - courseHandicapInt );
    
    [scoreTableView reloadData];
    
}




@end

