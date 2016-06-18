//
//  ViewController.m
//  CalendarPickView
//
//  Created by Bao on 16/6/17.
//  Copyright © 2016年 www.microlink.im. All rights reserved.
//

#import "ViewController.h"
#import "FABirthPickerView.h"
#import "Masonry.h"

#define __kScreenWidth [[UIScreen mainScreen]bounds].size.width
#define WeakSelf __weak __typeof(self) weakSelf = self;

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,FABirthDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FABirthPickerView *pick;
@property (nonatomic, strong) UITextField *birthTextFeild;
@property(nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, copy) NSString *calendarFA;
@property (nonatomic, copy) NSString *yearFA;
@property (nonatomic, copy) NSString *mouthFA;
@property (nonatomic, copy) NSString *dayFA;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.title = @"修改生日";
    self.view.backgroundColor = [self colorWithHexString:@"EDEDF3"];
    self.view.userInteractionEnabled = YES;
    [self makeUI];
}

- (void)makeUI
{
    WeakSelf;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.width.equalTo(weakSelf.view.mas_width);
        make.height.equalTo(weakSelf.view.mas_height);
    }];
    
}


- (NSString *)nowTime
{
    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:time(NULL)];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dt];
    return [dateString substringToIndex:4];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:tableView.tableHeaderView.bounds];
    bgView.backgroundColor = [self colorWithHexString:@"EFEFF4"];
    
    UIView *whiteView = [[UIView alloc] init];
    whiteView.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:whiteView];
    
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView.mas_top).offset(30);
        make.left.and.right.equalTo(bgView);
        make.height.mas_equalTo(50);
    }];
    
    [whiteView addSubview:self.birthTextFeild];
    [self.birthTextFeild mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.height.equalTo(whiteView);
        make.left.equalTo(bgView.mas_left).offset(20);
        make.right.equalTo(bgView.mas_right).offset(-5);
    }];
    
    self.birthTextFeild.inputView = self.pick;
    _toolbar=[self setToolbarStyle];
    self.birthTextFeild.inputAccessoryView = self.toolbar;
    return bgView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 200;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    return cell;
}

#pragma mark - 代理
- (void)birthdayPickView:(FABirthPickerView *)picker finishPickCalendar:(NSString *)calendar withYear:(NSString *)year withMouth:(NSString *)mouth withDay:(NSString *)day
{
    [self.birthTextFeild setText:[NSString stringWithFormat:@"%@ %@ %@",year,mouth,day]];
    self.calendarFA = calendar;
    self.yearFA = year;
    self.mouthFA = mouth;
    self.dayFA = day;
    NSLog(@"%@ -- %@  %@ %@ ",calendar,year,mouth,day);
}


-(UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.sectionFooterHeight = 0;
        _tableView.rowHeight = 0;
        //cell 解决分割线偏移
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
        {
            [_tableView   setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
        {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _tableView;
}

- (UITextField *)birthTextFeild {
    if(_birthTextFeild == nil) {
        _birthTextFeild = [[UITextField alloc] init];
        
        _birthTextFeild.borderStyle = UITextBorderStyleNone;
        _birthTextFeild.clearButtonMode = UITextFieldViewModeWhileEditing;
        _birthTextFeild.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
       // _birthTextFeild.text = self.bithdayStr;
        //关闭大写
        [_birthTextFeild setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_birthTextFeild setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        _birthTextFeild.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"请选择生日"] attributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:215/255.0f green:215/255.0f blue:215/255.0f alpha:1.0f], NSFontAttributeName : [UIFont systemFontOfSize:16.0]}];
    }
    return _birthTextFeild;
}



- (FABirthPickerView *)pick {
    if(_pick == nil) {
        _pick = [[FABirthPickerView alloc] init];
        _pick.birthDelegate = self;
    }
    return _pick;
}


-(UIToolbar *)setToolbarStyle{
    UIToolbar *toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, __kScreenWidth, 40)];
    UIBarButtonItem *lefttem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    
    UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *right=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    toolbar.items=@[lefttem,centerSpace,right];
    return toolbar;
}

-(void)remove{
    [UIView animateWithDuration:0.25 animations:^{
        [self.birthTextFeild resignFirstResponder];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [self remove];
}






- (UIColor *) colorWithHexString: (NSString *)color
{
    if (color == nil)
        return [UIColor clearColor];
    
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}




@end
