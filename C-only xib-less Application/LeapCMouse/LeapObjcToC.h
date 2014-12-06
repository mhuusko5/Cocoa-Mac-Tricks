#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"

typedef struct {
	int x;
	int y;
	int z;
} point;

@interface LeapObjcToC : NSObject {
	void (*pointSetFunction)(point pointSet[], int pointSetLength);
	LeapController *leapController;
}

- (void)startSendingPointSetsToFunction:(void (*)(point pointSet[], int pointSetLength))_pointSetFunction;
- (void)stopSendingPointSets;
- (void)onFrame:(LeapController *)aController;

@end
