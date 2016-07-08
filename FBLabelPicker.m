//
//  FBLabelPicker.m
//  FBLabelPicker
//
//  Created by fengfelix on 15/12/17.
//  Copyright © 2015年 felix. All rights reserved.
//

#import "FBLabelPicker.h"

NSString * const FBLabelPickerKeyID = @"FBLabelPickerKeyID";
NSString * const FBLabelPickerKeyTitle = @"FBLabelPickerKeyTitle";

static const CGFloat LEFT_PADDING = 10.0f;
static const CGFloat RIGHT_PADDING = 10.0f;
static const CGFloat TOP_PADDING = 10.0f;
static const CGFloat BOTTOM_PADDING = 10.0f;

static const CGFloat TOOLBAR_DEFAULT_HEIGHT = 49.0f;

@interface FBLabelPicker ()
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *labelButtons;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UILabel *placeholderLabel;
@end

@implementation FBLabelPicker

- (void)addAsset:(NSDictionary *)asset {
    [self.assets addObject:asset];
    [self addLabelButtonWithAsset:asset];
}

- (void)addAssets:(NSArray *)assets {
    for (NSDictionary *asset in assets) {
        [self addAsset:asset];
    }
}

- (void)removeAsset:(NSDictionary *)asset {
    for (NSUInteger i = 0; i < self.assets.count; i++) {
        NSDictionary *dict = self.assets[i];
        if ([dict[FBLabelPickerKeyID] isEqual:asset[FBLabelPickerKeyID]]) {
            [self.assets removeObjectAtIndex:i];
            [self removeLabelButtonWithIndex:i];
        }
    }
}

- (void)removeAssets:(NSArray *)assets {
    for (NSDictionary *asset in assets) {
        [self removeAsset:asset];
    }
}

- (void)clear {
    for (UIView *view in self.labelButtons) {
        [view removeFromSuperview];
    }
    
    [self.scrollView setContentSize:CGSizeZero];
    
    [self.labelButtons removeAllObjects];
    [self.assets removeAllObjects];
    
    [self updateUI];
}

#pragma mark - Life Cycle

- (instancetype)init {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat screenWidth = bounds.size.width;
    CGRect rect = CGRectMake(0.0f, 0.0f, screenWidth, TOOLBAR_DEFAULT_HEIGHT);
    
    return [self initWithFrame:rect];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.sendButton];
        [self addSubview:self.scrollView];
        [self addSubview:self.placeholderLabel];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, [UIColor colorWithRed:232.0f/255.0f
                                                               green:232.0f/255.0f
                                                                blue:232.0f/255.0f
                                                               alpha:1.0f].CGColor);
    CGContextFillRect(contextRef, rect);
    
    CGContextSetStrokeColorWithColor(contextRef, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(contextRef, 0.5f);
    CGContextMoveToPoint(contextRef, 0.0f, 0.0f);
    CGContextAddLineToPoint(contextRef, rect.size.width, 0.0f);
    CGContextStrokePath(contextRef);
}

#pragma mark - Event Response

- (void)sendButtonPressedHandler:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(pickerFinished:)]) {
        [self.delegate pickerFinished:self];
    }
}

- (void)labelButtonPressedHandler:(UIButton *)sender {
    NSUInteger index = [self.labelButtons indexOfObject:sender];
    NSDictionary *asset = self.assets[index];
    
    if ([self.delegate respondsToSelector:@selector(picker:didSelectedAsset:)]) {
        [self.delegate picker:self didSelectedAsset:asset];
    }
    
    [self removeAsset:asset];
}

#pragma mark - Private Methods

- (NSString *)sendTitle {
    NSString *str1 = @"确定";
    NSString *str2 = [NSString stringWithFormat:@"%@(%lu)", str1, (unsigned long)self.assets.count];
    return (self.assets.count > 0) ? str2 : str1;
}

- (CGSize)sendButtonSize {
    CGFloat sendButtonWidth = 80.0f;
    CGFloat sendButtonHeight = TOOLBAR_DEFAULT_HEIGHT - TOP_PADDING - BOTTOM_PADDING;
    return CGSizeMake(sendButtonWidth, sendButtonHeight);
}

