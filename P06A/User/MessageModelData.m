//
//  MessageModelData.m
//  P06A
//
//  Created by Binger Zeng on 2018/9/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MessageModelData.h"

@implementation MessageModelData
-(instancetype)init
{
    self = [super init];
    if(self){
        
        //聊天头像
        JSQMessagesAvatarImage *doctorImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"avatar_doctor"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        JSQMessagesAvatarImage *patientImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"avatar_patient"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
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
    
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Data/LogOfHireRecord?action=List"]
                                  params:@{@"hireid":hireId}
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                    if ([responseObject.result integerValue] == 1) {
                                        NSArray *messageArray = responseObject.content;
                                        if ([messageArray count]>0) {
                                            self.messages = [[NSMutableArray alloc]initWithCapacity:100];
                                            
                                            //doctor用户和patient用户显示名字
                                            NSString *patientName = [[NSString alloc]init];
                                            NSString *doctorName = [[NSString alloc]init];
                                            
                                            
                                            //循环消息队列
                                            for (NSDictionary *dataDic in messageArray) {
                                                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dataDic[@"time"]doubleValue]];

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

                                                    UIImage *image = [self getPhotoMessageWithId:recordId];
                                                    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
                                                    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:senderId
                                                                                                   displayName:dataDic[@"author"]
                                                                                                         media:photoItem];
                                                    [self.messages addObject:photoMessage];
                                                }else{
                                                    JSQMessage *message = [[JSQMessage alloc]initWithSenderId:senderId
                                                                                            senderDisplayName:dataDic[@"author"]
                                                                                                         date:date
                                                                                                         text:dataDic[@"msgtype"]];
                                                    [self.messages addObject:message];
                                                }
                                                self.users =  @{ kAvatarIdDoctor:doctorName,
                                                                                       kAvatarIdPatient:patientName };
                                            }
                                        }
                                    }
                                 }
                                 failure:nil];
}
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
                                                if (image) {
                                                    downloadImage = image;
                                                }}];
    return downloadImage;
}
@end
