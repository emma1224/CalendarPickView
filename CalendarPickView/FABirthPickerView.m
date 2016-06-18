
//
//  FABirthPickerView.m
//  Facework
//
//  Created by Bao on 16/6/13.
//  Copyright © 2016年 www.Microlink.im. All rights reserved.
//

#import "FABirthPickerView.h"

#define __kScreenWidth [[UIScreen mainScreen]bounds].size.width

static long lunarInfo[] = { 0x04bd8, 0x04ae0, 0x0a570, 0x054d5, 0x0d260, 0x0d950, 0x16554, 0x056a0, 0x09ad0, 0x055d2, 0x04ae0, 0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540, 0x0d6a0, 0x0ada2, 0x095b0, 0x14977, 0x04970, 0x0a4b0, 0x0b4b5, 0x06a50, 0x06d40, 0x1ab54, 0x02b60, 0x09570, 0x052f2, 0x04970, 0x06566, 0x0d4a0, 0x0ea50, 0x06e95, 0x05ad0, 0x02b60, 0x186e3, 0x092e0, 0x1c8d7, 0x0c950, 0x0d4a0, 0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4, 0x025d0, 0x092d0, 0x0d2b2, 0x0a950, 0x0b557, 0x06ca0, 0x0b550, 0x15355, 0x04da0, 0x0a5d0, 0x14573, 0x052d0, 0x0a9a8, 0x0e950, 0x06aa0, 0x0aea6, 0x0ab50, 0x04b60, 0x0aae4, 0x0a570, 0x05260, 0x0f263, 0x0d950, 0x05b57, 0x056a0, 0x096d0, 0x04dd5, 0x04ad0, 0x0a4d0, 0x0d4d4, 0x0d250, 0x0d558, 0x0b540, 0x0b5a0, 0x195a6, 0x095b0, 0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50, 0x06d40, 0x0af46, 0x0ab60, 0x09570, 0x04af5, 0x04970, 0x064b0, 0x074a3, 0x0ea50, 0x06b58, 0x055c0, 0x0ab60, 0x096d5, 0x092e0, 0x0c960, 0x0d954, 0x0d4a0, 0x0da50, 0x07552, 0x056a0, 0x0abb7, 0x025d0, 0x092d0, 0x0cab5, 0x0a950, 0x0b4a0, 0x0baa4, 0x0ad50, 0x055d9, 0x04ba0, 0x0a5b0, 0x15176, 0x052b0, 0x0a930, 0x07954, 0x06aa0, 0x0ad50, 0x05b52, 0x04b60, 0x0a6e6, 0x0a4e0, 0x0d260, 0x0ea65, 0x0d530, 0x05aa0, 0x076a3, 0x096d0, 0x04bd7, 0x04ad0, 0x0a4d0, 0x1d0b6, 0x0d250, 0x0d520, 0x0dd45, 0x0b5a0, 0x056d0, 0x055b2, 0x049b0, 0x0a577, 0x0a4b0, 0x0aa50, 0x1b255, 0x06d20, 0x0ada0 };

@interface FABirthPickerView () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong)NSArray *arr;
@property (nonatomic, strong)NSMutableArray *yearArr;
@property (nonatomic, strong)NSMutableArray *mouthArr;
@property (nonatomic, strong)NSMutableArray *dayArr;

@property (nonatomic, copy) NSString *calendar;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *mouth;
@property (nonatomic, copy) NSString *day;

@property (nonatomic, assign) NSInteger calendarRow;
@property (nonatomic, assign) NSInteger yearRow;
@property (nonatomic, assign) NSInteger mouthRow;
@property (nonatomic, assign) NSInteger dayRow;


@property (nonatomic, strong) NSMutableArray *dayDataSource;//假的农历数据

@end

@implementation FABirthPickerView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor whiteColor];
        self.calendarRow = self.yearRow = self.mouthRow = self.dayRow = 0;
        self.arr = @[@"公历",@"农历"];
    }
    return self;
}

/**
 *  获取最新的年份
 */
- (NSString *)nowTime
{
    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:time(NULL)];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dt];
    return [dateString substringToIndex:4];
}

