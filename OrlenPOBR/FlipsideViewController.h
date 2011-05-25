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
    
    
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) UIImage *workingImage;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;

- (IBAction)done:(id)sender;
- (IBAction)doSegmentation:(id) sender; 
- (void)setImage;

- (void)findOrlenLogo;

@end




@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end
