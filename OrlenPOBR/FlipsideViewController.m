//
//  FlipsideViewController.m
//  FaceDemo
//
//  Created by Tomek Kuźma  on 11-03-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"

#import "UIImage+Bytes.h"
#import "UIColor-Expanded.h"
#import "TKByteImage.h"
#import "TKBWImageIndexator.h"


BOOL TKPixelIsWhite(TKPixel pixel){
    if (pixel.red   == TKWhite &&
        pixel.green == TKWhite &&
        pixel.blue  == TKWhite) {
        return YES;
    }
    else
        return NO;
}

BOOL TKPixelIsBlack(TKPixel pixel){
    if (pixel.red   == TKBlack &&
        pixel.green == TKBlack &&
        pixel.blue  == TKBlack) {
        return YES;
    }
    else
        return NO;
}

BOOL TKValidCoordinate(int m,int n, int rows, int columns, int margin){
        
    if (margin > rows/2 || margin > columns/2) {
        return NO;
    }
    
    if (m>margin && m<rows-margin && n>margin && n< columns-margin ) {
        return YES;
    }
    else{
        return NO;
    }
}

TKPixel TKColorPixelToRed(void){
    TKPixel pixel;
    pixel.red = TKWhite;
    pixel.green = TKBlack;
    pixel.blue = TKBlack;
    pixel.alpha = TKWhite;
    return pixel;
}

void TKBurnPixels(TKPixel **pixels, int x, int y){
    
}

TKPoint TKPointMake(int x, int y){
    TKPoint point;
    
    point.x = x;
    point.y = y;
    
    return point;
}

BOOL TKPointIsEqualToPoint(TKPoint p1, TKPoint p2){
    if (p1.x == p2.x && p1.y == p2.y) {
        return YES;
    }
    else{
        return NO;
    }
}

@implementation FlipsideViewController

#pragma mark - Synthesize
@synthesize delegate=_delegate;
@synthesize imageView = _imageView;
@synthesize workingImage = _workingImage;
@synthesize activity = _activity;

#pragma mark -
#pragma mark - NSObject
#pragma mark -

- (void)dealloc{
    self.workingImage = nil;
    self.imageView = nil;
    self.activity = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark -
#pragma mark - View lifecycle
#pragma mark -

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden= YES;
    self.imageView.image = self.workingImage;
    
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self doSegmentation:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return [TKHelper isSupportedOrientation:interfaceOrientation];
}

#pragma mark - 
#pragma mark - IBActions
#pragma mark - 
- (IBAction)done:(id)sender{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)doSegmentation:(id) sender {
    
    [self findOrlenLogo];

}

#pragma mark - 
#pragma mark - Image Processing
#pragma mark - 

