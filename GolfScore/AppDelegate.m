//
//  AppDelegate.m
//  GolfScore
//
//  Created by Rex McIntosh on 9/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Calendar.h"

// #define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
// #define IS_OS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

//#import "ViewController.h"
//#import "ScoreTable.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize courseData;
@synthesize playersArray;
@synthesize courseNames;
@synthesize locationManager;

NSMutableDictionary *userData;

ViewController *viewController1;
ViewController *viewController2;
ViewController *viewController3;
ViewController *viewController4;
ViewController *viewController5;

ScoreTable *scoretable;
Courses *courses;  // view and controller
Players *players;  // view and controller

UIView *flippedToView;

NSTimer *GPSoffTimer;
NSTimer *GPSHeartBeat;

const float GPSoffDelay = 1200.0; // 1200 = 20 mins

//self.viewController2;
int numberOfPlayers;  //
int currentHoleNumber; // base 0
int currentplayerNumber; // base 0
NSArray *viewControllerViews;
NSArray *viewControllers;

NSString *locality;
NSString *subLocality;

CLLocation *zeroLocation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
//    _viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
//    [self getSavedData];
//    _viewController.score = [[userData objectForKey:@"Score"]intValue];
//    //_viewController.score = 0;
//    self.window.rootViewController = self.viewController;
//    [self.window makeKeyAndVisible];
//    [_viewController showScore];

    [self getSavedData];  // Game data includes players and current course
    if (courseData == nil) {
        [self loadCourse];
    }

    [self getAllPlayers];
    
    
    zeroLocation = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"OneCourse" ofType:@"json"];
//    
//    // Load the file into an NSData object called JSONData
//    
//    NSError *error = nil;
//    
//    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
//    
//    // Create an Objective-C object from JSON Data
//    
//    //    id JSONObject = [NSJSONSerialization
//    //                     JSONObjectWithData:JSONData
//    //                     options:kNilOptions     // NSJSONReadingAllowFragments
//    //                     error:&error];
//    
//    courseData = [NSJSONSerialization JSONObjectWithData:JSONData
//                                                         options:NSJSONReadingMutableContainers
//                                                           error:&error];
//    
//    //  NSLog(@"---+++ JSON: \n%@", json);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    viewController1 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    viewController1.score = [[userData objectForKey:@"Score"]intValue];
    viewController1.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:0];
    viewController1.playerNumber = 0;
    [viewController1 setDelegate:self];
   // viewController1.preferredStatusBarStyle
    
    viewController2 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    viewController2.score = [[userData objectForKey:@"Score"]intValue];
    viewController2.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:1];
    viewController2.playerNumber = 1;
    [viewController2 setDelegate:self];
     viewController2.view.frame = screenRect;

    viewController3 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    viewController3.score = [[userData objectForKey:@"Score"]intValue];
    viewController3.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:2];
    viewController3.playerNumber = 2;
    [viewController3 setDelegate:self];
    viewController3.view.frame = screenRect;
    
    viewController4 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    viewController4.score = [[userData objectForKey:@"Score"]intValue];
    viewController4.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:3];
    viewController4.playerNumber = 3;
    [viewController4 setDelegate:self];
    viewController4.view.frame = screenRect;
    
   // viewController5 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
   // viewController5.score = [[userData objectForKey:@"Score"]intValue];
   // viewController5.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:4];
   // viewController5.playerNumber = 4;
   // [viewController5 setDelegate:self];
   // viewController5.view.frame = screenRect;
    
    viewControllerViews = [NSArray arrayWithObjects:viewController1.view, viewController2.view, viewController3.view, viewController4.view,  nil];
    viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController3, viewController4, nil];
    
    [self setHoleNumbersForAllViews];
    
    scoretable = [[ScoreTable alloc]initWithNibName:@"ScoreTable" bundle:nil];
    [scoretable setDelegate:self];
    scoretable.view.frame = screenRect;
    scoretable.savedToCalendar = [[userData objectForKey:@"SavedRound"]boolValue];
    
    courses = [[Courses alloc]initWithNibName:@"Courses" bundle:nil];
    courses.view.frame = screenRect;
    [courses setDelegate:self];
    
    players = [[Players alloc]initWithNibName:@"PlayersTable" bundle:nil];
    players.view.frame = screenRect;
    [players setDelegate:self];
    
    self.window.rootViewController = viewController1;
    [self setCustomHole:0];
    [self.window makeKeyAndVisible];

    // iO9
     [application setStatusBarStyle:UIStatusBarStyleLightContent]; // AND set status bar to None in IB
    // AND in -Info.plist:   set UIViewControllerBasedStatusBarAppearance = NO

    // This means status bar appearance is global, but XCode 7 brings up 3 errors: CGContextSaveGState: invalid context 0x0. If you want to see the backtrace 
    // else needs to be set in each view controller http://www.ryadel.com/en/xcode-set-status-bar-style-and-color-in-objective-c/ 
    
   // NSLog(@"---+++ Did Finish Lauching");
    [self startOrRestartLocationManager];

    // ------ Font list ---------------
    /*
     NSArray *fontfamilies = [[NSArray alloc] initWithArray:[UIFont familyNames]];
     NSLog(@"---+++ font families %@", fontfamilies);
    
     for (NSString *family in [UIFont familyNames])
     {
         printf("%s\n",[family UTF8String]);
            for (NSString *font in [UIFont fontNamesForFamilyName:family])
            {
                //NSLog(@"\t%@", font);
                printf("\t%s\n", [font UTF8String]);
            }
     }
    */
    
  // [self writeBlankJSON];
  //  [self writeCurrentCourse];
     
    return YES;
}

