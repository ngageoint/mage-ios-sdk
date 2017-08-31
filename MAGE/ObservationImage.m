//
//  ObservationImage.m
//  Mage
//
//

#import "ObservationImage.h"
#import "Server.h"
#import "Event.h"

const CGFloat annotationScaleWidth = 35.0;

@implementation ObservationImage

+ (NSString *) imageNameForObservation:(Observation *) observation {
    if (!observation) return nil;
    
    NSString *primaryField = [observation getPrimaryField];
    NSString *secondaryField = [observation getSecondaryField];
    NSMutableArray *iconProperties = [[NSMutableArray alloc] init];
    NSArray *observationForms = [observation.properties objectForKey:@"forms"];
    [iconProperties addObject:[[observationForms objectAtIndex:0] objectForKey:@"formId"]];
    
    NSString *rootIconFolder = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat: @"/events/icons-%@/icons", observation.eventId]];
    
    if (primaryField != nil && [[[observationForms objectAtIndex:0] objectForKey:primaryField] length]) {
        [iconProperties addObject: [[observationForms objectAtIndex:0] objectForKey:primaryField]];
    }
    if (secondaryField != nil && [[[observationForms objectAtIndex:0] objectForKey:secondaryField] length]) {
        [iconProperties addObject: [[observationForms objectAtIndex:0] objectForKey:secondaryField]];
    }
    
    BOOL foundIcon = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    while(!foundIcon) {
        NSString *iconPath = [iconProperties componentsJoinedByString:@"/"];
        NSString *directoryToSearch = [rootIconFolder stringByAppendingPathComponent:iconPath];
        if ([fileManager fileExistsAtPath:directoryToSearch]) {
            NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:[rootIconFolder stringByAppendingPathComponent:iconPath] error:nil];
            
            if ([directoryContents count] != 0) {
                for (NSString *path in directoryContents) {
                    NSString *filename = [path lastPathComponent];
                    if ([filename hasPrefix:@"icon"]) {
                        return [[rootIconFolder stringByAppendingPathComponent:iconPath] stringByAppendingPathComponent:path];
                    }
                }
            }
            
            if ([iconProperties count] == 0) {
                foundIcon = YES;
            }
            [iconProperties removeLastObject];
        } else {
            if ([iconProperties count] == 0) {
                foundIcon = YES;
            }
            [iconProperties removeLastObject];
        }
    }
    return nil;
}

+ (UIImage *) imageForObservation:(Observation *) observation {
    NSString *imagePath = [ObservationImage imageNameForObservation:observation];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (image == nil) {
        image = [UIImage imageNamed:@"defaultMarker"];
    }
    
    [image setAccessibilityIdentifier:imagePath];
    
    return image;
}


+ (UIImage *) imageForObservation:(Observation *) observation inMapView: (MKMapView *) mapView {
    UIImage *image = [self imageForObservation:observation];
    
    if (mapView != nil && image != nil) {
        float scale = image.size.width / annotationScaleWidth;
        
        UIImage *scaledImage = [UIImage imageWithCGImage:[image CGImage] scale:scale orientation:image.imageOrientation];
        return scaledImage;
    }
    
    return image;
}

@end
