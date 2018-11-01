//
//  MessageModelData.m
//  P06A
//
//  Created by Binger Zeng on 2018/9/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MessageModelData.h"

@implementation MessageModelData
-(instancetype)initWithId:(NSString *)hireId{
    if (self = [super init]) {
        self = [self init];
        [self loadMessagesWithId:hireId];
    }
    return self;
}
-(instancetype)init
{
    self = [super init];
    if(self){
        
        //医生聊天头像
        JSQMessagesAvatarImage *doctorImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"avatar_doctor"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        //患者聊天头像
        JSQMessagesAvatarImage *patientImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"avatar_patient"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        //聊天头像集
        self.avatars = @{ kAvatarIdDoctor:doctorImage,
                          kAvatarIdPatient:patientImage };
        
        //聊天气泡
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    return self;
}
-(void)loadMessagesWithId:(NSString *)hireId{
    [SVProgressHUD showWithStatus:@"正在加载中.."];
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Data/LogOfHireRecord?action=List"]
                                  params:@{@"hireid":hireId}
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     [SVProgressHUD dismiss];
                                    if ([responseObject.result integerValue] == 1) {
                                        NSArray *messageArray = responseObject.content;
                                        if ([messageArray count]>0) {
                                            self.messages = [[NSMutableArray alloc]initWithCapacity:100];
                                            self.pictureRecordIdArrays = [[NSMutableArray alloc]initWithCapacity:100];
                                            //doctor用户和patient用户显示名字
                                            NSString *patientName = [[NSString alloc]init];
                                            NSString *doctorName = [[NSString alloc]init];

                                            //循环消息队列
                                            for (NSDictionary *dataDic in messageArray) {
                                                __block NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dataDic[@"time"]doubleValue]];

                                                //设置doctor或者patient的id
                                                NSString *senderId = [[NSString alloc]init];
                                                if ([dataDic[@"isdoctor"]boolValue]) {
                                                    senderId = kAvatarIdDoctor;
                                                    doctorName = dataDic[@"author"];
                                                }else{
                                                    senderId = kAvatarIdPatient;
                                                    patientName = dataDic[@"author"];
                                                }
                                                
                                                //判断消息类型是photo还是text
                                                BOOL isPhoto = [dataDic[@"msgtype"]boolValue];
                                                
                                                if (isPhoto) {
                                                    NSString *recordId = dataDic[@"msg"];
                                                    if (![self.pictureRecordIdArrays containsObject:recordId]) {
                                                        [self.pictureRecordIdArrays addObject:recordId];
                                                        //获取记录中的图片信息
                                                        SDWebImageManager *manager = [SDWebImageManager sharedManager];
                                                        NSString *token = [UserDefault objectForKey:@"Token"];
                                                        NSString *api = [HTTPServerURLString stringByAppendingString:[NSString stringWithFormat:@"Api/Data/GetImgFromTreatRecord?token=%@&recordid=%@",token,recordId]];
                                                        __block UIImage *downloadImage = [[UIImage alloc]init];
                                                        [[manager imageDownloader]downloadImageWithURL:[NSURL URLWithString:api]
                                                                                               options:0
                                                                                              progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                                                                  
                                                                                              }
                                                                                             completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                                                                                 
                                                                                                 //下载完图片通知更新UI
                                                                                                 [[NSNotificationCenter defaultCenter]postNotificationName:DidGetMessageModelNotification object:nil];
                                                                                                 
                                                                                                 [SVProgressHUD dismiss];
                                                                                                 if (image) {
                                                                                                     //下载完成照片后替换真实的照片
                                                                                                     for (JSQMessage *message in self.messages) {
                                                                                                         if ([message.date compare:date] ==  NSOrderedSame) {
                                                                                                             
                                                                                                             //根据日期获取要替换的记录
                                                                                                             NSUInteger index = [self.messages indexOfObject:message];
                                                                                                             
                                                                                                             JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];

                                                                                                             JSQMessage *photoMessage = [[JSQMessage alloc]initWithSenderId:senderId senderDisplayName:dataDic[@"author"]date:date media:photoItem];
                                                                                                             [self.messages replaceObjectAtIndex:index withObject:photoMessage];
                                                                                                             break;
                                                                                                         }
                                                                                                     }
                                                                                                 }
                                                                                             }];
                                                        
                                                        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:downloadImage];
                                                        photoItem.image = nil;
                                                        JSQMessage *photoMessage = [[JSQMessage alloc]initWithSenderId:senderId
                                                                                                     senderDisplayName:dataDic[@"author"]
                                                                                                                  date:date
                                                                                                                 media:photoItem];
                                                        [self.messages addObject:photoMessage];
                                                    }
                                                }else{
                                                    JSQMessage *message = [[JSQMessage alloc]initWithSenderId:senderId
                                                                                            senderDisplayName:dataDic[@"author"]
                                                                                                         date:date
                                                                                                         text:dataDic[@"msg"]];
                                                    [self.messages addObject:message];
                                                }
                                            }
                                            //循环message结束加入users
                                            self.users =  @{ kAvatarIdDoctor:doctorName,
                                                             kAvatarIdPatient:patientName };
                                            [[NSNotificationCenter defaultCenter]postNotificationName:DidGetMessageModelNotification object:nil];
                                        }
                                    }
                                 }
                                 failure:^(NSError *error){
                                      [SVProgressHUD dismiss];
                                 }];
}

/**
 *  获取评论列表中的图片
 */
-(UIImage *)getPhotoMessageWithId:(NSString *)recordId{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *token = [UserDefault objectForKey:@"Token"];
    NSString *api = [HTTPServerURLString stringByAppendingString:[NSString stringWithFormat:@"Api/Data/GetImgFromTreatRecord?token=%@&recordid=%@",token,recordId]];
   __block UIImage *downloadImage = [[UIImage alloc]init];
    [[manager imageDownloader]downloadImageWithURL:[NSURL URLWithString:api]
                                           options:0
                                          progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {

                                          }
                                         completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                             
                                             //下载完图片通知更新UI
                                             [[NSNotificationCenter defaultCenter]postNotificationName:DidGetMessageModelNotification object:nil];
                                             
                                             [SVProgressHUD dismiss];
                                                if (image) {
                                                    NSLog(@"图片");
                                                    downloadImage = image;
                                                }
                                             
                                             
                                         }];
    return downloadImage;
}
@end
