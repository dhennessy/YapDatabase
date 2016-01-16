//
//  AppDelegate.m
//  List
//
//  Created by Denis Hennessy on 06/04/2015.
//  Copyright (c) 2015 Peer Assembly. All rights reserved.
//

#import "AppDelegate.h"
#import "Database.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [Database sharedInstance];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
