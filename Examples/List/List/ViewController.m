//
//  ViewController.m
//  List
//
//  Created by Denis Hennessy on 06/04/2015.
//  Copyright (c) 2015 Peer Assembly. All rights reserved.
//

#import "ViewController.h"
#import "Database.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(databaseConnectionDidUpdate:)
                                                 name:UIDatabaseConnectionDidUpdateNotification
                                               object:nil];
}

- (void)databaseConnectionDidUpdate:(NSNotification *)notification {
    NSLog(@"databaseConnectionDidUpdate");
    [self configureUI];
}

- (void)configureUI {
    [[Database sharedInstance].uiConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [_breakfastButton setState:[[transaction objectForKey:@"breakfast" inCollection:@"meals"] integerValue]];
        [_lunchButton setState:[[transaction objectForKey:@"lunch" inCollection:@"meals"] integerValue]];
        [_dinnerButton setState:[[transaction objectForKey:@"dinner" inCollection:@"meals"] integerValue]];
    }];
    _snapshotTextField.stringValue = [NSString stringWithFormat:@"%llu", [[Database sharedInstance].uiConnection snapshot]];
}

- (IBAction)mealTapped:(NSButton *)sender {
    NSString *meal = nil;
    if (sender == _breakfastButton) {
        meal = @"breakfast";
    } else if (sender == _lunchButton) {
        meal = @"lunch";
    } else {
        meal = @"dinner";
    }
    [[Database sharedInstance].bgConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:[NSNumber numberWithInteger:sender.state] forKey:meal inCollection:@"meals"];
    }];
    
}

- (IBAction)refreshTapped:(id)sender {
    [[Database sharedInstance] invalidateCaches];
    //    [[Database sharedInstance] reconnect];
    [self configureUI];
}

@end
