
@protocol DMSplitViewControllerDelegate;

@interface DMSplitViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView* masterContainer;

@property (nonatomic, strong) IBOutlet UIView* detailContainer;

@property (nonatomic, readonly) UIViewController* masterController;

@property (nonatomic, readonly) UIViewController* detailController;

@property (nonatomic) id<DMSplitViewControllerDelegate> delegate;

@property (nonatomic, readonly) UIBarButtonItem* barButtonItem;

@property (nonatomic) BOOL shouldShowMasterInPortrait;

- (instancetype)initWithMaster:(UIViewController*)master andDetail:(UIViewController*)detail;

- (void)showMaster;

- (void)hideMaster;

@end

@protocol DMSplitViewControllerDelegate

- (void)splitViewControllerWillShowMaster:(DMSplitViewController*)splitViewController;

- (void)splitViewControllerWillHideMaster:(DMSplitViewController*)splitViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem;

@end

@interface UIViewController (DMSplitViewController)
@property (nonatomic, readonly) DMSplitViewController *dmSplitViewController;
@end