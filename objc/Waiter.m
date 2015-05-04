#import <Foundation/Foundation.h>
#import "Waiter.h"

@implementation Waiter {
    BOOL done;
}

- (void)done {
    done = YES;
}

- (void)wait {
    while (!done) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
}

@end