-(void)loadCourse // load current course, else
{
     [self getAllCourses];
   // NSLog(@"---+++ Found: %i Coures", courses.count);
    if (courseNames.count == 0){   // no courses so load Martinborough and copy it to documents directory
        NSLog(@"---+++ Copy Martinborough course from Bundle");
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Martinborough" ofType:@"JSON"];
        // Load the file into an NSData object called JSONData
        NSError *error = nil;
        NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
        
        // Create an Objective-C object from JSON Data
        
        courseData = [NSJSONSerialization JSONObjectWithData:JSONData
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
        [userData setObject:[courseData objectForKey:@"Name"] forKey:@"CurrentCourse"];
        [self writeCurrentCourse];  // write it to directory
       [self saveData];   // and save user data -- This is the Case where app is terminated before a save (i.e. using XCode)
    } else {  // load previous course
        NSString *currentCourse = [userData objectForKey:@"CurrentCourse"];
        if (currentCourse.length > 0) { // load current course
           // NSLog(@"---+++ Courses: %@",courses);
            NSLog(@"---+++ Current course: %@", currentCourse);
            [self getCourse:currentCourse];
        } else {
            NSLog(@"---+++ No Course Name ERROR!!!"); 
        }
    }
}

-(void)getAllPlayers // startup players, if not in Docs directory, copy from bundle
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"Players"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exists = [fm fileExistsAtPath:filePath];
    // exists = NO;  // reload the plist
    if (exists) {
        playersArray = [NSMutableArray arrayWithContentsOfFile:filePath];
       // NSLog(@"---+++ Got players list:\n%@", playersArray);
        NSLog(@"---+++ Got players list");
    } else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Players" ofType:@"plist"];
        playersArray = [NSMutableArray arrayWithContentsOfFile:path];
      //  NSLog(@"---+++ Copy the players plist");
        [playersArray writeToFile:filePath atomically:NO];
        for (int pointer = 0; pointer < playersArray.count; pointer++) {
            NSString *playerName = [[playersArray objectAtIndex:pointer]objectForKey:@"Name"];
            [[[userData objectForKey:@"Game"]objectAtIndex:pointer] setObject:playerName forKey:@"Name"];
            NSNumber *division = [[playersArray objectAtIndex:pointer]objectForKey:@"Division"];
            [[[userData objectForKey:@"Game"]objectAtIndex:pointer] setObject:division forKey:@"Division"];
            NSNumber *handicap = [[playersArray objectAtIndex:pointer]objectForKey:@"Handicap"];
            [[[userData objectForKey:@"Game"]objectAtIndex:pointer] setObject:handicap forKey:@"Handicap"];
            [self saveData];
        }
        
    }

}

-(void)writeAllPlayers
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"Players"];
    [playersArray writeToFile:filePath atomically:NO];
}

#pragma mark -  handicap and Stableford Calculations

