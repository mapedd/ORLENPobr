//
//  OrlenPOBRAppDelegate.h
//  OrlenPOBR
//
//  Created by Mapedd on 11-05-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BWHockeyManager.h"

@class MainViewController;

@interface OrlenPOBRAppDelegate : NSObject <UIApplicationDelegate, BWHockeyManagerDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end
