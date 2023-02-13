#import "TwitchLoginFixViewController.h"

@implementation TwitchLoginFixViewController
- (instancetype)initWithLoggedOutViewController:
                    (_TtC6Twitch23LoggedOutViewController *)
                        loggedOutViewController
                                            URL:(NSURL *)url {
  if ((self = [super init])) {
    _loggedOutViewController = loggedOutViewController;
    _url = url;
    UIActivityIndicatorViewStyle loadingIndicatorStyle =
        UIActivityIndicatorViewStyleGray;
    if (@available(iOS 13, *))
      loadingIndicatorStyle = UIActivityIndicatorViewStyleMedium;
    _loadingIndicator = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:loadingIndicatorStyle];
    _loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    _loadingIndicator.hidesWhenStopped = YES;
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    BOOL isDarkMode = NO;
    if (@available(iOS 13, *))
      isDarkMode =
          self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    WKUserScript *themeUserScript = [[WKUserScript alloc]
          initWithSource:[NSString
                             stringWithFormat:
                                 // clang-format off
                               @"localStorage.setItem('twilight.theme', %d);"
                                 // clang-format on
                                 ,
                                 isDarkMode]
           injectionTime:WKUserScriptInjectionTimeAtDocumentStart
        forMainFrameOnly:YES];
    WKUserScript *userScript = [[WKUserScript alloc]
          initWithSource:
              // clang-format off
                  @"var meta = document.createElement('meta');"
                  @"meta.name = 'viewport';"
                  @"meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';"
                  @"var css = `"
                  @"  div[data-a-target=\"auth-form-tab-container\"] {"
                  @"    display: none !important;"
                  @"  }"
                  @"  .hrNxVf > div {"
                  @"    min-width: 0 !important;"
                  @"  }"
                  @"`;"
                  @"var style = document.createElement('style');"
                  @"style.type = 'text/css';"
                  @"style.appendChild(document.createTextNode(css));"
                  @"var head = document.getElementsByTagName('head')[0];"
                  @"head.appendChild(meta);"
                  @"head.appendChild(style);"
                  @"document.__defineSetter__('cookie', function(cookie) {"
                  @"  window.webkit.messageHandlers.cookie.postMessage(cookie);"
                  @"});"
           // clang-format on
           injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
        forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:themeUserScript];
    [configuration.userContentController addUserScript:userScript];
    [configuration.userContentController addScriptMessageHandler:self
                                                            name:@"cookie"];
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero
                                  configuration:configuration];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.hidden = YES;
    _webView.navigationDelegate = self;
  }
  return self;
}
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [_webView.configuration.userContentController
      removeScriptMessageHandlerForName:@"cookie"];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
  if (@available(iOS 13, *))
    self.view.backgroundColor = UIColor.systemBackgroundColor;
  [self.view addSubview:_loadingIndicator];
  [self.view addSubview:_webView];
  [self.view addConstraints:@[
    [NSLayoutConstraint constraintWithItem:_loadingIndicator
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                  constant:0],
    [NSLayoutConstraint constraintWithItem:_loadingIndicator
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1
                                  constant:0],
    [NSLayoutConstraint constraintWithItem:_webView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1
                                  constant:0],
    [NSLayoutConstraint constraintWithItem:_webView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeHeight
                                multiplier:1
                                  constant:0],
  ]];
  [_webView.configuration.websiteDataStore
      removeDataOfTypes:[NSSet setWithArray:@[ WKWebsiteDataTypeCookies ]]
          modifiedSince:[NSDate dateWithTimeIntervalSince1970:0]
      completionHandler:^{
        [_loadingIndicator startAnimating];
        [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
      }];
}
- (void)webView:(WKWebView *)webView
    didFinishNavigation:(WKNavigation *)navigation {
  [_loadingIndicator stopAnimating];
  webView.hidden = NO;
}
- (void)showToastForError:(NSError *)error {
  [[objc_getClass("_TtC6Twitch12ToastManager") sharedInstance]
      showErrorToastWithText:error.localizedDescription];
  [_loggedOutViewController.navigationController popViewControllerAnimated:YES];
}
- (void)webView:(WKWebView *)webView
    didFailNavigation:(WKNavigation *)navigation
            withError:(NSError *)error {
  [self showToastForError:error];
}
- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
  [self showToastForError:error];
}
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
  if ([(NSString *)message.body hasPrefix:@"auth-token"]) {
    NSString *authToken =
        [[(NSString *)message.body componentsSeparatedByString:@"="][1]
            componentsSeparatedByString:@";"][0];
    [_loggedOutViewController.navigationController
        popViewControllerAnimated:YES];
    [_loggedOutViewController.navigationController setNavigationBarHidden:YES
                                                                 animated:YES];
    [_loggedOutViewController loginViewController:nil
                         completedLoginWithResult:1
                                        authToken:authToken
                                          forMode:0
                                    loginUserInfo:nil];
  }
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  BOOL isDarkMode = NO;
  if (@available(iOS 13, *))
    isDarkMode =
        self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
  [_webView
      evaluateJavaScript:
          [NSString stringWithFormat:
                        @"localStorage.setItem('twilight.theme', %d);"
                        @"var html = document.getElementsByTagName('html')[0];"
                        @"html.classList.remove('%@');"
                        @"html.classList.add('%@');",
                        isDarkMode, isDarkMode ? TW_THEME_LIGHT : TW_THEME_DARK,
                        isDarkMode ? TW_THEME_DARK : TW_THEME_LIGHT]
       completionHandler:nil];
}
@end