- (void)findOrlenLogo{
    /*
    totalWidth = 0;
    totalHeight = 0;
    currentIndex =0;
    
    [self.activity startAnimating]; 
    
    if (self.workingImage == nil) {
        return;
    }
    
    [TKHelper logImageWithDescription:self.workingImage];
    
    NSUInteger width = [self.workingImage width];
    NSUInteger height = [self.workingImage height];
    
    totalWidth = width;
    totalHeight = height;
    
    NSLog(@"width: %d, height:%d", width, height);
    
    unsigned char *rawData = [self.workingImage bytes];
    
    if (rawData == NULL) {
        return;
    }
    
    CGFloat distance, red, green, blue;
    
    UIColor *orlenRed = [UIColor colorWithRed:TKOrlenRed green:TKOrlenGreen blue:TKOrlenBlue alpha:1.0];
    
    unsigned long byteIndex = 0;
    
    
    // init points for burning /
    points = calloc(sizeof(TKPoint), totalWidth*totalHeight);
    

    NSInteger nrows = height;
    NSInteger ncolumns = width;
    mPixels = calloc(sizeof(TKPixel*), nrows);
    if(mPixels == NULL){NSLog(@"Not enough memory to allocate array.");}
    for(NSUInteger i = 0; i < nrows; i++)
    {
        mPixels[i] = calloc(sizeof(TKPixel), ncolumns);
        if(mPixels[i] == NULL){NSLog(@"Not enough memory to allocate array.");}
    }
    
    
    // do segmentation
    
    
    for (unsigned long ii = 0 ; ii < width * height ; ii++)
    {   
        red = [UIColor floatingComponentFromChar:rawData[byteIndex]];
        green = [UIColor floatingComponentFromChar:rawData[byteIndex+1]];
        blue = [UIColor floatingComponentFromChar:rawData[byteIndex+2]];
        
        distance = [orlenRed distanceFromColorWithRed:red green:green andBlue:blue];
        
        if (distance > kMaxDistance) {

            rawData[byteIndex] = 255;
            rawData[byteIndex+1] = 255;
            rawData[byteIndex+2] = 255;
        }
        else{
            rawData[byteIndex] = 0;
            rawData[byteIndex+1] = 0;
            rawData[byteIndex+2] = 0;
        }
        
        
		byteIndex += 4;
		
    }
    
    byteIndex =0 ;
    
    // write from array to two-dimensional pixel array
    
    for (int m=0; m<nrows; m++) {
       for (int n=0; n<ncolumns; n++) { 
           
            mPixels[m][n].red = rawData[byteIndex];
            mPixels[m][n].green = rawData[byteIndex+1];
            mPixels[m][n].blue = rawData[byteIndex+2];
            mPixels[m][n].alpha = rawData[byteIndex+3];

            byteIndex+=4;
        }
    }
    
    
    // and here the actual recognition takes place
    
    
    for (int k = 0; k<1; k++) {
        [self TKDeleteSmallObjets]; 
    }
    
    for (int k = 0; k<1; k++) {
        [self TKGrowObjets]; 
    }
    
    //
    
    BOOL seedSet = NO;
    
    if (TKPixelIsWhite(mPixels[0][0])) {
        points[0] = TKPointMake(0, 0);
    }
    else{
        int i = 0;
        while (seedSet == NO) {
            if (TKPixelIsWhite(mPixels[i][i])) {
                points[0] = TKPointMake(i, i);
                seedSet = YES;    
            }
            i++;
        }
    }
    
    TKPoint firstPoint = points[0];
    printf("point[0][0] = %d,%d\n", firstPoint.x,firstPoint.y);
    
    
    
    // write again to ordinary array and then display
    byteIndex = 0;

    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {

            rawData[byteIndex] = mPixels[m][n].red;
            rawData[byteIndex+1] = mPixels[m][n].green;
            rawData[byteIndex+2] = mPixels[m][n].blue;
            rawData[byteIndex+3] = mPixels[m][n].alpha;
            
            byteIndex+=4;
        }
    }
    
    
    self.imageView.image = nil;
   
    TKByteImage *img = [[TKByteImage alloc] initWithImage:imageFromBytes(rawData, width, height)];
    
    self.imageView.image = [img currentImage];
    
    */
    
    TKByteImage *img2 = [[TKByteImage alloc] initWithImage:self.workingImage tolerance:0.0 startPoint:CGPointMake(20,60)];
    
    self.imageView.image = [img2 indexatedImage];
    
    free(mPixels);
//    free(rawData);
    
    [self.activity stopAnimating];
}

- (void)TKBurnForX:(int)x andY:(int)y{
    
    //printf("TKBurn x:%d y:%d \n", x, y);
    
    
    if (mPixels == NULL) {
        return;
    }
    
    if (x>totalWidth || x<0) {
        return;
    }
    
    if (x>totalHeight || y<0) {
        return;
    }
    
    if (TKPixelIsWhite(mPixels[x][y])) {
        
        mPixels[x][y] = TKColorPixelToRed();
        
        [self TKBurnForX:x andY:y-1];
        [self TKBurnForX:x+1 andY:y];
        [self TKBurnForX:x andY:y+1];
        [self TKBurnForX:x-1 andY:y];
    }
    else{
        return; 
    }
    
}

- (void)TKDeleteSmallObjets{
    
    NSLog(@"deleting small objects");
    
    if (mPixels == NULL) {
        return;
    }
    
    TKPixel **pixels;
    
    NSInteger nrows = [self.workingImage height];
    NSInteger ncolumns = [self.workingImage width];
    
    pixels = calloc(sizeof(TKPixel*), nrows);
    if(pixels == NULL){NSLog(@"Not enough memory to allocate array.");}
    for(NSUInteger i = 0; i < nrows; i++)
    {
        pixels[i] = calloc(sizeof(TKPixel), ncolumns);
        if(pixels[i] == NULL){NSLog(@"Not enough memory to allocate array.");}
    }
    
    
    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {
            pixels[m][n].red = mPixels[m][n].red;
            pixels[m][n].green = mPixels[m][n].green;
            pixels[m][n].blue = mPixels[m][n].blue;
            pixels[m][n].alpha = mPixels[m][n].alpha;
        }
    }
    
    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {
            
            if (TKValidCoordinate(m, n, nrows, ncolumns, 1) ) {
            
                if (TKPixelIsBlack(mPixels[m][n]) &&
                         (
                         TKPixelIsWhite(mPixels[m][n-1]) || 
                         TKPixelIsWhite(mPixels[m-1][n]) || TKPixelIsWhite(mPixels[m+1][n]) || 
                         TKPixelIsWhite(mPixels[m][n+1])
                         )
                    ) 
                {
                    pixels[m][n].red = TKWhite;
                    pixels[m][n].green = TKWhite;
                    pixels[m][n].blue = TKWhite;
                    
                }
            }
        }
    }
    
    
    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {
            mPixels[m][n].red = pixels[m][n].red;
            mPixels[m][n].green = pixels[m][n].green;
            mPixels[m][n].blue = pixels[m][n].blue;
            mPixels[m][n].alpha = pixels[m][n].alpha;
        }
    }
    
    free(pixels);

}