-(NSDictionary*)handicapForPlayer:(int)playerNumber holeNumber:(int)holeNumber
{

    NSDictionary *playersGame = [[userData objectForKey:@"Game"]objectAtIndex:playerNumber];
    
    NSNumber *parNum =  [[[[[[courseData objectForKey:@"Holes"]objectAtIndex:holeNumber]objectForKey:@"Divisions"]
                 objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
               objectForKey:@"Par"];
    
    NSNumber *strokeNum =  [[[[[[courseData objectForKey:@"Holes"]objectAtIndex:holeNumber]objectForKey:@"Divisions"]
                    objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                   objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
                  objectForKey:@"Stroke"];
    
    
   // float playersHandicapIndex = [[[[userData objectForKey:@"Game"]objectAtIndex:currentplayerNumber]objectForKey:@"Handicap"]floatValue];
    float playersHandicapIndex =  [[playersGame objectForKey:@"Handicap"]floatValue];
    float slope = [[[[[[courseData objectForKey:@"Divisions"] objectAtIndex:[[playersGame objectForKey:@"Division"]intValue]]
                      objectForKey:@"Tees"] objectAtIndex:[[playersGame objectForKey:@"Tees"]intValue]]
                    objectForKey:@"Slope"]floatValue];
    float courseHandicap = roundf(playersHandicapIndex * (slope/113.0));
    float courseHandicapInt  =  floorf(courseHandicap /18.0);
    float handicapModulo = fmodf(courseHandicap, 18.0);
    
    if (handicapModulo >= [strokeNum floatValue]) {
        courseHandicapInt++ ;
    }
    NSDictionary *parStrokeHandicap = [NSDictionary dictionaryWithObjectsAndKeys:
                                       parNum,  @"Par",
                                       strokeNum, @"Stroke",
                                       [NSNumber numberWithInt:courseHandicapInt],  @"Handicap",
                                       nil];
    return parStrokeHandicap ;
    
}



#pragma mark - Swipes

-(void)swipeD:(int)playerViewNumber
{
   //  NSLog(@"---+++ Delegate Swipe Down %i", playerViewNumber);
    // NSLog(@"---+++ Location: %@", [self deviceLocation]);
    //    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    //    [geocoder reverseGeocodeLocation:locationManager.location
    //                   completionHandler:^(NSArray *placemarks, NSError *error) {
    //                       NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
    //
    //                       if (error){
    //                           NSLog(@"Geocode failed with error: %@", error);
    //                           return;
    //
    //                       }
    //
    //                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
    //
    //                       NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
    //                       NSLog(@"placemark.country %@",placemark.country);
    //                       NSLog(@"placemark.postalCode %@",placemark.postalCode);
    //                       NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
    //                       NSLog(@"placemark.locality %@",placemark.locality);
    //                       NSLog(@"placemark.subLocality %@",placemark.subLocality);
    //                       NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
    //                       
    //                   }];
}

-(void)swipeL:(int)playerViewNumber // flip to higher numbered player
{
    NSLog(@"---+++ Delegate Swipe Left %i", playerViewNumber);
    if (numberOfPlayers == 1){
        return;
    }
    int toPlayerNumber = (playerViewNumber +1) % numberOfPlayers; // loops to Zero
   // NSLog(@"---+++ flip Left from view: %i to view: %i", playerViewNumber, toPlayerNumber);
    
    [UIView transitionFromView:[viewControllerViews objectAtIndex:playerViewNumber] toView:[viewControllerViews objectAtIndex:toPlayerNumber]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:NULL];
    currentplayerNumber = toPlayerNumber;
    
//    UIView *fromView;
//    UIView *toView;
//    switch (playerViewNumber) {
//        case 0:
//            fromView = viewController1.view;
//            toView = viewController2.view;
//            break;
//        case 1:
//            fromView = viewController2.view;
//            if (playerViewNumber == numberOfPlayers-1){
//                toView = viewController1.view;
//            } else {
//                toView = viewController3.view;
//            }
//          //  toView = viewController3.view;
//            break;
//        case 2:
//            fromView = viewController3.view;
//            if (playerViewNumber == numberOfPlayers-1){
//                toView = viewController1.view;
//            } else {
//                toView = viewController4.view;
//            }
//            break;
//        case 3:
//            fromView = viewController4.view;
//            if (playerViewNumber == numberOfPlayers-1){
//                toView = viewController1.view;
//            } else {
//                toView = viewController5.view;
//            }
//            break;
//        case 4:
//            fromView = viewController5.view;
//            toView = viewController1.view;
//
//            break;
//        default:
//            break;
//    }
//    flippedToView = toView;
//    [UIView transitionFromView:fromView toView:toView
//                      duration:0.5
//                       options:UIViewAnimationOptionTransitionFlipFromRight
//                    completion:NULL];
}

//-(void)resetToView1
//{
//  //  UIView *fromView = self.window.rootViewController.view;
//    UIView *toView = viewController1.view;
//    if (toView != flippedToView) {
//    [UIView transitionFromView:flippedToView toView:toView
//                      duration:0.5
//                       options:UIViewAnimationOptionTransitionFlipFromRight
//                    completion:NULL];
//    }
//}

-(void)flipToViewN: (int)playerNumber // flip to any view number 'n'
{
    if (currentplayerNumber != playerNumber) {
        [UIView transitionFromView:[viewControllerViews objectAtIndex:currentplayerNumber] toView:[viewControllerViews objectAtIndex:playerNumber]
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        completion:NULL];
        currentplayerNumber = playerNumber;
    }
}

-(void)swipeR:(int)playerViewNumber
{
    if (numberOfPlayers == 1){
        return;
    }
    // NSLog(@"---+++ Delegate Swipe Right %i", playerViewNumber);
    int toPlayerNumber = (playerViewNumber -1);
    if (toPlayerNumber < 0){
        toPlayerNumber = numberOfPlayers -1;
    }
   // NSLog(@"---+++ flip Right from player %i to player %i", playerViewNumber, toPlayerNumber);
    [UIView transitionFromView:[viewControllerViews objectAtIndex:playerViewNumber] toView:[viewControllerViews objectAtIndex:toPlayerNumber]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:NULL];
    
    currentplayerNumber = toPlayerNumber;
    
//    UIView *fromView;
//    UIView *toView;
//    switch (playerViewNumber) {
//        case 0:
//            fromView = viewController1.view;
//            switch (numberOfPlayers) {
//                case 1:
//                   // toView = viewController1.view; // can't transition to self!
//                    break;
//                case 2:
//                    toView = viewController2.view;
//                    break;
//                case 3:
//                    toView = viewController3.view;
//                    break;
//                case 4:
//                    toView = viewController4.view;
//                    break;
//                case 5:
//                    toView = viewController5.view;
//                    break;
//                default:
//                    break;
//            }
//            break;
//        case 1:
//            fromView = viewController2.view;
//            toView = viewController1.view;
//            break;
//        case 2:
//            fromView = viewController3.view;
//            toView = viewController2.view;
//            break;
//        case 3:
//            fromView = viewController4.view;
//            toView = viewController3.view;
//            break;
//        case 4:
//            fromView = viewController5.view;
//            toView = viewController4.view;
//            break;
//        default:
//            break;
//    }
//    flippedToView = toView;
//    [UIView transitionFromView:fromView toView:toView
//                      duration:0.5
//                       options:UIViewAnimationOptionTransitionFlipFromLeft
//                    completion:NULL];
}

-(void)listofPlayers{
    players.playerNumber = currentplayerNumber;
    [UIView transitionFromView:[viewControllerViews objectAtIndex:currentplayerNumber] toView: players.view
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCurlUp
                    completion:NULL];
}


-(void)swipeU:(int)playerViewNumber
{
   // NSLog(@"---+++ Delegate Swipe Up %i  %i", playerViewNumber, currentplayerNumber);
   // NSLog(@"---+++ User data \n%@", userData);
    scoretable.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:currentplayerNumber];
    scoretable.savedToCalendar = [[userData objectForKey:@"SavedRound"]boolValue]; // display or not the save Button
    scoretable.currentPlayer = currentplayerNumber;
    [UIView transitionFromView:[viewControllerViews objectAtIndex:currentplayerNumber] toView: scoretable.view
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCurlUp
                    completion:NULL];
    
}

//-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//     NSLog(@"---!!! Location: %.3f %.3f +/-%.0fm Alt: %.0f +/-%.1f Speed: %.1f, %@",newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.horizontalAccuracy, newLocation.altitude, newLocation.verticalAccuracy, newLocation.speed, newLocation.timestamp);
//    // how old is this location?
//     NSLog(@"---!!! description: %@", newLocation.description ); // shortform
//    NSTimeInterval t = [[newLocation timestamp] timeIntervalSinceNow];
//    if (t < -180) {     // if older than 180 seconds, discard further processing
//        return;
//    }
//    if (newLocation.horizontalAccuracy < 100) {
//        [self updateLocationForAllViews:newLocation];
//    }
//    
//}

-(void)dissmissCourses:(NSString *)courseName
{
    NSLog(@"---+++ Change course to: %@", courseName);
    [self getCourse:courseName];
    NSLog(@"---+++ Got course data: %@", [courseData objectForKey:@"Name"]);
    [self setCustomHole:0];
    [UIView transitionFromView:courses.view toView: [viewControllerViews objectAtIndex:currentplayerNumber]
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCurlDown
                    completion:NULL];
}

-(void)dissmissPlayers:(int)selectedPlayer // number of player in array
{
   // NSLog(@"---+++ Current:%i selected Player:%i",currentplayerNumber, selectedPlayer );
    if (selectedPlayer >= 0 ){        // -1 no Players selected, just refresh all
        switch (currentplayerNumber) {
            case 0:
               [[[userData objectForKey:@"Game"]objectAtIndex:0]setObject:[NSNumber numberWithInt:selectedPlayer] forKey:@"PlayerPointer"];  // saves pointer to Player in PLayersArray
                viewController1.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:0];
               // NSLog(@"---+++ Users Data 0 %@", [[userData objectForKey:@"Game"]objectAtIndex:0]);
                break;
            case 1:
               [[[userData objectForKey:@"Game"]objectAtIndex:1]setObject:[NSNumber numberWithInt:selectedPlayer] forKey:@"PlayerPointer"];
                viewController2.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:1];
                break;
            case 2:
               [[[userData objectForKey:@"Game"]objectAtIndex:2]setObject:[NSNumber numberWithInt:selectedPlayer] forKey:@"PlayerPointer"];
                viewController3.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:2];
                break;
            case 3:
               [[[userData objectForKey:@"Game"]objectAtIndex:3]setObject:[NSNumber numberWithInt:selectedPlayer] forKey:@"PlayerPointer"];
                viewController4.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:3];
                break;
            case 4:
               [[[userData objectForKey:@"Game"]objectAtIndex:4]setObject:[NSNumber numberWithInt:selectedPlayer] forKey:@"PlayerPointer"];
                viewController5.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:4];
                break;
            default:
                break;
        }
    }
    [viewController1 refreshPlayer];
    [viewController2 refreshPlayer];
    [viewController3 refreshPlayer];
    [viewController4 refreshPlayer];
    [viewController5 refreshPlayer];
    
