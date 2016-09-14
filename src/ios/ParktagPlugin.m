//
//  ParktagPlugin.m
//  PhoneGapSample
//
//  Created by Arbisoft on 14/02/2015.
//
//

#import "ParktagPlugin.h"
#import "Parktag.h"

@implementation ParktagPlugin

- (void)start:(CDVInvokedUrlCommand*)command
{
    Parktag *parkTAG = [Parktag sharedInstance];
    parkTAG.delegate = self;
    
    if (command.arguments != nil && [command.arguments count] > 0) {
        parkTAG.apiKey = [command.arguments objectAtIndex:0];
        [parkTAG startWithCompletionHandler:^(NSError *error) {
            CDVPluginResult* pluginResult = nil;
            NSString *errorDescription = [error description];
            if (error == nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorDescription];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"API key missing"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)stop:(CDVInvokedUrlCommand*)command
{
    [[Parktag sharedInstance] stop];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)kickStartGPS:(CDVInvokedUrlCommand*)command
{
    [[Parktag sharedInstance] kickStartGPS];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addFence:(CDVInvokedUrlCommand*)command
{   
    if (command.arguments != nil && [command.arguments count] > 3) {
    	NSString *identifier = [command.arguments objectAtIndex:0];
    	NSNumber *centerLatitude = [command.arguments objectAtIndex:1];
    	NSNumber *centerLongitude = [command.arguments objectAtIndex:2];
    	NSNumber *radius = [command.arguments objectAtIndex:3];
    	
    	CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:[centerLatitude doubleValue]
                                                                longitude:[centerLongitude doubleValue]];
        
    	BOOL status = [[Parktag sharedInstance] addFence:identifier
                                                  center:centerLocation
                                                  radius:[radius doubleValue]];
        
    	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:status];
    	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid Arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)removeFence:(CDVInvokedUrlCommand*)command
{
    if (command.arguments != nil && [command.arguments count] > 0) {
    	NSString *identifier = [command.arguments objectAtIndex:0];
    	[[Parktag sharedInstance] removeFence:identifier];
    	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid Arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)setLoggingLevel:(CDVInvokedUrlCommand*)command
{
	if (command.arguments != nil && [command.arguments count] > 0) {
    	NSString *logLevelParam = [command.arguments objectAtIndex:0];
    	LogLevel logLevel;
    	if ([logLevelParam isEqualToString:@"Debug"]) {
    		logLevel = LogLevelDebug;
    	} else {
    		logLevel = LogLevelNone;
    	}
    	
    	[[Parktag sharedInstance] setLoggingLevel:logLevel];
    	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid Arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)trackerStatus:(CDVInvokedUrlCommand*)command
{    
    TrackerStatus trackerStatus = [[Parktag sharedInstance] trackerStatus];
    NSString *trackerStatusDesc = @"";
    if (trackerStatus == TrackerStatusActive) {
    	trackerStatusDesc = @"Active";
    } else if (trackerStatus == TrackerStatusLocationServicesDisabled) {
    	trackerStatusDesc = @"LocationServicesDisabled";
    } else if (trackerStatus == TrackerStatusInsufficientPermission) {
    	trackerStatusDesc = @"InsufficientPermission";
    } else if (trackerStatus == TrackerStatusInActive) {
    	trackerStatusDesc = @"InActive";
    }
    
    if ([trackerStatusDesc isEqualToString:@""]) {
    	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid Tracker Status"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
    	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:trackerStatusDesc];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

#pragma mark - ParktagDelegate Methods

/**
 * This method is invoked when ParkTAG detects that user is about to vacate the parking spot
 * and is approaching his vehicle
 * @param location:   The Location where ParkTAG identified the parking spot that is about to be vacated.
 * */
- (void)vacatingParking:(CLLocation *)location
{
    NSMutableDictionary *vacatingParkingData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              @(location.coordinate.latitude), @"latitude",
                                              @(location.coordinate.longitude), @"longitude",
                                              nil];
    
    NSString *params = [self jsonSerializeDictionary:vacatingParkingData];
    [self evaluateJSMethod:@"vacatingParking" params:params];
}

/**
 * This method is invoked when ParkTAG detects that user has just vacated
 * a parking spot and have started a new trip
 * @param location:  The Location where ParkTAG identified start of the trip
 * @param startTime: Start time of trip
 * */
- (void)vacatedParking:(CLLocation *)location startTime:(NSDate *)startTime
{
    NSMutableDictionary *vacatedParkingData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              @(location.coordinate.latitude), @"latitude",
                                              @(location.coordinate.longitude), @"longitude",
                                              @([startTime timeIntervalSince1970]), @"startTime",
                                              nil];
    
    NSString *params = [self jsonSerializeDictionary:vacatedParkingData];
    [self evaluateJSMethod:@"vacatedParking" params:params];
}

/**
 * This method is invoked when ParkTAG detects that recently vacated vehicle is not a Car
 * */
- (void)vacatedParkingCanceled
{
    [self evaluateJSMethod:@"vacatedParkingCanceled" params:nil];
}

/**
 * This method is invoked when ParkTAG detects that user has just parked his vehicle
 * @param location:  The Location where vehicle is parked
 * @param startTime: Start time of trip
 * @param stopTime:  Stop time of trip
 * */
- (void)vehicleParked:(CLLocation *)location startTime:(NSDate *)startTime stopTime:(NSDate *)stopTime
{
    NSMutableDictionary *vehicleParkedData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              @(location.coordinate.latitude), @"latitude",
                                              @(location.coordinate.longitude), @"longitude",
                                              @([startTime timeIntervalSince1970]), @"startTime",
                                              @([stopTime timeIntervalSince1970]), @"stopTime",
                                              nil];
    
    NSString *params = [self jsonSerializeDictionary:vehicleParkedData];
    [self evaluateJSMethod:@"vehicleParked" params:params];
}

/**
 * This method is invoked when ParkTAG user is looking for a free parking
 * @param location:  The Location where ParkTAG identified that user is searching for parking
 * */
- (void)searchingParking:(CLLocation *)location
{
    NSMutableDictionary *searchingParkingData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              @(location.coordinate.latitude), @"latitude",
                                              @(location.coordinate.longitude), @"longitude",
                                              nil];
    
    NSString *params = [self jsonSerializeDictionary:searchingParkingData];
    [self evaluateJSMethod:@"searchingParking" params:params];
}

/**
 * This is invoked when new location information is received from GPS
 * Implemented this method if you need raw GPS data, instead of creating new location manager
 * Since, it is not recommended using multiple location managers in a single app
 * @param location:  New location received from GPS
 * */
- (void)didUpdateLocation:(CLLocation *)location
{
    NSMutableDictionary *didUpdateLocationData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 @(location.coordinate.latitude), @"latitude",
                                                 @(location.coordinate.longitude), @"longitude",
                                                 nil];
    
    NSString *params = [self jsonSerializeDictionary:didUpdateLocationData];
    [self evaluateJSMethod:@"didUpdateLocation" params:params];
}

/*
 * This method is invoked when a vehicle enters the Geo-Fence
 * Implement this method if you need callback when user enters a Geo-Fence
 * @param region: region the vehicle entered
 */
- (void)didEnterRegion:(CLRegion *)region
{
    NSMutableDictionary *didUpdateLocationData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  region.identifier, @"identifier",
                                                  @(region.center.latitude), @"centerLatitude",
                                                  @(region.center.longitude), @"centerLongitude",
                                                  @(region.radius), @"radius",
                                                  nil];
    
    NSString *params = [self jsonSerializeDictionary:didUpdateLocationData];
    [self evaluateJSMethod:@"didEnterRegion" params:params];
}

