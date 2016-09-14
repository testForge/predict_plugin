//
//  ParktagPlugin.h
//  PhoneGapSample
//
//  Created by Arbisoft on 14/02/2015.
//
//

#import <Cordova/CDV.h>
#import "Parktag.h"

@interface ParktagPlugin : CDVPlugin
<ParktagDelegate>

/**
 * Starts the ParkTag Tracker if delegate and API-Key is set, otherwise returns Error
 * @param apiKey:   ParkTAG SDK API Key.
 * */
- (void)start:(CDVInvokedUrlCommand*)command;

/**
 * Stops the ParkTag Tracker
 * */
- (void)stop:(CDVInvokedUrlCommand*)command;

/**
 * Activates GPS (if not already activated)for short period of time whenever required,
 * Note: to use this method Tracker must have been started first.
 * */
- (void)kickStartGPS:(CDVInvokedUrlCommand*)command;

/*
 * This method adds a GeoFence of specified radius around the location
 * @param identifier (String): GeoFence identifier
 * @param centerLatitude (Number): Latitude of the center location of the GeoFence
 * @param centerLongitude (Number): Longitude of the center location of the GeoFence
 * @param radius (Number): The distance (measured in meters) from the center point of the geographic region to the edge of the circular boundary.
 *
 * This method returns a boolean value indicating if a GeoFence has been added successfuly or not
 */
- (void)addFence:(CDVInvokedUrlCommand*)command;

/*
 * This method removes the specified GeoFence around the location
 * @param identifier: GeoFence identifier
 */
- (void)removeFence:(CDVInvokedUrlCommand*)command;

/*
 * This method sets the logging level for the tracker
 * @param logLevel: Possible values can be "None" or "Debug"
 */
- (void)setLoggingLevel:(CDVInvokedUrlCommand*)command;

/**
 * This method returns the status of the Tracker i.e. if it is active or otherwise
 * Possible return values are,
 * Active : Tracker is in a working, active state
 * LocationServicesDisabled : Tracker not in a working state as the location services are disabled
 * InsufficientPermission : Tracker has not been allowed to start location services at any time
 * InActive : Tracker has not been started. It is in inactive state
 */
- (void)trackerStatus:(CDVInvokedUrlCommand*)command;

@end
