//
//  OEPDataInterfaceSpec.m
//  OpenEyesPhoto
//
//  Created by Will Jehring on 02/04/2014.
//  Copyright (c) 2014 Black Pear Software Ltd. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "OEPDataInterface.h"
#import "FTPManager.h"
#import <BPObjC/BPObjC.h>

#define TESTURLROOT @"Tankbook.local"
#define TESTURL @"Tankbook.local/testfolder"
#define TESTUSERNAME @"tester"
#define TESTPASSWORD @"TwoHappyMonkeyBeers"

#define TESTFOLDERNAME @"testfoldername"
#define TESTFILENAME @"testfile.txt"

SPEC_BEGIN(OEPDataInterfaceSpec)

describe(@"The OpenEyesPhoto Data Interface", ^{
    beforeAll(^{
        OEPDataInterface *dataInterface = [[OEPDataInterface alloc] init];
        dataInterface.username = TESTUSERNAME;
        dataInterface.password = TESTPASSWORD;
        dataInterface.serverURL = TESTURLROOT;
        [[dataInterface createNewFolderWithName:@"testfolder"] asynchronouslyWaitUntilCompleted:NULL];
        [dataInterface setServerURL:TESTURL];
        [[dataInterface createNewFolderWithName:@"test"] asynchronouslyWaitUntilCompleted:NULL];
    });
    afterAll(^{
        OEPDataInterface *dataInterface = [[OEPDataInterface alloc] init];
        dataInterface.username = TESTUSERNAME;
        dataInterface.password = TESTPASSWORD;
        dataInterface.serverURL = TESTURL;
        [[dataInterface deleteFileWithName:@"test"] asynchronouslyWaitUntilCompleted:NULL];
        [dataInterface setServerURL:TESTURLROOT];
        [[dataInterface deleteFileWithName:@"testfolder"] asynchronouslyWaitUntilCompleted:NULL];
    });
    __block OEPDataInterface *sut;
	context(@"when called with its shared accessor", ^{
        beforeEach(^{
            sut = [OEPDataInterface sharedInterface];
        });
        it(@"returns an object that is a member of the OEPDataInterface class", ^{
            [[sut should] beMemberOfClass:[OEPDataInterface class]];
        });
        it(@"returns the same object every time", ^{
            [[sut should] equal:[OEPDataInterface sharedInterface]];
        });
    });
    context(@"when created with init", ^{
        beforeEach(^{
            sut = [[OEPDataInterface alloc] init];
        });
        it(@"returns an object that is a member of the OEPDataInterface class", ^{
            [[sut should] beMemberOfClass:[OEPDataInterface class]];
        });
        it(@"has a blank server URL", ^{
            [[[sut serverURL] should] equal:@""];
        });
        it(@"has a blank username", ^{
            [[[sut username] should] equal:@""];
        });
        it(@"has a blank password", ^{
            [[[sut password] should] equal:@""];
        });
        it(@"returns error for check login", ^{
            [[theValue([[sut checkLogin] asynchronouslyWaitUntilCompleted:NULL]) should] beFalse];
        });
        it(@"returns error for contents of server", ^{
            [[theValue([[sut contentsOfServer] asynchronouslyWaitUntilCompleted:NULL]) should] beFalse];
        });
        it(@"returns error for create new folder", ^{
            [[theValue([[sut createNewFolderWithName:@"gfgh"] asynchronouslyWaitUntilCompleted:NULL]) should] beFalse];
        });
        it(@"returns error for delete file", ^{
            [[theValue([[sut deleteFileWithName:@"gfgh"] asynchronouslyWaitUntilCompleted:NULL]) should] beFalse];
        });
    });
    context(@"when created with the test server's settings", ^{
        beforeAll(^{
            sut = [[OEPDataInterface alloc] init];
            sut.serverURL = TESTURL;
            sut.username = TESTUSERNAME;
            sut.password = TESTPASSWORD;
        });
        it(@"returns success for check login", ^{
            [[theValue([[sut checkLogin] asynchronouslyWaitUntilCompleted:NULL]) should] beTrue];
        });
        it(@"returns error for check login if the internet is unreachable", ^{
            BPReachability *unreachable = [BPReachability reachabilityForInternetConnection];
            [unreachable stub:@selector(isReachable) andReturn:theValue(NO)];
            [BPReachability stub:@selector(reachabilityForInternetConnection) andReturn:unreachable];
            [[theValue([[sut checkLogin] asynchronouslyWaitUntilCompleted:NULL]) should] beFalse];
        });
        it(@"returns an array with one dictionary for contents of server next", ^{
            [[[[sut contentsOfServer] asynchronousFirstOrDefault:nil success:nil error:NULL] should] haveCountOf:1];
        });
        it(@"returns success for create new folder", ^{
            [[theValue([[sut createNewFolderWithName:TESTFOLDERNAME] asynchronouslyWaitUntilCompleted:NULL]) should] beTrue];
            [[sut deleteFileWithName:TESTFOLDERNAME] asynchronouslyWaitUntilCompleted:NULL];
        });
        it(@"returns success for delete file on a newly created folder", ^{
            [[sut createNewFolderWithName:TESTFOLDERNAME] asynchronouslyWaitUntilCompleted:NULL];
            [[theValue([[sut deleteFileWithName:TESTFOLDERNAME] asynchronouslyWaitUntilCompleted:NULL]) should] beTrue];
        });
        it(@"returns success for upload file", ^{
            [[theValue([[sut uploadData:[@"test" dataUsingEncoding:NSUTF8StringEncoding] withFileName:TESTFILENAME] asynchronouslyWaitUntilCompleted:NULL]) should] beTrue];
            [[sut deleteFileWithName:TESTFILENAME] asynchronouslyWaitUntilCompleted:NULL];
        });
        context(@"when a new folder is created", ^{
            beforeAll(^{
                [[sut createNewFolderWithName:TESTFOLDERNAME] asynchronouslyWaitUntilCompleted:NULL];
            });
            afterAll(^{
                [[sut deleteFileWithName:TESTFOLDERNAME] asynchronouslyWaitUntilCompleted:NULL];
            });
            it(@"returns an array with two dictionaries for contents of server next", ^{
                [[[[sut contentsOfServer] asynchronousFirstOrDefault:nil success:nil error:NULL] should] haveCountOf:2];
            });
            it(@"returns error when delete file is requested with an invalid name", ^{
                [[theValue([[sut deleteFileWithName:@"this name is invalid"] asynchronouslyWaitUntilCompleted:NULL]) should] beFalse];
            });
        });
        context(@"when an NSData object is uploaded", ^{
            __block NSData *sampleData;
            beforeAll(^{
                sampleData = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
                [[sut uploadData:sampleData withFileName:TESTFILENAME] asynchronouslyWaitUntilCompleted:NULL];
            });
            it(@"returns an array with two dictionaries for contents of server next", ^{
                __block NSArray *contents;
                [[sut contentsOfServer] subscribeNext:^(NSArray *resultAray) {
                    contents = resultAray;
                }];
                [[[[sut contentsOfServer] asynchronousFirstOrDefault:nil success:nil error:NULL] should] haveCountOf:2];
            });
            it(@"returns success for download file", ^{
                __block BOOL success = NO;
                [[sut downloadFileWithName:TESTFILENAME toDirectory:[NSURL fileURLWithPath:NSHomeDirectory()]] subscribeCompleted:^{
                    success = YES;
                }];
                [[theValue([[sut downloadFileWithName:TESTFILENAME toDirectory:[NSURL fileURLWithPath:NSHomeDirectory()]] asynchronouslyWaitUntilCompleted:NULL]) should] beTrue];
            });
            it(@"returns error for download file with incorrect name", ^{
                [[theValue([[sut downloadFileWithName:@"wrong name" toDirectory:[NSURL fileURLWithPath:NSHomeDirectory()]] asynchronouslyWaitUntilCompleted:NULL]) should] beFalse];
            });
            it(@"has a dictionary object in the contents of server list that matches the data passed in", ^{
                __block NSDictionary *matchingObject = nil;
                    [[[sut contentsOfServer] asynchronousFirstOrDefault:nil success:nil error:NULL] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                        if([[obj objectForKey:(id)kCFFTPResourceName] isEqualToString:TESTFILENAME]) {
                            matchingObject = obj;
                        };
                }];
                [[matchingObject should] beNonNil];
            });
            it(@"has a matching file for the data passed in when it downloads the test file", ^{
                [[sut downloadFileWithName:TESTFILENAME toDirectory:[NSURL fileURLWithPath:NSHomeDirectory()]] asynchronouslyWaitUntilCompleted:NULL];
                NSData *savedData = [NSData dataWithContentsOfURL:[[NSURL fileURLWithPath:NSHomeDirectory()] URLByAppendingPathComponent:TESTFILENAME]];
                [[savedData should] equal:sampleData];
            });
            afterAll(^{
                [[sut deleteFileWithName:TESTFILENAME] asynchronouslyWaitUntilCompleted:NULL];
            });
        });
    });
});
SPEC_END