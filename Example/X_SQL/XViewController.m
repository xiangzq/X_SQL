//
//  XViewController.m
//  X_SQL
//
//  Created by xiangzq on 03/03/2021.
//  Copyright (c) 2021 xiangzq. All rights reserved.
//

#import "XViewController.h"
#import <X_SQL.h>
@interface XViewController ()

@end

@implementation XViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [X_SQL setSqlName:nil];
    [X_SQL queryTableName:@"" object:@{@"1":@"a"} db:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
