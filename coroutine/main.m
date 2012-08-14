//
//  main.m
//  coroutine
//
//  Created by Marcin Świderski on 8/9/12.
//  Copyright (c) 2012 LoonyWare Marcin Świderski. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	bool ret = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	[pool drain];
	return ret;
}
