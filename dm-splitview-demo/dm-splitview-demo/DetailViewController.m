#import "DetailViewController.h"
#import "DMSplitViewController.h"

@implementation DetailViewController


- (void)viewDidLoad {
    self.dmSplitViewController.delegate = self;
    self.navigationItem.title = @"Detail Controller";
}

-(void)splitViewControllerWillHideMaster:(DMSplitViewController*)splitViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem {
    barButtonItem.title = @"BOOM";
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

-(void)splitViewControllerWillShowMaster:(DMSplitViewController*)splitViewController {
    self.navigationItem.leftBarButtonItem = nil;
}

@end