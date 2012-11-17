//
//  ViewController.h
//  Yao
//
//  Created by chenjs on 12-11-10.
//  Copyright (c) 2012年 HelloTom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

#define kAccelerationThreshold      1.05f
#define kUpdateInterval             1.0 / 10.0f
#define kMinimumShakeCount          1


@interface YaoViewController : UIViewController

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) SystemSoundID soundID;

@end
