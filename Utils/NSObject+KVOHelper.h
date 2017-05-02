//
//  NSObject+KVOHelper.h
//  YesView
//
//  Created by JinHao on 5/19/15.
//  Copyright (c) 2015 YesView. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KVOHelper)

- (void)registerKVO;
- (void)unregisterKVO;
- (NSArray *)observableKeyPaths;

@end
