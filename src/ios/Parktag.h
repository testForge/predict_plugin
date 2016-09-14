//
//  Parktag.h
//  parktag-sdk
//
//  Created by Zee on 28/02/2013.
//  Copyright (c) 2014 ParkTAG GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


/*
 * TrackerStatus
 * Discussion: Represents the current tracker state.
 */
typedef NS_ENUM(int, TrackerStatus) {
    // Tracker is in a working, active state
    TrackerStatusActive = 0,
    
    // Tracker not in a working state as the location services are disabled
    TrackerStatusLocationServicesDisabled,
    
    // Tracker has not been allowed to start location services at any time (kCLAuthorizationStatusAuthorizedAlways)
    TrackerStatusInsufficientPermission,
    
    // Tracker has not been started. It is in inactive state.
    TrackerStatusInActive
};

/*
 * LogLevel
 * Discussion: Represents the current tracker state.
 */
typedef NS_ENUM(int, LogLevel)  {
    LogLevelNone = 0, LogLevelDebug
};


@protocol ParktagDelegate;

@interface Parktag : NSObject

@property (nonatomic, weak) id <ParktagDelegate> delegate;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *version;

+ (Parktag *)sharedInstance;

/**
 * Starts the ParkTag Tracker if delegate and API-Key is set, otherwise returns Error
 * @param handler: The argument to the completion handler block is an error object that contains the description of the error in case an error is encountered while starting the ParkTAG tracker. If the tracker is started successfully, the error object is set to nil.
 * */
- (void)startWithCompletionHandler:(void(^)(NSError *error))handler;

/**
 * Stops the ParkTag Tracker
 * */
- (void)stop;

/**
 * Activates GPS (if not already activated)for short period of time whenever required,
 * Note: to use this method Tracker must have been started first.
 * */
- (void)kickStartGPS;

/*
 * This method adds a GeoFence of specified radius around the location
 * @param identifier: GeoFence identifier
 * @param location: Center location of the GeoFence
 * @param radius: The distance (measured in meters) from the center point of the geographic region to the edge of the circular boundary.
 */
- (BOOL)addFence:(NSString *)identifier center:(CLLocation *)location radius:(CLLocationDistance)radius;

/*
 * This method removes the specified GeoFence around the location
 * @param identifier: GeoFence identifier
 */
- (void)removeFence:(NSString *)identifier;

- (void)setLoggingLevel:(LogLevel)logLevel;

/**
 * This method returns the status of the tracker i.e. if it is active or otherwise
 */
- (TrackerStatus)trackerStatus;

@end

@protocol ParktagDelegate <NSObject>

@optional

/**
 * This method is invoked when ParkTAG detects that user is about to vacate the parking spot
 * and is approaching his vehicle
 * @param location:   The Location where ParkTAG identified the parking spot that is about to be vacated.
 * */
- (void)vacatingParking:(CLLocation *)location;

/**
 * This method is invoked when ParkTAG detects that user has just vacated
 * a parking spot and have started a new trip
 * @param location:  The Location where ParkTAG identified start of the trip
 * @param startTime: Start time of trip
 * */
- (void)vacatedParking:(CLLocation *)location startTime:(NSDate *)startTime;

/**
 * This method is invoked when ParkTAG detects that recently vacated vehicle is not a Car
 * */
- (void)vacatedParkingCanceled;

/**
 * This method is invoked when ParkTAG detects that user has just parked his vehicle
 * @param location:  The Location where vehicle is parked
 * @param startTime: Start time of trip
 * @param stopTime:  Stop time of trip
 * */
- (void)vehicleParked:(CLLocation *)location startTime:(NSDate *)startTime stopTime:(NSDate *)stopTime;

/**
 * This method is invoked when ParkTAG user is looking for a free parking
 * @param location:  The Location where ParkTAG identified that user is searching for parking
 * */
- (void)searchingParking:(CLLocation *)location;

/**
 * This is invoked when new location information is received from GPS
 * Implemented this method if you need raw GPS data, instead of creating new location manager
 * Since, it is not recommended using multiple location managers in a single app
 * @param location:  New location received from GPS
 * */
- (void)didUpdateLocation:(CLLocation *)location;

/**
 * This method is invoked when a vehicle enters the Geo-Fence
 * Implement this method if you need callback when user enters a Geo-Fence
 * @param region: region the vehicle entered
 */
- (void)didEnterRegion:(CLRegion *)region;

/**
 * This method is invoked when a vehicle exits the Geo-Fence
 * Implement this method if you need callback when user exits a Geo-Fence
 * @param region: region the vehicle exited
 */
- (void)didExitRegion:(CLRegion *)region;

@end
