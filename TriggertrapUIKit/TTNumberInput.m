//
//  TTNumberInput.m
//  TTNumericKeys
//
//  Created by Matt Kane on 09/08/2013.
//  Copyright (c) 2013 Triggertrap. All rights reserved.
//

#import "TTNumberInput.h"
#import "TTNumberPadView.h"
#import "UIColor+branding.h"
@import Masonry;

@implementation TTNumberInput

@synthesize maxNumberLength;

#pragma mark - Inits

- (id)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.displayView = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width - 20, self.bounds.size.height)];
    self.displayView.backgroundColor = [UIColor clearColor];
    self.displayView.textAlignment = NSTextAlignmentRight;
    
    self.borderColor = [UIColor TTDarkGreyColour];
    self.borderHighlightColor = [UIColor TTRedColour];
    self.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.valueFont = [UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle];
    } else {
        self.valueFont = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    }
    self.smallValueFont = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    self.maxNumberLength = 10;
    
    self.keyboardCanBeDismissed = YES;
    [self setup];
    
    [self addSubview:self.displayView];

    self.bottomBorder = [[UIView alloc] init];
    self.bottomBorder.backgroundColor = self.borderColor;
    [self addSubview:self.bottomBorder];


    self.leftBorder = [[UIView alloc] init];
    self.leftBorder.backgroundColor = self.borderColor;
    [self addSubview:self.leftBorder];

    self.rightBorder = [[UIView alloc] init];
    self.rightBorder.backgroundColor = self.borderColor;
    [self addSubview:self.rightBorder];

    [self.bottomBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
    }];

    [self.leftBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(8);
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
    }];

    [self.rightBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(8);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillRotate) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillRotate {
    
    if (self.keyboardOpen) {
        [self hideKeyboardWithAnimation:NO];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)openKeyboardInView:(UIView *)view covering:(UIView *)covered {
//    if ([[TTActivityManager sharedInstance] runningActivity]) {
//        [ActivityBar dismiss];
//    }
    
    [self openKeyboardInView:view covering:covered animate:YES];
}

- (void)openKeyboardInView:(UIView *)view covering:(UIView *)covered animate:(BOOL)animate {
    self.valueChanged = NO;
    self.initialValue = self.value;
    self.leftBorder.backgroundColor = self.borderHighlightColor;
    self.rightBorder.backgroundColor = self.borderHighlightColor;
    self.bottomBorder.backgroundColor = self.borderHighlightColor;
    
    // reset the display value to allow a fresh input
    self.displayValue = 0;
    
    self.keyboardJustOpened = YES;
    
    superView = view;
    coveredView = covered;
    
    if (self.keyboardCanBeDismissed) {
        [self showOverlay];
    }
    
    [self showKeyboardWithAnimation:animate];
}

- (void)normalise {
    if (self.value > self.maxValue) {
        self.value = self.maxValue;
    }
    
    if (self.value < self.minValue) {
        if (self.valueChanged) {
            if (!self.keyboardOpen) {
                self.value = self.minValue;
            }
        } else {
            self.value = self.initialValue;
        }
    }
    
    if ([self numberOfDigits:self.value] > self.maxNumberLength) {
        self.value = self.maxValue;
    }
    
    // Redraw
    [self updateValueDisplay];
}

- (int)numberOfDigits:(unsigned long long)n {
    // Yes, this is the fastest way to do this.
    if (n > 999999999) return 10;
    if (n > 99999999) return 9;
    if (n > 9999999) return 8;
    if (n > 999999) return 7;
    if (n > 99999) return 6;
    if (n > 9999) return 5;
    if (n > 999) return 4;
    if (n > 99) return 3;
    if (n > 9) return 2;
    return 1;
}

- (void)updateValueDisplay {
    self.displayView.text = [NSString stringWithFormat:@"%llu ", _displayValue];
    [self keyboardFinished];
}

- (void)hideKeyboard {
    [self hideKeyboardWithAnimation:YES];
}

- (void)hideKeyboardWithAnimation:(BOOL)animate {
    self.leftBorder.backgroundColor = self.borderColor;
    self.rightBorder.backgroundColor = self.borderColor;
    self.bottomBorder.backgroundColor = self.borderColor;

    if (!_keyboardOpen) {
        return;
    }
    
    _keyboardOpen = NO;
    self.keyboardJustOpened = NO;
    
//    if (self.valueChanged && [self validValue:self.displayValue]) {
//        [self setValue:self.displayValue];
//    }

    [self normalise];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (self.valueChanged) {
        if (self.displayValue < _minValue) {
            self.displayValue = _minValue;
        }
        
        if (self.displayValue > _maxValue) {
            self.displayValue = _maxValue;
        }
        
        if ([self validValue:self.displayValue]) {
            [self setValue:self.displayValue];
        }
    } else {
        if ([self validValue:self.initialValue]) {
            [self setValue:self.initialValue];
        }
    }
    
    if (animate) {
        CGRect rect = CGRectMake(coveredView.frame.origin.x,
                                 coveredView.frame.origin.y + coveredView.frame.size.height,
                                 coveredView.frame.size.width,
                                 coveredView.frame.size.height);
        
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self->numberPadView setFrame:rect];
                         } completion:^(BOOL finished) {
                             [self->overlayView removeFromSuperview];
                             self->overlayView = nil;
                             [self->numberPadView removeFromSuperview];
                             self->numberPadView = nil;
                             [self setNeedsDisplay];
                         }];
    } else {
        [overlayView removeFromSuperview];
        overlayView = nil;
        [numberPadView removeFromSuperview];
        numberPadView = nil;
        [self setNeedsDisplay];
    }
    
    // This will only show the activity bar if there is an activity
