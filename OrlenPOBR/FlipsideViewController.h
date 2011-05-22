//
//  FlipsideViewController.h
//  FaceDemo
//
//  Created by Tomek Kuźma  on 11-03-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController {
    
    UIImage *workingImage1;
    UIImage *workingImage2;
    UIImage *workingImage3;
    UIImage *maskImage;
    UIImageView *imageView;
    
    IBOutlet UILabel *redLabel;
    IBOutlet UILabel *greenLabel;
    IBOutlet UILabel *blueLabel;
    IBOutlet UILabel *overallLabel;
    
    IBOutlet UIActivityIndicatorView *activ;
    
    int redDifference;
    int greenDifference;
    int blueDifference;
    int overallDifference;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) UIImage *workingImage1;
@property (nonatomic, retain) UIImage *workingImage2;
@property (nonatomic, retain) UIImage *workingImage3;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (IBAction)done:(id)sender;
- (IBAction)doSegmentation:(id) sender; 
- (IBAction)adjustTreshold:(id) sender;
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)aMaskImage; 
- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize;

- (void)setImage;

@end




@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end
