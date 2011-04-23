//
//  MKViewAdditions.m
//
//  Created by Dmytro Golub on 3/27/11.
//

#import "MKMapViewAdditions.h"


#define kMapLocationLat  @"kMapLocationLat" 
#define kMapLocationLng  @"kMapLocationLng"

#define kMapLocationSpanLat @"kMapLocationSpanLat"
#define kMapLocationSpanLng @"kMapLocationSpanLng"


MKMapBoundingBox DGBoundingBoxMake(CLLocationCoordinate2D northeast,CLLocationCoordinate2D southwest)
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
	return DGBoundingBoxMake(northEastCorner,southWestCorner);
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
	region.span.latitudeDelta = [[NSUserDefaults standardUserDefaults] doubleForKey: kMapLocationSpanLng];
	
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
@end
