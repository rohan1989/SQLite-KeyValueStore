//
//  DatabaseManager.m
//  KVStore
//
//  Created by Rohan Sonawane on 03/09/15.
//  Copyright (c) 2015 Rohan. All rights reserved.
//

#import "DatabaseManager.h"
#import <UIKit/UIKit.h>

static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@interface DatabaseManager()
{
    NSString *databasePath;
    NSOperationQueue *databaseOperationQueue;
}

@end

@implementation DatabaseManager

#pragma mark --------------------------------------------------------------
#pragma mark Shared Instance
#pragma mark --------------------------------------------------------------
+ (id)sharedDatabaseManager
{
    static DatabaseManager  *sharedDatabaseManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedDatabaseManager = [[self alloc]init];
    });
    return sharedDatabaseManager;
}

#pragma mark --------------------------------------------------------------
#pragma mark Intialization
#pragma mark --------------------------------------------------------------
- (BOOL)intializeDatabaseWithIsTesting:(BOOL)_isTesting
{
    NSArray *directoryPathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = directoryPathsArray[0];

    databasePath= [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent: _isTesting?@"kvstore_test_v4.db":@"kvstore_v4.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE table KVStore (StoreKey VARCHAR PRIMARY KEY, AnyObject BLOB);";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            NSLog(@"Error %s while preparing statement", sqlite3_errstr(sqlite3_errcode(database)));
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

#pragma mark --------------------------------------------------------------
#pragma mark Save Record
#pragma mark --------------------------------------------------------------
- (void)saveAnyObject:(id<NSCoding>)_anyObject WithKey:(NSString *)_keyString WithCompletion:(void (^)(BOOL success, NSError *error))completion
{    
    if(!databaseOperationQueue)
    {
        databaseOperationQueue = [[NSOperationQueue alloc] init];
        [databaseOperationQueue setMaxConcurrentOperationCount:1];
    }
    
    [databaseOperationQueue addOperationWithBlock:^{
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            const char *sql = "INSERT INTO KVStore (StoreKey, AnyObject) VALUES (?, ?)";
            sqlite3_stmt *statement;
            
            // Prepare the statement.
            if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {

                sqlite3_bind_text(statement, 1, [_keyString UTF8String], -1, SQLITE_STATIC);

                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_anyObject];
                sqlite3_bind_blob(statement, 2, [data bytes], [[NSNumber numberWithInteger:[data length]] intValue], SQLITE_TRANSIENT);
            }
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Error updating table1: %s", sqlite3_errmsg(database));
                NSError *error = [NSError errorWithDomain:@"Save Record Error" code:sqlite3_errcode(database) userInfo:@{@"Reason":[NSString stringWithFormat:@"%s", sqlite3_errstr(sqlite3_errcode(database))]}];
                completion(FALSE, error);
            }
            else{
                completion(TRUE, nil);
            }
            // Clean up and delete the resources used by the prepared statement.
            sqlite3_finalize(statement);
        }
    }];
}

#pragma mark --------------------------------------------------------------
#pragma mark Get Records
#pragma mark --------------------------------------------------------------
- (void)getAllRecordsWithCompletion:(void (^)(NSArray *_recordsArray, NSError *error))completion;
{
    if(!databaseOperationQueue)
    {
        databaseOperationQueue = [[NSOperationQueue alloc] init];
        [databaseOperationQueue setMaxConcurrentOperationCount:1];
    }
    
    [databaseOperationQueue addOperationWithBlock:^{
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            const char *selectSql = "SELECT StoreKey, AnyObject FROM KVStore";
            sqlite3_stmt *selectStatement;
            NSMutableArray *recordsArray = [[NSMutableArray alloc] init];
            
            if (sqlite3_prepare_v2(database, selectSql, -1, &selectStatement, NULL) == SQLITE_OK)
            {
                while (sqlite3_step(selectStatement) == SQLITE_ROW) {
                    const void *blobBytes = sqlite3_column_blob(selectStatement, 1);
                    int blobBytesLength = sqlite3_column_bytes(selectStatement, 1); // Count the number of bytes in the BLOB.
                    NSData *blobData = [NSData dataWithBytes:blobBytes length:blobBytesLength];
                    id _anyObject = [NSKeyedUnarchiver unarchiveObjectWithData:blobData];
                    [recordsArray addObject:_anyObject];
                }
                NSLog(@"recordsArray: %@", recordsArray);
                completion(recordsArray, [recordsArray count]?nil:[NSError errorWithDomain:@"Fetch Record Error" code:sqlite3_errcode(database) userInfo:@{@"Reason":[NSString stringWithFormat:@"%s", sqlite3_errstr(sqlite3_errcode(database))]}]);
                NSLog(@"Error updating table11: %s", sqlite3_errmsg(database));
                // Clean up the select statement
                sqlite3_finalize(selectStatement);
            }
            // Close the connection to the database.
            sqlite3_close(database);
        }
    }];
}

#pragma mark --------------------------------------------------------------
#pragma mark Delete Record
#pragma mark --------------------------------------------------------------
- (BOOL)removeObjectFromDatabaseForKey:(NSString *)_keyString
{
    BOOL success = FALSE;
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM KVStore WHERE StoreKey = \'%@\'", _keyString];
        const char *sqliteQuery = [querySQL UTF8String];

        if( sqlite3_prepare_v2(database, sqliteQuery, -1, &statement, NULL) == SQLITE_OK )
        {
                if(SQLITE_DONE != sqlite3_step(statement))
                {
                    success = FALSE;
                }
                else{
                    success = TRUE;
                    sqlite3_reset(statement);
                }
        }
        
        NSLog(@"Error %s while preparing statement", sqlite3_errstr(sqlite3_errcode(database)));
        NSLog(@"Error code: %d", sqlite3_errcode(database));
       
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return success;
}


#pragma mark --------------------------------------------------------------
#pragma mark Search
#pragma mark --------------------------------------------------------------
- (void)retriveObjectForKey:(NSString *)_keyString WithCompletion:(void (^)(id anyObject, NSError *error))completion
{
    NSLog(@"_keyString: %@", _keyString);
    if(!databaseOperationQueue)
    {
        databaseOperationQueue = [[NSOperationQueue alloc] init];
        [databaseOperationQueue setMaxConcurrentOperationCount:1];
    }
    [databaseOperationQueue addOperationWithBlock:^{
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            NSString *querySQL = [NSString stringWithFormat:@"select AnyObject FROM KVStore WHERE StoreKey = \"%@\"", _keyString];
            const char *query_stmt = [querySQL UTF8String];
            
            if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                id _anyObject = nil;
                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    int length = sqlite3_column_bytes(statement, 0);
                    NSData *data = [NSData dataWithBytes:sqlite3_column_blob(statement, 0) length:length];
                    
                    _anyObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                }
                completion(_anyObject, _anyObject?nil:[NSError errorWithDomain:@"Fetch Record Error" code:sqlite3_errcode(database) userInfo:@{@"Reason":[NSString stringWithFormat:@"%s", sqlite3_errstr(sqlite3_errcode(database))]}]);
                sqlite3_reset(statement);
            }
            else{
                completion(nil, [NSError errorWithDomain:@"Fetch Record Error" code:sqlite3_errcode(database) userInfo:@{@"Reason":[NSString stringWithFormat:@"%s", sqlite3_errstr(sqlite3_errcode(database))]}]);
            }
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
    }];
}

@end
