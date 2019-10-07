//
//  Calendar.m
//  GolfScore
//
//  Created by Rex McIntosh on 3/12/14.
//
//

#import <Foundation/Foundation.h>
#import "Calendar.h"


static EKEventStore *eventStore = nil;

@implementation Calendar

+ (void)requestAccess:(void (^)(BOOL granted, NSError *error))callback;
{
    if (eventStore == nil) {
        eventStore = [[EKEventStore alloc] init];
    }
    // request permissions
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:callback];
}

+ (BOOL)addEventAt:(NSDate*)eventDate endDate:(NSDate*)endDate withTitle:(NSString*)title inLocation:(NSString*)location withNote:(NSString*)noteText
{
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    EKCalendar *calendar = nil;
    NSString *calendarIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:@"my_calendar_identifier"];
    int calendarSourceType = 0;  // deafault to Local Calendar
    // NSLog(@"---+++ Saved Calendar Identifier %@", calendarIdentifier);
    
    // when identifier exists, my calendar probably already exists
    // note that user can delete my calendar. In that case I have to create it again.
    NSArray *calendars  = [eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSArray *listOfSourceTypes = [[NSArray alloc] initWithObjects:@"EKSourceTypeLocal",
                                                            @"EKSourceTypeExchange",
                                                            @"EKSourceTypeCalDAV",
                                                            @"EKSourceTypeMobileMe",
                                                            @"EKSourceTypeSubscribed",
                                                            @"EKSourceTypeBirthdays",
                                                            nil];
    
    for (EKCalendar*  aCal in calendars) {
        // NSLog(@"---+++ Calendar: %@  \t\t- %@", listOfSourceTypes[aCal.source.sourceType], aCal.title); //, aCal.calendarIdentifier);
        if (aCal.source.sourceType == 2){  // if iCloud calendars put it there, don't know about other types!
            calendarSourceType = 2;
        }
        if ([aCal.calendarIdentifier isEqualToString:calendarIdentifier]) { // found our calendar
            calendar = aCal;
        }
    }
    
    if (calendarIdentifier) {
       // calendar = [eventStore calendarWithIdentifier:calendarIdentifier]; // brings up error in iOS8??? Error getting shared calendar invitations for entity types 3 from daemon:
       // NSLog(@"---+++ Fetched Calendar: %@   \t- %@", listOfSourceTypes[calendar.source.sourceType], calendar.title );
        // ----------- REMOVE an existing calendar --------------
       // NSLog(@"---+++ REMOVING CALENDAR");
       // NSError *err;
       // [eventStore removeCalendar:calendar commit:YES error:&err];
       // calendar = nil;
    }
    
    // calendar doesn't exist, create it and save it's identifier
    if (!calendar) {
        // http://stackoverflow.com/questions/7945537/add-a-new-calendar-to-an-ekeventstore-with-eventkit
        NSLog(@"---+++ Creating New calendar in %@", listOfSourceTypes[calendarSourceType]);
        calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
        
        // set calendar name. This is what users will see in their Calendar app
        [calendar setTitle:@"Golf"];
        
        // find appropriate source type. I'm interested only in local calendars but
        // there are also calendars in iCloud, MS Exchange, ...
        // look for EKSourceType in manual for more options
        // 0. EKSourceTypeLocal
        // 1. EKSourceTypeExchange,
        // 2. EKSourceTypeCalDAV,
        // 3. EKSourceTypeMobileMe,
        // 4. EKSourceTypeSubscribed,
        // 5. EKSourceTypeBirthdays
        for (EKSource *s in eventStore.sources) {
            if (s.sourceType == calendarSourceType) {   // use EKSourceTypeLocal (type0) if no iCloud (type2), if iCloud use EKSourceTypeCalDAV
                calendar.source = s;
                break;
            }
        }
        
        // save this in NSUserDefaults data for retrieval later
        NSString *calendarIdentifier = [calendar calendarIdentifier];
        
        NSError *error = nil;
        BOOL saved = [eventStore saveCalendar:calendar commit:YES error:&error];
        if (saved) {
            // http://stackoverflow.com/questions/1731530/whats-the-easiest-way-to-persist-data-in-an-iphone-app
            // saved successfuly, store it's identifier in NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:calendarIdentifier forKey:@"my_calendar_identifier"];
        } else {
            // unable to save calendar
            return NO;
        }
    }
   // NSLog(@"---+++ Calendar: %@ -Source: %@", calendar.title, calendar.source);
    
    // this shouldn't happen
    if (!calendar) {
        return NO;
    }
    
    // assign basic information to the event; location is optional
    event.calendar = calendar;
    event.location = location;
    event.title = title;
    event.notes = noteText;
    
    // set the start date to the current date/time and the event duration to two hours
   // NSDate *startDate = eventDate;
    event.startDate = eventDate;
    event.endDate = endDate;  //[startDate dateByAddingTimeInterval:3600 * 2];
    
    NSError *error = nil;
    // save event to the callendar
    // NSLog(@"---+++ Event %@", event);
    BOOL result = [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
    if (result) {
        return YES;
    } else {
         NSLog(@"Error saving event: %@", error);
        // unable to save event to the calendar
        return NO;
    }
}

@end


// Usage:
//[Calendar requestAccess:^(BOOL granted, NSError *error) {
//    if (granted) {
//        BOOL result = [Calendar addEventAt:[NSDate date] withTitle:@"Party" inLocation:@"My house"];
//        if (result) {
//            // added to calendar
//        } else {
//            // unable to create event/calendar
//        }
//    } else {
//        // you don't have permissions to access calendars
//    }
//}];
