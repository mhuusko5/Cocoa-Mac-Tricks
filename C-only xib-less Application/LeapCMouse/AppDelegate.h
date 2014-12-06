#include <objc/runtime.h>
#include <objc/message.h>

#include "InputHandler.h"
#include "DrawingView.h"

#ifndef LeapCDrawing_AppDelegate_h
#define LeapCDrawing_AppDelegate_h

struct AppDelegate
{
	Class isa;
	id window;
};

id AppDelegateClass_registerAllocInit();
static BOOL AppDelegateClass_didFinishLaunching(struct AppDelegate *self, SEL _cmd, id notification);
void AppDelegate_create();
void AppDelegate_destroy();

#endif
