//
//  TMPuni2AppDelegate.h
//  TMPuni2
//
//  Created by Toru Inoue on 10/11/28.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTMImageViewController.h"

@interface TMPuni2AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	
	MyTMImageViewController * myTMCont;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

