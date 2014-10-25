//
//  EditViewController.h
//  Test090101
//
//  Created by ibokan on 14-9-1.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface EditViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(strong, nonatomic) Person *person;

@end
