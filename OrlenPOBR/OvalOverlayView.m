//
//  OvalOverlayView.m
//  FaceDemo
//
//  Created by Tomek Kuźma  on 11-03-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OvalOverlayView.h"


@implementation OvalOverlayView

@synthesize isMasking;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        isMasking = NO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (!isMasking) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.87);
        CGContextSetLineWidth(context, 3.0f);
        CGContextAddEllipseInRect(context, CGRectMake(rect.size.width/6.0f, 60.5f,
                                                      2.0*rect.size.width/3.0f, 3.0*rect.size.height/5.0f));
        CGContextDrawPath(context, kCGPathStroke);
//        CGContextDrawPath(context, kCGPathFillStroke);
    }
    else{
        
    }
    
    
    
}


- (void)dealloc
{
    [super dealloc];
}

@end
