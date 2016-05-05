//
//  OEPDataInterface.h
//  OpenEyesPhoto
//
//  Created by Will Jehring on 02/04/2014.
//  Copyright (c) 2014 Black Pear Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OEPDataInterface : NSObject

+ (instancetype)sharedInterface;

@property (strong, nonatomic) NSString *serverURL;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

/**
 *    Checks login on the server - returns either a completed or an error depending on result
 *
 *    @return An RACSignal that will error or complete
 */
- (RACSignal *)checkLogin;

/**
 *    Gets an NSArray of NSDictionary objects representing files on the server
 *
 *    @return An RACSignal that will return a list of files as an NSArray
 */
- (RACSignal *)contentsOfServer;

/**
 *    Creates a folder on the server with the specified name
 *
 *    @param folderName The name of the folder to create
 *
 *    @return An RACSignal that completes if successful or errors if not
 */
- (RACSignal *)createNewFolderWithName:(NSString *)folderName;

/**
 *    Deletes a file with the given name, or a folder, if empty
 *
 *    @param fileName The name of the file to delete
 *
 *    @return An RACSignal that completes if successful or errors if not
 */
- (RACSignal *)deleteFileWithName:(NSString *)fileName;

/**
 *    Uploads the data, giving it the provided name
 *
 *    @param data     The data to upload
 *    @param fileName The name for the uploaded file
 *
 *    @return A signal that completes or errors
 */
- (RACSignal *)uploadData:(NSData *)data withFileName:(NSString *)fileName;

/**
 *    Downloads the file with the provided name to the specified directory
 *
 *    @param fileName  The name of the file to download
 *    @param directory The directory to save the file in
 *
 *    @return A signal that completes or errors
 */
- (RACSignal *)downloadFileWithName:(NSString *)fileName toDirectory:(NSURL *)directory;

@end
