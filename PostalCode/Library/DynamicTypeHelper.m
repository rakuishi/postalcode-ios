//
//  DynamicTypeHelper.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 4/5/14.
//  Copyright (c) 2014 OCHIISHI Koichiro. All rights reserved.
//

#import "DynamicTypeHelper.h"

@implementation DynamicTypeHelper

+ (UITableViewCell *)setupDynamicTypeCell:(UITableViewCell *)cell style:(UITableViewCellStyle)style;
{
    switch (style) {
        case UITableViewCellStyleDefault:
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            break;
        case UITableViewCellStyleSubtitle:
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
            break;
        case UITableViewCellStyleValue1:
        case UITableViewCellStyleValue2:
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            break;
        default:
            break;
    }
    
    return cell;
}

+ (CGFloat)heightWithStyle:(UITableViewCellStyle)style text:(NSString *)text detailText:(NSString *)detailText
{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    
    switch (style) {
        case UITableViewCellStyleDefault: {
            // 290.f は, 横幅目一杯に使った時の横幅を想定（320px だと思ったが, 余白が左右に 15px 存在する）
           width -= 30.f;
            CGFloat textHeight = [self heightWithText:text
                                                 font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                width:width];
            return MAX(44.f, textHeight + 6.f);
        }
        case UITableViewCellStyleSubtitle: {
            // 215.f は, sectionIndexTitle の文字数が 4 の場合のセル横幅を想定
            // お気に入り画面で改行する必要がない時に改行されてしまうが, これは共通化で仕方のないことにしておこう
            width -= 105.f;;
            CGFloat textHeight = [self heightWithText:text
                                                 font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                width:width];
            CGFloat detailTextHeight = [self heightWithText:detailText
                                                       font:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]
                                                      width:width];
            return MAX(44.f, textHeight + detailTextHeight + 6.f);
        }
        case UITableViewCellStyleValue1:
        case UITableViewCellStyleValue2: {
            // 244.f は, Dynamic Type 最大値, text が 2 文字の場合の横幅を想定
            width -= 76.f;
            CGFloat textHeight = [self heightWithText:text
                                                 font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                width:width];
            CGFloat detailTextHeight = [self heightWithText:detailText
                                                       font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                                      width:width];
            CGFloat height = MAX(textHeight, detailTextHeight) + 12.f;
            return MAX(44.f, height);
        }
        default:
            return 44.f;
    }
}

+ (CGFloat)heightWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]
                                     context:nil];
    return rect.size.height;
}

@end
