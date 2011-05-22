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
                                                    UIImagePickerControllerDelegate,
                                                    UIActionSheetDelegate> {
    
    UIImageView *_image;
    UIButton *_button;
    UIImagePickerController *_picker;

}
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) UIImagePickerController *picker;

@end
