//
//  TestDataBase.m
//  KVStore
//
//  Created by Rohan Sonawane on 03/09/15.
//  Copyright (c) 2015 Rohan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DatabaseManager.h"
#import "Employee.h"

@interface TestDataBase : XCTestCase
{
    DatabaseManager *sharedManager;
}
@end

@implementation TestDataBase

- (void)setUp {
    [super setUp];
    sharedManager = [DatabaseManager sharedDatabaseManager];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDatabaseSharedObject
{
    XCTAssertNotNil(sharedManager);
}

- (void)testDatabaseCreation {
    // This is an example of a functional test case.
    XCTAssert([sharedManager intializeDatabaseWithIsTesting:TRUE], @"Failed to create database with filename kvstore_test_v1.db");
}

- (void)testSaveRecord
{
    XCTestExpectation *saveRecordExpectation = [self expectationWithDescription:@"Save a record in database"];
    
    Employee *_employee = [[Employee alloc] initWithDepartment:[NSString stringWithFormat:@"Random department: %d", (arc4random() % 10000)] WithID:[NSString stringWithFormat:@"Random employee ID: %d", (arc4random() % 10000)] WithName:[NSString stringWithFormat:@"Random name: %d", (arc4random() % 10000)]];
    XCTAssertNotNil(_employee.employeeID);
    XCTAssertNotNil(_employee.employeeName);
    XCTAssertNotNil(_employee.employeeDepartment);

    [sharedManager saveAnyObject:_employee WithKey:_employee.employeeID WithCompletion:^(BOOL success, NSError *error) {
        XCTAssert(success, @"%@", error);
        [saveRecordExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        
    }];
}


- (void)testGetAllRecords
{
    __block NSArray *recordsArray = nil;
    XCTestExpectation *getAllRecordsExpectation = [self expectationWithDescription:@"Get all records from database."];
    [sharedManager getAllRecordsWithCompletion:^(NSArray *_recordsArray, NSError *error) {
        NSLog(@"_recordsArray: %@", _recordsArray);
        XCTAssert([_recordsArray count], @"%@", error);
        recordsArray = [[NSArray alloc] initWithArray:_recordsArray];
        [getAllRecordsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error);
        
        for (Employee *_employee in recordsArray) {
            XCTAssertNotNil(_employee.employeeID);
            XCTAssertNotNil(_employee.employeeName);
            XCTAssertNotNil(_employee.employeeDepartment);
        }
    }];
}

- (void)testSearchKey
{
    __block Employee *employee;
    NSString *key = [NSString stringWithFormat:@"Random employee ID: %d", (arc4random() % 10000)];
    
    XCTestExpectation *getRecordExpectation = [self expectationWithDescription:@"Get a record from database."];
    [sharedManager retriveObjectForKey:key WithCompletion:^(id anyObject, NSError *error) {
        XCTAssert(anyObject, @"%@", error);
        employee = (Employee *)anyObject;
        [getRecordExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertNotNil(employee.employeeID);
        XCTAssertNotNil(employee.employeeName);
        XCTAssertNotNil(employee.employeeDepartment);
    }];
}

- (void)testDeleteKey
{
    NSString *key = [NSString stringWithFormat:@"Random employee ID: %d", (arc4random() % 10000)];
    XCTAssert(![sharedManager removeObjectFromDatabaseForKey:key], @"Failed to delete key: %@", key);
}




@end
