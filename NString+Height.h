//
//  NString+Height.h
//
//  Created by y0n3l on 30/01/15.
//
//

#import <Foundation/Foundation.h>

/**
 Extension to adjust display of `NSString` instances. 
 */
@interface NSString (Height)

- (CGFloat)heightForWidth:(CGFloat)width usingFont:(UIFont *)font;

@end
