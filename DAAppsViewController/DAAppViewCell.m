//
//  DAAppViewCell.m
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/3/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import "DAAppViewCell.h"

static NSMutableDictionary *_iconCacheDictionary = nil;

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
    if (self == [DAAppViewCell class])
    {
        _iconCacheDictionary = [[NSMutableDictionary alloc] init];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
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
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.frame = (CGRect) {
            .origin.x = 12.0f,
            .origin.y = 9.0f,
            .size.width = 64.0f,
            .size.height = 64.0f
        };
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.iconView];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.frame = (CGRect) {
            .origin.x = 88.0f,
            .origin.y = 20.0f,
            .size.width = self.frame.size.width - 165.0f,
            .size.height = 15.0f
        };
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.nameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor colorWithWhite:78.0f/255.0f alpha:1.0f];
        [self addSubview:self.nameLabel];
        
        self.genreLabel = [[UILabel alloc] init];
        self.genreLabel.frame = (CGRect) {
            .origin.x = 88.0f,
            .origin.y = 39.0f,
            .size.width = 100.0f,
            .size.height = 11.0f
        };
        self.genreLabel.font = [UIFont systemFontOfSize:10.0f];
        self.genreLabel.backgroundColor = [UIColor clearColor];
        self.genreLabel.textColor = [UIColor colorWithWhite:99.0f/255.0f alpha:1.0f];
        [self addSubview:self.genreLabel];
        
        self.starImageView = [[UIImageView alloc] init];
        self.starImageView.frame = (CGRect) {
            .origin.x = 88.0f,
            .origin.y = 54.0f,
            .size.width = 44.0f,
            .size.height = 9.5f
        };
        self.starImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.starImageView.clipsToBounds = YES;
        [self addSubview:self.starImageView];
        
        self.noRatingsLabel = [[UILabel alloc] init];
        self.noRatingsLabel.frame = (CGRect) {
            .origin.x = 88.0f,
            .origin.y = 54.0f,
            .size.width = 60.0f,
            .size.height = 10.0f
        };
        self.noRatingsLabel.font = [UIFont systemFontOfSize:10.0f];
        self.noRatingsLabel.textColor = [UIColor colorWithWhite:99.0f/255.0f alpha:1.0f];
        self.noRatingsLabel.backgroundColor = [UIColor clearColor];
        self.noRatingsLabel.text = @"No Ratings";
        self.noRatingsLabel.hidden = YES;
        [self addSubview:self.noRatingsLabel];
        
        self.ratingsLabel = [[UILabel alloc] init];
        self.ratingsLabel.frame = (CGRect) {
            .origin.x = 135.0f,
            .origin.y = 52.0f,
            .size.width = 60.0f,
            .size.height = 12.0f
        };
        self.ratingsLabel.font = [UIFont systemFontOfSize:10.0f];
        self.ratingsLabel.textColor = [UIColor colorWithWhite:90.0f/255.0f alpha:1.0f];
        self.ratingsLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.ratingsLabel];
        
        self.purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.purchaseButton.frame = (CGRect) {
            .origin.x = self.frame.size.width - 67.0f,
            .origin.y = 28.0f,
            .size.width = 59.0f,
            .size.height = 25.0f
        };
        self.purchaseButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        UIColor *titleColor = [UIColor colorWithWhite:105.0f/255.0f alpha:1.0f];
        [self.purchaseButton setTitleColor:titleColor forState:UIControlStateNormal];
        [self.purchaseButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.purchaseButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [self.purchaseButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        [self.purchaseButton setTitle:@"VIEW" forState:UIControlStateNormal];
        UIImage *buttonImage = [UIImage imageNamed:@"DAAppsViewController.bundle/DAButtonImage"];
        UIImage *buttonImageSelected = [UIImage imageNamed:@"DAAppsViewController.bundle/DAButtonImageSelected"];
        [self.purchaseButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.purchaseButton setBackgroundImage:buttonImageSelected forState:UIControlStateHighlighted];
        [self.purchaseButton addTarget:self
                                action:@selector(purchaseButton:)
                      forControlEvents:UIControlEventTouchUpInside];
        [self setAccessoryView:self.purchaseButton];
    }
    return self;
}