/**
 *  获取农历 公历 每月有多少天
 *
 *  @param year  年
 *  @param mouth 月
 *
 *  @return 天数
 */
- (NSInteger)getNumberOfDaysInMonthWith:(NSString *)year withMouth:(NSString *)mouth
{
    NSString* timeStr;
    if([self.calendar isEqualToString:@"农历"])
    {
        mouth = [self mouthToString:mouth];
        timeStr = [NSString stringWithFormat:@"%@-%@-01 17:40:50",[year substringFromIndex:2],mouth];
    }
    else
    {
        timeStr = [NSString stringWithFormat:@"%@-%@-01 17:40:50",year,mouth];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    NSDate* datex = [formatter dateFromString:timeStr];
    // NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    // NSString *nowtimeStr = [formatter stringFromDate:datenow];//----------将nsdate按formatter格式转成nsstring
    //NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    //NSLog(@"timeSp:%@",timeSp); //时间戳的值
    
    NSDate * currentDate = [NSDate dateWithTimeIntervalSince1970:[datex timeIntervalSince1970]];
    
    if([self.calendar isEqualToString:@"农历"])
    {
       int dayCount = [self monthDays:[[year substringFromIndex:2] intValue] month:[mouth intValue]];
        return dayCount;
    }
    else
    {
        NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit: NSMonthCalendarUnit
                              forDate:currentDate];
        return range.length;
    }
    
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    //包含4列
    return 4;
}

