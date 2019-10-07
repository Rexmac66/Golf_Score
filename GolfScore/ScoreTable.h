//
//  ScoreTable.h
//  GolfScore
//
//  Created by Rex McIntosh on 18/11/14.
//
//

#import <UIKit/UIKit.h>
//#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>

@protocol scoreSwipes <NSObject>
@required
-(void)tablePullDown;

@optional
-(void)addToCalendar;
-(void)test;

@end

#import "AppDelegate.h"

@interface ScoreTable : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
{
    
    int currentplayer;
    BOOL savedToCalendar;
    NSMutableDictionary *playersGame;
    
    id <scoreSwipes> delegate;
    
    IBOutlet UITableView *scoreTableView;
}
-(void)reloadTable;

@property int currentPlayer;
@property BOOL savedToCalendar;
@property  NSMutableDictionary *playersGame;
@property (assign) id delegate;

@end
