//
//  DynamicTypeHelper.h
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 4/5/14.
//  Copyright (c) 2014 OCHIISHI Koichiro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DynamicTypeHelper : NSObject

+ (UITableViewCell *)setupDynamicTypeCell:(UITableViewCell *)cell style:(UITableViewCellStyle)style;
+ (CGFloat)heightWithStyle:(UITableViewCellStyle)style text:(NSString *)text detailText:(NSString *)detailText;

@end
