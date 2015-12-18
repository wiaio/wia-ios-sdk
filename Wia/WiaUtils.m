//
//  WiaUtils.m
//  Pods
//
//  Created by Conall Laverty on 18/12/2015.
//
//

#import "WiaUtils.h"

static BOOL kWiaLoggerShowLogs = NO;

// Logging

void WiaSetShowDebugLogs(BOOL showDebugLogs)
{
    kWiaLoggerShowLogs = showDebugLogs;
}

void WiaLogger(NSString *format, ...)
{
    if (!kWiaLoggerShowLogs)
        return;
    
    va_list args;
    va_start(args, format);
    NSLogv([NSString stringWithFormat:@"WiaDebug - %@", format], args);
    va_end(args);
}