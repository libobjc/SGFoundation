//
//  SGOffset.m
//  opera
//
//  Created by Single on 16/6/8.
//  Copyright © 2016年 HL. All rights reserved.
//

#import "SGOffset.h"

@interface SGOffset ()

@property (nonatomic, assign) SGOffsetState state;
@property (nonatomic, copy) SGOffsetEmptyBlock downEmptyBolok;
@property (nonatomic, copy) SGOffsetEmptyBlock upEmptyBolok;

@end

@implementation SGOffset

+ (instancetype)offset
{
    return [[self alloc] init];
}

+ (instancetype)offsetWithDownEmptyBolok:(SGOffsetEmptyBlock)downEmptyBolok upEmptyBolok:(SGOffsetEmptyBlock)upEmptyBolok
{
    return [[self alloc] initWithDownEmptyBolok:downEmptyBolok upEmptyBolok:upEmptyBolok];
}

- (instancetype)initWithDownEmptyBolok:(SGOffsetEmptyBlock)downEmptyBolok upEmptyBolok:(SGOffsetEmptyBlock)upEmptyBolok
{
    if (self = [super init]) {
        self.downEmptyBolok = downEmptyBolok;
        self.upEmptyBolok = upEmptyBolok;
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.size = 20;
}

- (void)beginDown
{
    self.state = SGOffsetStateDown;
}

- (void)beginUp
{
    self.state = SGOffsetStateUp;
}

- (void)success
{
    switch (self.state) {
        case SGOffsetStateDown:
        {
            self.offset = self.size;
        }
            break;
        case SGOffsetStateUp:
        {
            self.offset += self.size;
        }
            break;
    }
}

- (NSArray *)dealObjectsAfterSuccessOld:(NSArray *)oldObjs new:(NSArray *)newObjs
{
    BOOL newObjsTypeCheck = [newObjs isKindOfClass:[NSArray class]];
    BOOL newObjsCountCheck = NO;
    BOOL oldObjsTypeCheck = [oldObjs isKindOfClass:[NSArray class]];
    BOOL oldObjsCountCheck = NO;
    
    if (newObjsTypeCheck) newObjsCountCheck = newObjs.count > 0;
    if (oldObjsTypeCheck) oldObjsCountCheck = oldObjs.count > 0;
    
    switch (self.state) {
        case SGOffsetStateDown:
        {
            if (!newObjsTypeCheck || !newObjsCountCheck) {
                if (oldObjsTypeCheck && oldObjsCountCheck) {
                    return oldObjs;
                } else {
                    [self downEmptyAction];
                    return nil;
                }
            } else {
                return newObjs;
            }
        }
            break;
        case SGOffsetStateUp:
        {
            if (!newObjsTypeCheck || !newObjsCountCheck) {
                [self upEmptyAction];
                if (oldObjsTypeCheck && oldObjsCountCheck) {
                    return oldObjs;
                } else {
                    return nil;
                }
            } else {
                NSMutableArray * arrayM = [NSMutableArray arrayWithArray:oldObjs];
                [arrayM addObjectsFromArray:newObjs];
                return arrayM;
            }
        }
            break;
    }
}

- (void)downEmptyAction
{
    if (self.state == SGOffsetStateDown && self.downEmptyBolok != nil) {
        self.downEmptyBolok(self);
    }
}

- (void)upEmptyAction
{
    if (self.state == SGOffsetStateUp && self.upEmptyBolok != nil) {
        self.upEmptyBolok(self);
    }
}

- (SGOffsetParams)offsetParams
{
    SGOffsetParams params;

    NSInteger offset = 0;
    NSInteger size = self.size;
    
    switch (self.state) {
        case SGOffsetStateDown:
        {
            offset = 0;
        }
            break;
        case SGOffsetStateUp:
        {
            offset = self.offset;
        }
            break;
    }
    
    params.offset = offset;
    params.size = size;
    
    return params;
}

- (void)dealloc
{
    NSLog(@"SGOffset release");
}

@end
