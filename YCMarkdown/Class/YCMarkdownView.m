//
//  YCMarkdownView.m
//  YCMarkdown
//
//  Created by  Fancy on 2022/7/12.
//

#import "YCMarkdownView.h"
#import <WebKit/WebKit.h>

@interface YCMarkdownView () <WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy)   NSString  *markdownString;
@property (nonatomic, copy)   NSString  *htmlString;

@property (nonatomic, copy)   NSString *darkCssLink;
@property (nonatomic, copy)   NSString *lightCssLink;
@property (nonatomic, copy)   NSString *highlightStyleCssLink;
@property (nonatomic, copy)   NSArray  *highlightStyleArray;

@end

@implementation YCMarkdownView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    _highlight = YES;
    _githubStyle = YES;
    _highlightStyle = @"default";
    [self addSubview:self.webView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.webView.frame = self.bounds;
}

- (void)loadMarkdown:(NSString *)markdown {
    if (markdown.length) {
        self.markdownString = markdown;
        WKUserScript *script = [[WKUserScript alloc] initWithSource:@"inputMarkdownText()" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [self.webView.configuration.userContentController addUserScript:script];
        
        NSString *html = nil;
        NSMutableArray *cssArray = [NSMutableArray array];
        if (self.highlight) {
            [cssArray addObject:[NSString stringWithFormat:self.highlightStyleCssLink, self.highlightStyle]];
        }
        if (self.githubStyle) {
            if (@available(iOS 13.0, *)) {
                [cssArray addObject:self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? self.darkCssLink : self.lightCssLink];
            } else {
                [cssArray addObject:self.lightCssLink];
            }
        }
        if (cssArray.count) {
            html = [NSString stringWithFormat:self.htmlString, [cssArray componentsJoinedByString:@""]];
        } else {
            html = [self.htmlString stringByReplacingOccurrencesOfString:@"%%@" withString:@""];
        }
        [self.webView loadHTMLString:html baseURL:nil];
    }
}

- (NSArray *)supportedHighlightStyleArray {
    return self.highlightStyleArray.copy;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self loadMarkdown:self.markdownString];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    completionHandler(self.markdownString);
}

#pragma mark - Get
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        _webView= [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.UIDelegate = self;
    }
    return _webView;
}

- (NSString *)htmlString {
    if (!_htmlString) {
        _htmlString = @"<!DOCTYPE html>\
        <html>\
            <head>\
                <meta charset=\"utf-8\"/>\
                <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>\
                <style>\
                    .markdown-body\
                    {\
                        box-sizing: border-box;\
                        min-width: 200px;\
                        max-width: 980px;\
                        margin: 0 auto;\
                        padding: 45px;\
                    }\
                    @media (max-width: 767px)\
                    {\
                        .markdown-body\
                        {\
                            padding: 15px;\
                        }\
                    }\
                </style>\
                %@\
                <script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/highlight.min.js\"></script>\
                <script src=\"https://cdnjs.cloudflare.com/ajax/libs/marked/4.2.12/marked.min.js\"></script>\
                <script>\
                    marked.setOptions({\
                        renderer: new marked.Renderer(),\
                        gfm: true,\
                        tables: true,\
                        breaks: true,\
                        pedantic: false,\
                        sanitize: false,\
                        smartLists: true,\
                        smartypants: false,\
                        highlight: function (code, lang) {\
                              if (lang && hljs.getLanguage(lang)) {\
                                  return hljs.highlight(lang, code, true).value;\
                              } else {\
                                  return hljs.highlightAuto(code).value;\
                              }\
                          }\
                    });\
                </script>\
                <script>\
                    function inputMarkdownText() {\
                        var response = prompt('inputMarkdownText', 'MarkdownText');\
                        document.getElementById('content').innerHTML = marked.parse(response);\
                    }\
                </script>\
                <title></title>\
            </head>\
            <body>\
                <article id=\"content\" class=\"markdown-body\" style=\"text-align: left;\"></article>\
            </body>\
        </html>";
    }
    return _htmlString;
}

