//
//  ViewController.m
//  YCMarkdown
//
//  Created by  Fancy on 2022/7/12.
//

#import "ViewController.h"
#import "YCMarkdownView.h"

@interface ViewController ()

@property (nonatomic, strong) YCMarkdownView *markdownView;
@property (nonatomic, assign) NSInteger      styleIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Style" style:UIBarButtonItemStylePlain target:self action:@selector(changeStyle:)];
    
    [self.view addSubview:self.markdownView];
    
    NSString *markdown = [NSString stringWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"sample" ofType:@"md"] encoding:NSUTF8StringEncoding error:nil];
    [self.markdownView loadMarkdown:markdown];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.markdownView.frame = self.view.bounds;
}

#pragma mark - Action
- (void)changeStyle:(id)sender {
    self.styleIndex ++;
    NSArray *styleArray = [self.markdownView supportedHighlightStyleArray];
    if (self.styleIndex > styleArray.count - 1) {
        self.styleIndex = 0;
    }
    self.markdownView.highlightStyle = styleArray[self.styleIndex];
    self.title = styleArray[self.styleIndex];
}

#pragma mark - Get
- (YCMarkdownView *)markdownView {
    if (!_markdownView) {
        _markdownView = [[YCMarkdownView alloc] init];
    }
    return _markdownView;
}

@end
