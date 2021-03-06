//
//  MyRadioButtonsPopupSampleViewController.m
//  CJRadioDemo
//
//  Created by ciyouzen on 15/11/11.
//  Copyright (c) 2015年 dvlproad. All rights reserved.
//

#import "MyRadioButtonsPopupSampleViewController.h"
#import "TestDataUtil.h"


@interface MyRadioButtonsPopupSampleViewController () <DemoPopupRadioButtonsDataSource> {
    
}

@end

@implementation MyRadioButtonsPopupSampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *titles = @[@"人物", @"爱好", @"其他", @"地区"];
    DemoPopupRadioButtons *radioButtonsDropDownSample = [[DemoPopupRadioButtons alloc] init];
    [radioButtonsDropDownSample setFrame:CGRectMake(20, 300, 380, 40)];
    [radioButtonsDropDownSample setupWithTitles:titles
                                  dropDownImage:[UIImage imageNamed:@"arrowDown_dark"]
                                 popupSuperview:self.view
                              popupType:CJRadioButtonsPopupTypeUnderAll];
    radioButtonsDropDownSample.radioButtonsPopupSampleDataSource = self;
    [self.view addSubview:radioButtonsDropDownSample];
    self.radioButtonsDropDownSample = radioButtonsDropDownSample;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.radioButtonsDropDownSample scollToCurrentSelectedViewWithAnimated:NO];
}

- (UIView *)cj_RadioButtonsPopupSample:(DemoPopupRadioButtons *)radioButtonsPopupSample viewForButtonIndex:(NSInteger)index {
    UIView *popupView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    popupView.backgroundColor = [UIColor greenColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(20, 50, 280, 44)];
    NSString *title = [NSString stringWithFormat:@"%ld.生成随机数，并设置", index];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:btn];
    
    return popupView;
}

- (IBAction)btnAction:(UIButton *)sender {
    NSString *title = [NSString stringWithFormat:@"%d", rand()%10];
    
//    [self.radioButtonsDropDownSample cj_hideExtendViewAnimated:YES];
    [sender.superview cj_hidePopupView];
    
    [self.radioButtonsDropDownSample changeCurrentRadioButtonStateAndTitle:title];
    [self.radioButtonsDropDownSample setSelectedNone];
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

@end