//   // NSLog(@"---+++ Got player: %@", [[playersArray objectAtIndex:selectedPlayer]objectForKey:@"Name"]);
//    NSString *playerName = [[playersArray objectAtIndex:selectedPlayer]objectForKey:@"Name"];
//    NSNumber *division = [[playersArray objectAtIndex:selectedPlayer]objectForKey:@"Division"];
//    NSNumber *Handicap = [[playersArray objectAtIndex:selectedPlayer]objectForKey:@"Handicap"];
//    [[[userData objectForKey:@"Game"]objectAtIndex:currentplayerNumber] setObject:playerName forKey:@"Name"];
//    [[[userData objectForKey:@"Game"]objectAtIndex:currentplayerNumber] setObject:division forKey:@"Division"];
//    [[[userData objectForKey:@"Game"]objectAtIndex:currentplayerNumber] setObject:Handicap forKey:@"Handicap"];
//    
//    switch (currentplayerNumber) {
//        case 0:
//            viewController1.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:0];
//            [viewController1 refreshPlayer];
//            break;
//        case 1:
//            viewController2.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:1];
//            [viewController2 refreshPlayer];
//            break;
//        case 2:
//            viewController3.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:2];
//            [viewController3 refreshPlayer];
//            break;
//        case 3:
//            viewController4.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:3];
//            [viewController4 refreshPlayer];
//            break;
//        case 4:
//            viewController5.playersGame = [[userData objectForKey:@"Game"]objectAtIndex:4];
//            [viewController5 refreshPlayer];
//            break;
//        default:
//            break;
//    }
    
    [self saveData];
    
    [UIView transitionFromView:players.view toView: [viewControllerViews objectAtIndex:currentplayerNumber]
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCurlDown
                    completion:NULL];
}

#pragma mark - Location services

-(void)startOrRestartLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    locationManager.activityType = CLActivityTypeFitness;
    locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.delegate = self;
    
    
    if(IS_OS_8_OR_LATER) {
        // NSLog(@"--+++ iOS >8");
        [locationManager requestAlwaysAuthorization];  // needs always
        // entry in GolfScore-into.plist NSLocationAlwaysUsageDescription
        // [locationManager requestWhenInUseAuthorization];
        if (IS_OS_9_OR_LATER) {
            //    NSLog(@"---+++ iOS >9");
            self.locationManager.allowsBackgroundLocationUpdates = YES; // Need this!!!!
            
        }
    }
    
    
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

   // NSLog(@"---+++ Location Update: %.3f %.3f  - Accracy %.1f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude, locationManager.location.horizontalAccuracy);
    
    if (locationManager.location.horizontalAccuracy < 500) {
        [self updateLocationForAllViews:locationManager.location];
    }
    
    // -- get the location for Save to Calendar
//    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
//    [geocoder reverseGeocodeLocation:locationManager.location
//                   completionHandler:^(NSArray *placemarks, NSError *error) {
//                      // NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
//                       if (error){
//                           NSLog(@"Geocode failed with error: %@", error);
//                           return;
//                           
//                       }
//                       
//                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
//                       
//                       //NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
//                       //NSLog(@"placemark.country %@",placemark.country);
//                       //NSLog(@"placemark.postalCode %@",placemark.postalCode);
//                       //NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
//                      // NSLog(@"placemark.locality %@",placemark.locality);
//                      // NSLog(@"placemark.subLocality %@",placemark.subLocality);
//                       //NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
//                       locality = placemark.locality;
//                       subLocality = placemark.subLocality;
//                       
//                   }];
}


- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"%f, %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"---*** Location Error %@", error);
}

#pragma mark -

-(void)nextHole
{
   // NSLog(@"---+++ Next Hole");
    currentHoleNumber = (currentHoleNumber+1) % 18;  // loop to hole 1 again
    [self setHoleNumbersForAllViews];
    [self setHoleLocationForAllViews]; // and Last loc to current loc
   // [self updateLocationForAllViews:zeroLocation];
}

