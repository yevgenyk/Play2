#pragma once
#include "gen/Play2Network.h"
#include "gen/Play2ParsedItems.h"
#include "gen/Play2HttpResponse.h"


@interface NetworkObjc : NSObject <Play2Network>

- (Play2HttpResponse *)download:(NSDictionary *)params;

@end
