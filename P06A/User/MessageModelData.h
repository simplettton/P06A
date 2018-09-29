//
//  MessageModelData.h
//  P06A
//
//  Created by Binger Zeng on 2018/9/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "JSQMessages.h"

static NSString *const kAvatarIdDoctor = @"avatarIdDoctor";
static NSString *const kAvatarIdPatient = @"avatarIdPatient";
static NSString *const DidGetMessageModelNotification = @"DidGetMessageModelNotification";

@interface MessageModelData : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSDictionary *users;

//get network data
-(void)loadMessagesWithId:(NSString *)hireId;

-(instancetype)initWithId:(NSString *)hireId;
@end
