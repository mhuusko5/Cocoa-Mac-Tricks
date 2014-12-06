#include "DrawingView.h"

//This is necessary C boilerplate code to actually setup the drawing objective-c class at runtime
Class DrawingViewClass;
id drawingViewInstance;
id DrawingViewClass_registerAllocInit(NSRect frame) {
	DrawingViewClass = objc_allocateClassPair((Class)objc_getClass("NSView"), "DrawingView", 0);
    
	class_addMethod(DrawingViewClass, sel_getUid("drawRect:"), (IMP)DrawingViewClass_drawRect, "v@:");
    
	objc_registerClassPair(DrawingViewClass);
    
	drawingViewInstance = objc_msgSend(objc_msgSend(objc_getClass("DrawingView"), sel_getUid("alloc")), sel_getUid("initWithFrame:"), frame);
    
	return drawingViewInstance;
}

cursor *currentCursorSet;
int currentCursorSetLength;

//This drawrect class is what is attached to the definition of the view class, for drawing, all C
static void DrawingViewClass_drawRect(id _self, SEL _cmd, CGRect rect) {
	drawingViewInstance = _self;
    
	for (int i = 0; i < currentCursorSetLength; i++) {
		if (currentCursorSet[i].active) {
			objc_msgSend(objc_msgSend(objc_getClass("NSColor"), sel_getUid("greenColor")), sel_getUid("setFill"));
		}
		else {
			objc_msgSend(objc_msgSend(objc_getClass("NSColor"), sel_getUid("colorWithCalibratedWhite:alpha:"), 0.2, 0.7), sel_getUid("setFill"));
		}
        
		NSRect rect = NSMakeRect(currentCursorSet[i].x, currentCursorSet[i].y, 20, 20);
		id circlePath = objc_msgSend(objc_getClass("NSBezierPath"), sel_getUid("bezierPath"));
		objc_msgSend(circlePath, sel_getUid("appendBezierPathWithOvalInRect:"), rect);
		objc_msgSend(circlePath, sel_getUid("fill"));
	}
}

//The below function ar not specific to the view class at runtime, but in the same file for convenience

//Receives draw data, sets it, and tell the view class to redraw, since it doesn't happen automatically like it would in a normal cocoa class
void DrawingView_updateDraw(cursor cursorSet[], int cursorSetLength) {
	currentCursorSet = cursorSet;
	currentCursorSetLength = cursorSetLength;
    
	objc_msgSend(drawingViewInstance, sel_getUid("setNeedsDisplay:"), YES);
}

//Just returns appropriate function pointer for drawing
void *DrawingView_create() {
	return &DrawingView_updateDraw;
}

//Cleans up
void DrawingView_destroy() {
	free(currentCursorSet);
	free(drawingViewInstance);
}
