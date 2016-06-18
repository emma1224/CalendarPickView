//
//  FABirthPickerView.h
//  Facework
//
//  Created by Bao on 16/6/13.
//  Copyright © 2016年 www.Microlink.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class FABirthPickerView;

@protocol FABirthDelegate <NSObject>

- (void)birthdayPickView:(FABirthPickerView *)picker finishPickCalendar:(NSString *)calendar withYear:(NSString *)year withMouth:(NSString *)mouth withDay:(NSString *)day;

@end

@interface FABirthPickerView : UIPickerView

@property (nonatomic, weak) id <FABirthDelegate> birthDelegate;

@end
