//
//  MainViewController.m
//  Diary
//
//  Created by Henry on 15/5/27.
//  Copyright (c) 2015年 unbirdlikebird. All rights reserved.
//

#import "MainViewController.h"
#import "FMDatabase.h"
#import "DetailViewController.h"

@interface MainViewController ()

@property (strong, nonatomic)   FMDatabase          *diaryDB;

@property (strong, nonatomic)   NSMutableArray      *arrayOfDiaryList;
@property                       NSArray             *arrayOfValuePass;
@end

@implementation MainViewController

#pragma mark Lazy Initiatiation
- (FMDatabase *)diaryDB{
    if (!_diaryDB) {
//        NSString *diaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"diary.sqlite"];
        NSString *diaryPath = [self.documentPath stringByAppendingPathComponent:@"diary.sqlite"];

        _diaryDB = [FMDatabase databaseWithPath:diaryPath];

//        if ([[NSFileManager defaultManager] fileExistsAtPath:diaryPath]) {
//            [[NSFileManager defaultManager] removeItemAtPath:diaryPath error:nil];
//        }

        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS DIARY ( ID INTEGER PRIMARY KEY AUTOINCREMENT, TIMESTAMP TEXT, SUBJECT CONTEXT DEFAULT 'NO SUBJECT', CONTENT TEXT DEFAULT 'NO CONTENT')"];

        if ([_diaryDB open]) {
            BOOL result = [self.diaryDB executeUpdate:sqlCreateTable];
            if (result) {
                NSLog(@"table created");
            }
            else{
                NSLog(@"table create failed");
            }
            [_diaryDB close];
        }
        else{
            NSLog(@"database connot open");
        }
    }
    return _diaryDB;
}

- (NSString *)documentPath{
    if (!_documentPath) {
        _documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSLog(@"_documentPath%@",_documentPath);
    }
    return _documentPath;
}

- (NSMutableArray *)arrayOfDiaryList{
    if (!_arrayOfDiaryList) {
        _arrayOfDiaryList = [[NSMutableArray alloc]init];

        if ([self.diaryDB open]) {
            FMResultSet *array = [self.diaryDB executeQuery:@"SELECT * FROM DIARY"];
            while ([array next]) {
                NSLog(@"%@", array);
                NSArray *tmpArray = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",[array intForColumn:@"ID"]], [array stringForColumn:@"TIMESTAMP"], [array stringForColumn:@"SUBJECT"], [array stringForColumn:@"CONTENT"], nil];

                if (![_arrayOfDiaryList containsObject:tmpArray]) {
                    [_arrayOfDiaryList addObject:tmpArray];
                    NSLog(@"%@", _arrayOfDiaryList);
                }
            }
            [self.diaryDB close];
        }
    }
    return _arrayOfDiaryList;
}

#pragma mark Database Operate

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tblOfDiaryList setDelegate:self];
    [self.tblOfDiaryList setDataSource:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didWriteNewDiary:) name:@"didWriteNewDiary" object:nil];
    // Do any additional setup after loading the view.

    self.title = NSLocalizedString(@"abc", nil);
}

- (void)didWriteNewDiary:(NSNotification *)notification{
    //if arr length > 0
    NSDictionary *dictOfValuePass = [notification userInfo];
    NSLog(@"dict = %@", dictOfValuePass);

    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd-MM-yyyy hh:mm:ss";
    NSString *stringOfDate = [dateFormatter stringFromDate:date];

    NSLog(@"%@", stringOfDate);
    
    if (self.arrayOfValuePass == nil) {

        if ([self.diaryDB open]) {

            BOOL res = [self.diaryDB executeUpdate:[NSString stringWithFormat:@"INSERT INTO DIARY (TIMESTAMP, SUBJECT, CONTENT) VALUES('%@', '%@', '%@')", stringOfDate, dictOfValuePass[@"SUBJECT"], dictOfValuePass[@"CONTENT"]]];
            NSLog(@"%d",res);
        }
        [self.diaryDB close];
    }
    //if arr length = 0
    else{
        if ([self.diaryDB open]) {

            [self.diaryDB executeUpdate:[NSString stringWithFormat:@"UPDATE DIARY SET TIMESTAMP = '%@', SUBJECT  = '%@', CONTENT = '%@' WHERE ID = %d", stringOfDate, dictOfValuePass[@"SUBJECT"], dictOfValuePass[@"CONTENT"], [[self.arrayOfValuePass objectAtIndex:0]intValue]]];
            [self.diaryDB close];
        }
    }

    self.arrayOfDiaryList = nil;
    [self.tblOfDiaryList reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DetailViewController *destination = segue.destinationViewController;

    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        self.arrayOfValuePass = nil;
    }
    else{
        destination.arrayOfDetail = self.arrayOfValuePass;
    }

    if ([segue.identifier isEqualToString:@"showDetails"]) {

        destination.arrayOfDetail = self.arrayOfValuePass;
        NSLog(@"prepareForSegue arrayOfValuePass%@", destination.arrayOfDetail);
//        UITextField *tex
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];

//        label.text sizeWithAttributes:(NSDictionary *)
    }
}


- (IBAction)btnClickToEdit:(UIBarButtonItem *)sender {
    [self.tblOfDiaryList setEditing:!self.tblOfDiaryList.editing animated:YES];
    if ([sender.title isEqualToString:@"edit"]) {
        [sender setTitle:@"finish"];
    }
    else{
        [sender setTitle:@"edit"];
    }
}


#pragma mark Tableview Delegate Method


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.arrayOfDiaryList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        NSLog(@"%@", self.arrayOfDiaryList);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.arrayOfValuePass = [[NSArray alloc]initWithArray:[self.arrayOfDiaryList objectAtIndex:indexPath.row]];
    [self performSegueWithIdentifier:@"showDetails" sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayOfDiaryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusecellIdentifier"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusecellIdentifier"];
    }

    UILabel *lblOfSubject = (UILabel *)[cell viewWithTag:100];
    lblOfSubject.text = [[self.arrayOfDiaryList objectAtIndex:indexPath.row]objectAtIndex:2];

    UILabel *lblOfTimestamp = (UILabel *)[cell viewWithTag:200];
    lblOfTimestamp.text = [[self.arrayOfDiaryList objectAtIndex:indexPath.row]objectAtIndex:1];
//    NSDate *date = [[self.arrayOfDiaryList objectAtIndex:indexPath.row]objectAtIndex:1];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//    dateFormatter.dateFormat = @"dd-MM-yyyy hh:mm:ss";
//    NSString *stringOfDate = [dateFormatter stringFromDate:date];
//
//    lblOfTimestamp.text = stringOfDate;
//
//    NSLog(@"%@", [NSDate date]);

    return cell;
}
@end