-(void)setCustomHole:(int)newHoleNumber
{
    currentHoleNumber = newHoleNumber;
      //  NSLog(@"---+++ Hello 1");
    [self setHoleNumbersForAllViews];
      //  NSLog(@"---+++ Hello 2");
    [self setHoleLocationForAllViews];
      //  NSLog(@"---+++ Hello 3");
    [self updateLocationForAllViews:zeroLocation];
      //  NSLog(@"---+++ Hello 4");
}

-(void)saveScoreTime
{
    if ([[userData objectForKey:@"StartDateTime"] timeIntervalSince1970] < 86400.00) { // one day in case of time zone
        [userData setObject:[NSDate date] forKey:@"StartDateTime"];
    }
    if ([[userData objectForKey:@"endDateTime"] timeIntervalSince1970] < 86400.00) {
        [userData setObject:[NSDate date] forKey:@"EndDateTime"];
    }
    if ([[userData objectForKey:@"SavedRound"]boolValue] == YES){
      [userData setObject:[NSNumber numberWithBool:NO] forKey:@"SavedRound"];
    }
   // NSLog(@"---+++ Start Time %@", [userData objectForKey:@"StartDateTime"]);
   // NSLog(@"---+++   End Time %@", [userData objectForKey:@"EndDateTime"]);
}

-(void)tablePullDown
{
    [UIView transitionFromView:scoretable.view toView: [viewControllerViews objectAtIndex:currentplayerNumber]
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCurlDown
                    completion:NULL];
}

-(void)addToCalendar
{
//   // NSLog(@"---+++ Add game to Calendar");
//    
//    
//  //  NSDate *dateNow = [NSDate date];
//  //  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//  //  dateFormatter =
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"dd MMMM yyyy"];
//   // [formatter setDateFormat:@"dd MMMM yyyy z hh:mm"];
//    NSString *midDayToday = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
//    [formatter setDateFormat:@"dd MMMM yyyy"];
//   // NSLog(@"---+++ Today String: %@", midDayToday);
//    NSDate *today = [formatter dateFromString:midDayToday];
//   // NSTimeInterval halfDay = 24 * 60 * 60;  // brings to midday today!
//    // today = [today dateByAddingTimeInterval:halfDay];
//   //  NSLog(@"---+++ Today as Date: %@", today);
    
    // now start off with saved flag set so "Save Button does not appear till a stroke is entered
