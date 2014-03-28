//
//  Tweet.h
//  TwitterTimeline
//
//  Created by Anton Rivera on 3/25/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

- (id)initWithJSON:(NSDictionary *)json;

@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSString *query;
//@property (nonatomic, strong) UIImage *authorAvatar;

//@property (nonatomic, strong) NSString *htmlCache;

@end
