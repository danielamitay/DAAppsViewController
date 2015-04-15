//
//  DAAppViewCell.m
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/3/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import "DAAppViewCell.h"

static NSCache *_iconCache = nil;
static NSArray *_starRatingImages = nil;
static NSNumberFormatter *_decimalNumberFormatter = nil;

@interface DAAppViewCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *genreLabel;
@property (nonatomic, strong) UIImageView *starImageView;
@property (nonatomic, strong) UILabel *noRatingsLabel;
@property (nonatomic, strong) UILabel *ratingsLabel;
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
        
        NSInteger numberOfStars = 11;
        NSMutableArray *starRatingImages = [[NSMutableArray alloc] initWithCapacity:numberOfStars];
        UIImage *starsImageSheet = [UIImage imageNamed:@"DAAppsViewController.bundle/DAStarsImage"];
        CGSize starRatingImageSize = (CGSize) {
            .width = starsImageSheet.size.width,
            .height = starsImageSheet.size.height / (CGFloat)numberOfStars
        };
        for (NSInteger starIndex = numberOfStars - 1; starIndex >= 0; starIndex--) {
            UIGraphicsBeginImageContextWithOptions(starRatingImageSize, NO, 0.0f);
            CGPoint starPoint = (CGPoint) {
                .y = -starRatingImageSize.height * starIndex
            };
            [starsImageSheet drawAtPoint:starPoint];
            UIImage *starRatingImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [starRatingImages addObject:starRatingImage];
        }
        _starRatingImages = starRatingImages;

        _decimalNumberFormatter = [[NSNumberFormatter alloc] init];
        [_decimalNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            self.separatorInset = UIEdgeInsetsZero;
        }
        
        UIView *cellTopWhiteLine = [[UIView alloc] init];
        cellTopWhiteLine.frame = (CGRect) {
            .size.width = self.frame.size.width,
            .size.height = 1.0f
        };
        cellTopWhiteLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cellTopWhiteLine.backgroundColor = [UIColor whiteColor];
        [self addSubview:cellTopWhiteLine];
        
        UIImageView *cellImageShadowView = [[UIImageView alloc] init];
        cellImageShadowView.frame = (CGRect) {
            .origin.x = 11.0f,
            .origin.y = 8.0f,
            .size.width = 66.0f,
            .size.height = 67.0f
        };
        cellImageShadowView.contentMode = UIViewContentModeScaleAspectFit;
        cellImageShadowView.image = [UIImage imageNamed:@"DAAppsViewController.bundle/DAShadowImage"];
        [self addSubview:cellImageShadowView];
        
        _iconView = [[UIImageView alloc] init];
        _iconView.frame = (CGRect) {
            .origin.x = 12.0f,
            .origin.y = 9.0f,
            .size.width = 64.0f,
            .size.height = 64.0f
        };
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_iconView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:12.0f];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        [self addSubview:_nameLabel];
        
        _genreLabel = [[UILabel alloc] init];
        _genreLabel.font = [UIFont systemFontOfSize:10.0f];
        _genreLabel.backgroundColor = [UIColor clearColor];
        _genreLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:_genreLabel];
        
        _starImageView = [[UIImageView alloc] init];
        _starImageView.frame = (CGRect) {
            .origin.x = 88.0f,
            .origin.y = 54.0f,
            .size.width = 44.0f,
            .size.height = 9.5f
        };
        _starImageView.contentMode = UIViewContentModeScaleAspectFill;
        _starImageView.clipsToBounds = YES;
        [self addSubview:_starImageView];
        
        _noRatingsLabel = [[UILabel alloc] init];
        _noRatingsLabel.font = [UIFont systemFontOfSize:10.0f];
        _noRatingsLabel.textColor = [UIColor darkGrayColor];
        _noRatingsLabel.backgroundColor = [UIColor clearColor];
        _noRatingsLabel.text = NSLocalizedString(@"No Ratings",);
        _noRatingsLabel.hidden = YES;
        CGSize noRatingsLabelSize = [_noRatingsLabel sizeThatFits:_noRatingsLabel.bounds.size];
        _noRatingsLabel.frame = (CGRect) {
            .origin.x = 88.0f,
            .origin.y = 54.0f,
            .size = noRatingsLabelSize
        };
        [self addSubview:_noRatingsLabel];
        
        _ratingsLabel = [[UILabel alloc] init];
        _ratingsLabel.font = [UIFont systemFontOfSize:10.0f];
        _ratingsLabel.textColor = [UIColor darkGrayColor];
        _ratingsLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_ratingsLabel];
        
        _purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _purchaseButton.frame = (CGRect) {
            .origin.x = self.frame.size.width - 67.0f,
            .origin.y = 28.0f,
            .size.width = 56.0f,
            .size.height = (DA_IS_IOS7 ? 26.0f : 25.0f)
        };
        _purchaseButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        if (DA_IS_IOS7) {
            UIColor *titleColor = [UIColor colorWithRed:0.0f green:0.49f blue:0.96f alpha:1.0f];
            [_purchaseButton setTitleColor:titleColor forState:UIControlStateNormal];
            [_purchaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

            _purchaseButton.layer.borderColor = titleColor.CGColor;
            _purchaseButton.layer.borderWidth = 1.0f;
            _purchaseButton.layer.cornerRadius = 4.0f;
            _purchaseButton.layer.masksToBounds = YES;
            
            CGRect rect = CGRectMake(0.0f, 0.0f, 2.0f, 2.0f);
            UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, titleColor.CGColor);
            CGContextFillRect(context, rect);
            UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [_purchaseButton setBackgroundImage:coloredImage forState:UIControlStateHighlighted];
        } else {
            UIColor *titleColor = [UIColor colorWithWhite:105.0f/255.0f alpha:1.0f];
            [_purchaseButton setTitleColor:titleColor forState:UIControlStateNormal];
            [_purchaseButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_purchaseButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
            
            UIImage *buttonImage = [UIImage imageNamed:@"DAAppsViewController.bundle/DAButtonImage"];
            UIImage *buttonImageSelected = [UIImage imageNamed:@"DAAppsViewController.bundle/DAButtonImageSelected"];
            [_purchaseButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [_purchaseButton setBackgroundImage:buttonImageSelected forState:UIControlStateHighlighted];
        }
        [_purchaseButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [_purchaseButton setTitle:[NSLocalizedString(@"View",) uppercaseString] forState:UIControlStateNormal];
        
        [_purchaseButton addTarget:self
                                action:@selector(purchaseButton:)
                      forControlEvents:UIControlEventTouchUpInside];
        [self setAccessoryView:_purchaseButton];
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


#pragma mark - View methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat maxNameLabelWidth = self.bounds.size.width - 165.0f;
    CGSize nameLabelSize = [self.nameLabel sizeThatFits:(CGSize) {
        .width = maxNameLabelWidth
    }];
    self.nameLabel.frame = (CGRect) {
        .origin.x = 88.0f,
        .origin.y = 20.0f,
        .size.width = MIN(nameLabelSize.width, maxNameLabelWidth),
        .size.height = nameLabelSize.height
    };
    
    CGSize genreLabelSize = [self.genreLabel sizeThatFits:self.genreLabel.bounds.size];
    self.genreLabel.frame = (CGRect) {
        .origin.x = 88.0f,
        .origin.y = 38.0f,
        .size = genreLabelSize
    };
    
    CGSize ratingsLabelSize = [self.ratingsLabel sizeThatFits:self.ratingsLabel.bounds.size];
    self.ratingsLabel.frame = (CGRect) {
        .origin.x = 135.0f,
        .origin.y = 52.0f,
        .size = ratingsLabelSize
    };
}


#pragma mark - Property methods

- (void)setAppObject:(DAAppObject *)appObject
{
    _appObject = appObject;
    self.nameLabel.text = appObject.name;
    self.genreLabel.text = appObject.genre;
    NSNumber *userRatingCountNumber = [NSNumber numberWithInteger:appObject.userRatingCount];
    NSString *formattedRatingsCount = [_decimalNumberFormatter stringFromNumber:userRatingCountNumber];
    self.ratingsLabel.text = [NSString stringWithFormat:@"(%@)", formattedRatingsCount];
    self.ratingsLabel.hidden = (appObject.userRatingCount == 0);
    self.noRatingsLabel.hidden = (appObject.userRatingCount > 0);
    self.starImageView.hidden = (appObject.userRatingCount == 0);
    [self.purchaseButton setTitle:appObject.formattedPrice forState:UIControlStateNormal];
    self.starImageView.image = [_starRatingImages objectAtIndex:(2 * appObject.userRating)];
    
    UIImage *iconImage = [_iconCache objectForKey:self.appObject.iconURL];
    if (iconImage) {
        self.iconView.image = iconImage;
    } else {
        self.iconView.image = [UIImage imageNamed:@"DAAppsViewController.bundle/DAPlaceholderImage"];
        NSURL *iconURL = self.appObject.iconURL;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:iconURL
                                                        cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                    timeoutInterval:15.0f];
            NSData *iconData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                     returningResponse:NULL
                                                                 error:NULL];
            UIImage *iconImage = [UIImage imageWithData:iconData];
            if (iconImage) {
                CGSize finalSize = _iconView.bounds.size;
                UIGraphicsBeginImageContextWithOptions(finalSize, YES, 0.0f);
                [iconImage drawInRect:(CGRect) {
                    .size = finalSize
                }];
                
                if (!DA_IS_IOS7) {
                    [[UIImage imageNamed:@"DAAppsViewController.bundle/DAOverlayImage"] drawInRect:(CGRect) {
                        .size = finalSize
                    }];
                }
                
                UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                CGImageRef maskRef = [UIImage imageNamed:@"DAAppsViewController.bundle/DAMaskImage"].CGImage;
                CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                                    CGImageGetHeight(maskRef),
                                                    CGImageGetBitsPerComponent(maskRef),
                                                    CGImageGetBitsPerPixel(maskRef),
                                                    CGImageGetBytesPerRow(maskRef),
                                                    CGImageGetDataProvider(maskRef), NULL, false);
                CGImageRef maskedImageRef = CGImageCreateWithMask([resizedImage CGImage], mask);
                UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
                CGImageRelease(mask);
                CGImageRelease(maskedImageRef);
                
                if (maskedImage) {
                    [_iconCache setObject:maskedImage forKey:iconURL];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.appObject.iconURL == iconURL) {
                            [UIView transitionWithView:self.iconView
                                              duration:0.5f
                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                            animations:^{
                                                self.iconView.image = maskedImage;
                                            }
                                            completion:nil];
                        }
                    });
                }
            }
        });
    }
}

@end
