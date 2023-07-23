//
//  DAAppViewCell.m
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/3/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import "DAAppViewCell.h"

static NSCache *_iconCache = nil;
static CGSize const DAAppIconSize = {64, 64};

@interface DAAppViewCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *genreLabel;
@property (nonatomic, strong) UIButton *purchaseButton;

- (void)purchaseButton:(UIButton *)button;

@end

@implementation DAAppViewCell

+ (void)initialize
{
    if (self == [DAAppViewCell class]) {
        _iconCache = [[NSCache alloc] init];
        [_iconCache setCountLimit:100];
        
        // Automatically clear the icon cache if we receive a memory warning
        [[NSNotificationCenter defaultCenter] addObserver:_iconCache
                                                 selector:@selector(removeAllObjects)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.separatorInset = UIEdgeInsetsZero;
        
        UIView *cellTopWhiteLine = [[UIView alloc] init];
        cellTopWhiteLine.frame = (CGRect) {
            .size.width = self.frame.size.width,
            .size.height = 1.0f
        };
        cellTopWhiteLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if (@available(iOS 13.0, *)) {
            cellTopWhiteLine.backgroundColor = [UIColor systemBackgroundColor];
        } else {
            cellTopWhiteLine.backgroundColor = [UIColor whiteColor];
        }
        [self addSubview:cellTopWhiteLine];
        
        _iconView = [[UIImageView alloc] init];
        _iconView.layer.cornerRadius = 11.0;
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.borderWidth = 1.0;
        _iconView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.1].CGColor;
        if (@available(iOS 13.0, *)) {
            _iconView.layer.cornerCurve = kCACornerCurveContinuous;
            _iconView.backgroundColor = [UIColor tertiarySystemGroupedBackgroundColor];
        } else {
            _iconView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        }
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_iconView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.numberOfLines = 2;
        _nameLabel.font = [UIFont systemFontOfSize:16.0f];
        _nameLabel.backgroundColor = [UIColor clearColor];
        if (@available(iOS 13.0, *)) {
            _nameLabel.textColor = [UIColor labelColor];
        } else {
            _nameLabel.textColor = [UIColor blackColor];
        }
        [self addSubview:_nameLabel];
        
        _genreLabel = [[UILabel alloc] init];
        _genreLabel.font = [UIFont systemFontOfSize:13.0f];
        _genreLabel.backgroundColor = [UIColor clearColor];
        if (@available(iOS 13.0, *)) {
            _genreLabel.textColor = [UIColor secondaryLabelColor];
        } else {
            _genreLabel.textColor = [UIColor darkGrayColor];
        }
        [self addSubview:_genreLabel];

        _purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _purchaseButton.layer.cornerRadius = 14.0f;
        _purchaseButton.layer.masksToBounds = YES;

        UIColor *buttonColor = [UIColor colorWithWhite:0.75 alpha:0.2];
        CGRect rect = CGRectMake(0.0f, 0.0f, 2.0f, 2.0f);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, buttonColor.CGColor);
        CGContextFillRect(context, rect);
        UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [_purchaseButton setBackgroundImage:coloredImage forState:UIControlStateNormal];
        [_purchaseButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [_purchaseButton setTitle:[NSLocalizedString(@"View",) uppercaseString] forState:UIControlStateNormal];
        [_purchaseButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        [_purchaseButton addTarget:self
                                action:@selector(purchaseButton:)
                      forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_purchaseButton];

        UILayoutGuide *aboveNameGuide = [UILayoutGuide new];
        [self addLayoutGuide:aboveNameGuide];
        UILayoutGuide *belowGenreGuide = [UILayoutGuide new];
        [self addLayoutGuide:belowGenreGuide];

        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _genreLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _purchaseButton.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_iconView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:12.0],
            [_iconView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_iconView.widthAnchor constraintEqualToConstant:DAAppIconSize.width],
            [_iconView.heightAnchor constraintEqualToConstant:DAAppIconSize.height],

            [aboveNameGuide.topAnchor constraintEqualToAnchor:self.topAnchor],
            [aboveNameGuide.heightAnchor constraintEqualToAnchor:belowGenreGuide.heightAnchor],
            [belowGenreGuide.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

            [_nameLabel.topAnchor constraintEqualToAnchor:aboveNameGuide.bottomAnchor],
            [_nameLabel.leftAnchor constraintEqualToAnchor:_iconView.rightAnchor constant:12.0],
            [_nameLabel.rightAnchor constraintLessThanOrEqualToAnchor:_purchaseButton.leftAnchor constant:-10.0],

            [_genreLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:3.0],
            [_genreLabel.leftAnchor constraintEqualToAnchor:_nameLabel.leftAnchor],
            [_genreLabel.rightAnchor constraintLessThanOrEqualToAnchor:_purchaseButton.leftAnchor constant:-10.0],
            [_genreLabel.bottomAnchor constraintEqualToAnchor:belowGenreGuide.topAnchor],

            [_purchaseButton.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-21.0],
            [_purchaseButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_purchaseButton.widthAnchor constraintEqualToConstant:72.0],
            [_purchaseButton.heightAnchor constraintEqualToConstant:28.0],
        ]];
    }
    return self;
}

- (void)purchaseButton:(UIButton *)button
{
    // UITableViewCells and UITableViews are not guaranteed to be the current
    // view's parent and grandparent views, respectively. (e.g. iOS7 vs iOS6)
    // As such, we iterate upwards until we find both.
    UITableView *tableView = nil;
    UIResponder *nextResponder = self;
    while (nextResponder && !tableView) {
        nextResponder = nextResponder.nextResponder;
        if ([nextResponder isKindOfClass:[UITableView class]]) {
            tableView = (UITableView *)nextResponder;
        }
    }
    
    NSIndexPath *pathOfTheCell = [tableView indexPathForCell:self];
    if ([tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:pathOfTheCell];
    }
}


#pragma mark - Property methods

- (void)setAppObject:(DAAppObject *)appObject
{
    _appObject = appObject;
    self.nameLabel.text = appObject.name;
    self.genreLabel.text = appObject.genre;
    if (appObject.formattedPrice) {
        [self.purchaseButton setTitle:appObject.formattedPrice forState:UIControlStateNormal];
    } else {
        [self.purchaseButton setTitle:[NSLocalizedString(@"View",) uppercaseString] forState:UIControlStateNormal];
    }

    UIImage *iconImage = [_iconCache objectForKey:self.appObject.iconURL];
    if (iconImage) {
        self.iconView.image = iconImage;
    } else {
        self.iconView.image = nil;
        NSURL *iconURL = self.appObject.iconURL;
        NSURLRequest *request = [NSURLRequest requestWithURL:iconURL
                                                 cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                             timeoutInterval:15.0f];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, id res, NSError *err) {
            UIImage *iconImage = [UIImage imageWithData:data];
            if (iconImage) {
                UIGraphicsBeginImageContextWithOptions(DAAppIconSize, YES, 0.0f);
                [iconImage drawInRect:(CGRect) { .size = DAAppIconSize }];
                UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                if (resizedImage) {
                    [_iconCache setObject:resizedImage forKey:iconURL];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.appObject.iconURL == iconURL) {
                            [UIView transitionWithView:self.iconView
                                              duration:0.3
                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                            animations:^{
                                                self.iconView.image = resizedImage;
                                            }
                                            completion:nil];
                        }
                    });
                }
            }
        }] resume];
    }
}

@end
