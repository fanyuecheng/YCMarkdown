//
//  YCMarkdownView.h
//  YCMarkdown
//
//  Created by  Fancy on 2022/7/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCMarkdownView : UIView

/// 支持高亮 默认 YES
@property (nonatomic, assign) BOOL highlight;
/// github风格 默认 YES
@property (nonatomic, assign) BOOL githubStyle;
/// 设置高亮风格 默认 default
@property (nonatomic, copy)   NSString *highlightStyle;

- (void)loadMarkdown:(NSString *)markdown;
- (NSArray *)supportedHighlightStyleArray;

@end

NS_ASSUME_NONNULL_END
