//
//  LGViewHUD.m
//  Created by y0n3l on 4/13/11.
//

#import "LGViewHUD.h"
#import "NString+Height.h"
#import <QuartzCore/QuartzCore.h>

static LGViewHUD* defaultHUD = nil;

@interface LGViewHUD () {
    UIFont* _labelsFont;
    UIColor* _hudColor;
    NSString* _topText;
    NSString* _bottomText;
    UIImage* image;
    NSTimeInterval displayDuration;
    NSTimer* displayTimer;
    BOOL activityIndicatorOn;
    UIActivityIndicatorView* activityIndicator;
}

@end

@implementation LGViewHUD

@synthesize displayDuration;

#define kHUDDefaultAlphaValue 0.65
#define kHUDDefaultDisplayDuration 2
#define kHUDCornerRadius 10

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _labelsFont = [[UIFont boldSystemFontOfSize:17] retain];
		self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
								UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.userInteractionEnabled = NO;
		displayDuration = kHUDDefaultDisplayDuration;
        _hudColor = [[UIColor colorWithWhite:0 alpha:kHUDDefaultAlphaValue] retain];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    [_labelsFont release];
    _labelsFont = nil;
    [_hudColor release];
    _hudColor = nil;
	[super dealloc];
}

+(LGViewHUD*) defaultHUD {
	if (defaultHUD==nil)
		defaultHUD=[[LGViewHUD alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
	return defaultHUD;
}

-(void) setTopText:(NSString *)t {
    [t retain];
    [_topText release];
    _topText = t;
	[self setNeedsDisplay];
}

-(NSString*) topText {
	return _topText;
}

-(void) setBottomText:(NSString *)t {
    [t retain];
    [_bottomText release];
    _bottomText = t;
    [self setNeedsDisplay];
}

-(NSString*) bottomText {
	return _bottomText;
}

/** This disables the activity indicator on if any. */
-(void) setImage:(UIImage*) img {
    [img retain];
    [image release];
    image = img;
    self.activityIndicatorOn = NO;
    [self setNeedsDisplay];
}

-(UIImage*) image {
	return image;
}

-(BOOL) activityIndicatorOn {
	return activityIndicatorOn;
}

-(void) setActivityIndicatorOn:(BOOL)isOn {
	if (activityIndicatorOn!=isOn) {
		activityIndicatorOn=isOn;
		if (activityIndicatorOn) {
			activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			[activityIndicator startAnimating];
			activityIndicator.center=CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
			//imageView.hidden=YES;
			[self addSubview:activityIndicator];
		} else {
			//when applying an image, this will auto hide the HUD.
			[activityIndicator removeFromSuperview];
			//imageView.hidden=NO;
			[activityIndicator release];
			activityIndicator=nil;
		}
        [self setNeedsDisplay];
	}
}

-(void) drawRect:(CGRect)rect {
    UIBezierPath* bPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kHUDCornerRadius];
    [_hudColor setFill];
    [bPath fill];
    
    CGFloat imgHeight = MIN(self.frame.size.width, self.frame.size.height) / 2.0;
    
    CGFloat labelSideMargins = 5;
    CGFloat labelsWidth = self.frame.size.width - 2*labelSideMargins;
    CGFloat topLabelHeight = [_topText heightForWidth:labelsWidth usingFont:_labelsFont];
    
    CGFloat labelsMaxHeight = (self.frame.size.height - imgHeight) / 2.0;
    NSDictionary* attrs = nil;
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attrs = @{NSFontAttributeName: _labelsFont,
              NSForegroundColorAttributeName: [UIColor whiteColor],
              NSParagraphStyleAttributeName: paragraphStyle};
    [_topText drawInRect:CGRectMake(labelSideMargins, (labelsMaxHeight - topLabelHeight) /2.0 ,
                                         labelsWidth, topLabelHeight)
               withAttributes:attrs];
    
    CGFloat bottomLabelHeight = [_bottomText heightForWidth:labelsWidth usingFont:_labelsFont];
    [_bottomText drawInRect:CGRectMake(labelSideMargins,
                                       imgHeight + labelsMaxHeight + (labelsMaxHeight - bottomLabelHeight) /2.0 ,
                                       labelsWidth,
                                       bottomLabelHeight)
               withAttributes:attrs];
    
    [paragraphStyle release];
    
    if (!activityIndicatorOn) {
        CGRect imageFrame = CGRectMake((self.frame.size.width - image.size.width) /2.0,
                                       (self.frame.size.height - image.size.height) / 2.0,
                                       image.size.width,
                                       image.size.height);
        [image drawInRect:imageFrame];
    }
    [super drawRect:rect];
}

-(void) layoutSubviews {
    activityIndicator.center = CGPointMake(ceilf(self.frame.size.width / 2.0),
                                           ceilf(self.frame.size.height / 2.0));
    
    [super layoutSubviews];
}

-(void) show {
    [self showWithAnimation:HUDAnimationNone];
}

-(void) showWithAnimation:(HUDAnimation)animation {
    [self showInView:[UIApplication sharedApplication].windows.firstObject withAnimation:animation];
}

-(void) showInView:(UIView*)view {
	[self showInView:view withAnimation:HUDAnimationNone];
}

-(void) showInView:(UIView *)view withAnimation:(HUDAnimation)animation {
	//NSLog(@"HUD showing in view %@ | %@", view, NSStringFromCGRect(view.bounds));
	switch (animation) {
		case HUDAnimationNone:
			self.alpha=1.0;
			self.transform=CGAffineTransformMakeScale(1, 1);
			self.center=CGPointMake(view.bounds.size.width/2.0, view.bounds.size.height/2.0);
			[view addSubview:self];
			break;
		case HUDAnimationShowZoom:
			self.center=CGPointMake(view.bounds.size.width/2.0, view.bounds.size.height/2.0);
			self.alpha=0;
			self.transform=CGAffineTransformMakeScale(1.7, 1.7);
			[view addSubview:self];
			[UIView beginAnimations:@"HUDShowZoom" context:nil];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			self.transform=CGAffineTransformMakeScale(1, 1);
			self.alpha=1.0;
			[UIView commitAnimations];
		default:
			break;
	}
	if (!activityIndicatorOn) {
		HUDAnimation disappearAnimation = HUDAnimationHideFadeOut;
		switch (animation) {
			case HUDAnimationShowZoom:
				disappearAnimation = HUDAnimationHideZoom;
				break;
			default:
				disappearAnimation = HUDAnimationHideFadeOut;
				break;
		}
		[self hideAfterDelay:displayDuration withAnimation:disappearAnimation ];
	} else {
		//invalidate current timer for hide if any.
		[displayTimer invalidate];
		[displayTimer release];
		displayTimer=nil;
	}
}

-(void) hideAfterDelay:(NSTimeInterval)delayDuration withAnimation:(HUDAnimation) animation{
	[displayTimer invalidate];
	[displayTimer release];
	displayTimer = [[NSTimer timerWithTimeInterval:delayDuration target:self selector:@selector(displayTimeOut:) 
										  userInfo:[NSNumber numberWithInt:animation] repeats:NO] retain];
	[[NSRunLoop mainRunLoop] addTimer:displayTimer forMode:NSRunLoopCommonModes];
	//displayTimer = [[NSTimer scheduledTimerWithTimeInterval:delayDuration target:self 
//												   selector:@selector(displayTimeOut:) 
//												   userInfo:[NSNumber numberWithInt:animation] repeats:NO] retain];	
}

-(void) displayTimeOut:(NSTimer*)timer {
	[displayTimer release];
	displayTimer=nil;
	[self hideWithAnimation:(HUDAnimation)[[timer userInfo] intValue]];
}

-(void) hideWithAnimation:(HUDAnimation)animation {
	switch (animation) {
		case HUDAnimationHideZoom:
			[UIView beginAnimations:@"HUDHideZoom" context:nil];
			[UIView setAnimationDuration:0.4];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			self.transform=CGAffineTransformMakeScale(0.1, 0.1);
			self.alpha=0;
			[UIView commitAnimations];
			break;
		case HUDAnimationHideFadeOut:
			[UIView beginAnimations:@"HUDHideFade" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:1.0];
			self.alpha=0.0;
			[UIView commitAnimations];
			break;
		case HUDAnimationNone:
		default:
			[self removeFromSuperview];
			break;
	}
}

-(void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if (self.alpha==0.0) {
		[self removeFromSuperview];
	}
}

@end
