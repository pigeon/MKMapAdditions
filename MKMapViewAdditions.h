//
//  MKViewAdditions.h
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

#define kMaxLong 180 
#define kMaxLat 90



MKMapBoundingBox MKBoundingBoxMake(CLLocationCoordinate2D northeast,CLLocationCoordinate2D southwest); 
NSString* NSStringFromDGDGBoundingBox(MKMapBoundingBox bbox);

@interface MKMapView (BBox) 

-(MKMapBoundingBox) bboxForMap;
-(void) removeAllAnnotations;
-(void) setBBox:(MKMapBoundingBox) bbox;

-(BOOL) isPreviousMapPositionKnown;
- (MKCoordinateRegion) loadMapPosition;
- (void) saveMapPosition;

-(MKMapSizeInMeters) currentBBoxSize;
-(MKMapBoundingBox) findBBoxWithCoordinates:(NSArray*) arrayOfCoordinates;

@end