//    if ([[TTActivityManager sharedInstance] runningActivity]) {
//        TTViewController *activeViewController = (TTViewController *)[TTActivityManager sharedInstance].activeViewController;
//        
//        [ActivityBar showWithStatus:activeViewController.activityStatus];
//    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(TTNumberInputKeyboardDidDismiss)]) {
        [_delegate performSelector:@selector(TTNumberInputKeyboardDidDismiss)];
    }
}

- (void)drawCursor {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, self.displayView.textColor.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, self.bounds.size.width - 7, 5);
    CGContextAddLineToPoint(context, self.bounds.size.width - 7, 35);
    CGContextStrokePath(context);
}

- (void)saveValue:(unsigned long long)value forKey:(NSString *)identifier {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *val = [NSNumber numberWithUnsignedLongLong:value];
    [defaults setObject:val forKey:identifier];
    [defaults synchronize];
}

- (unsigned long long)savedValueForKey:(NSString *)identifier {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // We do it like this to tell the difference between a missing key, and a stored value of 0.0;
    if ([defaults objectForKey:identifier] != nil) {
        NSNumber *val = [defaults objectForKey:identifier];
        unsigned long long savedValue = val.unsignedLongLongValue;
        return savedValue;
    } else {
        return self.value;
    }
}

#pragma mark - Private

- (void)setup {
    if (!self.maxValue) {
        self.maxValue = ULONG_LONG_MAX;
    }
    
    if (!self.minValue) {
        self.minValue = (unsigned long long)0;
    }
}

- (void)showKeyboardWithAnimation:(BOOL)animate {
    if (_keyboardOpen) {
        return;
    }
    
    _keyboardOpen = YES;
    CGRect rect = CGRectMake(coveredView.frame.origin.x,
                             coveredView.frame.origin.y + coveredView.frame.size.height,
                             coveredView.frame.size.width,
                             coveredView.frame.size.height);
    
    if (!numberPadView) {
        numberPadView = [[TTNumberPadView alloc] initWithFrame:rect];
        
        if (self.smallValueFont) {
            numberPadView.font = self.smallValueFont;
        }
        
        numberPadView.delegate = self;
        UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        gestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [numberPadView addGestureRecognizer:gestureRecognizer];
        [superView addSubview:numberPadView];
        [self setup];
    } else {
        numberPadView.frame = rect;
    }
    
    if (animate) {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self->numberPadView setFrame:self->coveredView.frame];
                             
                         } completion:^(BOOL finished) {
                             [self setNeedsDisplay];
                         }];
    } else {
        [numberPadView setFrame:coveredView.frame];
        [self setNeedsDisplay];
    }
    
    [self updateValueDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_keyboardOpen) {
        [self drawCursor];
    }
}