- (void)purchaseButton:(UIButton *)button
{
    id view = [self superview];
    while ([view isKindOfClass:[UITableView class]] == NO) {
      view = [view superview];
    }
  
    UITableView *tableView = (UITableView *)view;
    NSIndexPath *pathOfTheCell = [tableView indexPathForCell:self];
    if ([tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)])
    {
        [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:pathOfTheCell];
    }
}

#pragma mark - Property methods

- (void)setAppObject:(DAAppObject *)appObject
{
    _appObject = appObject;
    self.nameLabel.text = appObject.name;
    self.genreLabel.text = appObject.genre;
    self.ratingsLabel.text = [NSString stringWithFormat:@"(%i)", appObject.userRatingCount];
    self.ratingsLabel.hidden = !appObject.userRatingCount;
    self.noRatingsLabel.hidden = appObject.userRatingCount;
    self.starImageView.hidden = !appObject.userRatingCount;
    [self.purchaseButton setTitle:appObject.formattedPrice forState:UIControlStateNormal];
    
    UIImage *starsImage = [UIImage imageNamed:@"DAAppsViewController.bundle/DAStarsImage"];
    UIGraphicsBeginImageContextWithOptions(self.starImageView.frame.size, NO, 0);
    CGPoint starPoint = (CGPoint) {
        .y = (self.starImageView.frame.size.height * (2 * appObject.userRating + 1)) - starsImage.size.height
    };
    [starsImage drawAtPoint:starPoint];
    self.starImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *iconImage = [_iconCacheDictionary objectForKey:self.appObject.iconURL];
    if (iconImage)
    {
        self.iconView.image = iconImage;
    }
    else
    {
        self.iconView.image = [UIImage imageNamed:@"DAAppsViewController.bundle/DAPlaceholderImage"];
        NSURL *iconURL = self.appObject.iconURL;
        dispatch_queue_t thread = dispatch_queue_create(NULL, NULL);
        dispatch_async(thread, ^{
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:iconURL
                                                        cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                    timeoutInterval:10.0f];
            NSData *iconData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                     returningResponse:NULL
                                                                 error:NULL];
            UIImage *iconImage = [UIImage imageWithData:iconData];
            
            if (!self.appObject.iconIsPrerendered)
            {
                UIGraphicsBeginImageContext(iconImage.size);
                [iconImage drawAtPoint:CGPointZero];
                CGRect imageRect = (CGRect) {
                    .size = iconImage.size
                };
                [[UIImage imageNamed:@"DAAppsViewController.bundle/DAOverlayImage"] drawInRect:imageRect];
                iconImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            CGImageRef maskRef = [UIImage imageNamed:@"DAAppsViewController.bundle/DAMaskImage"].CGImage;
            CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                                CGImageGetHeight(maskRef),
                                                CGImageGetBitsPerComponent(maskRef),
                                                CGImageGetBitsPerPixel(maskRef),
                                                CGImageGetBytesPerRow(maskRef),
                                                CGImageGetDataProvider(maskRef), NULL, false);
            CGImageRef maskedImageRef = CGImageCreateWithMask([iconImage CGImage], mask);
            iconImage = [UIImage imageWithCGImage:maskedImageRef];
            CGImageRelease(mask);
            CGImageRelease(maskedImageRef);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_iconCacheDictionary setObject:iconImage forKey:iconURL];
                if (self.appObject.iconURL == iconURL)
                {
                    self.iconView.image = iconImage;
                }
            });
        });
#if !OS_OBJECT_USE_OBJC
        dispatch_release(thread);
#endif
    }
}

@end
