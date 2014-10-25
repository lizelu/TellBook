//
//  EditViewController.m
//  Test090101
//
//  Created by ibokan on 14-9-1.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "EditViewController.h"
#import "Pinyin.h"

@interface EditViewController ()
//显示用户信息
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *telTextField;

//显示用户图片
@property (strong, nonatomic) IBOutlet UIButton *imageButton;

//声明ImagePicker
@property (strong, nonatomic) UIImagePickerController *picker;

//声明上下文
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

@end




@implementation EditViewController



//点击图片按钮设置图片
- (IBAction)tapImageButton:(id)sender {
    
    //跳转到ImagePickerView来获取按钮
    [self presentViewController:self.picker animated:YES completion:^{}];
    
}

//回调图片选择取消
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //在ImagePickerView中点击取消时回到原来的界面
    [self dismissViewControllerAnimated:YES completion:^{}];
}




//实现图片回调方法，从相册获取图片
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    //获取到编辑好的图片
    UIImage * image = info[UIImagePickerControllerEditedImage];
    
    //把获取的图片设置成用户的头像
    [self.imageButton setImage:image forState:UIControlStateNormal];
    
    //返回到原来View
    [self dismissViewControllerAnimated:YES completion:^{}];

}

- (IBAction)tapSave:(id)sender
{
   
    if (![self.nameTextField.text isEqualToString:@""] && ![self.telTextField.text isEqualToString:@""])
    {
    
    //如果person为空则新建，如果已经存在则更新
    if (self.person == nil)
    {
        self.person = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Person class]) inManagedObjectContext:self.managedObjectContext];
    }
    //赋值
    self.person.name = self.nameTextField.text;
    self.person.tel = self.telTextField.text;
    self.person.firstN = [NSString stringWithFormat:@"%c", pinyinFirstLetter([self.person.name characterAtIndex:0])-32];
    
    //把button上的图片存入对象
    UIImage *buttonImage = [self.imageButton imageView].image;
    self.person.imageData = UIImagePNGRepresentation(buttonImage);
 
        //保存
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        //保存成功后POP到表视图
        [self.navigationController popToRootViewControllerAnimated:YES];

        
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  
        self.nameTextField.text = self.person.name;
        self.telTextField.text = self.person.tel;
        
        if (self.person.imageData != nil)
        {
            UIImage *image = [UIImage imageWithData:self.person.imageData];
            [self.imageButton setImage:image forState:UIControlStateNormal];

        }


    //获取上下文
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = application.delegate;
    self.managedObjectContext = [delegate managedObjectContext];
    
    
    //处理键盘
    self.nameTextField.delegate = self;
    self.telTextField.delegate = self;
    
    
    
    //初始化并配置ImagePicker
    self.picker = [[UIImagePickerController alloc] init];
    //picker是否可以编辑
    self.picker.allowsEditing = YES;
    //注册回调
    self.picker.delegate = self;
    
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.nameTextField resignFirstResponder];
    [self.telTextField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
