//
//  NSObject+KVOHelper.m
//  YesView
//
//  Created by JinHao on 5/19/15.
//  Copyright (c) 2015 YesView. All rights reserved.
//

#import "NSObject+KVOHelper.h"

@implementation NSObject (KVOHelper)

- (void)registerKVO
{
    for (NSString *keyPath in[self observableKeyPaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterKVO
{
    for (NSString *keyPath in[self observableKeyPaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeyPaths
{
    return @[];
}

@end
