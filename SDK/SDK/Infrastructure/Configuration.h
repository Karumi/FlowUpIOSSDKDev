//
//  Configuration.h
//  SDK
//
//  Created by Sergio Gutiérrez on 25/05/2017.
//  Copyright © 2017 flowup. All rights reserved.
//

#ifndef Configuration_h
#define Configuration_h

#import "TimeIntervalUnits.h"

static NSTimeInterval const CollectorSchedulerSamplingTimeInterval = 10;
static NSTimeInterval const ConfigSyncSchedulerFirstReportDelayTimeInterval = 1;
static NSTimeInterval const ConfigSyncSchedulerTimeBetweenSyncsTimeInterval = HOURS(10);
static NSTimeInterval const ConfigSyncSchedulerSyncingTimeInterval = MINUTES(5);
static NSTimeInterval const ReportSchedulerFirstReportDelayTimeInterval = 2;
static NSTimeInterval const ReportSchedulerReportingTimeInterval = 10;
static NSTimeInterval const ReportSchedulerTimeBetweenReportsTimeInterval = MINUTES(2);
static NSUInteger const MaxNumberOfReportsPerRequest = 898;
static NSString *const SDKVersion = @"0.0.1";
static NSString *const ApiBaseUrl = @"https://api.flowupapp.com";

#endif /* Configuration_h */
