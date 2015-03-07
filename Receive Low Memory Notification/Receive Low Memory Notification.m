static dispatch_source_t source;
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
	source = dispatch_source_create(DISPATCH_SOURCE_TYPE_MEMORYPRESSURE, 0, DISPATCH_MEMORYPRESSURE_WARN | DISPATCH_MEMORYPRESSURE_CRITICAL, dispatch_get_main_queue());
	
	dispatch_source_set_event_handler(source, ^{
		dispatch_source_memorypressure_flags_t pressureLevel = dispatch_source_get_data(source);
		
		NSLog(@"Received memory warning with pressure: %@", @(pressureLevel).description);
	});
	
	dispatch_resume(source);
});