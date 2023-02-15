#import <LoggedOutView.h>
#import <LoggedOutViewController.h>
#import "TwitchLoginFixViewController.h"

#define TW_LOGIN_URL @"https://www.twitch.tv/login"
#define TW_SIGNUP_URL @"https://www.twitch.tv/signup"

static void auth(_TtC6Twitch23LoggedOutViewController *loggedOutViewController, NSURL *url) {
  TwitchLoginFixViewController *loginFixViewController =
      [[TwitchLoginFixViewController alloc] initWithLoggedOutViewController:loggedOutViewController
                                                                        URL:url];
  [loggedOutViewController.navigationController pushViewController:loginFixViewController
                                                          animated:YES];
  [loggedOutViewController.navigationController setNavigationBarHidden:NO animated:YES];
}

@interface _TtC6Twitch23LoggedOutViewController ()
- (void)startAuthFlowWithURL:(NSURL *)url;
@end

@interface _TtC6Twitch13LoggedOutView ()
- (void)startAuthFlowWithURL:(NSURL *)url;
@end

%hook _TtC6Twitch23LoggedOutViewController
- (void)tapLogin {
  [self startAuthFlowWithURL:[NSURL URLWithString:TW_LOGIN_URL]];
}
- (void)tapSignup {
  [self startAuthFlowWithURL:[NSURL URLWithString:TW_SIGNUP_URL]];
}
%new
- (void)startAuthFlowWithURL:(NSURL *)url {
  auth(self, url);
}
%end

%hook _TtC6Twitch13LoggedOutView
- (void)loginTapped {
  [self startAuthFlowWithURL:[NSURL URLWithString:TW_LOGIN_URL]];
}
- (void)signupTapped {
  [self startAuthFlowWithURL:[NSURL URLWithString:TW_SIGNUP_URL]];
}
%new
- (void)startAuthFlowWithURL:(NSURL *)url {
  _TtC6Twitch23LoggedOutViewController *loggedOutViewController =
      (_TtC6Twitch23LoggedOutViewController *)self;
  while (loggedOutViewController &&
         ![loggedOutViewController
             isKindOfClass:objc_getClass("_TtC6Twitch23LoggedOutViewController")])
    loggedOutViewController =
        (_TtC6Twitch23LoggedOutViewController *)loggedOutViewController.nextResponder;
  auth(loggedOutViewController, url);
}
%end

%hook _TtC6Twitch21PrivacyConsentManager
- (void)userAvailabilityChanged {
}
- (void)refreshIfNeeded {
}
%end

%ctor {
  if ([%c(_TtC6Twitch23LoggedOutViewController)
          instancesRespondToSelector:@selector
          (loginViewController:completedLoginWithResult:authToken:forMode:loginUserInfo:)])
    %init;
}
