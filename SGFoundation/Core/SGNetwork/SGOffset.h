//
//  SGOffset.h
//  opera
//
//  Created by Single on 16/6/8.
//  Copyright © 2016年 HL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SGOffset;

typedef NS_ENUM(NSUInteger, SGOffsetState) {
    SGOffsetStateDown,
    SGOffsetStateUp,
};

typedef struct SGOffsetParams {
    NSInteger offset;
    NSInteger size;
} SGOffsetParams;


typedef void(^SGOffsetEmptyBlock)(SGOffset * offset);

@interface SGOffset : NSObject

+ (instancetype)offset;
+ (instancetype)offsetWithDownEmptyBolok:(SGOffsetEmptyBlock)downEmptyBolok upEmptyBolok:(SGOffsetEmptyBlock)upEmptyBolok;

@property (nonatomic, assign, readonly) SGOffsetState state;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger size; // default is 20

- (void)beginDown;
- (void)beginUp;
- (void)success;

- (NSArray *)dealObjectsAfterSuccessOld:(NSArray *)oldObjs new:(NSArray *)newObjs;
- (SGOffsetParams)offsetParams;

@end