//    if ([[userData objectForKey:@"StartDateTime"] timeIntervalSince1970] == 0.00) {
//       // NSLog(@"---+++ No data to Save");
//        UIAlertView *noSaveAlert = [[UIAlertView alloc]initWithTitle:@"No data to save" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [noSaveAlert show];
//        return;
//    }
    
    
    NSString *buildAllPlayers = [[NSString alloc]init];
    for (int player = 0; player < numberOfPlayers ; player++) {
        NSString *playerName = [[[userData objectForKey:@"Game"]objectAtIndex:player]objectForKey:@"Name"];
        int frontNineTotal = 0;
        int frontNinePutts = 0;
        int frontNinePenalties = 0;
        int backNineTotal = 0;
        int backNinePutts = 0;
        int backNinePenalties = 0;
        
        int strokeNumber = 0;
        int strokes = 0;
        NSDictionary *parStrokeHandicap;
        int gross = 0;
        int adjGross = 0;
        int handicapAccum = 0;
        
        for (int holeNum = 0; holeNum < 9; holeNum++){
            frontNineTotal += (int)[[[[[[userData objectForKey:@"Game"]objectAtIndex:player]objectForKey:@"Scores"]objectAtIndex:holeNum]objectForKey:@"Total" ] integerValue];
            frontNinePutts += (int)[[[[[[userData objectForKey:@"Game"]objectAtIndex:player]objectForKey:@"Scores"]objectAtIndex:holeNum]objectForKey:@"Putts" ] integerValue];
            frontNinePenalties += (int)[[[[[[userData objectForKey:@"Game"]objectAtIndex:player]objectForKey:@"Scores"]objectAtIndex:holeNum]objectForKey:@"Penalties" ] integerValue];
        }
        for (int holeNum = 9; holeNum < 18; holeNum++){
            backNineTotal += (int)[[[[[[userData objectForKey:@"Game"]objectAtIndex:player]objectForKey:@"Scores"]objectAtIndex:holeNum]objectForKey:@"Total" ] integerValue];
            backNinePutts += (int)[[[[[[userData objectForKey:@"Game"]objectAtIndex:player]objectForKey:@"Scores"]objectAtIndex:holeNum]objectForKey:@"Putts" ] integerValue];
            backNinePenalties += (int)[[[[[[userData objectForKey:@"Game"]objectAtIndex:player]objectForKey:@"Scores"]objectAtIndex:holeNum]objectForKey:@"Penalties" ] integerValue];
        }
        
        for (int holeNum = 0; holeNum <18; holeNum++) {
             strokeNumber =  (int)[[[[[[userData objectForKey:@"Game"]objectAtIndex:player]objectForKey:@"Scores"]objectAtIndex:holeNum]objectForKey:@"Strokes" ] integerValue];
            if (strokeNumber > 0 ){
                parStrokeHandicap = [self handicapForPlayer:player holeNumber:holeNum];
                strokes = [[[[[[userData objectForKey:@"Game"]objectAtIndex:player]objectForKey:@"Scores"]objectAtIndex:holeNum]objectForKey:@"Total" ] intValue];
                gross += strokes;
                int handicapForHole = [[parStrokeHandicap objectForKey:@"Handicap"]intValue];
                int stableford = [[parStrokeHandicap objectForKey:@"Par"]intValue] + handicapForHole - strokes + 2;
               // int nettForHole = strokes - handicapForHole;
                if (stableford <= 0) {
                    adjGross += strokes + stableford;
                } else {
                    adjGross += strokes;
                }
                handicapAccum += handicapForHole;
                // NSLog(@"---+++ Hole: %i, handicap:%i strokes:%i HandiAccum:%i", holeNum+1, handicapForHole, strokes, handicapAccum);
            }
        }
       // NSLog(@"----+++ AdjGross:%i Handicap:%i, AdjNett:%i", adjGross, handicapAccum, adjGross - handicapAccum);
        
       // NSString *frontNine = [NSString stringWithFormat: @"    Front 9:      %i strokes\n    Putts: %i    Penalties: %i\n", frontNineTotal, frontNinePutts, frontNinePenalties];
       // NSString *backNine = [NSString stringWithFormat:  @"    Back 9:       %i strokes\n    Putts: %i    Penalties: %i\n", backNineTotal, backNinePutts, backNinePenalties];
       // NSString *roundTotals =[NSString stringWithFormat:@"    Round:       %i strokes\n    Putts: %i    Penalties: %i\n", frontNineTotal+backNineTotal, frontNinePutts+backNinePutts, frontNinePenalties+backNinePenalties];
       // NSString *nettRound =  [NSString stringWithFormat:@"    AdjGross:    %i \n    AdjNett:  %i      (Handicap: %i)\n", adjGross, handicapAccum, adjGross - handicapAccum];
       // NSString *buildPlayer = [NSString stringWithFormat:@"\n%@\n%@\n%@\n%@\n%@", playerName, frontNine, backNine, roundTotals, nettRound];
        NSLog(@"\n---+++ Player:%i", player);
        NSLog(@"---+++ Gross:%i(%i)", gross, adjGross);
        NSLog(@"---+++ Nett:%i(%i)", gross-handicapAccum, adjGross-handicapAccum);
        NSLog(@"---+++ Handicap:%i", handicapAccum);
        
        NSString *frontNine = [NSString stringWithFormat: @"    Front 9:      %i strokes", frontNineTotal];
        NSString *backNine = [NSString stringWithFormat:  @"    Back 9:       %i strokes", backNineTotal];
        NSString *roundTotals =[NSString stringWithFormat:@"    Gross:       %i (%i) strokes", frontNineTotal+backNineTotal, adjGross];
        NSString *nettRound =  [NSString stringWithFormat:@"    Nett:        %i (%i)  (Handicap: %i)", gross-handicapAccum, adjGross - handicapAccum, handicapAccum];
        NSString *puttsAnd =[NSString stringWithFormat:   @"    Putts:   %i    Penalties: %i", frontNinePutts+backNinePutts, frontNinePenalties+backNinePenalties];
        NSString *buildPlayer = [NSString stringWithFormat:@"\n%@\n%@\n%@\n%@\n%@\n%@\n", playerName, frontNine, backNine, roundTotals, nettRound, puttsAnd];
      //  NSLog(@"---+++ Player %@", buildPlayer);
        buildAllPlayers = [buildAllPlayers stringByAppendingString:buildPlayer];
    }
   // NSLog(@"---+++ Complete store: %@", buildAllPlayers);
    
    [Calendar requestAccess:^(BOOL granted, NSError *error){
        if (granted) {
           // BOOL result = [Calendar addEventAt:today withTitle:@"Golf" inLocation:@"Martinborough" withNote:buildAllPlayers];
            BOOL result = [Calendar addEventAt:[userData objectForKey:@"StartDateTime"]
                                        endDate:[userData objectForKey:@"EndDateTime"]
                                      withTitle:@"Golf ~ Results"
                                    inLocation:[self->courseData objectForKey:@"Name"]
                                       withNote:buildAllPlayers];
            if (result) {
                NSLog(@"---+++ Event added to Calendar");
                [userData setObject:[NSNumber numberWithBool:YES] forKey:@"SavedRound"];
                scoretable.savedToCalendar = [[userData objectForKey:@"SavedRound"]boolValue];
                [scoretable reloadTable];
            } else {
                // unable to create event/calendar
                NSLog(@"---+++ Unable to create Event/Calendar");
            }
        } else {
            // you don't have permissions to access calendars
            NSLog(@"---+++ you don't have permissions to access calendars");
        }
    }];
}

-(void)test
{
    NSLog(@"---*** test!");
}

-(void)reCalibratePinDistance:(int)button
{
    if (button == 1) {
        CLLocation *holeLocation = locationManager.location;
       // double latDouble = [[[[courseData objectForKey:@"Holes"]objectAtIndex:currentHoleNumber]objectForKey:@"Lat"] doubleValue];
       // double longDouble = [[[[courseData objectForKey:@"Holes"]objectAtIndex:currentHoleNumber]objectForKey:@"Long"] doubleValue];

       // CLLocation *holeLocation = [[CLLocation alloc] initWithLatitude:latDouble longitude:longDouble];
        
        [[[courseData objectForKey:@"Holes"]objectAtIndex:currentHoleNumber]setObject:[NSNumber numberWithDouble:holeLocation.coordinate.latitude] forKey:@"Lat"];
        [[[courseData objectForKey:@"Holes"]objectAtIndex:currentHoleNumber]setObject:[NSNumber numberWithDouble:holeLocation.coordinate.longitude] forKey:@"Long"];
       // NSLog(@"---+++ Course to write %@", courseData);
       // NSLog(@"---+++ New Pin: %f %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
        [self writeCurrentCourse];

        viewController1.holeLocation = holeLocation;
        viewController2.holeLocation = holeLocation;
        viewController3.holeLocation = holeLocation;
        viewController4.holeLocation = holeLocation;
        viewController5.holeLocation = holeLocation;
    }
}


#pragma mark # Example Deep Copy

