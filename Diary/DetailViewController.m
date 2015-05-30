//
//  DetailViewController.m
//  Diary
//
//  Created by Henry on 15/5/27.
//  Copyright (c) 2015年 unbirdlikebird. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *tvOfDiaryContent;
@property (weak, nonatomic) IBOutlet UITextField *tfOfDiarySubject;

@end

@implementation DetailViewController

- (NSArray *)arrayOfDetail{
    if (!_arrayOfDetail) {
        _arrayOfDetail = [[NSArray alloc]init];
    }
    return _arrayOfDetail;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.arrayOfDetail);
    if ([self.arrayOfDetail count] > 0) {
        self.tfOfDiarySubject.text = [self.arrayOfDetail objectAtIndex:2];
        self.tvOfDiaryContent.text = [self.arrayOfDetail objectAtIndex:3];
    }

//    self.tvOfDiaryContent.suto
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
- (IBAction)btnClickToSave:(UIBarButtonItem *)sender {
    if (self.tfOfDiarySubject.text.length > 0 || self.tvOfDiaryContent.text.length > 0 ) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"didWriteNewDiary" object:nil userInfo:@{@"SUBJECT" : self.tfOfDiarySubject.text, @"CONTENT" : self.tvOfDiaryContent.text}];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    CGRect inputRect = textView.frame;
    inputRect.size = CGSizeMake(textView.frame.size.width, textView.frame.size.height - 216);
    textView.inputView.frame = inputRect;

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    textView.inputView.frame = textView.frame;

    return YES;
}






@end
