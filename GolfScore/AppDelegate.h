//
//  AppDelegate.h
//  GolfScore
//
//  Created by Rex McIntosh on 9/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"
#import "ScoreTable.h"
#import "Courses.h"
#import "Players.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, swipes, scoreSwipes, CLLocationManagerDelegate, coursesActions>
{
    NSMutableDictionary  *courseData;
    NSMutableArray *courseNames;
    NSMutableArray *playersArray;
    CLLocationManager *locationManager;

}

-(void)writeCurrentCourse;
-(void)getCourse:(NSString *)courseName;
-(void)getAllCourses;

-(NSDictionary*)handicapForPlayer:(int)playerNumber holeNumber:(int)holeNumber;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableDictionary  *courseData;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) NSMutableArray *playersArray;
@property (strong, nonatomic) NSMutableArray *courseNames;

@end
