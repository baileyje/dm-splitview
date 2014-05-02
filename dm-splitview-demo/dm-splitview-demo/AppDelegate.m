#import "AppDelegate.h"
#import "DMSplitViewController.h"
#import "MasterViewController.h"
#import "DetailViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    UIViewController* master = [[UINavigationController alloc] initWithRootViewController:[MasterViewController new]];
    UIViewController* detail = [[UINavigationController alloc] initWithRootViewController:[DetailViewController new]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[DMSplitViewController alloc] initWithMaster:master andDetail:detail];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication*)application {

}

- (void)applicationDidEnterBackground:(UIApplication*)application {

}

- (void)applicationWillEnterForeground:(UIApplication*)application {

}

- (void)applicationDidBecomeActive:(UIApplication*)application {

}

- (void)applicationWillTerminate:(UIApplication*)application {

}

@end