//该方法返回值决定该控件指定列包含多少个列表项
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 0: return self.arr.count;
        case 1: return self.yearArr.count;
        case 2: return self.mouthArr.count;
        case 3: return self.dayArr.count;
    }
    return 0;
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return __kScreenWidth/4;
    
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        self.calendarRow = row;
        self.calendar = [self.arr objectAtIndex:self.calendarRow];
        
        if ([self.calendar isEqualToString:@"农历"])
        {
            [self selectChineseCalendar];
        }
        else
        {
            [self selectGregorianCalendar];
        }
        self.year = [self.yearArr objectAtIndex:self.yearRow];
        self.mouth = [self.mouthArr objectAtIndex:self.mouthRow];
        [pickerView reloadAllComponents];
    }
    else if(component == 1)
    {
        self.yearRow = row;
        self.year = [self.yearArr objectAtIndex:self.yearRow];
        
        //计算每月多少天
        NSInteger dayx = [self getNumberOfDaysInMonthWith:[self.yearArr objectAtIndex:self.yearRow] withMouth:[self.mouthArr objectAtIndex:self.mouthRow]];
        if ([self.calendar isEqualToString:@"农历"])
        {
            [self.dayArr removeAllObjects];
            [self.dayDataSource  enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (dayx > idx)
                {
                    [self.dayArr addObject:self.dayDataSource[idx]];
                }
            }];
        }
        else
        {
            [self.dayArr removeAllObjects];
            for (int i = 01; i <= dayx ; i ++)
            {
                [self.dayArr addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
        
        if (self.dayRow >= self.dayArr.count)
        {
            self.dayRow = self.dayArr.count - 1;
        }
        [pickerView reloadComponent:3];
        [pickerView selectRow:self.dayRow inComponent:3 animated:YES];
        [self reloadShowDataSource];
        [pickerView reloadAllComponents];
        
    }
    else if (component == 2)
    {
        self.mouthRow = row;
        self.mouth = [self.mouthArr objectAtIndex:self.mouthRow];
        
        NSInteger dayx = [self getNumberOfDaysInMonthWith:[self.yearArr objectAtIndex:self.yearRow] withMouth:[self.mouthArr objectAtIndex:self.mouthRow]];
        if ([self.calendar isEqualToString:@"农历"]) {
            [self.dayArr removeAllObjects];
            [self.dayDataSource  enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (dayx  > idx)
                {
                    [self.dayArr addObject:self.dayDataSource[idx]];
                }
            }];
        }
        else
        {
            [self.dayArr removeAllObjects];
            for (int i = 01; i <= dayx ; i ++)
            {
                [self.dayArr addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
        
        if (self.dayRow >= self.dayArr.count)
        {
            self.dayRow = self.dayArr.count - 1;
        }
        [pickerView reloadComponent:3];
        [pickerView selectRow:self.dayRow inComponent:3 animated:YES];
        [self reloadShowDataSource];
        [pickerView reloadAllComponents];
    }
    else
    {
        self.dayRow = row;
        [self reloadShowDataSource];
    }
    
    if ([self.birthDelegate respondsToSelector:@selector(birthdayPickView:finishPickCalendar:withYear:withMouth:withDay:)])
    {
        if (self.calendar == nil)
        {
            self.calendar = [self.arr firstObject];
        }
        if (self.year == nil)
        {
            self.year = [self.yearArr firstObject];
        }
        if (self.mouth == nil)
        {
            self.mouth = [self.mouthArr firstObject];
        }
        if (self.day == nil)
        {
            self.day = [self.dayArr firstObject];    
        }
        if ([self.calendar isEqualToString:@"农历"]) {
            [self.birthDelegate birthdayPickView:self finishPickCalendar:self.calendar withYear:[self.year substringFromIndex:2] withMouth:[self mouthToString:self.mouth] withDay:self.day];
        }else
        {
            [self.birthDelegate birthdayPickView:self finishPickCalendar:self.calendar withYear:self.year withMouth:self.mouth withDay:self.day];
        }
    }
    
}

// 切换农历
- (void)selectChineseCalendar
{
    [self.yearArr removeAllObjects];
    int yearCount = [[self nowTime] intValue];
    for (int i = yearCount - 120 ; i <= yearCount ; i ++)
    {
        [self.yearArr insertObject:[NSString stringWithFormat:@"%@%d",[self getChineseCalendarWithDate:[self getDateWithDateString:[NSString stringWithFormat:@"%d",i]]],i] atIndex:0];
    }
    [self.mouthArr removeAllObjects];
    self.mouthArr = [NSMutableArray arrayWithArray:@[@"正月",@"二月",@"三月",@"四月",@"五月",@"六月",@"七月",@"八月",@"九月",@"十月",@"冬月",@"腊月"]];
    
    [self.dayArr removeAllObjects];
    
    self.dayArr = [NSMutableArray arrayWithObjects:@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",@"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",@"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    
    self.day = [self dayToString:[NSString stringWithFormat:@"%@",self.dayArr[self.dayRow]]];
}

// 切换到公历
- (void)selectGregorianCalendar
{
    [self.yearArr removeAllObjects];
    int yearCount = [[self nowTime] intValue];
    for (int i = yearCount - 120 ; i <= yearCount ; i ++)
    {
        [self.yearArr insertObject:[NSString stringWithFormat:@"%d",i] atIndex:0];
    }
    [self.mouthArr removeAllObjects];
    self.mouthArr = [NSMutableArray arrayWithArray:@[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12"]];
    
    [self.dayArr removeAllObjects];
    for (int i = 01 ; i <= 31 ; i ++)
    {
        [self.dayArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    self.day = self.dayArr[self.dayRow];
}

- (void)reloadShowDataSource
{
    if ([self.calendar isEqualToString:@"农历"]) {
        self.day = [self dayToString:[NSString stringWithFormat:@"%@",self.dayArr[self.dayRow]]];
    }
    else
    {
        self.day = [self.dayArr objectAtIndex:self.dayRow];
    }
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return [self.arr objectAtIndex:row];
    } else if(component == 1)
    {
        return [self.yearArr objectAtIndex:row];
        
    }
    else if (component == 2)
    {
        return [self.mouthArr objectAtIndex:row];
    }else
    {
        return [self.dayArr objectAtIndex:row];
    }
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *titleLabel = (UILabel *)view;
    if (!titleLabel)
    {
        titleLabel = [self labelForPickerView];
    }
    titleLabel.text = [self titleForComponent:component row:row];
    return titleLabel;
}


#pragma mark - Private
- (UILabel *)labelForPickerView
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithRed:85/255 green:85/255 blue:85/255 alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    return label;
}

- (NSString *)titleForComponent:(NSInteger)component row:(NSInteger)row;
{
    switch (component)
    {
        case 0: return [self.arr objectAtIndex:row];
        case 1: return [self.yearArr objectAtIndex:row];
        case 2: return [self.mouthArr objectAtIndex:row];
        case 3: return [self.dayArr objectAtIndex:row];
    }
    return @"";
}


#pragma mark 农历 y年m月的总天数
- (int)monthDays:(int)year month:(int)month
{
    if ((lunarInfo[year - 1900] & (0x10000 >> month)) == 0)
    {
        return 29;
    }else
    {
        return 30;
    }
}

- (NSDate *)getDateWithDateString:(NSString *)strDate
{
    NSString * timeStr = [NSString stringWithFormat:@"%@-05-01 17:40:50",strDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate* datex = [formatter dateFromString:timeStr];
    return datex;
}

- (NSString *)mouthToString:(NSString *)mouth
{
    __block NSString *mouthStr = @"";
    
    NSArray *chineseMonths=[NSArray arrayWithObjects:@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",@"九月", @"十月", @"冬月", @"腊月", nil];
    NSArray *mathMouth = [NSArray arrayWithObjects:@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",nil];
    [chineseMonths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:mouth])
        {
            mouthStr = [NSString stringWithFormat:@"%@",mathMouth[idx]];
        }
    }];
    
    return mouthStr;
}

- (NSString*)getChineseCalendarWithDate:(NSDate *)date
{
    
    NSArray *chineseYears = [NSArray arrayWithObjects:
                             @"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
                             @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未",
                             @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
                             @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑",
                             @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
                             @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥", nil];
    /*
     NSArray *chineseMonths=[NSArray arrayWithObjects:
     @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
     @"九月", @"十月", @"冬月", @"腊月", nil];
     NSArray *chineseDays=[NSArray arrayWithObjects:
     @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
     @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
     @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
     
     */
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    
    // NSLog(@"%ld_%ld_%ld  %@",localeComp.year,localeComp.month,localeComp.day, localeComp.date);
    
    NSString *y_str = [chineseYears objectAtIndex:localeComp.year - 1];
    //  NSString *m_str = [chineseMonths objectAtIndex:localeComp.month-1];
    //  NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
    
    // NSString *chineseCal_str =[NSString stringWithFormat: @"%@ %@ %@",y_str,m_str,d_str];
    
    
    return y_str;
}

- (NSString *)dayToString:(NSString *)day
{
    __block NSString *dayStr = @"";
    NSArray *chineseDays=[NSArray arrayWithObjects:@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",@"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",@"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    NSArray *mathDays = [NSArray arrayWithObjects:@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30", nil];
    [chineseDays enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:day])
        {
            dayStr = [NSString stringWithFormat:@"%@",mathDays[idx]];
        }
    }];
    return dayStr;
    
}

#pragma mark - 懒加载
- (NSMutableArray *)yearArr {
    if(_yearArr == nil) {
        _yearArr = [NSMutableArray arrayWithCapacity:0];
        
        int yearCount = [[self nowTime] intValue];
        for (int i = yearCount - 120 ; i <= yearCount ; i ++)
        {
            [self.yearArr insertObject:[NSString stringWithFormat:@"%d",i] atIndex:0];
        }
    }
    return _yearArr;
}

- (NSMutableArray *)mouthArr {
    if(_mouthArr == nil) {
        _mouthArr = [NSMutableArray arrayWithCapacity:0];
        _mouthArr = [NSMutableArray arrayWithArray:@[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12"]];
    }
    return _mouthArr;
}

- (NSMutableArray *)dayArr {
    if(_dayArr == nil) {
        _dayArr = [NSMutableArray arrayWithCapacity:0];
        for (int i = 01 ; i <= 31 ; i ++)
        {
            [_dayArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _dayArr;
}

- (NSMutableArray *)dayDataSource {
    if(_dayDataSource == nil) {
        _dayDataSource = [NSMutableArray arrayWithCapacity:0];
        _dayDataSource = [NSMutableArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",@"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",@"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    }
    return _dayDataSource;
}

@end