- (NSString *)darkCssLink {
    if (!_darkCssLink) {
        _darkCssLink = @"<link href=\"https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown-dark.min.css\" rel=\"stylesheet\"/>";
    }
    return _darkCssLink;
}

- (NSString *)lightCssLink {
    if (!_lightCssLink) {
        _lightCssLink = @"<link href=\"https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown-light.min.css\" rel=\"stylesheet\"/>";
    }
    return _lightCssLink;
}

- (NSString *)highlightStyleCssLink {
    if (!_highlightStyleCssLink) {
        _highlightStyleCssLink = @"<link href=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/%@.min.css\" rel=\"stylesheet\"/>";
    }
    return _highlightStyleCssLink;
}

- (NSArray *)highlightStyleArray {
    if (!_highlightStyleArray) {
        _highlightStyleArray = @[@"a11y-dark", @"a11y-light", @"agate", @"an-old-hope", @"androidstudio", @"arduino-light", @"arta", @"ascetic", @"atom-one-dark-reasonable", @"atom-one-dark", @"atom-one-light", @"brown-paper", @"codepen-embed", @"color-brewer", @"dark", @"default", @"devibeans", @"docco", @"far", @"felipec", @"foundation", @"github-dark-dimmed", @"github-dark", @"github", @"gml", @"googlecode", @"gradient-dark", @"gradient-light", @"grayscale", @"hybrid", @"idea", @"intellij-light", @"ir-black", @"isbl-editor-dark", @"isbl-editor-light", @"kimbie-dark", @"kimbie-light", @"lightfair", @"lioshi", @"magula", @"mono-blue", @"monokai-sublime", @"monokai", @"night-owl", @"nnfx-dark", @"nnfx-light", @"nord", @"obsidian", @"paraiso-dark", @"paraiso-light", @"pojoaque", @"purebasic", @"qtcreator-dark", @"qtcreator-light", @"rainbow", @"routeros", @"school-book", @"shades-of-purple", @"srcery", @"stackoverflow-dark", @"stackoverflow-light", @"sunburst", @"tokyo-night-dark", @"tokyo-night-light", @"tomorrow-night-blue", @"tomorrow-night-bright", @"vs", @"vs2015", @"xcode", @"xt256", @"base16/3024", @"base16/apathy", @"base16/apprentice", @"base16/ashes", @"base16/atelier-cave-light", @"base16/atelier-cave", @"base16/atelier-dune-light", @"base16/atelier-dune", @"base16/atelier-estuary-light", @"base16/atelier-estuary", @"base16/atelier-forest-light", @"base16/atelier-forest", @"base16/atelier-heath-light", @"base16/atelier-heath", @"base16/atelier-lakeside-light", @"base16/atelier-lakeside", @"base16/atelier-plateau-light", @"base16/atelier-plateau", @"base16/atelier-savanna-light", @"base16/atelier-savanna", @"base16/atelier-seaside-light", @"base16/atelier-seaside", @"base16/atelier-sulphurpool-light", @"base16/atelier-sulphurpool", @"base16/atlas", @"base16/bespin", @"base16/black-metal-bathory", @"base16/black-metal-burzum", @"base16/black-metal-dark-funeral", @"base16/black-metal-gorgoroth", @"base16/black-metal-immortal", @"base16/black-metal-khold", @"base16/black-metal-marduk", @"base16/black-metal-mayhem", @"base16/black-metal-nile", @"base16/black-metal-venom", @"base16/black-metal", @"base16/brewer", @"base16/bright", @"base16/brogrammer", @"base16/brush-trees-dark", @"base16/brush-trees", @"base16/chalk", @"base16/circus", @"base16/classic-dark", @"base16/classic-light", @"base16/codeschool", @"base16/colors", @"base16/cupcake", @"base16/cupertino", @"base16/danqing", @"base16/darcula", @"base16/dark-violet", @"base16/darkmoss", @"base16/darktooth", @"base16/decaf", @"base16/default-dark", @"base16/default-light", @"base16/dirtysea", @"base16/dracula", @"base16/edge-dark", @"base16/edge-light", @"base16/eighties", @"base16/embers", @"base16/equilibrium-dark", @"base16/equilibrium-gray-dark", @"base16/equilibrium-gray-light", @"base16/equilibrium-light", @"base16/espresso", @"base16/eva-dim", @"base16/eva", @"base16/flat", @"base16/framer", @"base16/fruit-soda", @"base16/gigavolt", @"base16/github", @"base16/google-dark", @"base16/google-light", @"base16/grayscale-dark", @"base16/grayscale-light", @"base16/green-screen", @"base16/gruvbox-dark-hard", @"base16/gruvbox-dark-medium", @"base16/gruvbox-dark-pale", @"base16/gruvbox-dark-soft", @"base16/gruvbox-light-hard", @"base16/gruvbox-light-medium", @"base16/gruvbox-light-soft", @"base16/hardcore", @"base16/harmonic16-dark", @"base16/harmonic16-light", @"base16/heetch-dark", @"base16/heetch-light", @"base16/helios", @"base16/hopscotch", @"base16/horizon-dark", @"base16/horizon-light", @"base16/humanoid-dark", @"base16/humanoid-light", @"base16/ia-dark", @"base16/ia-light", @"base16/icy-dark", @"base16/ir-black", @"base16/isotope", @"base16/kimber", @"base16/london-tube", @"base16/macintosh", @"base16/marrakesh", @"base16/materia", @"base16/material-darker", @"base16/material-lighter", @"base16/material-palenight", @"base16/material-vivid", @"base16/material", @"base16/mellow-purple", @"base16/mexico-light", @"base16/mocha", @"base16/monokai", @"base16/nebula", @"base16/nord", @"base16/nova", @"base16/ocean", @"base16/oceanicnext", @"base16/one-light", @"base16/onedark", @"base16/outrun-dark", @"base16/papercolor-dark", @"base16/papercolor-light", @"base16/paraiso", @"base16/pasque", @"base16/phd", @"base16/pico", @"base16/pop", @"base16/porple", @"base16/qualia", @"base16/railscasts", @"base16/rebecca", @"base16/ros-pine-dawn", @"base16/ros-pine-moon", @"base16/ros-pine", @"base16/sagelight", @"base16/sandcastle", @"base16/seti-ui", @"base16/shapeshifter", @"base16/silk-dark", @"base16/silk-light", @"base16/snazzy", @"base16/solar-flare-light", @"base16/solar-flare", @"base16/solarized-dark", @"base16/solarized-light", @"base16/spacemacs", @"base16/summercamp", @"base16/summerfruit-dark", @"base16/summerfruit-light", @"base16/synth-midnight-terminal-dark", @"base16/synth-midnight-terminal-light", @"base16/tango", @"base16/tender", @"base16/tomorrow-night", @"base16/tomorrow", @"base16/twilight", @"base16/unikitty-dark", @"base16/unikitty-light", @"base16/vulcan", @"base16/windows-10-light", @"base16/windows-10", @"base16/windows-95-light", @"base16/windows-95", @"base16/windows-high-contrast-light", @"base16/windows-high-contrast", @"base16/windows-nt-light", @"base16/windows-nt", @"base16/woodland", @"base16/xcode-dusk", @"base16/zenburn"];
    }
    return _highlightStyleArray;
}

#pragma mark - Set
- (void)setHighlight:(BOOL)highlight {
    _highlight = highlight;
    [self loadMarkdown:self.markdownString];
}

- (void)setGithubStyle:(BOOL)githubStyle {
    _githubStyle = githubStyle;
    [self loadMarkdown:self.markdownString];
}

- (void)setHighlightStyle:(NSString *)highlightStyle {
    _highlightStyle = highlightStyle;
    [self loadMarkdown:self.markdownString];
}

@end
