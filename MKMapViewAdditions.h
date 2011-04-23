//
//  MKViewAdditions.h
//
//  Created by Dmytro Golub on 3/27/11.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>



typedef struct {
	CLLocationCoordinate2D northeast;
	CLLocationCoordinate2D southwest;
} MKMapBoundingBox;

typedef struct {
	double width;
	double height;
} MKMapSizeInMeters;


MKMapBoundingBox DGBoundingBoxMake(CLLocationCoordinate2D northeast,CLLocationCoordinate2D southwest); 
NSString* NSStringFromDGDGBoundingBox(MKMapBoundingBox bbox);

@interface MKMapView (BBox) 

-(MKMapBoundingBox) bboxForMap;
-(void) removeAllAnnotations;
-(void) setBBox:(MKMapBoundingBox) bbox;

-(BOOL) isPreviousMapPositionKnown;
- (MKCoordinateRegion) loadMapPosition;
- (void) saveMapPosition;

-(MKMapSizeInMeters) currentBBoxSize;


@end
