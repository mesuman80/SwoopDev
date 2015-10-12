//
//  BaseTabbarController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 10/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "BaseTabbarController.h"

@implementation BaseTabbarController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        Record *record = [Utility getObjectFromDefaultsWithKey:@"User"];
        
        if (record && [[record type] isEqualToString:@"genie"])
        {
            NSArray *controllers = [self viewControllers];
            [self setViewControllers:@[controllers[1], [controllers lastObject]]];
        }
        
//        //Setting tabbar icons
//        NSArray *items = [[self tabBar] items];
//        
//        if ([[self viewControllers] count] == 2)
//        {
//            UITabBarItem *item1 = [items firstObject];
//            UITabBarItem *item2 = [items lastObject];
//            
//            [item1 setImage:[[UIImage imageNamed:@"gin_btn_notification_inactive"] getOriginalImage]];
//            [item2 setImage:[[UIImage imageNamed:@"gin_btn_profile_inactive"] getOriginalImage]];
//            
//            [item1 setSelectedImage:[[UIImage imageNamed:@"gin_btn_notification_active"] getOriginalImage]];
//            [item2 setSelectedImage:[[UIImage imageNamed:@"gin_btn_profile_active"] getOriginalImage]];
//        }
//        else
//        {
//            UITabBarItem *item1 = [items firstObject];
//            UITabBarItem *item2 = items[1];
//            UITabBarItem *item3 = [items lastObject];
//            
//            [item1 setImage:[[UIImage imageNamed:@"gen_btn_findgenie_inactive"] getOriginalImage]];
//            [item2 setImage:[[UIImage imageNamed:@"gen_btn_notification_inactive"] getOriginalImage]];
//            [item3 setImage:[[UIImage imageNamed:@"gen_btn_profile_inactive"] getOriginalImage]];
//            
//            [item1 setSelectedImage:[[UIImage imageNamed:@"gen_btn_findgenie_active"] getOriginalImage]];
//            [item2 setSelectedImage:[[UIImage imageNamed:@"gen_btn_notification_active"] getOriginalImage]];
//            [item3 setSelectedImage:[[UIImage imageNamed:@"gen_btn_profile_active"] getOriginalImage]];
//        }
    }
    return self;
}

@end
