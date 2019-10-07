//
//  Calendar.h
//  GolfScore
//
//  Created by Rex McIntosh on 3/12/14.
//
//


#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface Calendar : NSObject

+ (void)requestAccess:(void (^)(BOOL granted, NSError *error))success;
+ (BOOL)addEventAt:(NSDate*)eventDate endDate:(NSDate*)endDate withTitle:(NSString*)title inLocation:(NSString*)location withNote:(NSString*)noteText;


@end
