//
//  OEPViewModelSpec.m
//  OpenEyesPhoto
//
//  Created by Will Jehring on 08/04/2014.
//  Copyright (c) 2014 Black Pear Software Ltd. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "OEPViewModel.h"
#import "OEPDataInterface.h"

#define CorrectUsername @"CorrectUsername"
#define CorrectPassword @"CorrectPassword"
#define CorrectSSID @"CorrectSSID"
#define CorrectHostname @"ftp.correct.com"

@interface OEPViewModel ()
- (NSString *)currentSSID;
@end

SPEC_BEGIN(OEPViewModelSpec)

describe(@"The OEP View Model", ^{
    __block OEPViewModel *sut;
    __block NSUserDefaults *stubbedDefaults;
    beforeEach(^{
        stubbedDefaults = [[NSUserDefaults alloc] init];
        [NSUserDefaults stub:@selector(standardUserDefaults) andReturn:stubbedDefaults];
    });
	context(@"when created with blank defaults", ^{
        beforeEach(^{
            [stubbedDefaults stub:@selector(objectForKey:) andReturn:nil withArguments:OEPDefaultsKeyUsername, nil];
            [stubbedDefaults stub:@selector(objectForKey:) andReturn:nil withArguments:OEPDefaultsKeyHostname, nil];
            [stubbedDefaults stub:@selector(objectForKey:) andReturn:nil withArguments:OEPDefaultsKeySSID, nil];
            sut = [[OEPViewModel alloc] init];
        });
        it(@"is not nil", ^{
            [[sut shouldNot] beNil];
        });
        it(@"has a blank string for username", ^{
            [[[sut username] should] equal:@""];
        });
        it(@"has a blank string for password", ^{
            [[[sut password] should] equal:@""];
        });
        it(@"has a blank string for ssid", ^{
            [[[sut ssid] should] equal:@""];
        });
        it(@"has a blank string for hostname", ^{
            [[[sut hostname] should] equal:@""];
        });
        it(@"has nil for photo data", ^{
            [[[sut photoData] should] beNil];
        });
    });
    context(@"when created and the user defaults for username, hostname and SSID return values", ^{
        NSString *expectedUsername = @"username";
        NSString *expectedHostname = @"hostname";
        NSString *expectedSSID = @"SSID";
        beforeEach(^{
            [stubbedDefaults stub:@selector(objectForKey:) andReturn:expectedUsername withArguments:OEPDefaultsKeyUsername, nil];
            [stubbedDefaults stub:@selector(objectForKey:) andReturn:expectedHostname withArguments:OEPDefaultsKeyHostname, nil];
            [stubbedDefaults stub:@selector(objectForKey:) andReturn:expectedSSID withArguments:OEPDefaultsKeySSID, nil];
            sut = [[OEPViewModel alloc] init];
        });
        it(@"sets the username from the defaults", ^{
            [[sut.username should] equal:expectedUsername];
        });
        it(@"sets the hostname from the defaults", ^{
            [[sut.hostname should] equal:expectedHostname];
        });
        it(@"sets the SSID from the defaults", ^{
            [[sut.ssid should] equal:expectedSSID];
        });
    });
    context(@"when the data properties are valid & correct", ^{
        __block NSData *photoData;
        __block OEPDataInterface *stubbedDataInterface;
        beforeEach(^{
            photoData = [@"teststring" dataUsingEncoding:NSUTF8StringEncoding];
            stubbedDataInterface = [[OEPDataInterface alloc] init];
            [stubbedDataInterface stub:@selector(uploadData:withFileName:) andReturn:[RACSignal empty]];
            [stubbedDataInterface stub:@selector(checkLogin) andReturn:[RACSignal empty]];
            [OEPDataInterface stub:@selector(sharedInterface) andReturn:stubbedDataInterface];
            
            sut = [[OEPViewModel alloc] init];
            sut.username = CorrectUsername;
            sut.password = CorrectPassword;
            sut.ssid = CorrectSSID;
            sut.hostname = CorrectHostname;
            sut.photoData = photoData;
            [sut stub:@selector(currentSSID) andReturn:CorrectSSID];
        });
        it(@"sets the username on the data interface", ^{
            [[stubbedDataInterface.username should] equal:CorrectUsername];
        });
        it(@"sets the password on the data interface", ^{
            [[stubbedDataInterface.password should] equal:CorrectPassword];
        });
        it(@"sets the server URL on the data interface", ^{
            [[stubbedDataInterface.serverURL should] equal:CorrectHostname];
        });
        it(@"returns a completed signal from upload photo", ^{
            [[theValue([[sut uploadPhoto] asynchronouslyWaitUntilCompleted:NULL]) should] beTrue];
        });
        it(@"calls upload file with the correct parameters on the Data Interface when upload photo is called", ^{
            [[[OEPDataInterface sharedInterface] should] receive:@selector(uploadData:withFileName:) withArguments:photoData, @"photo"];
            [[sut uploadPhoto] asynchronouslyWaitUntilCompleted:NULL];
        });
        it(@"errors when the upload data call on the Data Interface errors", ^{
            [stubbedDataInterface stub:@selector(uploadData:withFileName:) andReturn:[RACSignal error:[NSError errorWithDomain:@"domain" code:100 userInfo:nil]]];
            [[theValue([[sut uploadPhoto] asynchronouslyWaitUntilCompleted:NULL]) should] beFalse];
        });
        it(@"errors when the check login call on the Data Interface errors", ^{
            [stubbedDataInterface stub:@selector(checkLogin) andReturn:[RACSignal error:[NSError errorWithDomain:@"domain" code:100 userInfo:nil]]];
            [[theValue([[sut uploadPhoto] asynchronouslyWaitUntilCompleted:NULL]) should] beFalse];
        });
        it(@"errors when the SSID field is not the same as the returned network SSID", ^{
            sut.ssid = @"incorrectssid";
            [[theValue([[sut uploadPhoto] asynchronouslyWaitUntilCompleted:NULL]) should] beFalse];
        });
        it(@"saves the username to the defaults when upload photo is called", ^{
            [[sut uploadPhoto] asynchronouslyWaitUntilCompleted:NULL];
            [[[[NSUserDefaults standardUserDefaults] objectForKey:OEPDefaultsKeyUsername] should] equal:sut.username];
        });
        it(@"saves the hostname to the defaults when upload photo is called", ^{
            [[sut uploadPhoto] asynchronouslyWaitUntilCompleted:NULL];
            [[[[NSUserDefaults standardUserDefaults] objectForKey:OEPDefaultsKeyHostname] should] equal:sut.hostname];
        });
        it(@"saves the ssid to the defaults when the upload photo is called", ^{
            [[sut uploadPhoto] asynchronouslyWaitUntilCompleted:NULL];
            [[[[NSUserDefaults standardUserDefaults] objectForKey:OEPDefaultsKeySSID] should] equal:sut.ssid];
        });
        it(@"calls synchronise on the defaults when the upload photo is called", ^{
            [[[NSUserDefaults standardUserDefaults] should] receive:@selector(synchronize)];
            [[sut uploadPhoto] asynchronouslyWaitUntilCompleted:NULL];
        });
    });
});

SPEC_END