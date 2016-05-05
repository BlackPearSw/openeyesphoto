//
//  OEPDataInterface.m
//  OpenEyesPhoto
//
//  Created by Will Jehring on 02/04/2014.
//  Copyright (c) 2014 Black Pear Software Ltd. All rights reserved.
//

#import "OEPDataInterface.h"
#import "FTPManager.h"
#import <BPObjC/BPObjC.h>

@implementation OEPDataInterface

+ (instancetype)sharedInterface {
    static OEPDataInterface *sharedInterface = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInterface = [[self alloc] init];
    });
    return sharedInterface;
}

- (id)init {
    if (self = [super init]) {
        _serverURL = @"";
        _username = @"";
        _password = @"";
    }
    return self;
}

#pragma mark Convenience Methods
- (BOOL)serverDetailsValid {
    if (!self.serverURL ||
        ![NSURL URLWithString:self.serverURL] ||
        !self.username ||
        [self.username isEqualToString:@""] ||
        !self.password) {
        return NO;
    }
    return YES;
}

- (RACSignal *)checkDetailsValidSignal {
    if ([self serverDetailsValid]) {
        return [RACSignal empty];
    } else {
        return [RACSignal error:[NSError errorWithCode:200 andDescription:@"Server details invalid"]];
    }
}

- (RACSignal *)checkInternetReachability {
    if ([[BPReachability reachabilityForInternetConnection] isReachable]) {
        return [RACSignal empty];
    } else {
        return [RACSignal error:[NSError errorWithCode:98 andDescription:@"No internet connection available"]];
    }
}

- (FMServer *)serverFromCurrentSettings {
    return [FMServer serverWithDestination:self.serverURL username:self.username password:self.password];
}

#pragma mark Public Interface
- (RACSignal *)checkLogin {
    @weakify(self);
    return [[self checkInternetReachability] then:^RACSignal *{
        return [[self checkDetailsValidSignal] then:^RACSignal *{
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                FMServer *server = [self serverFromCurrentSettings];
                FTPManager *manager = [[FTPManager alloc] init];
                BOOL success = [manager checkLogin:server];
                if (success) {
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:[NSError errorWithCode:400 andDescription:@"Login failed"]];
                }
                return [RACDisposable disposableWithBlock:^{
                    [manager abort];
                }];
            }];
        }];
    }];
}

- (RACSignal *)contentsOfServer {
    @weakify(self);
    return [[self checkDetailsValidSignal] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            FMServer *server = [self serverFromCurrentSettings];
            FTPManager *manager = [[FTPManager alloc] init];
            NSArray *contents = [manager contentsOfServer:server];
            if (contents) {
                [subscriber sendNext:contents];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError errorWithCode:401 andDescription:@"Get file list failed"]];
            }
            return [RACDisposable disposableWithBlock:^{
                [manager abort];
            }];
        }];
    }];
}

- (RACSignal *)createNewFolderWithName:(NSString *)folderName {
    @weakify(self);
    return [[self checkDetailsValidSignal] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            FMServer *server = [self serverFromCurrentSettings];
            FTPManager *manager = [[FTPManager alloc] init];
            BOOL success = [manager createNewFolder:folderName atServer:server];
            if (success) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError errorWithCode:402 andDescription:@"Create new folder failed"]];
            }
            return [RACDisposable disposableWithBlock:^{
                [manager abort];
            }];
        }];
    }];
}

- (RACSignal *)deleteFileWithName:(NSString *)fileName {
    @weakify(self);
    return [[self checkDetailsValidSignal] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            FMServer *server = [self serverFromCurrentSettings];
            FTPManager *manager = [[FTPManager alloc] init];
            BOOL success = [manager deleteFileNamed:fileName fromServer:server];
            if (success) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError errorWithCode:403 andDescription:@"Delete file failed"]];
            }
            return [RACDisposable disposableWithBlock:^{
                [manager abort];
            }];
        }];
    }];
}

- (RACSignal *)uploadData:(NSData *)data withFileName:(NSString *)fileName {
    @weakify(self);
    return [[self checkInternetReachability] then:^RACSignal *{
        return [[self checkDetailsValidSignal] then:^RACSignal *{
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                FMServer *server = [self serverFromCurrentSettings];
                FTPManager *manager = [[FTPManager alloc] init];
                NSError *error;
                BOOL success = [manager uploadData:data withFileName:fileName toServer:server error:&error];
                if (success) {
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:error];
                }
                return [RACDisposable disposableWithBlock:^{
                    [manager abort];
                }];
            }];
        }];
    }];
}

- (RACSignal *)downloadFileWithName:(NSString *)fileName toDirectory:(NSURL *)directory {
    @weakify(self);
    return [[self checkDetailsValidSignal] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            FMServer *server = [self serverFromCurrentSettings];
            FTPManager *manager = [[FTPManager alloc] init];
            BOOL success = [manager downloadFile:fileName toDirectory:directory fromServer:server];
            if (success) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError errorWithCode:405 andDescription:@"Download file failed"]];
            }
            return [RACDisposable disposableWithBlock:^{
                [manager abort];
            }];
        }];
    }];
}

@end
