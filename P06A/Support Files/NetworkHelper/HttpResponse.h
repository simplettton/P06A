//
//  HttpResponse.h
//  demo
//
//  Created by Macmini on 2017/10/23.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#ifndef HttpResponse_h
#define HttpResponse_h

#import <Foundation/Foundation.h>

@interface HttpResponse:NSObject

@property NSDictionary *jsonDist;
@property NSString *result;
@property id content;
@property NSString *errorString;
@end

#endif /* HttpResponse_h */
