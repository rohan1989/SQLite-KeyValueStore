//
//  Employee.h
//  KVStore
//
//  Created by Rohan Sonawane on 07/09/15.
//  Copyright (c) 2015 Rohan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Employee : NSObject<NSCoding>

@property(nonatomic, retain)NSString *employeeID;
@property(nonatomic, retain)NSString *employeeName;
@property(nonatomic, retain)NSString *employeeDepartment;

- (id)initWithDepartment:(NSString *)_department WithID:(NSString *)_id WithName:(NSString *)_name;

@end
