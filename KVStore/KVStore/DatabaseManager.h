//
//  DatabaseManager.h
//  KVStore
//
//  Created by Rohan Sonawane on 03/09/15.
//  Copyright (c) 2015 Rohan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseManager : NSObject

//This function will return a shared instance of DatabaseManager class
+ (id)sharedDatabaseManager;

//Use this method to create database file and database table.
//Pass TRUE/FALSE value to _isTesting param to segregate application and testing databases.
- (BOOL)intializeDatabaseWithIsTesting:(BOOL)_isTesting;


//use this method to save Key/Value record in database
//pass any object here provided the it has implemented "initWithCoder:", "encodeWithCoder:" and conforms to NSCoding protocol
//use completion block to get the results.
- (void)saveAnyObject:(id<NSCoding>)_anyObject WithKey:(NSString *)_keyString WithCompletion:(void (^)(BOOL success, NSError *error))completion;

//use this method to fetch all the Key/Value records from the database
//completion block will give the array of records.
- (void)getAllRecordsWithCompletion:(void (^)(NSArray *_recordsArray, NSError *error))completion;

//use this method to remove value/record
//pass key string
//returns TRUE on success
- (BOOL)removeObjectFromDatabaseForKey:(NSString *)_keyString;

//use this method to get a specifie record with key
//completion block will give the object associated with the key
- (void)retriveObjectForKey:(NSString *)_keyString WithCompletion:(void (^)(id anyObject, NSError *error))completion;

@end
