//
//  WebViewController.m
//  OKWeb
//
//  Created by cort xu on 2021/7/18.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController() <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (strong, nonatomic) WKWebView*      webView;
@property (strong, nonatomic) UIProgressView* progressView;
@end

@implementation WebViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"WKWebView";
  self.view.backgroundColor = [UIColor whiteColor];
  
  UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(onLeftClick)];
  self.navigationItem.leftBarButtonItem = leftItem;
  
  [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
  
  NSURL* url = [NSURL URLWithString:@"https://www.baidu.com"];
  NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
  [self.webView loadRequest:request];
}

- (void)dealloc {
  [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (WKWebView*)webView {
  if (_webView) {
    return _webView;
  }
  
  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
  
  WKPreferences *preferences = [WKPreferences new];
  preferences.javaScriptCanOpenWindowsAutomatically = YES;
  preferences.minimumFontSize = 40.0;
  configuration.preferences = preferences;
  
  // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
  configuration.allowsInlineMediaPlayback = YES;
  //设置是否允许画中画技术 在特定设备上有效
  configuration.allowsPictureInPictureMediaPlayback = YES;
  //设置请求的User-Agent信息中应用程序名称 iOS9后可用
  configuration.applicationNameForUserAgent = @"ChinaDailyForiPad";
  
  _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
  
  _webView.backgroundColor = UIColor.blueColor;
  _webView.allowsBackForwardNavigationGestures = YES;
  _webView.UIDelegate = self;
  _webView.navigationDelegate = self;
  [self.view addSubview:_webView];
  
  return _webView;
}

- (UIProgressView*)progressView {
  if (_progressView) {
    return _progressView;
  }
  
  CGFloat kScreenWidth = [[UIScreen mainScreen] bounds].size.width;
  _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 2)];
  _progressView.tintColor = [UIColor redColor];
  _progressView.trackTintColor = [UIColor lightGrayColor];
  [self.view addSubview:_progressView];
  
  return _progressView;
}

- (void)onLeftClick {
  if ([self.webView canGoBack]) {
      [self.webView goBack];
      NSLog(@"goBack");
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
    CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
    if (newprogress == 1) {
      [self.progressView setProgress:1.0 animated:YES];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
      });
      
    }else {
      self.progressView.hidden = NO;
      [self.progressView setProgress:newprogress animated:YES];
    }
  }
}

#pragma mark - WKNavigationDelegate
/*
 WKNavigationDelegate主要处理一些跳转、加载处理操作，WKUIDelegate主要处理JS脚本，确认框，警告框等
 */

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  NSLog(@"didStartProvisionalNavigation, webView: %@", webView);
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
  [self.progressView setProgress:0.0f animated:NO];
  
  NSLog(@"didFailProvisionalNavigation, webView: %@ error: %@", webView, error);
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
  NSLog(@"didCommitNavigation, webView: %@", webView);
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  NSLog(@"didFinishNavigation, webView: %@", webView);
  
  NSString *JsStr = @"(document.getElementsByTagName(\"video\")[0]).src";
  [self.webView evaluateJavaScript:JsStr completionHandler:^(id _Nullable response, NSError * _Nullable error) {
    if(![response isEqual:[NSNull null]] && response != nil){
      //截获到视频地址了
      NSLog(@"got video url success, %@", response);
      //
      //      NSURL* url = [NSURL URLWithString:response];
      //      NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
      //
      //      [self.webView startDownloadUsingRequest:request completionHandler:^(WKDownload * _Nonnull download) {
      //        download.delegate = self;
      //        NSLog(@"download url: %@", download.originalRequest.URL.absoluteURL);
      //      }];
    }else{
      //没有视频链接
      NSLog(@"got video url fail");
    }
  }];
}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  [self.progressView setProgress:0.0f animated:NO];
  
  NSLog(@"didFailNavigation, webView: %@ error: %@", webView, error);
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
  NSLog(@"didReceiveServerRedirectForProvisionalNavigation, webView: %@", webView);
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  NSString * urlStr = navigationAction.request.URL.absoluteString;
  
  NSLog(@"decidePolicyForNavigationAction, webView: %@ url: %@", webView, urlStr);
  
  //  if ([urlStr isEqualToString:@"about:blank"]) {
  //      NSLog(@"发送跳转请求 blank");
  //      decisionHandler(WKNavigationActionPolicyCancel);
  //      return;
  //  }
  
  //自己定义的协议头
  NSString *htmlHeadString = @"github://";
  if([urlStr hasPrefix:htmlHeadString]){
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"通过截取URL调用OC" message:@"你想前往我的Github主页?" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
      
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      NSURL * url = [NSURL URLWithString:[urlStr stringByReplacingOccurrencesOfString:@"github://callName_?" withString:@""]];
      [[UIApplication sharedApplication] openURL:url];
      
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
    decisionHandler(WKNavigationActionPolicyCancel);
    
  }else{
    decisionHandler(WKNavigationActionPolicyAllow);
  }
}

// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
  NSString * urlStr = navigationResponse.response.URL.absoluteString;
  NSLog(@"decidePolicyForNavigationResponse, webView: %@ url: %@", webView, urlStr);
  //允许跳转
  decisionHandler(WKNavigationResponsePolicyAllow);
  //不允许跳转
  //decisionHandler(WKNavigationResponsePolicyCancel);
}

//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
  
  //用户身份信息
  NSURLCredential * newCred = [[NSURLCredential alloc] initWithUser:@"user123" password:@"123" persistence:NSURLCredentialPersistenceNone];
  //为 challenge 的发送方提供 credential
  [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
  completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
  
}

//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
  NSLog(@"webViewWebContentProcessDidTerminate, webView: %@", webView);
}

#pragma mark - WKUIDelegate
/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"HTML的弹出框" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
  [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    completionHandler();
  }])];
  [self presentViewController:alertController animated:YES completion:nil];
}
// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
  [alertController addAction:([UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    completionHandler(NO);
  }])];
  [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    completionHandler(YES);
  }])];
  [self presentViewController:alertController animated:YES completion:nil];
}
// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
  [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.text = defaultText;
  }];
  [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    completionHandler(alertController.textFields[0].text?:@"");
  }])];
  [self presentViewController:alertController animated:YES completion:nil];
}
// 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
  if (!navigationAction.targetFrame.isMainFrame) {
    [webView loadRequest:navigationAction.request];
  }
  return nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
  //    message.body  --  Allowed types are NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull.
}



@end
