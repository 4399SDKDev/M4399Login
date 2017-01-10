//
//  ViewController.m
//  m4399LoginExample
//
//  Created by 郑旭 on 16/7/27.
//  Copyright © 2016年 4399 Inc. All rights reserved.
//

#import "ViewController.h"
#import <M4399Login/M4399Login.h>
#import "AppDelegate.h"

#define URL_SERVER_REQUEST @"https://ptlogin.4399.com/oauth2/token.do"

@interface ViewController (){
    NSString *_accessToken;
    NSString *_refreshToken;
    NSString *_displayName;
    NSString *_username;
    NSString *_uid;
    
    NSDateFormatter *_formatter;
}

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self outputLog:[NSString stringWithFormat:@"初始化成功！SDK版本号:v%@",[M4399LoginManager version]]];
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"hh:mm:ss:SSS"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender{
    [[M4399LoginManager shareManager] login:^(BOOL isUserCancel, NSString * _Nullable code, NSString * _Nullable refreshToken, NSString * _Nullable errorMsg) {
        
        if (isUserCancel) {
            [self outputLog:[NSString stringWithFormat:@"用户取消登录"]];
        }else{
            if (code) {
                [self analysisCode:code];
            }else if(refreshToken){
                [self analysisRefreshToken:refreshToken];
            }else{
                [self outputLog:[NSString stringWithFormat:@"登录异常：%@",errorMsg]];
            }
        }
    }];
}

- (IBAction)register:(id)sender{
    [[M4399LoginManager shareManager] register:^(BOOL isUserCancel, NSString * _Nullable code, NSString * _Nullable refreshToken, NSString * _Nullable errorMsg)  {
        if (isUserCancel) {
            [self outputLog:[NSString stringWithFormat:@"用户取消注册"]];
        }else{
            if (code) {
                [self analysisCode:code];
            }else if(refreshToken){
                [self analysisRefreshToken:refreshToken];
            }else{
                [self outputLog:[NSString stringWithFormat:@"注册异常：%@",errorMsg]];
            }
        }
    }];
}


-(IBAction)modifyUserInfo:(id)sender{
    if (!_accessToken) {
        [[[UIAlertView alloc] initWithTitle:@"请登入" message:@"请登入成功后使用该功能！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    [[M4399LoginManager shareManager] modifyUserInfoWithUid:_uid accessToken:_accessToken handler:^(BOOL isSuccess, NSString * _Nullable errorMsg) {
        if(isSuccess){
            [self outputLog:@"用户信息修改成功"];
        }else{
            [self outputLog:@"取消修改用户信息"];
        }
    }];
}

//请于服务端实现以下code解析的网络请求。
- (void)analysisCode:(NSString *)code{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@?grant_type=AUTHORIZATION_CODE&client_id=%@&redirect_uri=%@&client_secret=%@&code=%@",URL_SERVER_REQUEST,APP_CLIENT_ID,APP_CALLBACK_URL,APP_CLIENT_SECRET,code];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
        [request setHTTPMethod:@"GET"];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error && data) {
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
                NSLog(@"%@",resultDic);
                if(resultDic[@"error"]==nil){
                    _accessToken = [resultDic objectForKey:@"access_token"];
                    _refreshToken = [resultDic objectForKey:@"refresh_token"];
                    _username =[resultDic objectForKey:@"username"];
                    _uid =[resultDic objectForKey:@"uid"];
                    
                    //几个昵称字段中部分可能为空值，APP界面显示昵称时应遵循规则：`display_name` > `ext_nick` > `username`
                    NSString *displayName = [resultDic objectForKey:@"display_name"];
                    NSString *ext_nick = [resultDic objectForKey:@"ext_nick"];
                    if (displayName) {
                        //URLDecode
                        _displayName  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                              (__bridge CFStringRef)displayName,
                                                                                                                              CFSTR(""),
                                                                                                                              CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
                    }else if (ext_nick){
                        _displayName = ext_nick;
                    }else{
                        _displayName = _username;
                    }
                    
                    
                    [self outputLog:[NSString stringWithFormat:@"UID:%@",_uid]];
                    [self outputLog:[NSString stringWithFormat:@"用户名:%@",_username]];
                    [self outputLog:[NSString stringWithFormat:@"昵称:%@",_displayName]];
                    [self outputLog:[NSString stringWithFormat:@"ACCESS_TOKEN:%@",_accessToken]];
                    [self outputLog:[NSString stringWithFormat:@"REFRESH_TOKEN:%@",_refreshToken]];
                    [self outputLog:@"登录成功"];
                }
            }
        }];
        [task resume];
    });
    
}

//请于服务端实现以下RefreshToken解析的网络请求。
- (void)analysisRefreshToken:(NSString *)refreshToken{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@?grant_type=REFRESH_TOKEN&client_id=%@&redirect_uri=%@&client_secret=%@&refresh_token=%@",URL_SERVER_REQUEST,APP_CLIENT_ID,APP_CALLBACK_URL,APP_CLIENT_SECRET,refreshToken];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
        [request setHTTPMethod:@"GET"];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error && data) {
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:nil];
                NSLog(@"%@",resultDic);
                _accessToken = [resultDic objectForKey:@"access_token"];
                _refreshToken = refreshToken;
                NSString *nick = [resultDic objectForKey:@"nick"];
                _username =[resultDic objectForKey:@"username"];
                _uid =[resultDic objectForKey:@"uid"];
                //几个昵称字段中部分可能为空值，APP界面显示昵称时应遵循规则：`nick` > `username`
                if (nick && (![nick isEqualToString:@""])) {
                    _displayName = nick;
                }else{
                    _displayName = _username;
                }
                

                [self outputLog:[NSString stringWithFormat:@"UID:%@",_uid]];
                [self outputLog:[NSString stringWithFormat:@"用户名:%@",_username]];
                [self outputLog:[NSString stringWithFormat:@"昵称:%@",_displayName]];
                [self outputLog:[NSString stringWithFormat:@"ACCESS_TOKEN:%@",_accessToken]];
                [self outputLog:[NSString stringWithFormat:@"REFRESH_TOKEN:%@",_refreshToken]];
                [self outputLog:@"登录成功"];
            }
        }];
        [task resume];
    });
}

- (void)outputLog:(NSString *)log{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_logTextView.text isEqualToString:@""]) {
            _logTextView.text = log;
            _logTextView.text = [NSString stringWithFormat:@"%@ > %@",[_formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]],log];
        }else{
            _logTextView.text = [NSString stringWithFormat:@"%@ > %@\n%@",[_formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]],log,_logTextView.text];
        }
    });
    
}

@end
