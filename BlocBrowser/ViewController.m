//
//  ViewController.m
//  BlocBrowser
//
//  Created by Samuel Shih on 1/25/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/Webkit.h>

// Declare that our view controller conforms to the following protocols
@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate>

// Private Properties
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation ViewController

#pragma mark - UIViewController

- (void)loadView{
    
    // Create an instance of the UIView
    UIView *mainView = [UIView new];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    // Intialize the text field
    self.textField = [[UITextField alloc] init];
    
    // Determines the style of keyboard to be shown to the user
    self.textField.keyboardType = UIKeyboardTypeURL;
    
    // Determines the return key type "Done"
    self.textField.returnKeyType = UIReturnKeyDone;
    
    // No automatic text capitalization
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    // Disables auto-correction functionality
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // Initialize placeholder text
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    
    // Set the background color of the text field
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0 alpha:1.0];
    
    self.textField.delegate = self;
    
    // Adding the button views
    
    self.backButton =[UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back command") forState:UIControlStateNormal];
    
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward command") forState:UIControlStateNormal];
    
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Refresh command") forState:UIControlStateNormal];

    [self addButtonTargets];
    
    //    // Create a string with a website url
    //    NSString *urlString = @"http://www.google.com";
    //
    //    // Create an NSURL with that string
    //    NSURL *url = [NSURL URLWithString:urlString];
    //
    //    // Create an NSURLRequest with the url
    //    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //    [self.webView loadRequest:request];
    
//    [mainView addSubview:self.webView];
//    [mainView addSubview:self.textField];
//    [mainView addSubview:self.backButton];
//    [mainView addSubview:self.forwardButton];
//    [mainView addSubview:self.stopButton];
//    [mainView addSubview:self.reloadButton];

    for (UIView *viewToAdd in @[self.webView, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    // Welcome Message Alert
    
    // Create a UIAlertController that contains the content of the alert
    UIAlertController *welcomeAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Welcome",@"Welcome") message:@"Welcome to this awesome app!" preferredStyle:UIAlertControllerStyleAlert];
    
    // Create a UIAlertAction to determine what action the user can take when the alert pops up
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
    
    // Add the action to the alert
    [welcomeAlert addAction:okAction];
    
    // Display the alert
    [self presentViewController:welcomeAlert animated:YES completion:nil];
    
}

- (void) viewWillLayoutSubviews {
    
    // Let the viewWillLayoutSubviews method carry out it's job
    [super viewWillLayoutSubviews];
    
    // Set the webView frame to be the same frame as the containing main view
    self.webView.frame = self.view.frame;
    
    // Static height of URL bar
    static const CGFloat itemHeight = 50;
    
    // Width to be the same as the view width. Gets the CGRect of the view bounds
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    // Calculate the height of the browser view to be the height of the entire main view, minus the height of the URL bar
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
    
    // Determine the width of each button
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    // Assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    CGFloat currentButtonX = 0;
    
    // Set the button positions
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        
        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webView.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }

}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Once a user presses return the keyboard disappears
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    NSString *replacedSpaceURLString = [[NSString alloc]init];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    // Check if there is white space
    NSRange whiteSpaceRange = [URLString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Replace white space with the "+" sign and place it into the google search parameter
    if (whiteSpaceRange.location != NSNotFound) {
        replacedSpaceURLString = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSLog(@"%@",replacedSpaceURLString);
        URL = [NSURL URLWithString: [NSString stringWithFormat: @"http://www.google.com/search?q=%@", replacedSpaceURLString]];
    }
    
    // If the URL doesn't follow the scheme of a typical http:// url then add it.
   if (!URL.scheme) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
 
    
    // If a URL is present in the text field, then create an NSURLRequest and load the request in the web view
    if(URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    
    return NO;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    [self updateButtonsAndTitle];
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    [self updateButtonsAndTitle];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {

    [self webView: webView didFailNavigation:navigation withError:error];

}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {

    if (error.code != NSURLErrorCancelled) {
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error",@"Error") message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:okAction];
    
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self updateButtonsAndTitle];
}

#pragma mark - Other Methods

- (void) updateButtonsAndTitle {
    
    // Change the title of the Navigation Bar to reflect the loaded web page title
    NSString *webPageTitle = [self.webView.title copy];
    if ([webPageTitle length]){
        self.title = webPageTitle;
    } else {
        self.title = self.webView.URL.absoluteString;
    }
    
    // Start the activity indicator when the web page is loading and stop it when it isn't
    if (self.webView.isLoading){
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    // Enable the buttons
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
    self.stopButton.enabled = self.webView.isLoading;
    self.reloadButton.enabled = !self.webView.isLoading && self.webView.URL;
}

- (void) resetWebView {

    // Removes the old web view from the view hierarchy
    [self.webView removeFromSuperview];
    
    // Creates a new empty web view and adds it back in
    WKWebView *newWebView = [[WKWebView alloc] init];
    newWebView.navigationDelegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    // Point buttons to the new web view
    [self addButtonTargets];
    
    // Clears the URL field
    self.textField.text = nil;
    [self updateButtonsAndTitle];
    
}

- (void) addButtonTargets {

    for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]){
        
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    }
    
    [self.backButton addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self.webView action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadButton addTarget:self.webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];

}


@end
