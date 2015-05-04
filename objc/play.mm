#import <Foundation/Foundation.h>

#import <Waiter.h>

#include "stl.hpp"

#include <json11/json11.hpp>

using namespace json11;

#import "gen/Play2Api.h"
#import "gen/Play2Item.h"
#import "gen/Play2ApiCppProxy.h"
#import "gen/Play2Network.h"
#import "gen/Play2NetworkParams.h"
#import "NetworkObjc.h"


@interface HttpTestSetup : NSObject
@property (strong, nonatomic) NSString *data;
@property (strong, nonatomic) Waiter *w;
@end

@implementation HttpTestSetup
- (instancetype) init {
    self = [super init];
    self.w = [[Waiter alloc] init];
    return self;
}
@end


void test() {
    NetworkObjc *impl = [[NetworkObjc alloc] init];
    
    Play2ApiCppProxy *api = [Play2ApiCppProxy create:@"numbers.sqlite"];

    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@(Play2NetworkParamsURL)] = @"https://api.random.org/json-rpc/1/invoke";
    params[@(Play2NetworkParamsN)] = @"5";
    params[@(Play2NetworkParamsMAX)] = @"7";
    params[@(Play2NetworkParamsAPIKEY)] = @"00000000-0000-0000-0000-000000000000";
    
    Play2ParsedItems *items = [api download:params impl:impl];
    
    NSLog(@"Download ended with status: %d ", items.httpCode);
    
    NSLog(@"Download yielded: %lu items", (unsigned long)[items.items count]);
    
    if ([items.items count] > 0) {
        
        time_t seconds_past_epoch = time(0);
        
        [api updateItemsFromList:items.items stamp:seconds_past_epoch];
    }
    
    NSArray *updatedItems = [api items:@""];
    int newCount = [updatedItems count];
    NSLog(@"Updated count : %d ", newCount);
    
}

int main() {
    
    test();

    return 0;
}
