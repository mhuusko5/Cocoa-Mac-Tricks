#include <objc/runtime.h>
#include <objc/message.h>
#include <ApplicationServices/ApplicationServices.h>
#include <AppKit/AppKit.h>

#ifndef LeapCDrawing_DrawingView_h
#define LeapCDrawing_DrawingView_h

typedef struct {
	int x;
	int y;
	int active;
} cursor;

id DrawingViewClass_registerAllocInit(NSRect frame);
static void DrawingViewClass_drawRect(id _self, SEL _cmd, CGRect rect);
void DrawingView_updateDraw(cursor cursorSet[], int cursorSetLength);
void *DrawingView_create();
void DrawingView_destroy();

#endif
