//
//  Person.h
//  Test090101
//
//  Created by ibokan on 14-9-1.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * firstN;

@end
