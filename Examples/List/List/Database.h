//
//  Database.h
//  List
//
//  Created by Denis Hennessy on 06/04/2015.
//  Copyright (c) 2015 Peer Assembly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YapDatabase.h"
#import "YapDatabaseView.h"

extern NSString *const UIDatabaseConnectionWillUpdateNotification;
extern NSString *const UIDatabaseConnectionDidUpdateNotification;
extern NSString *const kNotificationsKey;

@interface Database : NSObject <NSFilePresenter> {
    NSFileCoordinator *_fileCoordinator;
}

@property (nonatomic, readonly) NSURL *databaseURL;
@property (nonatomic, readonly) YapDatabase *database;
@property (nonatomic, readonly) YapDatabaseConnection *uiConnection;
@property (nonatomic, readonly) YapDatabaseConnection *bgConnection;

+ (Database *)sharedInstance;
+ (NSString *)newUuid;

- (void)reconnect;
- (void)invalidateCaches;

@end
