//
//  ViewController.m
//  KVStore
//
//  Created by Rohan Sonawane on 02/09/15.
//  Copyright (c) 2015 Rohan. All rights reserved.
//

#import "ViewController.h"
#import "DatabaseManager.h"
#import "Employee.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSMutableArray *recordsArray;
    __weak IBOutlet UITableView *recordsTableView;
    __weak IBOutlet UISearchBar *searchBar;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL dataBaseSuccesfullyCreated = [[DatabaseManager sharedDatabaseManager] intializeDatabaseWithIsTesting:FALSE];
    
    if(!dataBaseSuccesfullyCreated)
    {
        [self showAlertWithMesage:@"An error occured while creating database." WithTitle:@"Database creation failed"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateAllRecordsAndRefreshTableView];
}

- (void)populateAllRecordsAndRefreshTableView
{
    if(!recordsArray)
    {
        recordsArray = [[NSMutableArray alloc] init];
    }
    [recordsArray removeAllObjects];
    [[DatabaseManager sharedDatabaseManager] getAllRecordsWithCompletion:^(NSArray *_recordsArray, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_recordsArray && [_recordsArray count])
            {
                [recordsArray addObjectsFromArray:_recordsArray];
            }
            [recordsTableView reloadData];
        });
    }];
}

#pragma mark --------------------------------------------------------------
#pragma mark TableView Datasources And Delegates
#pragma mark --------------------------------------------------------------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [recordsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tableViewCell == nil) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [tableViewCell setBackgroundColor:[UIColor lightTextColor]];
        [tableViewCell setEditing:TRUE animated:TRUE];
    }
    
    Employee *_employee = (Employee *)[recordsArray objectAtIndex:indexPath.row];
    
    [tableViewCell.textLabel setText:[NSString stringWithFormat:@"Name: %@   Key:%@", _employee.employeeName, _employee.employeeID]];
    [tableViewCell.detailTextLabel setText:[NSString stringWithFormat:@"Department: %@", _employee.employeeDepartment]];
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        Employee *_employee = [recordsArray objectAtIndex:indexPath.row];
        NSLog(@"ID: %@", _employee.employeeID);
        
        if([[DatabaseManager sharedDatabaseManager] removeObjectFromDatabaseForKey:_employee.employeeID])
        {
            [self populateAllRecordsAndRefreshTableView];
            [self showAlertWithMesage:[NSString stringWithFormat:@"Successfully removed employee with ID key: %@", _employee.employeeID]  WithTitle:@"Employee Removed"];
        }
        else
        {
            [self showAlertWithMesage:[NSString stringWithFormat:@"Failed to delete key: %@", _employee.employeeID]  WithTitle:@"Delete Failed!"];
        }
    }
}

#pragma mark --------------------------------------------------------------
#pragma mark Alert View
#pragma mark --------------------------------------------------------------
- (void)showAlertWithMesage:(NSString *)_alertMessage WithTitle:(NSString *)_alertTitle
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_alertTitle message:_alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark --------------------------------------------------------------
#pragma mark Search Bar Delegates
#pragma mark --------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    if([_searchBar.text length])
    {
        [[DatabaseManager sharedDatabaseManager] retriveObjectForKey:_searchBar.text WithCompletion:^(id anyObject, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Employee *_employee = (Employee *)anyObject;
                if(_employee && !error)
                {
                    if(!recordsArray)
                    {
                        recordsArray = [[NSMutableArray alloc] init];
                    }
                    [recordsArray removeAllObjects];
                    [recordsArray addObject:_employee];
                    [recordsTableView reloadData];
                }
                else{
                    [self populateAllRecordsAndRefreshTableView];
                    [self showAlertWithMesage:[NSString stringWithFormat:@"Failed to search employee with ID key: %@", _searchBar.text]  WithTitle:@"Search Failed"];
                }
            });
        }];
    }
    
    [_searchBar resignFirstResponder];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar setText:@""];
    [_searchBar resignFirstResponder];
    [self populateAllRecordsAndRefreshTableView];
}

@end
