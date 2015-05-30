//
//  MainViewController.h
//  Diary
//
//  Created by Henry on 15/5/27.
//  Copyright (c) 2015年 unbirdlikebird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnOfNewDiary;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnOfEditList;
@property (weak, nonatomic) IBOutlet UITableView *tblOfDiaryList;
@property (strong, nonatomic)   NSString        *documentPath;

- (IBAction)btnClickToEdit:(UIBarButtonItem *)sender;

@end
