//
//  DMTHViewController.m
//  DragMeToHell
//
//  Created by Robert Irwin on 2/18/12.
//  Copyright (c) 2012 Robert J. Irwin. All rights reserved.
//

#import "DMTHViewController.h"

@implementation DMTHViewController

- (void)viewDidLoad
{
    NSLog( @"viewDidLoad" );
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor cyanColor]];   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
