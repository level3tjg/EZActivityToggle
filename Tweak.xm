@interface IGActivityStatusSetting
-(BOOL)activityStatusEnabled;
@end

@interface IGActivityStatusSettingService
-(void)setActivityStatusSetting:(BOOL)setting successBlock:(id)success failureBlock:(id)failure;
-(void)fetchActivityStatusSettingWithSuccessBlock:(id)success failureBlock:(id)failure;
@end

@interface IGUserSession : NSObject
-(IGActivityStatusSettingService *)activityStatusSettingService;
@end

@interface IGActiveUserSessions
-(IGUserSession *)presentedUserSession;
@end

@interface IGDirectInboxNavigationController : UINavigationController
@property (nonatomic, retain) UISwitch *activitySwitch;
@end

%group Hooks

%hook IGDirectInboxNavigationController
%property (nonatomic, retain) UISwitch *activitySwitch;
-(void)viewDidLoad{
    %orig;
    if(!self.activitySwitch){
        self.activitySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(50, 5, 0, 0)];
        self.activitySwitch.onTintColor = [UIColor colorWithRed:0 green:0.584 blue:0.965 alpha:1];
        [self.activitySwitch addTarget:self action:@selector(setActivityStatus:) forControlEvents:UIControlEventValueChanged];
        [self.navigationBar addSubview:self.activitySwitch];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    %orig;
    [[(IGUserSession *)[self valueForKey:@"_userSession"] activityStatusSettingService] fetchActivityStatusSettingWithSuccessBlock:^(IGActivityStatusSetting *statusSetting){
        [self.activitySwitch setOn:[statusSetting activityStatusEnabled]];
    } failureBlock:nil];
}
%new
-(void)setActivityStatus:(id)sender{
    [[(IGUserSession *)[self valueForKey:@"_userSession"] activityStatusSettingService] setActivityStatusSetting:[sender isOn] successBlock:nil failureBlock:nil];
}
%end

%end

%hookf(void *, dlopen, const char *path, int mode){
    void *handle = %orig;
    if(strstr(path, "InstagramAppCoreFramework"))
        %init(Hooks);
    return handle;
}

%ctor{
    %init(_ungrouped);
}
