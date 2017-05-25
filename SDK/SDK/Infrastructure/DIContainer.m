//
//  DIContainer.m
//  SDK
//
//  Created by Sergio Gutiérrez on 25/05/2017.
//  Copyright © 2017 flowup. All rights reserved.
//

#import "DIContainer.h"

@implementation DIContainer

+ (CollectorScheduler *)collectorScheduler
{
    static CollectorScheduler *_scheduler;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _scheduler = [[CollectorScheduler alloc] init];
    });

    return _scheduler;
}

+ (CpuUsageCollector *)cpuUsageCollector
{
    return [[CpuUsageCollector alloc] init];
}

+ (ReportScheduler *)reportSchedulerWithApiKey:(NSString *)apiKey
{
    static ReportScheduler *_scheduler;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _scheduler = [[ReportScheduler alloc] initWithDevice:[DIContainer device]
                                             reportApiClient:[DIContainer reportApiClientWithApiKey:apiKey]
                                                        time:[DIContainer time]];
    });

    return _scheduler;
}

+ (ReportApiClient *)reportApiClientWithApiKey:(NSString *)apiKey
{
    static ReportApiClient *_apiClient;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *uuid = [DIContainer uuidGenerator].uuid;
        _apiClient = [[ReportApiClient alloc] initWithBaseUrl:ApiBaseUrl
                                                       apiKey:apiKey
                                                         uuid:uuid];
    });

    return _apiClient;
}

+ (Device *)device
{
    return [[Device alloc] initWithUuidGenerator:[DIContainer uuidGenerator]];
}

+ (UuidGenerator *)uuidGenerator
{
    return [[UuidGenerator alloc] init];
}

+ (TimeProvider *)time
{
    return [[TimeProvider alloc] init];
}

@end
