//
//  BindingsViewsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 26.07.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "BindingsViewsDemoViewController.h"

#import "Employee.h"
#import "EmployeeHeaderView.h"
#import "EmployeeTableViewCell.h"
#import "EmployeeView.h"

@interface BindingsViewsDemoViewController ()

@property (nonatomic, strong) NSArray *employees;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet EmployeeView *employeeView;

@end

@implementation BindingsViewsDemoViewController {
@private
    NSInteger _currentEmployeeIndex;
}

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        Employee *employee1 = [[Employee alloc] init];
        employee1.fullName = @"Jack Bauer";
        employee1.age = @40;
        
        Employee *employee2 = [[Employee alloc] init];
        employee2.fullName = @"Tony Soprano";
        employee2.age = @46;
        
        Employee *employee3 = [[Employee alloc] init];
        employee3.fullName = @"Walter White";
        employee3.age = @52;
        
        self.employees = @[employee1, employee2, employee3];
    }
    return self;
}

#pragma mark Accessors and mutators

- (NSString *)numberOfEmployeesString
{
    return [NSString stringWithFormat:NSLocalizedString(@"%d employees", nil), [self.employees count]];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.rowHeight = [EmployeeTableViewCell height];
    self.tableView.sectionHeaderHeight = [EmployeeHeaderView height];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self changeEmployee];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Views", nil);
}

#pragma mark Updating data

- (void)changeEmployee
{
    _currentEmployeeIndex = (_currentEmployeeIndex + 1) % [self.employees count];
    self.employeeView.employee = [self.employees objectAtIndex:_currentEmployeeIndex];
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.employees count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EmployeeTableViewCell cellForTableView:tableView];
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmployeeTableViewCell *employeeCell = (EmployeeTableViewCell *)cell;
    employeeCell.employee = [self.employees objectAtIndex:indexPath.row];
    employeeCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [EmployeeHeaderView view];
}

#pragma mark Actions

- (IBAction)changeEmployee:(id)sender
{
    [self changeEmployee];
}

@end
