//
//  Employee.m
//  KVStore
//
//  Created by Rohan Sonawane on 07/09/15.
//  Copyright (c) 2015 Rohan. All rights reserved.
//

#define DEPARTMENT_KEY @"departmentKey"
#define EMPLOYEE_ID_KEY @"employeeIDKey"
#define NAME_KEY @"nameKey"

#import "Employee.h"

@implementation Employee
@synthesize employeeDepartment, employeeID, employeeName;

- (id)initWithDepartment:(NSString *)_department WithID:(NSString *)_id WithName:(NSString *)_name;
{
    self = [super init];
    if (self) {
        employeeDepartment = _department;
        employeeID = _id;
        employeeName = _name;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *_department = [decoder decodeObjectOfClass:[NSString class] forKey:DEPARTMENT_KEY];
    NSString *_id = [decoder decodeObjectOfClass:[NSString class] forKey:EMPLOYEE_ID_KEY];
    NSString *_name = [decoder decodeObjectOfClass:[NSString class] forKey:NAME_KEY];
    self = [self initWithDepartment:_department WithID:_id WithName:_name];
    if (!self) {
        return nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:employeeDepartment forKey:DEPARTMENT_KEY];
    [coder encodeObject:employeeID forKey:EMPLOYEE_ID_KEY];
    [coder encodeObject:employeeName forKey:NAME_KEY];
}



@end
