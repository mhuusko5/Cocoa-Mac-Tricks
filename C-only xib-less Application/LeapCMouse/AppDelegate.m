#include "AppDelegate.h"

//This does objective-c runtime magic to act like a normal cocoa app
Class AppDelegateClass;
id appDelegateInstance;
id AppDelegateClass_registerAllocInit() {
	AppDelegateClass = objc_allocateClassPair(objc_getClass("NSObject"), "AppDelegate", 0);
    
	class_addMethod(AppDelegateClass, sel_getUid("applicationDidFinishLaunching:"), (IMP)AppDelegateClass_didFinishLaunching, "i@:@");
    
	objc_registerClassPair(AppDelegateClass);
    
	appDelegateInstance = objc_msgSend(objc_msgSend(objc_getClass("AppDelegate"), sel_getUid("alloc")), sel_getUid("init"));
    
	return appDelegateInstance;
}

//So does this, also creating a single window and view – once again, all behind the scenes c-calls
static BOOL AppDelegateClass_didFinishLaunching(struct AppDelegate *self, SEL _cmd, id notification) {
	self->window = objc_msgSend(objc_getClass("NSWindow"), sel_getUid("alloc"));
    
	id mainScreen = objc_msgSend(objc_getClass("NSScreen"), sel_getUid("mainScreen"));
	NSRect screenFrame = ((NSRect (*)(id, SEL, NSString *))objc_msgSend_stret)(mainScreen, sel_getUid("frame"), nil);
	NSRect visibleFrame = ((NSRect (*)(id, SEL, NSString *))objc_msgSend_stret)(mainScreen, sel_getUid("frame"), nil);
	screenFrame.size.height = visibleFrame.size.height;
    
	self->window = objc_msgSend(self->window, sel_getUid("initWithContentRect:styleMask:backing:defer:"), screenFrame, (NSBorderlessWindowMask), NSBackingStoreBuffered, NO);
    
	objc_msgSend(self->window, sel_getUid("setCollectionBehavior:"), NSWindowCollectionBehaviorCanJoinAllSpaces);
	objc_msgSend(self->window, sel_getUid("setLevel:"), NSFloatingWindowLevel);
	objc_msgSend(self->window, sel_getUid("setIgnoresMouseEvents:"), YES);
	objc_msgSend(self->window, sel_getUid("setOpaque:"), NO);
	objc_msgSend(self->window, sel_getUid("setMovableByWindowBackground:"), NO);
	objc_msgSend(self->window, sel_getUid("setBackgroundColor:"), objc_msgSend(objc_getClass("NSColor"), sel_getUid("clearColor")));
    
	//Creates the view "class" and adds it to the window
	objc_msgSend(self->window, sel_getUid("setContentView:"), DrawingViewClass_registerAllocInit(screenFrame));
    
	objc_msgSend(self->window, sel_getUid("becomeFirstResponder"));
	objc_msgSend(self->window, sel_getUid("makeKeyAndOrderFront:"), self);
    
	return YES;
}

//None of the below code actually has to do with the AppDelegate class at runtime, but are related functions
id leapObjcToC;

//Handles intiating to the Leap objective-c to c bridge, and starts it with a pointer to the c InputHandler function, after setuping up the InputHandler file with a pointer to the DrawingView function to pass draw data to
void AppDelegate_create() {
	leapObjcToC = objc_msgSend(objc_msgSend(objc_getClass("LeapObjcToC"), sel_getUid("alloc")), sel_getUid("init"));
	objc_msgSend(leapObjcToC, sel_getUid("startSendingPointSetsToFunction:"), InputHandler_create(DrawingView_create()));
}

//Cleans up
void AppDelegate_destroy() {
	objc_msgSend(leapObjcToC, sel_getUid("stopSendingPointSets"));
	free(leapObjcToC);
	DrawingView_destroy();
	InputHandler_destroy();
	free(appDelegateInstance);
}
