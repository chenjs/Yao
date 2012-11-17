//
//  ViewController.m
//  Yao
//
//  Created by chenjs on 12-11-10.
//  Copyright (c) 2012年 HelloTom. All rights reserved.
//

#import "YaoViewController.h"

//#define kDeltaY     100
const int kTopMargin = -12;
const int kBottomMargin = 160;

@interface YaoViewController ()

@property (nonatomic, assign) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, assign) IBOutlet UIImageView *basketTop;
@property (nonatomic, assign) IBOutlet UIImageView *basketBottom;

@end

@implementation YaoViewController {
    CGRect originalBugFrame;
    CGRect originalBasketTopFrame;
    CGRect originalBasketBottomFrame;
}

@synthesize motionManager = _motionManager;
@synthesize soundID = _soundID;
@synthesize backgroundImage = _backgroundImage;
@synthesize basketTop = _basketTop;
@synthesize basketBottom = _basketBottom;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *voicePath = [[NSBundle mainBundle] pathForResource:@"shake_sound_male" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:voicePath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_soundID);
    
    originalBasketTopFrame = self.basketTop.frame;
    originalBasketBottomFrame = self.basketBottom.frame;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = kUpdateInterval;
    [self startMonitorShake];
    
    self.backgroundImage.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openBasketWithAnimation
{
    self.backgroundImage.hidden = NO;
    
    CGRect basketTopFrame = self.basketTop.frame;
    //basketTopFrame.origin.y = - basketTopFrame.size.height;
    //basketTopFrame.origin.y -= kDeltaY;
    basketTopFrame.origin.y = kTopMargin;
    
    CGRect basketBottomFrame = self.basketBottom.frame;
    //basketBottomFrame.origin.y = self.view.bounds.size.height;
    //basketBottomFrame.origin.y += kDeltaY;
    basketBottomFrame.origin.y = 480 - kBottomMargin;
        
    [UIView animateWithDuration:0.3f delay:0.2f options:UIViewAnimationCurveEaseOut animations:^{
         self.basketTop.frame = basketTopFrame;
         self.basketBottom.frame = basketBottomFrame;
         
     } completion:^(BOOL finished) {
         //NSLog(@"Basket has been opened!");
         
         [self closeBasketWithAnimation];
     }];
}

- (void)closeBasketWithAnimation
{
    CGRect basketTopFrame = self.basketTop.frame;
    //basketTopFrame.origin.y = 0;
    //basketTopFrame.origin.y += kDeltaY;
    basketTopFrame.origin.y = originalBasketTopFrame.origin.y;
    
    CGRect basketBottomFrame = self.basketBottom.frame;
    //basketBottomFrame.origin.y = self.view.bounds.size.height - basketBottomFrame.size.height;
    //basketBottomFrame.origin.y -= kDeltaY;
    basketBottomFrame.origin.y = originalBasketBottomFrame.origin.y;
    
    [UIView animateWithDuration:0.3f delay:0.4f options:UIViewAnimationCurveEaseIn animations:^{
        self.basketTop.frame = basketTopFrame;
        self.basketBottom.frame = basketBottomFrame;
        
    } completion:^(BOOL finished) {
        //NSLog(@"Basket has been closed yet!");
        
        //[self openBasketWithAnimation];
        
        self.backgroundImage.hidden = YES;
        [self startMonitorShake];
    }];
}

- (void)startMonitorShake
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [self.motionManager startAccelerometerUpdatesToQueue:queue
         withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
             
             if (error) {
                 NSLog(@"meet error: %@", error);
                 [self.motionManager stopAccelerometerUpdates];
             } else {
                 
                 CMAcceleration acceleration = accelerometerData.acceleration;
                 if (acceleration.x >= kAccelerationThreshold ||
                     acceleration.y >= kAccelerationThreshold ||
                     acceleration.z >= kAccelerationThreshold) {
                     
                     [self didAccelerate:accelerometerData];
                 }
             }
         }];
}


- (void)didAccelerate:(CMAccelerometerData *)accelerometerData
{
    static NSInteger shakeCount = 0;
    static NSDate *shakeStart;
    
    NSDate *now = [[NSDate alloc] init];
    NSDate *checkDate = [[NSDate alloc] initWithTimeInterval:1.5f sinceDate:shakeStart];
    
    if ([now compare:checkDate] == NSOrderedDescending || shakeStart == nil) {
        shakeCount = 0;
        shakeStart = [[NSDate alloc] init];
    }
    
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    if (fabsf(acceleration.x) > kAccelerationThreshold
        || fabsf(acceleration.y) > kAccelerationThreshold
        || fabsf(acceleration.z) > kAccelerationThreshold) {
        shakeCount++;
        if (shakeCount > kMinimumShakeCount) {
            // Do something
            [self reportShakeEvent];
            
            shakeCount = 0;
            shakeStart = [[NSDate alloc] init];
        }
    }
}

- (void)reportShakeEvent
{
    [self performSelectorOnMainThread:@selector(openBasketWithAnimation) withObject:nil waitUntilDone:NO];
    [self.motionManager stopAccelerometerUpdates];
    
    AudioServicesPlaySystemSound(self.soundID);
}


@end
