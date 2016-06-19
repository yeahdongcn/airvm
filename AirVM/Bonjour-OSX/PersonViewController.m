//
//  PersonViewController.m
//  AirVM
//
//  Created by Zhaokai Yuan on 6/18/16.
//  Copyright © 2016 VMware. All rights reserved.
//

#import "PersonViewController.h"

@interface PersonViewController ()

@property (nonatomic, strong) AirVM *person;

@property (weak) IBOutlet NSImageView *portraitView;
@property (weak) IBOutlet NSTextField *nameLabel;

@end

@implementation PersonViewController 

- (instancetype)initWithAirVM:(AirVM *)airVM {
   self = [super initWithNibName:@"PersonViewController" bundle:nil];
   if (self) {
      _person = airVM;
   }
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.portraitView.image = [NSImage imageNamed:@"person"];
   self.portraitView.wantsLayer = YES;
   self.portraitView.layer.cornerRadius = self.portraitView.frame.size.width / 2;
   self.nameLabel.stringValue = self.person.machineName;
}





@end