- (void)TKColorizePicture{
    NSLog(@"colirizint image");
    
    if (mPixels == NULL) {
        return;
    }
    
    TKPixel **pixels;
    
    NSInteger nrows = [self.workingImage height];
    NSInteger ncolumns = [self.workingImage width];
    
    pixels = calloc(sizeof(TKPixel*), nrows);
    if(pixels == NULL){NSLog(@"Not enough memory to allocate array.");}
    for(NSUInteger i = 0; i < nrows; i++)
    {
        pixels[i] = calloc(sizeof(TKPixel), ncolumns);
        if(pixels[i] == NULL){NSLog(@"Not enough memory to allocate array.");}
    }
    
    
    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {
            pixels[m][n].red = mPixels[m][n].red;
            pixels[m][n].green = mPixels[m][n].green;
            pixels[m][n].blue = mPixels[m][n].blue;
            pixels[m][n].alpha = mPixels[m][n].alpha;
        }
    }
    
    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {
            if (TKPixelIsWhite(mPixels[m][n]) && TKValidCoordinate(m, n, 512, 600, 50)) {
                
                pixels[m][n].red = 0;
                pixels[m][n].green = 255;
                pixels[m][n].blue = 255;
                
                if (TKValidCoordinate(m, n, nrows, ncolumns, 100)) {
                    pixels[m][n].red = 0;
                    pixels[m][n].green = 255;
                    pixels[m][n].blue = 0;
                }
            }
        }
    }
    
    
    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {
            mPixels[m][n].red = pixels[m][n].red;
            mPixels[m][n].green = pixels[m][n].green;
            mPixels[m][n].blue = pixels[m][n].blue;
            mPixels[m][n].alpha = pixels[m][n].alpha;
        }
    }
    
    free(pixels);
}

- (void)TKGrowObjets{
    NSLog(@"growing");
    
    if (mPixels == NULL) {
        return;
    }
    
    TKPixel **pixels;
    
    NSInteger nrows = [self.workingImage height];
    NSInteger ncolumns = [self.workingImage width];
    
    pixels = calloc(sizeof(TKPixel*), nrows);
    if(pixels == NULL){NSLog(@"Not enough memory to allocate array.");}
    for(NSUInteger i = 0; i < nrows; i++)
    {
        pixels[i] = calloc(sizeof(TKPixel), ncolumns);
        if(pixels[i] == NULL){NSLog(@"Not enough memory to allocate array.");}
    }
    
    
    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {
            pixels[m][n].red = mPixels[m][n].red;
            pixels[m][n].green = mPixels[m][n].green;
            pixels[m][n].blue = mPixels[m][n].blue;
            pixels[m][n].alpha = mPixels[m][n].alpha;
        }
    }
    
    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {
            
            if (TKValidCoordinate(m, n, nrows, ncolumns, 1) ) {
                
                if (TKPixelIsBlack(mPixels[m][n]) &&
                    (
                     TKPixelIsWhite(mPixels[m][n-1]) || 
                     TKPixelIsWhite(mPixels[m-1][n]) || TKPixelIsWhite(mPixels[m+1][n]) || 
                     TKPixelIsWhite(mPixels[m][n+1])
                     )
                    ) 
                {
                    pixels[m][n].red = TKBlack;
                    pixels[m][n].green = TKBlack;
                    pixels[m][n].blue = TKBlack;
                    
                }
            }
        }
    }
    
    
    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {
            mPixels[m][n].red = pixels[m][n].red;
            mPixels[m][n].green = pixels[m][n].green;
            mPixels[m][n].blue = pixels[m][n].blue;
            mPixels[m][n].alpha = pixels[m][n].alpha;
        }
    }
    
    free(pixels);
}

- (BOOL)TKWhitePixelsLeft{
    NSInteger nrows = [self.workingImage height];
    NSInteger ncolumns = [self.workingImage width];
    NSInteger whitePixelsLeft = 0;
    
    for (int m=0; m<nrows; m++) {
        for (int n=0; n<ncolumns; n++) {
            if (TKPixelIsWhite(mPixels[m][n])) {
                whitePixelsLeft++;
            }
        }
    }
    
    if (whitePixelsLeft == 0)
        return NO;
    else
        return YES;
}

@end
