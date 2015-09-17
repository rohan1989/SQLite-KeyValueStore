//
//  AddNewRecordViewController.m
//  KVStore
//
//  Created by Rohan Sonawane on 03/09/15.
//  Copyright (c) 2015 Rohan. All rights reserved.
//

#import "AddNewRecordViewController.h"
#import "DatabaseManager.h"
#import "Employee.h"

@interface AddNewRecordViewController ()<UITextFieldDelegate>
{
    
    __weak IBOutlet UITextField *employeeIDTextfield;
    __weak IBOutlet UITextField *employeeNameTextfield;
    __weak IBOutlet UITextField *employeeDepartmentTextfield;
    
}
@end

@implementation AddNewRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark --------------------------------------------------------------
#pragma mark Textfield Delegates
#pragma mark --------------------------------------------------------------
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

#pragma mark --------------------------------------------------------------
#pragma mark Button Actions
#pragma mark --------------------------------------------------------------
- (IBAction)saveRecordButtonAction:(id)sender {
    if([self validateFields])
    {
        Employee *employee = [[Employee alloc] initWithDepartment:employeeDepartmentTextfield.text WithID:employeeIDTextfield.text WithName:employeeNameTextfield.text];
        [[DatabaseManager sharedDatabaseManager] saveAnyObject:employee WithKey:employee.employeeID WithCompletion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(success && !error)
                {
                    [self showAlertWithMesage:@"Successfully save record." WithTitle:@"Save Success"];
                }
                else{
                    [self showAlertWithMesage:(error.code == 19)?@"Key already exists in database.":@"An error occurred while saving record." WithTitle:error.domain];
                }
            });
        }];
    }
}

#pragma mark --------------------------------------------------------------
#pragma mark Validations
#pragma mark --------------------------------------------------------------
- (BOOL)validateFields
{
    if(![employeeIDTextfield.text length] || ![employeeNameTextfield.text length] || ![employeeDepartmentTextfield.text length])
    {
        [self showAlertWithMesage:@"Fields cannot be left empty" WithTitle:@"Empty fields"];
        return FALSE;
    }
    if([employeeIDTextfield isFirstResponder])
    {
        [employeeIDTextfield resignFirstResponder];
    }
    if([employeeNameTextfield isFirstResponder])
    {
        [employeeNameTextfield resignFirstResponder];
    }
    if([employeeDepartmentTextfield isFirstResponder])
    {
        [employeeDepartmentTextfield resignFirstResponder];
    }
    return TRUE;
}

#pragma mark --------------------------------------------------------------
#pragma mark Alert View
#pragma mark --------------------------------------------------------------
- (void)showAlertWithMesage:(NSString *)_alertMessage WithTitle:(NSString *)_alertTitle
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_alertTitle message:_alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}


@end
