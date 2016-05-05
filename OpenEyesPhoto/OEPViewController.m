//
//  OEPViewController.m
//  OpenEyesPhoto
//
//  Created by Will Jehring on 02/04/2014.
//  Copyright (c) 2014 Black Pear Software Ltd. All rights reserved.
//

#import "OEPViewController.h"
#import "OEPDataInterface.h"
#import <BPForms2/BPForms2.h>
#import "OEPViewModel.h"
#import <BPComponents_iOS/SVProgressHUD.h>

@interface OEPViewController ()

@end

@implementation OEPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _viewModel = [[OEPViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = @"EyeApp";
    [super viewDidLoad];
    BPFormController *dataFormController = [self dataFormController];
    [self addChildViewController:dataFormController];
    [self.view addSubviewWithFullSizeConstraints:dataFormController.view];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel setActive:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel setActive:NO];
}

#pragma mark Private
- (BPFormController *)dataFormController {
    BPFRootElement *root = [[BPFRootElement alloc] initWithJSONFile:[[NSBundle mainBundle] pathForResource:@"EyeApp" ofType:@"bpfrm"]];
    [root populateFromDataSource:self];
    root.delegate = self;
    BPFormController *controller = [[BPFormController alloc] initWithRoot:root];
    return controller;
}

#pragma mark BPFormDataSource
- (id)valueForElementWithKey:(NSString *)key {
    if ([key isEqualToString:OEPFormKeyUsername]) {
        return self.viewModel.username;
    }
    if ([key isEqualToString:OEPFormKeyHostname]) {
        return self.viewModel.hostname;
    }
    if ([key isEqualToString:OEPFormKeySSID]) {
        return self.viewModel.ssid;
    }
    return nil;
}

#pragma mark BPFormDelegate
- (void)valueChangedForKey:(NSString *)key value:(id)value root:(BPFRootElement *)root {
    if ([key isEqualToString:OEPFormKeyUsername]) {
        if ([value isKindOfClass:[NSString class]]) {
            self.viewModel.username = value;
        }
    }
    if ([key isEqualToString:OEPFormKeyPassword]) {
        if ([value isKindOfClass:[NSString class]]) {
            self.viewModel.password = value;
        }
    }
    if ([key isEqualToString:OEPFormKeySSID]) {
        if ([value isKindOfClass:[NSString class]]) {
            self.viewModel.ssid = value;
        }
    }
    if ([key isEqualToString:OEPFormKeyHostname]) {
        if ([value isKindOfClass:[NSString class]]) {
            self.viewModel.hostname = value;
        }
    }
}

- (void)buttonTouchedWithKey:(NSString *)key root:(BPFRootElement *)root {
    if ([key isEqualToString:OEPFormKeyUploadButton]) {
        BPFImageElement *photoElement = [root bpfEntityForKey:OEPFormKeyPhoto];
        if (photoElement) {
            self.viewModel.photoData = photoElement.document.documentData;
        }
        [SVProgressHUD showWithStatus:@"Uploading"];
        [[[self.viewModel uploadPhoto] deliverOn:[RACScheduler mainThreadScheduler]] subscribeError:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } completed:^{
            [SVProgressHUD showSuccessWithStatus:@"Upload Complete"];
        }];
    }
}


@end
