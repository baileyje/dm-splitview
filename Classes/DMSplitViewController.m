#import "DMSplitViewController.h"

#define DM_SPLITVIEW_MASTER_WIDTH 320.0
#define DM_SPLITVIEW_DIVIDER_WIDTH 1.0
#define DM_SPLITVIEW_DIVIDER_COLOR [UIColor darkGrayColor]
#define DM_SPLITVIEW_EMBED_MASTER @"EmbedMaster"
#define DM_SPLITVIEW_EMBED_DETAIL @"EmbedDetail"


@interface DMSplitViewController()
@property (nonatomic, strong) UIView* dividerView;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer* leftEdgeDetector;
@property (nonatomic, strong) UISwipeGestureRecognizer* masterCloseRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* detailTapRecognizer;
@property (nonatomic, strong) UIViewController* masterController;
@property (nonatomic, strong) UIViewController* detailController;
@property (nonatomic, strong) UIBarButtonItem* barButtonItem;
@end

@implementation DMSplitViewController {
    BOOL masterVisible;
    id<DMSplitViewControllerDelegate> delegate;
}

- (CGSize)sizeForOrientation:(UIInterfaceOrientation)orientation {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    return CGSizeMake(width, height);
}

- (CGRect)masterFrameFor:(UIInterfaceOrientation)orientation {
    CGSize fullView = [self sizeForOrientation:orientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(0, 0, DM_SPLITVIEW_MASTER_WIDTH, fullView.height);
    } else {
        CGFloat offset = masterVisible ? 0 : -DM_SPLITVIEW_MASTER_WIDTH;
        return CGRectMake(offset, 0, DM_SPLITVIEW_MASTER_WIDTH, fullView.height);
    }
}

- (CGRect)detailFrameFor:(UIInterfaceOrientation)orientation {
    CGSize fullView = [self sizeForOrientation:orientation];
    NSLog(@"Full: %@", NSStringFromCGSize(fullView));
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(DM_SPLITVIEW_MASTER_WIDTH + 1, 0, fullView.width - DM_SPLITVIEW_MASTER_WIDTH - 1, fullView.height);
    } else {
        return CGRectMake(0, 0, fullView.width, fullView.height);
    }
}

- (CGRect)dividerFrameFor:(UIInterfaceOrientation)orientation {
    CGSize fullView = [self sizeForOrientation:orientation];
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
//    [self.masterController viewWillAppear:YES];
    [self.view bringSubviewToFront:self.masterContainer];
    [self.view bringSubviewToFront:self.dividerView];
    [self.detailContainer addGestureRecognizer:self.detailTapRecognizer];
    [self.view removeGestureRecognizer:self.leftEdgeDetector];
    [self.view addGestureRecognizer:self.masterCloseRecognizer];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             self.masterContainer.frame = [self masterFrameFor:self.interfaceOrientation];
             self.dividerView.frame = [self dividerFrameFor:self.interfaceOrientation];
         }
         completion:^(BOOL finished) {
//             [self.masterController viewDidAppear:YES];
             [self.view setNeedsLayout];

         }];
}

- (void)hideMaster {
    masterVisible = NO;
    [self.detailContainer removeGestureRecognizer:self.detailTapRecognizer];
    [self.view addGestureRecognizer:self.leftEdgeDetector];
    [self.view removeGestureRecognizer:self.masterCloseRecognizer];
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
        [delegate splitViewControllerWillHideMaster:self];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    self.dividerView = [UIView new];
    self.dividerView.backgroundColor = DM_SPLITVIEW_DIVIDER_COLOR;
    self.dividerView.alpha = .8;
    [self.view addSubview:self.dividerView];
    self.detailTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMaster)];
    self.leftEdgeDetector = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showMaster)];
    self.leftEdgeDetector.edges = UIRectEdgeLeft;
    self.masterCloseRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMaster)];
    self.masterCloseRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    self.barButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(showMaster)];
}

- (void)viewDidLayoutSubviews {
    self.dividerView.frame = [self dividerFrameFor:self.interfaceOrientation];
    self.detailContainer.frame = [self detailFrameFor:self.interfaceOrientation];
    self.masterContainer.frame = [self masterFrameFor:self.interfaceOrientation];

    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [self.view addGestureRecognizer:self.leftEdgeDetector];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    NSLog(@"SVC: Prepare Segue");
    if ([segue.identifier isEqualToString:DM_SPLITVIEW_EMBED_MASTER]) {
        self.masterController = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:DM_SPLITVIEW_EMBED_DETAIL]) {
        self.detailController = segue.destinationViewController;
    }
}

- (void)willRotate:(NSNotification*)notification {
    if (![self isViewLoaded] || notification == nil) { return; }

    UIInterfaceOrientation orientation = [[notification.userInfo valueForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
    NSLog(@"SVC: Will Rotate: %d", orientation);
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.detailContainer removeGestureRecognizer:self.detailTapRecognizer];
        [self.view removeGestureRecognizer:self.leftEdgeDetector];
        [delegate splitViewControllerWillShowMaster:self];
    }
    else {
        masterVisible = NO;
        [self.view addGestureRecognizer:self.leftEdgeDetector];
        [delegate splitViewControllerWillHideMaster:self withBarButtonItem:(UIBarButtonItem*)self.barButtonItem];
    }
}

@end

@implementation UIViewController (DMSplitViewController)

- (DMSplitViewController *)dmSplitViewController {
    UIViewController *parentViewController = self;
    while (parentViewController)
    {
        if ([parentViewController isKindOfClass:[DMSplitViewController class]])
            return (DMSplitViewController *)parentViewController;
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}

@end