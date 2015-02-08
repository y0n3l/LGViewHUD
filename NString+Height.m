//
//  NString+Height.m
//
//  Created by y0n3l on 30/01/15.
//
//

#import "NString+Height.h"

@implementation NSString (Height)

- (CGFloat)heightForWidth:(CGFloat)width usingFont:(UIFont *)font {
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize labelSize = (CGSize){width, FLT_MAX};
    CGRect r = [self boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:context];
    return r.size.height;
}

@end
