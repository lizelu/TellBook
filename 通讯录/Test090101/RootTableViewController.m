//
//  RootTableViewController.m
//  Test090101
//
//  Created by ibokan on 14-9-1.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "RootTableViewController.h"
#import "Person.h"
#import "SearchCell.h"

@interface RootTableViewController ()

//声明上下文和fetchedResultController
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;

//添加Search Display Controller属性
@property (strong, nonatomic) IBOutlet UISearchDisplayController *displayC;




@end

@implementation RootTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //获取上下文
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = application.delegate;
    self.managedObjectContext = [delegate managedObjectContext];
    
    //创建请求对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Person class])];
    //创建排序规则
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstN" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    //执行查询
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstN" cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    
    //注册我们自定义的Cell
    [self.displayC.searchResultsTableView registerClass:[SearchCell class] forCellReuseIdentifier:@"SearchCell"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//当search中的文本变化时就执行下面的方法
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //新建查询语句
    NSFetchRequest * request = [[NSFetchRequest alloc]initWithEntityName:NSStringFromClass([Person class])];
    
    //排序规则
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstN" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    //添加谓词
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains %@",searchText];
    [request setPredicate:predicate];
    
    //把查询结果存入fetchedResultsController中
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstN" cacheName:nil];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

//当在searchView中点击取消按钮时我们重新刷新一下通讯录
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
   [self viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    NSArray *sections = [self.fetchedResultsController sections];
    return sections.count;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return [sectionInfo numberOfObjects];


}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return [sectionInfo name];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell;
    
    
    //根据不同的tableView来设置不同的cell模板
    if ([tableView isEqual:self.tableView])
    {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
        
    }
    
    if (person.imageData != nil) {
        UIImage *image = [UIImage imageWithData:person.imageData];
        cell.imageView.image = image;
    }
    
    cell.textLabel.text = person.name;
    cell.detailTextLabel.text = person.tel;
    
    return cell;


}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.displayC.searchResultsTableView])
    {
        return NO;
    }
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


-(NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:person];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}


//给我们的通讯录加上索引，下面的方法返回的时一个数组
-(NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //通过fetchedResultsController来获取section数组
    NSArray *sectionArray = [self.fetchedResultsController sections];
    
    //新建可变数组来返回索引数组，大小为sectionArray中元素的多少
    NSMutableArray *index = [NSMutableArray arrayWithCapacity:sectionArray.count];
    
    //通过循环获取每个section的header,存入addObject中
    for (int i = 0; i < sectionArray.count; i ++)
    {
        id <NSFetchedResultsSectionInfo> info = sectionArray[i];
        [index addObject:[info name]];
    }
    
    //返回索引数组
    return index;


}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.displayC.searchResultsTableView])
    {
         Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UIStoryboard * s = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        //获取要目标视图
        UIViewController *destination = [s instantiateViewControllerWithIdentifier:@"EditViewController"];
        
        //键值编码传值
        [destination setValue:person forKeyPath:@"person"];
        
        [self.navigationController pushViewController:destination animated:YES];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   //Navigation切换时调用该方法，把值传递给下一个Push的页面，


    //在本viewController中sender会有两种情况，因为我们点击cell和itemAdd都可以跳转到下一个界面，所以得判断一下
    if ([sender isKindOfClass:([UITableViewCell class])])
    {
        UITableViewCell *cell = sender;
        //通过cell获取索引
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        //获取实体对象
        Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //获取要目标视图
        UIViewController *destination = [segue destinationViewController];
    
        //键值编码传值
        [destination setValue:person forKeyPath:@"person"];
    }
}










/*
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
