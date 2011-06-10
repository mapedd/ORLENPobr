//
//  FlipsideViewController.h
//  FaceDemo
//
//  Created by Tomek Kuźma  on 11-03-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


struct TKPixel {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    unsigned char alpha;
};


typedef struct TKPixel TKPixel;

BOOL TKPixelIsWhite(TKPixel pixel);

BOOL TKPixelIsBlack(TKPixel pixel);

static unsigned char const TKWhite = 255;
static unsigned char const TKBlack = 0;

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController {
    TKPixel** mPixels;
    int totalWidth;
    int totalHeight;
    
    int currentIndex;
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

@end




@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end
