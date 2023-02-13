#import <LoggedOutViewController.h>
#import <ToastManager.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

#define TW_THEME_LIGHT @"tw-root--theme-light"
#define TW_THEME_DARK @"tw-root--theme-dark"

@interface TwitchLoginFixViewController
    : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
@property(nonatomic) UIActivityIndicatorView *loadingIndicator;
@property(nonatomic, weak)
    _TtC6Twitch23LoggedOutViewController *loggedOutViewController;
@property(nonatomic, copy) NSURL *url;
@property(nonatomic) WKWebView *webView;
- (instancetype)initWithLoggedOutViewController:
                    (_TtC6Twitch23LoggedOutViewController *)
                        loggedOutViewController
                                            URL:(NSURL *)url;
@end