-(void)clearGameOptions:(int)options forPlayerNumber:(int)playerNumber
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"UserData" ofType:@"plist"];
    NSMutableDictionary *emptyAllPlayersData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *emptySinglePlayer = [[emptyAllPlayersData objectForKey:@"Game"]objectAtIndex:0];
   // NSLog(@"---+++ player:\n %@", emptySinglePlayer);
    NSArray *emptySinglePlayerScores = [emptySinglePlayer objectForKey:@"Scores"];
   // NSLog(@"---+++ scores: %@", emptySinglePlayerScores);
  //  NSLog(@"---+++ User data instance player 1: %@", [[userData objectForKey:@"Game"]objectAtIndex:0]);
  //  NSLog(@"---+++ User data on view controller: %@", viewController1.playersGame );
    switch (options) {
        case 0: // Clear this Game - keep Names
            [[[userData objectForKey:@"Game"] objectAtIndex:0] setObject:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                                          [NSKeyedArchiver archivedDataWithRootObject:emptySinglePlayerScores]] forKey:@"Scores"];
            [[[userData objectForKey:@"Game"] objectAtIndex:1] setObject:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                                          [NSKeyedArchiver archivedDataWithRootObject:emptySinglePlayerScores]] forKey:@"Scores"];
            [[[userData objectForKey:@"Game"] objectAtIndex:2] setObject:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                                          [NSKeyedArchiver archivedDataWithRootObject:emptySinglePlayerScores]] forKey:@"Scores"];
            [[[userData objectForKey:@"Game"] objectAtIndex:3] setObject:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                                          [NSKeyedArchiver archivedDataWithRootObject:emptySinglePlayerScores]] forKey:@"Scores"];
            [[[userData objectForKey:@"Game"] objectAtIndex:4] setObject:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                                          [NSKeyedArchiver archivedDataWithRootObject:emptySinglePlayerScores]] forKey:@"Scores"];
           // currentHoleNumber = 0;
            [userData setObject:[emptyAllPlayersData objectForKey:@"StartDateTime"] forKey:@"StartDateTime"];
            [userData setObject:[emptyAllPlayersData objectForKey:@"EndDateTime"] forKey:@"EndDateTime"];
           // [self setHoleNumbersForAllViews];
           // [self setHoleLocationForAllViews];
            [self setCustomHole:0];
            break;
        case 1: // clear this Player
            [[[userData objectForKey:@"Game"] objectAtIndex:playerNumber] setObject:emptySinglePlayerScores.copy forKey:@"Scores"];
           // currentHoleNumber = 0;
           // [self setHoleNumbersForAllViews];
           // [self setHoleLocationForAllViews];
            [self setCustomHole:0];
            break;
        case 2: // new game option -1 players, leave scores 
        case 3: // 2 players
        case 4: // 3 players
        case 5: // 4 players
            // NSLog(@"---+++ %i players", options-1 );
            // [[userData objectForKey:@"Game"] setObject:emptySinglePlayer atIndex:0];
            // [[userData objectForKey:@"Game"] setObject:emptySinglePlayer atIndex:1];
            // [[userData objectForKey:@"Game"] setObject:emptySinglePlayer atIndex:2];
            // [[userData objectForKey:@"Game"] setObject:emptySinglePlayer atIndex:3];
            // [[userData objectForKey:@"Game"] setObject:emptySinglePlayer atIndex:4];
            if (numberOfPlayers > options-1) {
                // NSLog(@"---+++ reduced players reset to player 1");
                [self flipToViewN:0];
                //[self resetToView1];  // Thinks; set to new player!
            } else {
                // NSLog(@"---+++ new players - do nothing");
            }
            numberOfPlayers = options-1;
            // [self resetToView1];  // safetysingle player
            //            if (playerNumber > 0 ) {
            //                [self resetToView1];
            //            }
            
            break;
        case 6:
            // NSLog(@"---+++ Course Change %@", [self getAllCourses]);
            [self getAllCourses];
            [UIView transitionFromView:[viewControllerViews objectAtIndex:currentplayerNumber] toView: courses.view
                              duration:1.0
                               options:UIViewAnimationOptionTransitionCurlUp
                            completion:NULL];
        default:
            break;
    }
    //[emptyAllPlayersData removeAllObjects];
    //[emptySinglePlayer removeAllObjects];
    //[emptySinglePlayerScores removeAllObjects];
    [userData setObject:[emptyAllPlayersData objectForKey:@"SavedRound"] forKey:@"SavedRound"];
    emptyAllPlayersData = nil;
    emptySinglePlayer = nil;
    emptySinglePlayerScores = nil;

}

-(void)setHoleNumbersForAllViews
{
    [viewController1 nextHole:currentHoleNumber];
    [viewController2 nextHole:currentHoleNumber];
    [viewController3 nextHole:currentHoleNumber];
    [viewController4 nextHole:currentHoleNumber];
    [viewController5 nextHole:currentHoleNumber];
}

-(void)setHoleLocationForAllViews
{
    double latDouble = [[[[courseData objectForKey:@"Holes"]objectAtIndex:currentHoleNumber]objectForKey:@"Lat"] doubleValue];
    double longDouble = [[[[courseData objectForKey:@"Holes"]objectAtIndex:currentHoleNumber]objectForKey:@"Long"] doubleValue];
    CLLocation *holeLocation = [[CLLocation alloc] initWithLatitude:latDouble longitude:longDouble];
    viewController1.holeLocation = holeLocation;
    viewController2.holeLocation = holeLocation;
    viewController3.holeLocation = holeLocation;
    viewController4.holeLocation = holeLocation;
    viewController5.holeLocation = holeLocation;
   // NSLog(@"---!!! Hole %i Location: %f %f", currentHoleNumber, holeLocation.coordinate.latitude, holeLocation.coordinate.longitude );
    
    // --------- leave lastStoke alone, so only updated by Next stroke -  going to another hole and back should still be valid
   // viewController1.lastStrokeLoc = locationManager.location;
   // viewController2.lastStrokeLoc = locationManager.location;
   // viewController3.lastStrokeLoc = locationManager.location;
   // viewController4.lastStrokeLoc = locationManager.location;
   // viewController5.lastStrokeLoc = locationManager.location;
}

-(void)updateLocationForAllViews:(CLLocation*)newLocation
{
  //  NSLog(@"---+++ update Location %.1f %.1f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [viewController1 updateLocation:newLocation];
    [viewController2 updateLocation:newLocation];
    [viewController3 updateLocation:newLocation];
    [viewController4 updateLocation:newLocation];
    [viewController5 updateLocation:newLocation];
}

#pragma mark -
#pragma mark File system

