//
//  AppDelegate.m
//  OcvARCocos2D
//
//  Created by Markus Konrad on 08.07.14.
//  Copyright INKA Research Group 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "ARScene.h"
#import "ARCtrl.h"
#import "CCNavigationControllerAR.h"
#import "CCDirectorAR.h"

@interface AppDelegate (Private)
- (void)createGLViewWithFrame:(CGRect)frame;
@end

@implementation AppDelegate


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    rootViewCtrl = [[RootViewCtrl alloc] init];
    
	[self createGLViewWithFrame:self.window.bounds];
    
    [glView setOpaque:NO];   // needed for transparent overlay
    
    CCDirectorIOS *director = (CCDirectorIOS*) [CCDirector sharedDirector];
    [director setWantsFullScreenLayout:YES];
    
    [director setView:glView];
    
#ifdef DEBUG
    [director setDisplayStats:YES];
#endif
    
    CGSize size = glView.frame.size;
    CGSize fixed = {384, 568};
    
    CGFloat scaleFactor = size.width / fixed.width;
    
    director.contentScaleFactor = scaleFactor;
    director.UIScaleFactor = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 1.0 : 0.5);
    
    // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
    [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor: 2.0];
    
    director.designSize = fixed;
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change this setting at any time.
	[CCTexture setDefaultAlphaPixelFormat:CCTexturePixelFormat_RGBA8888];
    
    // Initialise OpenAL
    [OALSimpleAudio sharedInstance];
	
    
    // "viewSize" returns the wrong px size (512x384), so we use viewSizeInPixels
    NSLog(@"view size in units: %dx%d, scale factor: %f",
          (int)glView.frame.size.width, (int)glView.frame.size.height,  director.UIScaleFactor);
//    int viewWUnits = glView.frame.size.width * director.UIScaleFactor;
//    int viewHUnits = glView.frame.size.height * director.UIScaleFactor;
    arCtrl = [[ARCtrl alloc] initWithFrame:glView.frame
                               orientation:UIInterfaceOrientationLandscapeRight];
    
    [arCtrl startCam];  // must be called before the subsequent commands
    
    // the "baseView" contains the camera view
    UIView *baseView = arCtrl.baseView;
    [baseView addSubview:glView];    // add the cocos2d opengl on top of the camera view
    
//    [((UIViewController *)director) setView:baseView];
    
//    [rootViewCtrl addChildViewController:director];
    [rootViewCtrl setView:baseView];
    
	arScene = [ARScene sceneWithMarkerScale:[ARCtrl markerScale]];
    
    [arScene setTracker:[arCtrl tracker]];
    
    [arCtrl setupProjection];

	// Create a Navigation Controller with the Director
	CCNavigationControllerAR *navCtrl = [[CCNavigationControllerAR alloc] initWithRootViewController:rootViewCtrl];
    [navCtrl setNavigationBarHidden:YES];
    [navCtrl setAppDelegateAR:self];
    [navCtrl setScreenOrientationAR:CCScreenOrientationLandscape];
    navController_ = navCtrl;
    
	// for rotation and other messages
	[director setDelegate:navController_];

//    [navController_ setView:baseView];
    
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
    
//    // replace cocos2d opengl view by "baseView" with camera view and opengl overlay
//    [window_.rootViewController setView:baseView];
	
	// make main window visible
	[window_ makeKeyAndVisible];
    
    [director startAnimation];
	
	return YES;
}



-(CCScene *)startScene
{
    return arScene;
}

// doesnt work:
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
//}

- (void)createGLViewWithFrame:(CGRect)frame {
	glView = [CCGLView viewWithFrame:frame
                         pixelFormat:kEAGLColorFormatRGBA8
                         depthFormat:GL_DEPTH_COMPONENT24_OES
                  preserveBackbuffer:NO
                          sharegroup:nil
                       multiSampling:NO
                     numberOfSamples:0 ];

}

@end
