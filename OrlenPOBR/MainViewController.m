//
//  MainViewController.m
//  FaceDemo
//
//  Created by Tomek Kuźma  on 11-03-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "OvalOverlayView.h"

@interface UIImage (masking) 
- (UIImage*) maskWithMask:(UIImage *)maskImage ;
@end

@implementation UIImage (masking)

- (UIImage*) maskWithMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage; 
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([self CGImage], mask);
	return [UIImage imageWithCGImage:masked];
    
}

@end

@interface MainViewController ()


- (IBAction)showInfo:(id)sender;
- (IBAction)grabImage;
- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize; 

@end

@implementation MainViewController

@synthesize image = _image;
@synthesize picker = _picker;
@synthesize button = _button;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
    self.image.image = nil;
    [self.button setTitle:@"Pick a photo" forState:UIControlStateNormal];
}

- (IBAction)showInfo:(id)sender
{    
    if (self.image.image != nil) {
        FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
        controller.delegate = self;
        controller.workingImage= self.image.image;
        
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
   // [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
  
    [super viewDidUnload];
    

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad{
   
    [super viewDidLoad];
    
    self.picker = [[[UIImagePickerController alloc] init] autorelease];
    [self.picker setDelegate:self];

    self.image.layer.borderWidth = 3.0f;
    self.image.layer.borderColor = [[UIColor whiteColor] CGColor];
    

}

- (void)dealloc
{
    self.button = nil;
    self.picker = nil;
    self.image = nil;
    [super dealloc];
}

- (IBAction)grabImage {
    if (self.image.image == nil) {
        UIActionSheet *alertSheet;
        
        if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]) {
            alertSheet = [[[UIActionSheet alloc] initWithTitle:@"Image Source"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Camera",@"Library", nil] autorelease];
        }
        else{
            alertSheet = [[[UIActionSheet alloc] initWithTitle:@"Image Source"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Library", nil] autorelease];
        }
        
        
        [alertSheet showInView:self.view];
    }
    else{
        [self showInfo:nil];
    }

    
    
    
}

#pragma - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    for (NSString *key in info) {
//       NSLog(@"key: %@, object: %@", key, [info objectForKey:key]);
//    }
    
    UIImage *photo;
    
    [self dismissModalViewControllerAnimated:YES];
    if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
            photo = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            [self.image setImage:[self imageWithImage:photo scaledToSize:CGSizeMake(320, 480)]];

            [self.button setTitle:@"Find ORLEN" forState:UIControlStateNormal];


    }
    
     
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.numberOfButtons == 3){
        if (buttonIndex == 0)
            [self.picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        else  if(buttonIndex == 1)
            [self.picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    else{
        [self.picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [self presentModalViewController:self.picker animated:YES];

}


@end