- (void)showOverlay {
    overlayView = [[UIView alloc] initWithFrame:superView.frame];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    [overlayView addGestureRecognizer:gestureRecognizer];
    
    [superView addSubview:overlayView];
}

- (BOOL)validValue:(unsigned long long)value {
    if (value >= _minValue && value <= _maxValue) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Setters

- (void)setValue:(unsigned long long)value {
    [self setDisplayValue:value];
    
    if (value <= ULONG_LONG_MAX) {
        if (value > _maxValue) {
            _value = _maxValue;
        } else if (value < _minValue) {
            _value = _minValue;
        } else {
            _value = value;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(numberInputValueChanged)]) {
                [self.delegate performSelector:@selector(numberInputValueChanged)];
            }
        }
    } else {
        // The value is negative, or too large
        _value = ULONG_LONG_MAX;
    }
}

- (void)setDisplayValue:(unsigned long long)displayValue {
    _displayValue = displayValue;
    [self updateValueDisplay];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberInputDisplayValueChanged)]) {
        [self.delegate performSelector:@selector(numberInputDisplayValueChanged)];
    }
}

- (void)setValueFont:(UIFont *)valueFont {
    _valueFont = valueFont;
    self.displayView.font = valueFont;
}

- (void)setMaxValue:(unsigned long long)maxValue {
    if (maxValue <= ULONG_LONG_MAX) {
        _maxValue = maxValue;
    } else {
        _maxValue = ULONG_LONG_MAX;
    }
}

- (void)setMinValue:(unsigned long long)minValue {
    if (minValue <= ULONG_LONG_MAX) {
        if (minValue <= _maxValue) {
            _minValue = minValue;
        } else {
            _minValue = _maxValue;
        }
    } else {
        _minValue = ULONG_LONG_MAX;
    }
}

#pragma mark - TTNumberPadViewDelegate methods

- (void)digitPressed:(NSInteger)value {
    self.valueChanged = YES;
    
    unsigned long long newVal = self.displayValue * 10ul + value;
    
    if ([self numberOfDigits:newVal] > self.maxNumberLength) {
        return;
    }
    
    if (newVal < self.displayValue) {
        return;
    }
    
    [self setDisplayValue:self.displayValue * 10 + value];
    
    [self keyboardFinished];
}

- (void)deletePressed {
    self.valueChanged = YES;
    [self setValue:floor(self.displayValue / 10)];
    [self keyboardFinished];
}

- (void)dismissKeypad {
    
    if (self.nextField) {
        [self hideKeyboardWithAnimation:NO];
        [self.nextField openKeyboardInView:superView covering:coveredView animate:NO];
    } else {
        [self hideKeyboardWithAnimation:YES];
    }
    
    [self keyboardFinished];
    
    if (self.ttKeyboardDelegate && [self.ttKeyboardDelegate respondsToSelector:@selector(dismissButtonPressed)]) {
        [self.ttKeyboardDelegate performSelector:@selector(dismissButtonPressed) withObject:nil];
    }
}

- (void)clearPressed {
    self.valueChanged = YES;
    [self setDisplayValue:0];
    
    [self keyboardFinished];
}

- (void)keyboardFinished {
    if (self.ttKeyboardDelegate && [self.ttKeyboardDelegate respondsToSelector:@selector(editingChanged)]) {
        [self.ttKeyboardDelegate performSelector:@selector(editingChanged) withObject:nil];
    }
}

@end
