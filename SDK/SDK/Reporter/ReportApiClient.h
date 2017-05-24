//
//  ReportApiClient.h
//  SDK
//
//  Created by Sergio Gutiérrez on 24/05/2017.
//  Copyright © 2017 flowup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reports.h"
#import "AFNetworking.h"

@interface ReportApiClient : NSObject

@property (readonly, nonatomic, strong) AFHTTPRequestSerializer *serializer;

- (void)sendReports: (Reports *) reports;

@end
