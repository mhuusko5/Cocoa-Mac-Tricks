#include "AppDelegate.h"

//This function uses objective-c runtimes operations (in C!) to start a full-on Cocoa NSApplication, but with no Objective-C, no NIB, nothing
extern id NSApp;
void runApplication(id appDelegate) {
	objc_msgSend(objc_getClass("NSApplication"), sel_getUid("sharedApplication"));
    
	objc_msgSend(NSApp, sel_getUid("setDelegate:"), appDelegate);
	objc_msgSend(NSApp, sel_getUid("run"));
}

//Main sets up the AppDelegate "class" which does need to exist, but then also just sets up the AppDelegate C environment
int main(int argc, char *argv[]) {
	id appDelegate = AppDelegateClass_registerAllocInit();
	AppDelegate_create();
    
	runApplication(appDelegate);
    
	AppDelegate_destroy();
    
	return EXIT_SUCCESS;
}
