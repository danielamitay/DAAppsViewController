//
//  DAAppsViewCell.h
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/3/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAAppsViewCell : UITableViewCell

@property (nonatomic) NSInteger appId;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, copy) UIImage *icon;

@property (nonatomic) NSInteger userRatingCount;
@property (nonatomic) CGFloat userRating;

@property (nonatomic, copy) NSString *buttonText;

@end
