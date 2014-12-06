#import "LeapObjcToC.h"

//This is handwritten (non-Leap-SDK code to setup interaction with Leap, get finger locations on screen, put them in a struct and pass them off to a function in InputHandler so that the rest of the project can be C code only.
@implementation LeapObjcToC

NSRect screenFrame;

//This method starts the Leap connection, and also takes a pointer to the C function it should send data to
- (void)startSendingPointSetsToFunction:(void (*)(point pointSet[], int pointSetLength))_pointSetFunction {
	pointSetFunction = _pointSetFunction;
	leapController = [[LeapController alloc] initWithDelegate:self];
	screenFrame = [[NSScreen mainScreen] frame];
}

- (void)stopSendingPointSets {
	pointSetFunction = nil;
	leapController = nil;
}

//This is a delegate function of the Leap SDK, receives frames fromw which finger locations can be extracted
- (void)onFrame:(LeapController *)aController {
	if (pointSetFunction) {
		LeapFrame *aFrame = [aController frame:0];
		LeapHand *hand = [aFrame.hands objectAtIndex:0];
        
		NSMutableArray *fingersUnordered = [[NSMutableArray alloc] init];
		NSMutableArray *fingersFromLeftToRight = [[NSMutableArray alloc] init];
        
		[fingersUnordered addObjectsFromArray:[hand fingers]];
		while (fingersUnordered.count > 0) {
			int selectedFinger = 0;
			LeapFinger *leftFinger = [fingersUnordered objectAtIndex:0];
			for (int i = 0; i < fingersUnordered.count; i++) {
				if ([[[fingersUnordered objectAtIndex:i] tipPosition] x] <= [[leftFinger tipPosition] x]) {
					leftFinger = [fingersUnordered objectAtIndex:i];
					selectedFinger = i;
				}
			}
			[fingersFromLeftToRight addObject:leftFinger];
			[fingersUnordered removeObjectAtIndex:selectedFinger];
		}
        
		int pointSetLength = (int)hand.fingers.count;
		point *newPointSet = malloc(pointSetLength * sizeof(point));
        
		int pointIndex = 0;
		for (LeapFinger *finger in fingersFromLeftToRight) {
			point newPoint;
			newPoint.x = (int)(screenFrame.size.width / 2.0f + ([finger tipPosition].x / 100.0f) * (screenFrame.size.width / 2.0f));
			newPoint.y = (int)(-screenFrame.size.height / 4.0f + ([finger tipPosition].y / 220.f) * (screenFrame.size.height));
			newPoint.z = (int)[finger tipPosition].z;
			newPointSet[pointIndex++] = newPoint;
		}
        
		pointSetFunction(newPointSet, pointSetLength);
	}
}

@end
