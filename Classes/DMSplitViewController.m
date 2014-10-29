#import "DMSplitViewController.h"

#define DM_SPLITVIEW_MASTER_WIDTH 320.0
#define DM_SPLITVIEW_DIVIDER_WIDTH 1.0
#define DM_SPLITVIEW_DIVIDER_COLOR [UIColor darkGrayColor]


@interface DMSplitViewController()
@property (nonatomic, strong) UIView* dividerView;
@property (nonatomic, strong) UIView* detailOverlay;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer* leftEdgeDetector;
@property (nonatomic, strong) UIViewController* masterController;
@property (nonatomic, strong) UIViewController* detailController;
@property (nonatomic, strong) UIBarButtonItem* barButtonItem;
@end

@implementation DMSplitViewController {
    BOOL masterVisible;
    id<DMSplitViewControllerDelegate> delegate;
}

- (instancetype)initWithMaster:(UIViewController*)master andDetail:(UIViewController*)detail {
    if(self = [super init]) {
        self.masterController = master;
        self.detailController = detail;
        CGRect masterFrame = [self masterFrameFor:UIApplication.sharedApplication.statusBarOrientation];
        self.masterContainer = [[UIView alloc] initWithFrame:masterFrame];
        self.masterContainer.autoresizesSubviews = YES;
        master.view.frame = CGRectMake(0, 0, masterFrame.size.width, masterFrame.size.height);
        [self addChildViewController:master];
        [master didMoveToParentViewController:self];
        [self.masterContainer addSubview:master.view];
        [self.view addSubview:self.masterContainer];
        CGRect detailFrame = [self detailFrameFor:UIApplication.sharedApplication.statusBarOrientation];
        self.detailContainer = [[UIView alloc] initWithFrame:detailFrame];
        self.detailContainer.autoresizesSubviews = YES;
        detail.view.frame = CGRectMake(0, 0, detailFrame.size.width, detailFrame.size.height);
        [self addChildViewController:detail];
        [detail didMoveToParentViewController:self];
        [self.detailContainer addSubview:detail.view];
        [self.view addSubview:self.detailContainer];
    }
    return self;
}

- (CGRect)masterFrameFor:(UIInterfaceOrientation)orientation {
    CGSize fullView = self.view.bounds.size;
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(0, 0, DM_SPLITVIEW_MASTER_WIDTH, fullView.height);
    } else {
        CGFloat offset = masterVisible ? 0 : -DM_SPLITVIEW_MASTER_WIDTH;
        return CGRectMake(offset, 0, DM_SPLITVIEW_MASTER_WIDTH, fullView.height);
    }
}

- (CGRect)detailFrameFor:(UIInterfaceOrientation)orientation {
    CGSize fullView = self.view.bounds.size;
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(DM_SPLITVIEW_MASTER_WIDTH + DM_SPLITVIEW_DIVIDER_WIDTH, 0, fullView.width - DM_SPLITVIEW_MASTER_WIDTH - DM_SPLITVIEW_DIVIDER_WIDTH, fullView.height);
    } else {
        return CGRectMake(0, 0, fullView.width, fullView.height);
    }
}

- (CGRect)dividerFrameFor:(UIInterfaceOrientation)orientation {
    CGSize fullView = self.view.bounds.size;
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(DM_SPLITVIEW_MASTER_WIDTH, 0, DM_SPLITVIEW_DIVIDER_WIDTH, fullView.height);
    } else {
        CGFloat offset = masterVisible ? DM_SPLITVIEW_MASTER_WIDTH : -DM_SPLITVIEW_DIVIDER_WIDTH;
        return CGRectMake(offset, 0, DM_SPLITVIEW_DIVIDER_WIDTH, fullView.height);
    }
}

- (void)showMaster {
    if(masterVisible) return;
    masterVisible = YES;
    [self.view bringSubviewToFront:self.masterContainer];
    [self.view bringSubviewToFront:self.dividerView];
    [self.view removeGestureRecognizer:self.leftEdgeDetector];
    [self.view insertSubview:self.detailOverlay belowSubview:self.masterContainer];
    self.detailOverlay.frame = [self detailFrameFor:self.interfaceOrientation];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             self.masterContainer.frame = [self masterFrameFor:self.interfaceOrientation];
             self.dividerView.frame = [self dividerFrameFor:self.interfaceOrientation];
         }
         completion:^(BOOL finished) {
             [self.view setNeedsLayout];
         }];
}

- (void)hideMaster {
    masterVisible = NO;
    [self.view addGestureRecognizer:self.leftEdgeDetector];
    [self.detailOverlay removeFromSuperview];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             self.masterContainer.frame = [self masterFrameFor:self.interfaceOrientation];
             self.dividerView.frame = [self dividerFrameFor:self.interfaceOrientation];
         }
         completion:^(BOOL finished) {
             [self.view setNeedsLayout];
         }];
}

- (void)setDelegate:(id <DMSplitViewControllerDelegate>)_delegate {
    delegate = _delegate;
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [delegate splitViewControllerWillShowMaster:self];
    } else {
        [delegate splitViewControllerWillHideMaster:self withBarButtonItem:self.barButtonItem];
    }
}

- (void)willRotate:(NSNotification*)notification {
    if (![self isViewLoaded] || notification == nil) { return; }
    UIInterfaceOrientation orientation = [[notification.userInfo valueForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.view removeGestureRecognizer:self.leftEdgeDetector];
        [delegate splitViewControllerWillShowMaster:self];
    }
    else {
        masterVisible = NO;
        [self.view addGestureRecognizer:self.leftEdgeDetector];
        [delegate splitViewControllerWillHideMaster:self withBarButtonItem:self.barButtonItem];
        [self.detailOverlay removeFromSuperview];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    for(UIViewController* child in self.childViewControllers) {
        if(!self.masterController && child.view.superview == self.masterContainer) {
            self.masterController = child;
        } else if(!self.detailController && child.view.superview == self.detailContainer) {
            self.detailController = child;
        }
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.dividerView = [UIView new];
    self.dividerView.backgroundColor = DM_SPLITVIEW_DIVIDER_COLOR;
    self.dividerView.alpha = .8;
    [self.view addSubview:self.dividerView];
    self.leftEdgeDetector = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showMaster)];
    self.leftEdgeDetector.edges = UIRectEdgeLeft;
    self.detailOverlay = [UIView new];
    UITapGestureRecognizer* detailTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMaster)];
    [self.detailOverlay addGestureRecognizer:detailTapRecognizer];
    UISwipeGestureRecognizer* masterCloseRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMaster)];
    masterCloseRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.detailOverlay addGestureRecognizer:masterCloseRecognizer];
    self.barButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(showMaster)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    self.dividerView.frame = [self dividerFrameFor:UIApplication.sharedApplication.statusBarOrientation];
    self.detailContainer.frame = [self detailFrameFor:UIApplication.sharedApplication.statusBarOrientation];
    self.masterContainer.frame = [self masterFrameFor:UIApplication.sharedApplication.statusBarOrientation];
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [self.view addGestureRecognizer:self.leftEdgeDetector];
    }
}

@end

@implementation UIViewController (DMSplitViewController)

- (DMSplitViewController *)dmSplitViewController {
    UIViewController* parentViewController = self;
    while (parentViewController)
    {
        if ([parentViewController isKindOfClass:[DMSplitViewController class]])
            return (DMSplitViewController*)parentViewController;
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}

@end