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

@implementation MainViewController

@synthesize image1, image2, picker;

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    NSLog(@"init");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    firstSet = NO;
    secondSet = NO;
    NSBundle *bundle = [NSBundle mainBundle];
    maskImage = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"maskBig" ofType:@"png"]];
    return self;
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
    image1.image = nil;
    image2.image = nil;
    firstSet = NO;
    secondSet = NO;
    [button setTitle:@"Grab two photos" forState:UIControlStateNormal];
}

- (IBAction)showInfo:(id)sender
{    
    if (image1.image != nil && image2.image != nil) {
        FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
        controller.delegate = self;
        controller.workingImage1 = image2.image;
        controller.workingImage2 = image1.image;
        
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
        
        [controller release];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
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
    

    
    
    UIScreen *MainScreen = [UIScreen mainScreen];
    UIScreenMode *ScreenMode = [MainScreen currentMode];
    CGSize Size = [ScreenMode size];
    if (Size.width>320) {
        NSLog(@"ip4");
        iphone4 = YES;
    }
    else    
        iphone4 = NO;

    
    self.picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]) {
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if (iphone4) {
            UIImageView *overlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mask6.png"]];
            [overlay setFrame:CGRectMake(0, 0, 320, 480)];
            self.picker.cameraOverlayView = overlay;
            [overlay release];
        }
        else {
            OvalOverlayView *oval = [[OvalOverlayView alloc] initWithFrame:CGRectMake(10,10, 100, 100)];
            self.picker.cameraOverlayView = oval;
            [oval release];
        }
    }
    else{
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
   
    [picker setDelegate:self];

    
    
    
    image1.layer.borderWidth = 3.0f;
    image1.layer.borderColor = [[UIColor whiteColor] CGColor];
    image2.layer.borderWidth = 3.0f;
    image2.layer.borderColor = [[UIColor whiteColor] CGColor];
    

}

- (void)dealloc
{
    [maskImage release];
    [image1 release];
    [image2 release];
    [picker  release];
    [super dealloc];
}

- (IBAction)grabImage {
    if ([[[button titleLabel] text] isEqualToString:@"Substract and find the face"]) {
        [self showInfo:nil];
    }
    else{
        [self presentModalViewController:self.picker animated:YES];
    }
}

#pragma - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    for (NSString *key in info) {
       NSLog(@"key: %@, object: %@", key, [info objectForKey:key]);
    }
    
    UIImage *photo;
    
    [self dismissModalViewControllerAnimated:YES];
    if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
        if (firstSet == NO) {
            photo = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            [self.image1 setImage:[self imageWithImage:photo scaledToSize:CGSizeMake(320, 480)]];
//            [self.image1 setImage:photo];
            firstSet = YES;
            [button setTitle:@"Grab second image" forState:UIControlStateNormal];

        }
        else 
        {
            photo = [info objectForKey:UIImagePickerControllerOriginalImage];
            secondSet  = YES;
            [self.image2 setImage:[self imageWithImage:photo scaledToSize:CGSizeMake(320, 480)]];
//            [self.image2 setImage:photo];
            [button setTitle:@"Substract and find the face" forState:UIControlStateNormal];
        }

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


@end
