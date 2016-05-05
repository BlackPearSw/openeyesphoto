//
//  OEPViewModel.h
//  OpenEyesPhoto
//
//  Created by Will Jehring on 08/04/2014.
//  Copyright (c) 2014 Black Pear Software Ltd. All rights reserved.
//

#import "RVMViewModel.h"

@interface OEPViewModel : RVMViewModel

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *ssid;
@property (strong, nonatomic) NSString *hostname;
@property (strong, nonatomic) NSData *photoData;

- (RACSignal *)uploadPhoto;

@end