-(void)getAllCourses        // get the names of all the courses
{
    courseNames = [[NSMutableArray alloc]init];
    NSFileManager *fManager = [NSFileManager defaultManager];
   // NSLog(@"---+++ Documents Path: %@", NSHomeDirectory());
    NSArray *contents = [fManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil];
    // >>> this section here adds all files with the chosen extension to an array
    NSString *item;
    NSString *trimmedCourse;
    for (item in contents){
        if ([[item pathExtension] isEqualToString:@"JSON"]) {
            trimmedCourse = [item stringByReplacingOccurrencesOfString:@".JSON" withString:@""];
            [courseNames addObject:trimmedCourse];
        }
    }
   // NSLog(@"---+++ Courses: \n%@", courseNames);
   // return courses; // now in externaly referenced CourseNames
}


-(void)writeBlankJSON
{
    NSString *blankFilePath = [[NSBundle mainBundle] pathForResource:@"BlankCourse" ofType:@"JSON"];
    
    // Load blank course into an NSData object called JSONData
    
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:blankFilePath options:NSDataReadingMappedIfSafe error:&error];
    [self writeJSON:JSONData withName:@"Blank" ];
}

-(void)writeJSON:(NSData*)JSONData withName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *docsFilePath = [documentsDir stringByAppendingPathComponent:name];
    NSString *completeFilePath = [docsFilePath stringByAppendingPathExtension:@"JSON"];
    NSLog(@"---+++ Write JSON File Path: %@", completeFilePath );
    
    BOOL result = [JSONData writeToFile:completeFilePath atomically:YES];
    if (!result ) {
        NSLog(@"---!!! File Write Error");
    }
}

-(void)writeCurrentCourse
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:courseData
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    [self writeJSON:jsonData withName:[courseData objectForKey:@"Name"]];
}

-(void)getCourse:(NSString *)courseName  // load course data to courseData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *docsFilePath = [documentsDir stringByAppendingPathComponent:courseName];
    NSString *completeFilePath = [docsFilePath stringByAppendingPathExtension:@"JSON"];
   // NSLog(@"---+++ JSON File Path: %@", completeFilePath );
    
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:completeFilePath options:NSDataReadingMappedIfSafe error:&error];
    if (error == nil) {
        // Create an Objective-C object from JSON Data
        
        courseData = [NSJSONSerialization JSONObjectWithData:JSONData
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
        [courseData setObject:courseName forKey:@"Name"];
        [userData setObject:[courseData objectForKey:@"Name"] forKey:@"CurrentCourse"];
       // NSLog(@"---+++ Got Course %@", courseData);
    } else {
        NSLog(@"---!!! File ERROR %@", error);
    }

}


#pragma mark -
#pragma mark Life Cycle

- (void)applicationWillResignActive:(UIApplication *)application
{
   // NSLog(@"---+++ Will enter Background");
   // GPSHeartBeat = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(GPSHeartBeat) userInfo:nil repeats:YES];
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    GPSoffTimer = [NSTimer scheduledTimerWithTimeInterval:GPSoffDelay target:self selector:@selector(offGPS) userInfo:nil repeats:NO];

    // 1200 = 20mins
    NSLog(@"---+++ Enter background - Starting GPS Off timer");
    [self saveData];
    [viewController1 viewWillDisappear:NO];
    [viewController2 viewWillDisappear:NO];
    [viewController3 viewWillDisappear:NO];
    [viewController4 viewWillDisappear:NO];
    [viewController5 viewWillDisappear:NO];
}

-(void)offGPS
{
    NSLog(@"---+++ Stoping the GPS");
    [locationManager stopUpdatingLocation];
    if (IS_OS_9_OR_LATER ) {
        self.locationManager.allowsBackgroundLocationUpdates = NO;
    }
    locationManager = nil;
}

-(void)GPSHeartBeat
{
    NSLog(@"---+++ GPS Tick");
    [locationManager requestLocation];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"---+++ Enter Foreground");
    if (locationManager == nil) {
        [self startOrRestartLocationManager];
        NSLog(@"---+++ restart GPS");
    } else {
        [GPSoffTimer invalidate];
        NSLog(@"---+++ turning the GPS-off timer off");
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



-(void)getSavedData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"userData"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exists = [fm fileExistsAtPath:filePath];
    // exists = NO;  // Authoring : reload the plist
    if (exists) {
        userData = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        numberOfPlayers = [[userData objectForKey:@"NumberOfPlayers"]intValue];
        currentHoleNumber = [[userData objectForKey:@"HoleNumber"]intValue];
      // NSLog(@"---+++ Loaded user data %@",[userData objectForKey:@"Game"]);
    } else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"UserData" ofType:@"plist"];
        userData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        NSLog(@"---+++ Copy the userdata Plist");
        numberOfPlayers = [[userData objectForKey:@"NumberOfPlayers"]intValue];
        currentHoleNumber = [[userData objectForKey:@"HoleNumber"]intValue];
        [self saveData];
    }
}

-(void)saveData // save user Data
{
    [userData setObject:[NSNumber numberWithInt:(self.viewController.score)] forKey:@"Score"];
   // [[userData objectForKey:@"Game"]setObject:viewController1.playersGame atIndex:0];
   // [[userData objectForKey:@"Game"]setObject:viewController2.playersGame atIndex:1];
   // [[userData objectForKey:@"Game"]setObject:viewController3.playersGame atIndex:2];
   // [[userData objectForKey:@"Game"]setObject:viewController4.playersGame atIndex:3];
   // [[userData objectForKey:@"Game"]setObject:viewController5.playersGame atIndex:4];
    [userData setObject:[NSNumber numberWithInt:numberOfPlayers] forKey:@"NumberOfPlayers"];
    [userData setObject:[NSNumber numberWithInt:currentHoleNumber] forKey:@"HoleNumber"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"userData"];
    // NSLog(@"---+++ Saving user data %@", userData);
    [userData writeToFile:filePath atomically:NO];
}

@end
