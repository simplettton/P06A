//
//  MessageViewController.h
//  P06A
//
//  Created by Binger Zeng on 2018/9/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModelData.h"
// Import all the things
#import "JSQMessages.h"
@interface MessageViewController :JSQMessagesViewController <JSQMessagesComposerTextViewPasteDelegate>

@property (strong, nonatomic)MessageModelData *messageData;

@property (strong, nonatomic)NSString *hireId;

@end
