# 4399统一登录SDK iOS版接入说明

## 简介

本SDK主要用于4399账号的统一授权登录使用，旨在统一内部产品及外部第三方应用统一规范使用4399账户体系完成登录系统，便于用户使用4399账号登录自己的iOS应用。

框架内置4399游戏盒授权登录 & 4399用户中心WEB登录，根据用户是否安装游戏盒情况，优先选择游戏盒授权登录。

## 登录流程

用户登录/注册时，待接入应用可以配合以下流程完成授权流程，并合理保存授权令牌（Token）。

​![登录/注册授权流程](http://ww4.sinaimg.cn/large/006tNbRwgw1f6qqm38gl7j30ui0f9jsj.jpg)

登录成功后，客户端应保存用户AccessToken，用于下次启动是验证用户登录状态是否正常，每个AccessToken有效时间在上图中5.中返回。

![启动验证登录](http://ww4.sinaimg.cn/large/006tNbRwgw1f6qqo6y179j30mr0gimxz.jpg)

服务端应保存用户RefreshToken，用于在AccessToken过期时，向登录SDK服务端请求刷新AccessToken的有效期。

![AccessToken过期流程](http://ww4.sinaimg.cn/large/006tNbRwgw1f6qqory8rwj30mr0giab3.jpg)

RefreshToken没有设置过期时间，但当用户修改密码或其他异常情况时，RefreshToken将自动失效，此刻需要求用户重新登录。

![RefreshToken失效流程](http://ww4.sinaimg.cn/large/006tNbRwgw1f6qqpcwgwwj30mr0gijsf.jpg)

## 接入方式

### CocoaPods托管



### 直接导入文件



## 客户端接口说明

### 初始化

#### 配置登录SDK

建议在AppDelegate的`- application: didFinishLaunchingWithOptions:` 函数内初始化SDK，避免游戏盒回调应用时，应用已退出，造成回调无法执行。

``` objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // .....应用自身业务代码
    M4399LoginManagerConfig *config = [[M4399LoginManagerConfig alloc] initWithClientId:APP_CLIENT_ID callbackUrl:APP_CALLBACK_URL urlScheme:URL_SCHEMES];
    M4399LoginManager *manager = [[M4399LoginManager shareManager] initWithConfig:config];
  // .....应用自身业务代码
    return YES;
}
```

M4399LoginManagerConfig变量说明

| 变量名                     |    类型    | 必选填参数 | 备注                  | 
| :---------------------- | :------: | :---: | :------------------ | 
| clientId                | NSString |   √   | 4399用户中心分配的ClientID | 
| callbackUrl             | NSString |   √   | 4399用户中心登记的回调地址     | 
| urlSchemes              | NSString |   √   | 应用接收回调的UrlScheme    | 
| navBackgroupColor       | UIColor  |       | WEB授权页面的导航栏颜色       | 
| navButtonColor          | UIColor  |       | WEB授权页面的导航栏按钮颜色     | 
| navButtonHighlightColor | UIColor  |       | WEB授权页面的导航栏按钮按下颜色   | 
| hudColor                | UIColor  |       | WEB授权页面的加载动画组件颜色    | 

#### 接收回调通知

在使用游戏盒授权登录时，需要通过调用UrlScheme来跳转回当前应用。回调参数通过url传递，需要接入方在AppDelegate的`- application: handleOpenURL:` 或`- application: openURL: sourceApplication: annotation:`函数内接收到启动的URL时，将其传入`M4399LoginManager`中。

``` objective-c
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
  	// .....应用自身业务代码
    [[M4399LoginManager shareManager] handleOpenURL:url];
    return YES;
}
```

*如果应用启动游戏盒授权后，无法正常返回应用，请检查接入时是否正确配置了`UrlSchemes`，并且在启动时写入`M4399LoginManagerConfig`配置`M4399LoginManager` *

### 登录

登录时，登录SDK会自动判断用户手机是否有安装支持登录授权功能的游戏盒版本，如果已安装，则跳转游戏盒登录授权，登录成功后返回RefreshToken。如果未安装，则跳转用户中心WEB登录页面，登录成功后返回Code。然后返回到服务端向登录SDK服务端发起请求。

``` objective-c
[[M4399LoginManager shareManager] login:^(BOOL isUserCancel, NSString * _Nullable code, NSString * _Nullable refreshToken, NSString * _Nullable errorMsg) {
  		if(!isUserCancel){
        	if (code) {
            	//将code传递至服务端获取AccessToken
        	}else{
            	//将refreshToken传递至服务端获取AccessToken
        	}
        }
    }];
```

返回值

| 参数名          | 参数类型     | 备注                    | 
| ------------ | -------- | --------------------- | 
| isUserCancel | BOOL     | `YES`用户取消登录  `NO`登录成功 | 
| code         | NSString | WEB登录成功返回             | 
| refreshToken | NSString | 游戏盒登录成功返回             | 
| errorMsg     | NSString | 错误信息                  | 

### 注册

注册流程、返回值与登录流程一直，返回值请参考登录接口。

``` objective-c
[[M4399LoginManager shareManager] register:^(BOOL isUserCancel, NSString * _Nullable code, NSString * _Nullable refreshToken, NSString * _Nullable errorMsg)  {
        if(!isUserCancel){
        	if (code) {
            	//将code传递至服务端获取AccessToken
        	}else{
            	//将refreshToken传递至服务端获取AccessToken
        	}
        }
    }];
```



### 修改昵称

修改昵称需在用户已登录时使用，调用接口时需使用有效的AccessToken和uid

``` objective-c
[[M4399LoginManager shareManager] modifyNicknameWithUid:_uid accessToken:_accessToken handler:^(BOOL isSuccess, NSString * _Nullable newNickname, NSString * _Nullable errorMsg) {
  if(isSuccess){
  	//处理用户更新后的新昵称 newNickname
  }
}];
```

返回值

| 参数名         | 参数类型     | 备注                              | 
| ----------- | -------- | ------------------------------- | 
| isSuccess   | BOOL     | `YES` 修改成功;`NO` 用户取消/修改失败       | 
| newNickname | NSString | 修改后的新昵称，`isSuccess==NO`时值为`nil` | 
| errorMsg    | NSString | 错误信息                            | 

## 服务端接口说明

### 游戏盒登录REFRESH_TOKEN授权

- 接口地址：https://ptlogin.4399.com/oauth2/token.do
- 请求方式：GET / POST
- 请求参数


| 参数名           | 备注                          | 
| ------------- | --------------------------- | 
| grant_type    | 传递固定参数值`REFRESH_TOKEN` | 
| client_id     | 4399用户中心分配的ClientID         | 
| redirect_uri  | 4399用户中心登记的回调地址             | 
| client_secret | 4399用户中心分配的ClientSecret     | 
| refresh_token | 游戏盒登录流程中返回的refresh_token     | 

- 返回值 

| 参数名           | 备注                          | 
| ------------- | --------------------------- | 
| uid    | 4399用户ID | 
| username     | 用户名         | 
| nick | 昵称     | 
| access_token          | 授权令牌                            | 
| expires_in          | AccessTokne有效时长                            | 

注1：部分返回值在使用本SDK时无需关注，此处暂不列出
注2：几个昵称字段中部分可能为空值，APP界面显示昵称时应遵循规则：`nick` > `username`


### 4399用户中心WEB登录CODE授权 

- 接口地址：https://ptlogin.4399.com/oauth2/token.do 
- 请求方式：GET / POST 
- 请求参数 

| 参数名           | 备注                          | 
| ------------- | --------------------------- | 
| grant_type    | 传递固定参数值`AUTHORIZATION_CODE` | 
| client_id     | 4399用户中心分配的ClientID         | 
| redirect_uri  | 4399用户中心登记的回调地址             | 
| client_secret | 4399用户中心分配的ClientSecret     | 
| code          | WEB登录流程中返回的CODE    | 


- 返回值 

| 参数名           | 备注                          | 
| ------------- | --------------------------- | 
| uid    | 4399用户ID | 
| username     | 用户名         | 
| display_name     | 昵称         | 
| ext_nick     | 昵称         | 
| expires_in          | AccessTokne有效时长                            | 
| expired_at          | AccessTokne过期时间                            |
| access_token          | 授权令牌                            | 
| refresh_token          | 授权刷新令牌                            |

注1：部分返回值在使用本SDK时无需关注，此处暂不列出
注2：几个昵称字段中部分可能为空值，APP界面显示昵称时应遵循规则：`display_name` > `ext_nick` > `username`