/**
 * This method is invoked when a vehicle exits the Geo-Fence
 * Implement this method if you need callback when user exits a Geo-Fence
 * @param region: region the vehicle exited
 */
- (void)didExitRegion:(CLRegion *)region
{
	NSMutableDictionary *didUpdateLocationData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  region.identifier, @"identifier",
                                                  @(region.center.latitude), @"centerLatitude",
                                                  @(region.center.longitude), @"centerLongitude",
                                                  @(region.radius), @"radius",
                                                  nil];
    
    NSString *params = [self jsonSerializeDictionary:didUpdateLocationData];
    [self evaluateJSMethod:@"didExitRegion" params:params];
}

#pragma mark - Helper Methods

- (NSString *)jsonSerializeDictionary:(NSDictionary *)dictionary
{
    NSString *jsonString = nil;
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    if (jsonData != nil) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

- (void)evaluateJSMethod:(NSString *)methodName params:(NSString *)params
{
    NSString *jsStatement = methodName;
    
    if (params == nil) {
        jsStatement = [jsStatement stringByAppendingString:@"();"];
    } else {
        jsStatement = [jsStatement stringByAppendingString:@"('"];
        jsStatement = [jsStatement stringByAppendingString:params];
        jsStatement = [jsStatement stringByAppendingString:@"');"];
    }
    
    [self.commandDelegate evalJs:jsStatement];
}

@end