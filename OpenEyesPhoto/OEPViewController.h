//
//  OEPViewController.h
//  OpenEyesPhoto
//
//  Created by Will Jehring on 02/04/2014.
//  Copyright (c) 2014 Black Pear Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BPForms2/BPForms2.h>

@class OEPViewModel;
@interface OEPViewController : UIViewController <BPFormDelegate, BPFormDataSource>

@property (strong, nonatomic) OEPViewModel *viewModel;

@end
