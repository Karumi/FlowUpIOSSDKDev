//
//  FUPReportScheduler.m
//  SDK
//
//  Created by Sergio Gutiérrez on 25/05/2017.
//  Copyright © 2017 flowup. All rights reserved.
//

#import "FUPReportScheduler.h"

static NSTimeInterval const NeverReported = -1;

@interface FUPReportScheduler ()

@property (readonly, nonatomic) FUPMetricsStorage *storage;
@property (readonly, nonatomic) FUPReportApiClient *reportApiClient;
@property (readonly, nonatomic) FUPDevice *device;
@property (readonly, nonatomic) FUPTime *time;
@property (readonly, nonatomic) FUPConfigService *configService;
@property (readonly, nonatomic) FUPSafetyNet *safetyNet;
@property (readwrite, nonatomic) NSTimeInterval lastReportTimeInterval;

@end

@implementation FUPReportScheduler

- (instancetype)initWithMetricsStorage:(FUPMetricsStorage *)metricsStorage
                       reportApiClient:(FUPReportApiClient *)reportApiClient
                                device:(FUPDevice *)device
                         configService:(FUPConfigService *)configService
                             safetyNet:(FUPSafetyNet *)safetyNet
                                  time:(FUPTime *)time
{
    self = [super init];
    if (self) {
        _storage = metricsStorage;
        _reportApiClient = reportApiClient;
        _device = device;
        _configService = configService;
        _safetyNet = safetyNet;
        _time = time;
        _lastReportTimeInterval = NeverReported;
    }
    return self;
}

- (void)start
{
    NSLog(@"[ReportScheduler] Start");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ReportSchedulerFirstReportDelayTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:ReportSchedulerReportingTimeInterval repeats:YES block:^(NSTimer *timer) {
            async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.safetyNet runBlock:^{
                    [self reportMetrics];
                }];
            });
        }];        
    });
}

- (void)reportMetrics
{
    NSLog(@"[ReportScheduler] Report metrics");
    if (!self.configService.enabled) {
        NSLog(@"[ReportScheduler] FlowUp is disabled for this device");
        return;
    }

    if (self.lastReportTimeInterval != NeverReported && [self.time now] - self.lastReportTimeInterval < ReportSchedulerTimeBetweenReportsTimeInterval) {
        NSLog(@"[ReportScheduler] Did not pass enought time to report");
        return;
    }

    if (!self.storage.hasReports) {
        NSLog(@"[ReportScheduler] Do not have any report to send");
        return;
    }

    NSArray<FUPMetric *> *metrics = [self.storage metricsAtMost:MaxNumberOfReportsPerRequest];
    FUPReports *reports = [self reportsWithMetrics:metrics];
    [self.reportApiClient sendReports:reports completion:^(FUPApiClientError *error) {
        if (error == nil) {
            NSLog(@"[ReportScheduler] Reports successfully sent [%ld]", metrics.count);
            [self removeReportedMetricsCount:metrics.count];
        } else if (error.code == FUPApiClientErrorCodeUnauthorized || error.code == FUPApiClientErrorCodeServerError) {
            NSLog(@"[ReportScheduler] There was an error sending the reports: Unauthorized OR Server error");
            [self removeReportedMetricsCount:metrics.count];
            [self disableSdk];
        } else if (error.code == FUPApiClientErrorCodeClientDisabled) {
            NSLog(@"[ReportScheduler] There was an error sending the reports: Client Disabled");
            [self.storage clear];
            [self disableSdk];
        } else {
            NSLog(@"[ReportScheduler] There was an error sending the reports: Unknown");
        }
    }];
}

- (void)removeReportedMetricsCount:(NSInteger)metricsCount
{
    [self.storage removeNumberOfMetrics:metricsCount];
    self.lastReportTimeInterval = [self.time now];
}

- (void)disableSdk
{
    [self.configService disable];
}

- (FUPReports *)reportsWithMetrics:(NSArray<FUPMetric *> *)metrics
{
    return [[FUPReports alloc] initWithAppPackage:self.device.appPackage
                                 installationUuid:self.device.installationUuid
                                      deviceModel:self.device.deviceModel
                                    screenDensity:self.device.screenDensity
                                       screenSize:self.device.screenSize
                                    numberOfCores:self.device.numberOfCores
                                       cpuMetrics:[self filteredMetrics:metrics byName:@"CPU"]
                                        uiMetrics:[self filteredMetrics:metrics byName:@"UI"]
                                      diskMetrics:[self filteredMetrics:metrics byName:@"Disk"]];
}

- (NSArray <FUPMetric *> *)filteredMetrics:(NSArray<FUPMetric *> *)metrics byName:(NSString *)name
{
    return [metrics filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [((FUPMetric *)evaluatedObject).name isEqualToString:name];
    }]];
}

@end
