//
//  ViewController.m
//  BlocBrowser
//
//  Created by Samuel Shih on 1/25/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.

#import "ViewController.h"
#import <WebKit/Webkit.h>
#import "AwesomeFloatingToolbar.h"

// Define keywords that will be replaced with whatever we define here
#define kWebBrowerBackString NSLocalizedString(@"Back", @"Back command ")
#define kWebBrowerForwardString NSLocalizedString(@"Forward", @"Forward command ")
#define kWebBrowerStopString NSLocalizedString(@"Stop", @"Stop command ")
#define kWebBrowerRefreshString NSLocalizedString(@"Refresh", @"Reload command ")

// Declare that our view controller conforms to the following protocols
@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

// Private Properties
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;
@property (nonatomic, assign) NSUInteger framecount;
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
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowerBackString, kWebBrowerForwardString, kWebBrowerRefreshString, kWebBrowerStopString]];
    self.awesomeToolbar.delegate = self;


    for (UIView *viewToAdd in @[self.webView, self.textField, self.awesomeToolbar]) {
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
    
    // Creating my own toolbar in the view
    self.awesomeToolbar.frame = CGRectMake(20, 180, 340, 100);
    
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
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    
    // Assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    
    // Set the button positions
//    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
//        
//        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webView.frame), buttonWidth, itemHeight);
//        currentButtonX += buttonWidth;
//    }

}

// Implementing the protocol method
- (void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    
    // Update the titles to use our #defined properties
    if ([title isEqual:kWebBrowerBackString]) {
        [self.webView goBack];
    } else if ([title isEqual:kWebBrowerForwardString]){
        [self.webView goForward];
    } else if ([title isEqual:kWebBrowerStopString]){
        [self.webView stopLoading];
    } else if ([title isEqual:kWebBrowerRefreshString]) {
        [self.webView reload];
    }
    

}

// Implement the pan method
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    
    // Top-left corner of where the toolbar is located
    CGPoint startingPoint = toolbar.frame.origin;
    
    // Where the future top-left corner
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
}

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didPinchToolbar:(CGFloat)scale {
    
//    CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
//    toolbar.bounds = CGRectApplyAffineTransform(toolbar.bounds, scaleTransform);
    
    CGPoint startingPoint = toolbar.frame.origin;
    
    CGRect potentialNewFrame = CGRectMake(startingPoint.x, startingPoint.y, CGRectGetWidth(toolbar.frame) * scale, CGRectGetHeight(toolbar.frame) * scale);
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
    
    
}

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didLongPress:(CFTimeInterval)minimumPressDuration {
    
    NSLog(@"Labels: %@",toolbar.labels);
    
    for (UILabel *label in toolbar.labels) {
        
        NSUInteger currentLabelIndex = [toolbar.labels indexOfObject:label];
        label.backgroundColor = toolbar.colors[currentLabelIndex];
        
        NSLog(@"%lu",(unsigned long)currentLabelIndex);

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
    
    // Enable the buttons if these states are true
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowerBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowerForwardString];
    [self.awesomeToolbar setEnabled:[self.webView isLoading] forButtonWithTitle:kWebBrowerStopString];
    [self.awesomeToolbar setEnabled:[self.webView isLoading] && self.webView.URL forButtonWithTitle:kWebBrowerRefreshString];
}

- (void) resetWebView {
    
    // Removes the old web view from the view hierarchy
    [self.webView removeFromSuperview];
    
    // Creates a new empty web view and adds it back in
    WKWebView *newWebView = [[WKWebView alloc] init];
    newWebView.navigationDelegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    // Clears the URL field
    self.textField.text = nil;
    [self updateButtonsAndTitle];
    
}

@end
