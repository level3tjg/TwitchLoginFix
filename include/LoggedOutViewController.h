#import "LoginUserInfo.h"
#import "LoginViewController.h"
#import "TWBaseViewController.h"

@interface _TtC6Twitch23LoggedOutViewController : TWBaseViewController
- (void)loginViewController:
            (_TtC6Twitch19LoginViewController *)loginViewController
    completedLoginWithResult:(NSInteger)result
                   authToken:(NSString *)authToken
                     forMode:(NSInteger)mode
               loginUserInfo:(_TtC6Twitch13LoginUserInfo *)loginUserInfo;
@end