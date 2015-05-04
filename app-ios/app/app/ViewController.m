//
//  ViewController.m
//  app
//
//  Created by Yevgeny Kolyakov on 3/6/15.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "gen/Play2Api.h"
#import "gen/Play2Item.h"
#import "gen/Play2Network.h"
#import "gen/Play2ParsedItems.h"
#import "NetworkObjc.h"


NSString *const CellIdentifier = @"Play2Cell";


@interface ViewController ()

@property (strong, nonatomic) Play2Api *api;
@property (strong, nonatomic) NSArray *items;
@property (readwrite) int64_t mLatestStamp;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellIdentifier];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.dbPath == nil) {
        return;
    }
    
    self.api = [Play2Api create:appDelegate.dbPath];
    
    self.items = [self.api itemsGroupedByCount:@""];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

    [self refreshTable];
}

- (void)refreshTable {

    self.mLatestStamp = [[NSDate date] timeIntervalSince1970];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NetworkObjc *impl = [[NetworkObjc alloc] init];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        params[@(Play2NetworkParamsURL)] = @"https://api.random.org/json-rpc/1/invoke";
        params[@(Play2NetworkParamsN)] = @"3";
        params[@(Play2NetworkParamsMAX)] = @"5";
        params[@(Play2NetworkParamsAPIKEY)] = @"00000000-0000-0000-0000-000000000000";
        
#if 0
        //--->This flavor flies json string into UI. Presented as an option if needed.
        Play2HttpResponse *response = [impl download:params];
        if (response.httpCode == 200) {
            if ([response.data length] > 0) {
                [self.api updateItems:response.data stamp:self.mLatestStamp];
            }
        }
#endif
        
        Play2ParsedItems *items = [self.api download:params impl:impl];
        
        if ([items.error length] > 0) {
            NSLog(@"*** Error: %@", items.error);
            return;
        }
        if ([items.items count] > 0) {
            [self.api updateItemsFromList:items.items stamp:self.mLatestStamp];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.items = [self.api itemsGroupedByCount:@""];
            
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    });
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items != nil ? [self.items count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    Play2Item *item = [self.items objectAtIndex:indexPath.row];
    NSString *value = [NSString stringWithFormat:@"Number %lld (count %d)", item.value, item.count];
    cell.textLabel.text = value;//item.name;
    if (item.time == self.mLatestStamp) {
        cell.textLabel.textColor = [UIColor blueColor];
    }
    
    return cell;
}

@end
