#include "InputHandler.h"

//A pointer to the function to send draw data (cursor data, since this is a mouse control app)
void (*passInput)(cursor cursorSet[], int cursorSetLength);

NSRect screenFrame;

void *InputHandler_create(void (*_passInput)(cursor cursorSet[], int cursorSetLength)) {
	passInput = _passInput;
	screenFrame = ((NSRect (*)(id, SEL, NSString *))objc_msgSend_stret)(objc_msgSend(objc_getClass("NSScreen"), sel_getUid("mainScreen")), sel_getUid("frame"), nil);
    
	return &InputHandler_receivePointSet;
}

void InputHandler_destroy() {
}

int stillClicked = 0;
CFAbsoluteTime lastClickTime;

//The important taking of leap finger data, and making that useful for mouse control
//Will take up to five fingers, and pass that along as draw data
//If one finger present, moves the mouse to that location
//If a second finger (thumb) comes into view after that one finger, that counts as a click
//If that thumb stays out for more than .5 secs, that is a right click
//Actually works decently
void InputHandler_receivePointSet(point pointSet[], int pointSetLength) {
	if ((CFAbsoluteTimeGetCurrent() - lastClickTime) >= 0.04) {
		cursor *newCursorSet = malloc(pointSetLength * sizeof(cursor));
		for (int i = 0; i < pointSetLength; i++) {
			cursor newCursor;
			newCursor.x = pointSet[i].x;
			newCursor.y = pointSet[i].y;
			newCursor.active = 0;
			newCursorSet[i] = newCursor;
		}
        
		if (pointSetLength <= 2) {
			CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
			CGPoint mouseLocation = CGPointMake(newCursorSet[pointSetLength - 1].x + 10, (screenFrame.size.height - newCursorSet[pointSetLength - 1].y) - 10);
            
			//Only use new mouse location if on screen
			if (mouseLocation.x >= 0 && mouseLocation.x <= screenFrame.size.width && mouseLocation.y >= 0 && mouseLocation.y <= screenFrame.size.height) {
				CGEventRef mouse = CGEventCreateMouseEvent(source, kCGEventMouseMoved, mouseLocation, 0);
				CGEventPost(kCGHIDEventTap, mouse);
				CFRelease(mouse);
                
				if (pointSetLength == 2) {
					//A necessary check to see if thumb is reasonably horizontally aligned with index finger
					//This is because thumb when aimed down can fligger out of view a lot, causing lots of clicks
					if (abs(newCursorSet[0].y - newCursorSet[1].y) <= (screenFrame.size.height) / 10.0) {
						if (!stillClicked) {
							newCursorSet[1].active = 1;
                            
							//C Carbon api calls to click and release mouse
							CGEventRef mouseDown = CGEventCreateMouseEvent(source, kCGEventLeftMouseDown, mouseLocation, 0);
							CGEventPost(kCGHIDEventTap, mouseDown);
							CFRelease(mouseDown);
                            
							CGEventRef mouseUp = CGEventCreateMouseEvent(source, kCGEventLeftMouseUp, mouseLocation, 0);
							CGEventPost(kCGHIDEventTap, mouseUp);
							CFRelease(mouseUp);
                            
							//Keep track of click time, for not having immediate another click, and to detect right clicks
							lastClickTime = CFAbsoluteTimeGetCurrent();
							stillClicked = 1;
						}
						else if ((CFAbsoluteTimeGetCurrent() - lastClickTime) >= 0.5) {
							newCursorSet[1].active = 1;
                            
							CGEventRef mouseDown = CGEventCreateMouseEvent(source, kCGEventRightMouseDown, mouseLocation, 0);
							CGEventPost(kCGHIDEventTap, mouseDown);
							CFRelease(mouseDown);
                            
							CGEventRef mouseUp = CGEventCreateMouseEvent(source, kCGEventRightMouseUp, mouseLocation, 0);
							CGEventPost(kCGHIDEventTap, mouseUp);
							CFRelease(mouseUp);
                            
							lastClickTime = CFAbsoluteTimeGetCurrent();
							stillClicked = 1;
						}
					}
				}
				else {
					stillClicked = 0;
				}
			}
		}
        
		//Pass input to the drawing function
		passInput(newCursorSet, pointSetLength);
	}
}
