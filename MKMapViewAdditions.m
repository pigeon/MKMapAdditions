//
//  MKViewAdditions.m
//
//  Created by Dmytro Golub on 3/27/11.
//
//  Copyright 2011 Dmytro Golub.
//	
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.


#import "MKMapViewAdditions.h"


#define kMapLocationLat  @"kMapLocationLat" 
#define kMapLocationLng  @"kMapLocationLng"

#define kMapLocationSpanLat @"kMapLocationSpanLat"
#define kMapLocationSpanLng @"kMapLocationSpanLng"


static const double kRMMinLatitude = -kMaxLat;
static const double kRMMaxLatitude = kMaxLat;
static const double kRMMinLongitude = -kMaxLong;
static const double kRMMaxLongitude = kMaxLong;

MKMapBoundingBox MKBoundingBoxMake(CLLocationCoordinate2D northeast,CLLocationCoordinate2D southwest)
{
	MKMapBoundingBox bbox;
	bbox.northeast = northeast;
	bbox.southwest = southwest;
	return bbox;
}

NSString* NSStringFromDGDGBoundingBox(MKMapBoundingBox bbox)
{
	return [NSString stringWithFormat:@"ne = {%f,%f} sw = {%f,%f}",bbox.northeast.latitude,
			bbox.northeast.longitude,bbox.southwest.latitude,bbox.southwest.longitude];
}

NSString* NSStringFromMKCoordinateRegion(MKCoordinateRegion region)
{
	return [NSString stringWithFormat:@"center = {%f,%f} spanLat = %f spanLng = %f",
			region.center.latitude,region.center.longitude,region.span.latitudeDelta,region.span.longitudeDelta];
}

@implementation MKMapView (BBox)




-(MKMapBoundingBox) bboxForMap
{
	CLLocationCoordinate2D center = self.centerCoordinate;
	MKCoordinateRegion region = [self region];
	CLLocationCoordinate2D northEastCorner, southWestCorner;
	northEastCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
	northEastCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
	southWestCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
	southWestCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0); 	
	return MKBoundingBoxMake(northEastCorner,southWestCorner);
}

-(void) setBBox:(MKMapBoundingBox) bbox
{
	MKCoordinateRegion region;
	region.span.latitudeDelta = - bbox.southwest.latitude + bbox.northeast.latitude;
	region.span.longitudeDelta = bbox.northeast.longitude - bbox.southwest.longitude;
	
	region.center = CLLocationCoordinate2DMake((bbox.northeast.latitude - region.span.latitudeDelta/2),
											   bbox.northeast.longitude - region.span.longitudeDelta/2);
	
	[self setRegion:region];
}

-(void) removeAllAnnotations
{
	NSArray* theAnnotations = self.annotations;
	if (theAnnotations)
	{
		[self removeAnnotations:theAnnotations];
	}
}

-(BOOL) isPreviousMapPositionKnown
{
	BOOL result = YES;
	double lngSpan = [[NSUserDefaults standardUserDefaults] doubleForKey: kMapLocationSpanLng];
	
	if(lngSpan  < 0.00001) 
	{
		result = NO;
	}	
	return result;
}

- (MKCoordinateRegion) loadMapPosition
{
	MKCoordinateRegion region;
	region.center.latitude  = [[NSUserDefaults standardUserDefaults] doubleForKey: kMapLocationLat];
	region.center.longitude = [[NSUserDefaults standardUserDefaults] doubleForKey: kMapLocationLng];		
	region.span.latitudeDelta = [[NSUserDefaults standardUserDefaults] doubleForKey: kMapLocationSpanLat];
	region.span.longitudeDelta = [[NSUserDefaults standardUserDefaults] doubleForKey: kMapLocationSpanLng];
	
	return region;
}


- (void) saveMapPosition
{	
	MKCoordinateRegion region = [self region];	
	[[NSUserDefaults standardUserDefaults] setDouble: region.center.latitude forKey: kMapLocationLat];
	[[NSUserDefaults standardUserDefaults] setDouble: region.center.longitude forKey: kMapLocationLng];
	[[NSUserDefaults standardUserDefaults] setDouble: region.span.latitudeDelta forKey: kMapLocationSpanLat];
	[[NSUserDefaults standardUserDefaults] setDouble: region.span.longitudeDelta forKey: kMapLocationSpanLng];	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(MKMapSizeInMeters) currentBBoxSize
{
	MKMapBoundingBox bbox = [self bboxForMap];
	CLLocation* leftTop     = [[CLLocation alloc] initWithLatitude:bbox.northeast.latitude longitude:bbox.southwest.longitude];
	CLLocation* ne = [[CLLocation alloc] initWithLatitude:bbox.northeast.latitude longitude:bbox.northeast.longitude];
	CLLocation* sw = [[CLLocation alloc] initWithLatitude:bbox.southwest.latitude longitude:bbox.southwest.longitude];
	
	double distanceX = [leftTop distanceFromLocation:ne];
	double distanceY = [leftTop distanceFromLocation:sw];
	return (MKMapSizeInMeters){distanceX,distanceY};		
}

-(MKMapBoundingBox) findBBoxWithCoordinates:(NSArray*) arrayOfCoordinates
{
	
	CLLocationCoordinate2D atmLocation;
	
	float minLat = kRMMaxLatitude;
	float minLng = kRMMaxLongitude;
	
	float maxLat = kRMMinLatitude;
	float maxLng = kRMMinLongitude;	
	
	for (id obj in arrayOfCoordinates)
	{	
		//atmLocation.latitude =   atm.coordinate.latitude;
		//atmLocation.longitude =  atm.coordinate.longitude;
		
		atmLocation = [obj coordinate];
				
		minLat = (minLat > atmLocation.latitude)? atmLocation.latitude : minLat;
		minLng = (minLng > atmLocation.longitude)? atmLocation.longitude : minLng;
		
		maxLat = (maxLat < atmLocation.latitude)? atmLocation.latitude : maxLat;
		maxLng = (maxLng < atmLocation.longitude)? atmLocation.longitude : maxLng;		
	}
	
	CLLocationCoordinate2D ne = (CLLocationCoordinate2D){maxLat,maxLng};
	CLLocationCoordinate2D sw = (CLLocationCoordinate2D){minLat,minLng};
	
	return MKBoundingBoxMake(ne,sw);
	
	//LOG(@"{%f,%f,%f,%f}",maxLat,maxLng,minLat,minLng);
	
}


@end
