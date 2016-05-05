//
//  OEPViewControllerSpec.m
//  OpenEyesPhoto
//
//  Created by Will Jehring on 09/04/2014.
//  Copyright (c) 2014 Black Pear Software Ltd. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "OEPViewController.h"
#import "OEPViewModel.h"

SPEC_BEGIN(OEPViewControllerSpec)

describe(@"The OEP View Controller", ^{
    __block OEPViewController *sut;
	context(@"when created", ^{
        NSString *initialUsername = @"initialuser";
        NSString *initialHostname = @"initialhostname";
        NSString *initialSSID = @"initialSSID";
        beforeEach(^{
            sut = [[OEPViewController alloc] initWithNibName:nil bundle:nil];
            sut.viewModel.username = initialUsername;
            sut.viewModel.hostname = initialHostname;
            sut.viewModel.ssid = initialSSID;
        });
        it(@"is not nil", ^{
            [[sut shouldNot] beNil];
        });
        it(@"conforms to the BPFormDelegate protocol", ^{
            [[sut should] conformToProtocol:@protocol(BPFormDelegate)];
        });
        it(@"conforms to the BPFormDatasource protocol", ^{
            [[sut should] conformToProtocol:@protocol(BPFormDataSource)];
        });
        it(@"changes the username on the view model to the value changed for key OEPFormKeyUsername value", ^{
            NSString *testValue = @"testuser";
            [sut valueChangedForKey:OEPFormKeyUsername value:testValue root:nil];
            [[[sut.viewModel username] should] equal:testValue];
        });
        it(@"changes the password on the view model to the value changed for key OEPFormKeyPassword value", ^{
            NSString *testValue = @"testpassword";
            [sut valueChangedForKey:OEPFormKeyPassword value:testValue root:nil];
            [[[sut.viewModel password] should] equal:testValue];
        });
        it(@"changes the ssid on the view model to the value changed for key OEPFormKeySSID value", ^{
            NSString *testValue = @"testssid";
            [sut valueChangedForKey:OEPFormKeySSID value:testValue root:nil];
            [[[sut.viewModel ssid] should] equal:testValue];
        });
        it(@"changes the hostname on the view model to the value changed for key OEPFormKeyHostname value", ^{
            NSString *testValue = @"testhost";
            [sut valueChangedForKey:OEPFormKeyHostname value:testValue root:nil];
            [[[sut.viewModel hostname] should] equal:testValue];
        });
        it(@"calls upload photo on the viewmodel when the upload button is pressed", ^{
            [[sut.viewModel should] receive:@selector(uploadPhoto)];
            [sut buttonTouchedWithKey:OEPFormKeyUploadButton root:nil];
        });
        it(@"returns the viewModel's username for the value for element with username key", ^{
            [[[sut valueForElementWithKey:OEPFormKeyUsername] should] equal:initialUsername];
        });
        it(@"returns the viewModel's hostname for the value for element with hostname key", ^{
            [[[sut valueForElementWithKey:OEPFormKeyHostname] should] equal:initialHostname];
        });
        it(@"returns the viewModel's ssid for the value for element with ssid key", ^{
            [[[sut valueForElementWithKey:OEPFormKeySSID] should] equal:initialSSID];
        });
    });
});

SPEC_END