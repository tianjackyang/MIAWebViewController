//
//  MIAWebProtocol.h
//  Pods
//
//  Created by 杨鹏 on 16/3/27.
//
//

#import <Foundation/Foundation.h>

@protocol MIAWebProtocol <NSObject>
@required

@optional
- (NSMutableURLRequest*)ModifyWebViewRequestHeader:(NSURL*)url;

@end
