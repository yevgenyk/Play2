#include <Foundation/Foundation.h>
#include "NetworkObjc.h"
#include "gen/Play2Item.h"
#include "gen/Play2NetworkParams.h"
#include "stl.hpp"
#include <json11/json11.hpp>

@implementation NetworkObjc

- (Play2ParsedItems *)download000:(NSString *)url {
    NSURL *URL            = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.random.org/json-rpc/1/invoke"]];
    [request setHTTPMethod:@"POST"];
    NSString *postString = @"{\"jsonrpc\":\"2.0\",\"method\":\"generateIntegers\",\"params\":{\"apiKey\":\"00000000-0000-0000-0000-000000000000\",\"n\":3,\"min\":1,\"max\":5,\"replacement\":false,\"base\":10},\"id\":24448}";
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    //Send a synchronous request
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    NSMutableArray *itemz = [[NSMutableArray alloc] init];
    NSString *errorString = @"";
    if (error == nil)
    {
        NSString * strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        std::string errorJson;
        std::string json = std::string([strData UTF8String]);
        auto json_response = json11::Json::parse(json, errorJson);
        if (!errorJson.empty()) {
            errorJson = errorJson;
        } else {
            if (json_response.is_object()) {
                auto result = json_response["result"];
                if (result.is_object()) {
                    auto random = result["random"];
                    if (random.is_object()) {
                        auto data = random["data"];
                        if (data.is_array()) {
                            for (const auto& item : data.array_items()) {
                                int64_t value = item.number_value();
                                Play2Item *a = [[Play2Item alloc] initWithId:0 value:value name:@"" time:0 count:0];
                                [itemz addObject:a];
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    //TEST:
    //sleep(20);
    
    int16_t httpCode = [(NSHTTPURLResponse*) response statusCode];

    Play2ParsedItems *a = [[Play2ParsedItems alloc] initWithHttpCode:httpCode error:errorString items:itemz];
    return a;
}

- (Play2HttpResponse *)download:(NSDictionary *)params {
    
    NSString *url = [params objectForKey:@(Play2NetworkParamsURL)];
    
    NSString *apiKey    = @"00000000-0000-0000-0000-000000000000";
    if (params[@(Play2NetworkParamsAPIKEY)]) {
        apiKey = params[@(Play2NetworkParamsAPIKEY)];
    }
    
    NSString *n         = @"3";
    if (params[@(Play2NetworkParamsN)]) {
        n = params[@(Play2NetworkParamsN)];
    }
    
    NSString *max       = @"5";
    if (params[@(Play2NetworkParamsMAX)]) {
        max = params[@(Play2NetworkParamsMAX)];
    }
    
    NSURL *URL            = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"{\"jsonrpc\":\"2.0\",\"method\":\"generateIntegers\",\"params\":{\"apiKey\":\"%@\",\"n\":%@,\"min\":1,\"max\":%@,\"replacement\":false,\"base\":10},\"id\":24448}", apiKey, n, max];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Send a synchronous request
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    NSString * strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    //TEST:
    //sleep(20);
    
    int16_t httpCode = [(NSHTTPURLResponse*) response statusCode];
    
    NSString *strError = @"";
    if (error != nil) {
        strError = [error description];
    }
    
    Play2HttpResponse *a = [[Play2HttpResponse alloc] initWithHttpCode:httpCode error:strError data:strData];
    return a;
}

@end