- (UIImage *)sendBackgroundImageWithColor:(UIColor *)color {
    CGSize size = [self sendButtonSize];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

- (UIColor *)iOS7BlueColor {
    return [UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f];
}

- (UIColor *)iOS7BlueHighlightColor {
    return [UIColor colorWithRed:0.11f green:0.38f blue:0.94f alpha:1.0f];
}

- (void)fillScrollView {
    for (NSDictionary *asset in self.assets) {
        [self addLabelButtonWithAsset:asset];
    }
}

- (void)addLabelButtonWithAsset:(NSDictionary *)asset {
    UIView *view = [self newLabelButtonWithText:asset[FBLabelPickerKeyTitle]];
    [self.labelButtons addObject:view];
    
    CGFloat w = self.scrollView.contentSize.width + view.frame.size.width + RIGHT_PADDING;
    [self.scrollView setContentSize:CGSizeMake(w, 0)];
    [self.scrollView addSubview:view];
    
    CGFloat offsetX = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
    if (offsetX > 0) {
        [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
    
    [self updateUI];
}

- (void)removeLabelButtonWithIndex:(NSUInteger)index {
    NSUInteger loc = index + 1;
    NSRange range = NSMakeRange(loc, self.labelButtons.count - loc);
    NSArray *offsetLabelButtons = [self.labelButtons subarrayWithRange:range];
    
    UIView *view = self.labelButtons[index];
    [self.labelButtons removeObject:view];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    CGFloat w = self.scrollView.contentSize.width - view.frame.size.width - RIGHT_PADDING;
    [self.scrollView setContentSize:CGSizeMake(w, 0)];
    
    CGFloat offsetX = view.frame.size.width + RIGHT_PADDING;
    [view removeFromSuperview];
    
    for (UIView *offsetView in offsetLabelButtons) {
        CGRect r = offsetView.frame;
        offsetView.frame = CGRectMake(r.origin.x - offsetX, r.origin.y, r.size.width, r.size.height);
    }
    [UIView commitAnimations];
    
    [self updateUI];
}

- (void)updateUI {
    [self.sendButton setTitle:[self sendTitle]
                     forState:UIControlStateNormal];
    self.placeholderLabel.hidden = self.assets.count ? YES : NO;
    self.scrollView.hidden = self.assets.count ? NO : YES;
}

#pragma mark - Getters And Setters

- (NSMutableArray *)assets {
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    
    return _assets;
}

- (NSMutableArray *)labelButtons {
    if (!_labelButtons) {
        _labelButtons = [NSMutableArray array];
    }
    
    return _labelButtons;
}

- (UIButton *)newLabelButtonWithText:(NSString *)text {
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    
    NSDictionary *attributes = @{NSFontAttributeName: font};
    NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:text
                                                                                             attributes:attributes];
    CGRect required = [dateAttributedString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                         context:nil];
    
    CGFloat space = 12.0f;
    CGSize size = CGSizeMake(required.size.width + space, 25.0f);
    UIButton *title = [[UIButton alloc] initWithFrame:CGRectMake(LEFT_PADDING + self.scrollView.contentSize.width, (TOOLBAR_DEFAULT_HEIGHT-size.height)/2, size.width, size.height)];
    title.titleLabel.font = font;
    title.backgroundColor = [self iOS7BlueColor];
    title.layer.masksToBounds = YES;
    title.layer.cornerRadius = space;
    [title setTitle:text forState:UIControlStateNormal];
    [title setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [title addTarget:self action:@selector(labelButtonPressedHandler:) forControlEvents:UIControlEventTouchUpInside];

    return title;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
}

- (NSArray *)selectedAssets {
    return [NSArray arrayWithArray:self.assets];
}

- (void)setSelectedAssets:(NSArray *)selectedAssets {
    [self clear];
    self.assets = [NSMutableArray arrayWithArray:selectedAssets];
    [self fillScrollView];
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        CGFloat sendButtonWidth = [self sendButtonSize].width;
        CGFloat sendButtonHeight = [self sendButtonSize].height;
        CGFloat sendButtonX = [UIScreen mainScreen].bounds.size.width - RIGHT_PADDING - sendButtonWidth;
        CGFloat sendButtonY = TOP_PADDING;
        
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame = CGRectMake(sendButtonX, sendButtonY, sendButtonWidth, sendButtonHeight);
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.cornerRadius = 4.0f;
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        [_sendButton setTitle:[self sendTitle]
                     forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
        [_sendButton setBackgroundImage:[self sendBackgroundImageWithColor:[self iOS7BlueColor]]
                               forState:UIControlStateNormal];
        [_sendButton setBackgroundImage:[self sendBackgroundImageWithColor:[self iOS7BlueHighlightColor]]
                               forState:UIControlStateHighlighted];
        [_sendButton addTarget:self
                        action:@selector(sendButtonPressedHandler:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sendButton;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        CGFloat scrollViewX = 0;
        CGFloat scrollViewY = 0;
        CGFloat scrollViewWidth = [UIScreen mainScreen].bounds.size.width - [self sendButtonSize].width - LEFT_PADDING - RIGHT_PADDING;
        CGFloat scrollViewHeight = TOOLBAR_DEFAULT_HEIGHT;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(scrollViewX, scrollViewY, scrollViewWidth, scrollViewHeight)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
    }
    
    return _scrollView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        CGFloat labelX = LEFT_PADDING;
        CGFloat labelY = TOP_PADDING;
        CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width - [self sendButtonSize].width - LEFT_PADDING - RIGHT_PADDING - RIGHT_PADDING;
        CGFloat labelHeight = TOOLBAR_DEFAULT_HEIGHT - TOP_PADDING - BOTTOM_PADDING;
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelWidth, labelHeight)];
        _placeholderLabel.font = [UIFont systemFontOfSize:17.0f];
        _placeholderLabel.textColor = [UIColor blackColor];
    }
    
    return _placeholderLabel;
}

@end
