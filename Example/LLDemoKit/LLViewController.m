//
//  LLViewController.m
//  LLDemoKit
//
//  Created by LLPayiOSDev on 05/06/2019.
//  Copyright (c) 2019 LLPayiOSDev. All rights reserved.
//

#import "LLViewController.h"

@interface LLViewController ()

@end

@implementation LLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self userInterfaceWithPlist:@"LLDemoTest"];
}


- (void)lldNextAction {
    [self pushInfoVC:@"Title" success:YES text:@"headerInfo" detail:@"detail info lskoweosdlfjsldjflsjdfldjflsjdjfljl" info:@{@"test":@"testsdkfjlsdjflj"}];
}

@end
