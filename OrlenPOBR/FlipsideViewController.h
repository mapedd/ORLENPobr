//
//  FlipsideViewController.h
//  FaceDemo
//
//  Created by Tomek Kuźma  on 11-03-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKConstants.h"

struct TKPoint {
    int x;
    int y;
};



typedef struct TKPoint TKPoint;

TKPoint TKPointMake(int x, int y);

BOOL TKPointIsEqualToPoint(TKPoint p1, TKPoint p2);

BOOL TKPixelIsWhite(TKPixel pixel);

BOOL TKPixelIsBlack(TKPixel pixel);

void TKBurnPixels(TKPixel **pixels, int x, int y);

BOOL TKValidCoordinate(int m,int n, int rows, int columns, int margin);

TKPixel TKColorPixelToRed(void);


static unsigned char const TKWhite = 255;
static unsigned char const TKBlack = 0;

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController {
    TKPixel** mPixels;
    int totalWidth;
    int totalHeight;
    
    int currentIndex;
    
    TKPoint *points;
    
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) UIImage *workingImage;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;

- (IBAction)done:(id)sender;
- (IBAction)doSegmentation:(id) sender; 

- (void)findOrlenLogo;

- (void)TKBurnForX:(int)x andY:(int)y;
- (void)TKDeleteSmallObjets;
- (void)TKGrowObjets;
- (BOOL)TKWhitePixelsLeft;

@end




@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end
