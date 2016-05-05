//
//  OEPViewModel.m
//  OpenEyesPhoto
//
//  Created by Will Jehring on 08/04/2014.
//  Copyright (c) 2014 Black Pear Software Ltd. All rights reserved.
//

#import "OEPViewModel.h"
#import "OEPDataInterface.h"
#import <BPObjC/BPObjC.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation OEPViewModel

- (id)init {
    if (self = [super init]) {
        _username = [[NSUserDefaults standardUserDefaults] objectForKey:OEPDefaultsKeyUsername] ?: @"";
        _password = @"";
        _ssid = [[NSUserDefaults standardUserDefaults] objectForKey:OEPDefaultsKeySSID] ?: @"";
        _hostname = [[NSUserDefaults standardUserDefaults] objectForKey:OEPDefaultsKeyHostname] ?: @"";
    }
    return self;
}

#pragma mark - Bindings
- (void)setUsername:(NSString *)username {
    _username = username;
    [[OEPDataInterface sharedInterface] setUsername:username];
}

- (void)setPassword:(NSString *)password {
    _password = password;
    [[OEPDataInterface sharedInterface] setPassword:password];
}

- (void)setHostname:(NSString *)hostname {
    _hostname = hostname;
    [[OEPDataInterface sharedInterface] setServerURL:hostname];
}

#pragma mark - Network Access
- (RACSignal *)uploadPhoto {
    [[NSUserDefaults standardUserDefaults] setObject:self.username forKey:OEPDefaultsKeyUsername];
    [[NSUserDefaults standardUserDefaults] setObject:self.hostname forKey:OEPDefaultsKeyHostname];
    [[NSUserDefaults standardUserDefaults] setObject:self.ssid forKey:OEPDefaultsKeySSID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[[self ssidCorrect] then:^RACSignal *{
        return [[OEPDataInterface sharedInterface] checkLogin];
    }] then:^RACSignal *{
        return [[OEPDataInterface sharedInterface] uploadData:self.photoData withFileName:@"photo"];
    }];
}

- (RACSignal *)ssidCorrect {
    NSString *currentSSID = [self currentSSID];
    if ([self.ssid isEqualToString:currentSSID]) {
        return [RACSignal empty];
    } else {
        return [RACSignal error:[NSError errorWithCode:OEPErrorCodeIncorrectSSID andDescription:@"Entered SSID does not match current SSID"]];
    }
}

- (NSString *)currentSSID {
    NSString *currentSSID = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil){
        NSDictionary* myDict = (__bridge NSDictionary *) CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict!=nil){
            currentSSID=[myDict valueForKey:@"SSID"];
        }
    }
    return currentSSID;
}

@end
