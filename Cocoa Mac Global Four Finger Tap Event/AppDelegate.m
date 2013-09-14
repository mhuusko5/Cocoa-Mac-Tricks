#import "AppDelegate.h"

@implementation AppDelegate

CFMachPortRef eventTap;
int recentEvents[12] = {29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29};
NSTimer *clearRecentEventsTimer;
bool newRecentEvents;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionListenOnly, kCGEventMaskForAllEvents, handleAllEvents, (__bridge void *)(self));
    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
    
    clearRecentEventsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(clearRecentEvents) userInfo:nil repeats:YES];
}

- (void) clearRecentEvents
{
    if (!newRecentEvents)
    {
        recentEvents[0] = 29;
        recentEvents[1] = 29;
        recentEvents[2] = 29;
        recentEvents[3] = 29;
        recentEvents[4] = 29;
        recentEvents[5] = 29;
        recentEvents[6] = 29;
        recentEvents[7] = 29;
        recentEvents[8] = 29;
        recentEvents[9] = 29;
        recentEvents[10] = 29;
        recentEvents[11] = 29;
    }
    else
    {
        newRecentEvents = false;
    }
}

- (void) checkRecentEvents:(NSString *)recentEventsString
{
    if ([[NSString stringWithFormat:@"%i/%i/%i/%i/%i/%i/%i/%i/%i/%i/%i/%i/", recentEvents[0], recentEvents[1], recentEvents[2], recentEvents[3], recentEvents[4], recentEvents[5], recentEvents[6], recentEvents[7], recentEvents[8], recentEvents[9], recentEvents[10], recentEvents[11]] isEqualToString:recentEventsString])
    {
        newRecentEvents = false;
        [self clearRecentEvents];
        
        NSLog(@"Four finger trackpad tap detected!");
    }
}

- (int) occurrencesOfString:(NSString *)find inString:(NSString *)full
{
    return (int)( ([full length] - [[full stringByReplacingOccurrencesOfString:find withString:@""] length]) / [find length] );
}

- (void) handleEvent:(CGEventRef)event withType:(int)type
{
    if ((int)type != (kCGEventKeyDown | kCGEventKeyUp))
    {
        newRecentEvents = true;
        
        recentEvents[0] = recentEvents[1];
        recentEvents[1] = recentEvents[2];
        recentEvents[2] = recentEvents[3];
        recentEvents[3] = recentEvents[4];
        recentEvents[4] = recentEvents[5];
        recentEvents[5] = recentEvents[6];
        recentEvents[6] = recentEvents[7];
        recentEvents[7] = recentEvents[8];
        recentEvents[8] = recentEvents[9];
        recentEvents[9] = recentEvents[10];
        recentEvents[10] = recentEvents[11];
        recentEvents[11] = (int)type;
        
        NSString *recentEventsString = [NSString stringWithFormat:@"%i/%i/%i/%i/%i/%i/%i/%i/%i/%i/%i/%i/", recentEvents[0], recentEvents[1], recentEvents[2], recentEvents[3], recentEvents[4], recentEvents[5], recentEvents[6], recentEvents[7], recentEvents[8], recentEvents[9], recentEvents[10], recentEvents[11]];
        
        int specialOccurrence = [self occurrencesOfString:@"30/0/" inString:recentEventsString];
        int otherOccurrence = [self occurrencesOfString:@"29/" inString:recentEventsString];
        int nullOccurrence = [self occurrencesOfString:@"0/" inString:recentEventsString];
        if ( specialOccurrence == 1 && ( otherOccurrence == 10 || (otherOccurrence == 9 && nullOccurrence == 2) ) )
        {
            [self performSelector:@selector(checkRecentEvents:) withObject:recentEventsString afterDelay:0.022];
        }
    }
    else
    {
        newRecentEvents = false;
        [self clearRecentEvents];
    }
}


CGEventRef handleAllEvents(CGEventTapProxy proxy, CGEventType type, CGEventRef eventRef, void *refcon)
{
    [(__bridge AppDelegate *)refcon handleEvent:eventRef withType:(int)type];
    
    return eventRef;
}

@end
