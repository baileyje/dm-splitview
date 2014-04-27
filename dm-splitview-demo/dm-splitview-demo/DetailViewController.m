#import "DetailViewController.h"
#import "DMSplitViewController.h"

@implementation DetailViewController


- (void)viewDidLoad {
    NSLog(@"DVC: Will Appear");
    self.dmSplitViewController.delegate = self;
    self.navigationItem.title = @"Detail Controller";
}

-(void)splitViewControllerWillHideMaster:(DMSplitViewController*)splitViewController {
    NSLog(@"DVC: Will Hide");
    NSLog(@"Hiding....");
    UIBarButtonItem* toggle = splitViewController.barButtonItem;
    toggle.title = @"BOOM";
    self.navigationItem.leftBarButtonItem = toggle;
}

-(void)splitViewControllerWillShowMaster:(DMSplitViewController*)splitViewController {
    NSLog(@"DVC: Will Show");
    NSLog(@"Showing....");
    self.navigationItem.leftBarButtonItem = nil;
}

@end