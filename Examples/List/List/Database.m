//
//  Database.m
//  List
//
//  Created by Denis Hennessy on 06/04/2015.
//  Copyright (c) 2015 Peer Assembly. All rights reserved.
//

#import "Database.h"

NSString *const UIDatabaseConnectionWillUpdateNotification = @"UIDatabaseConnectionWillUpdateNotification";
NSString *const UIDatabaseConnectionDidUpdateNotification  = @"UIDatabaseConnectionDidUpdateNotification";
NSString *const kNotificationsKey = @"notifications";

static NSOperationQueue *_presentedItemOperationQueue;

@implementation Database

+ (NSString *)newUuid {
    return [[NSUUID UUID] UUIDString];
}

+ (Database *)sharedInstance {
    static Database *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _presentedItemOperationQueue = [[NSOperationQueue alloc] init];
        _sharedInstance = [[Database alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *url = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        NSURL *folder = [url URLByAppendingPathComponent:bundleID];
        [fileManager createDirectoryAtURL:folder withIntermediateDirectories:YES attributes:nil error:NULL];
        _databaseURL = [folder URLByAppendingPathComponent:@"List.sqlite"];

        [NSFileCoordinator addFilePresenter:self];
        _fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
        [self openDatabase];
    }
    return self;
}

#pragma mark - NSFilePresenter

- (NSURL *)presentedItemURL {
    return _databaseURL;
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return _presentedItemOperationQueue;
}

- (void)invalidateCaches {
    [_bgConnection flushMemoryWithFlags:YapDatabaseConnectionFlushMemoryFlags_Caches];
    [_uiConnection endLongLivedReadTransaction];
    [_uiConnection flushMemoryWithFlags:YapDatabaseConnectionFlushMemoryFlags_Caches];
    [_uiConnection beginLongLivedReadTransaction];
}

#pragma mark - Implementation

- (void)openDatabase {
    NSError *error = nil;
    [_fileCoordinator coordinateWritingItemAtURL:_databaseURL options:0 error:&error byAccessor:^(NSURL *newURL) {
        NSLog(@"DB: %@", newURL.path);
        _database = [[YapDatabase alloc] initWithPath:newURL.path];
        if (!_database) {
            NSLog(@"Fatal: unable to create/open database");
        }
        _bgConnection = [_database newConnection];
        _bgConnection.objectCacheLimit = 400;
        _bgConnection.metadataCacheEnabled = NO;
        
        _uiConnection = [_database newConnection];
        _uiConnection.objectCacheLimit = 400;
        _uiConnection.metadataCacheEnabled = NO;
#if DEBUG
        _uiConnection.permittedTransactions = YDB_SyncReadTransaction | YDB_MainThreadOnly;
#endif
        [_uiConnection enableExceptionsForImplicitlyEndingLongLivedReadTransaction];
        [_uiConnection beginLongLivedReadTransaction];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yapDatabaseModified:)
                                                     name:YapDatabaseModifiedNotification
                                                   object:_database];
    }];
}

- (void)reconnect {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _bgConnection = nil;
    _uiConnection = nil;
    _database = nil;
    
    [self openDatabase];
}

- (void)yapDatabaseModified:(NSNotification *)ignored {
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDatabaseConnectionWillUpdateNotification object:self];
    NSArray *notifications = [_uiConnection beginLongLivedReadTransaction];
    NSDictionary *userInfo = @{ kNotificationsKey : notifications };
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDatabaseConnectionDidUpdateNotification object:self userInfo:userInfo];
}


@end
