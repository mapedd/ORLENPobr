//
//  MainViewController.h
//  FaceDemo
//
//  Created by Tomek Kuźma  on 11-03-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"


@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, 
                                                    UINavigationControllerDelegate,
                                                    UIImagePickerControllerDelegate> {
    
    UIImageView *image1;
    UIImageView *image2;
    UIImage *maskImage;
    IBOutlet UIButton *button;
    BOOL firstSet;
    BOOL secondSet;
                                                        BOOL iphone4;
    
    UIImagePickerController *picker;

}
@property(nonatomic, retain) IBOutlet UIImageView *image1;
@property(nonatomic, retain) IBOutlet UIImageView *image2;
@property(nonatomic, retain) UIImagePickerController *picker;

- (IBAction)showInfo:(id)sender;
- (IBAction)grabImage;
- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize; 
@end
