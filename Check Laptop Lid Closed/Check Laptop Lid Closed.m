static bool laptopLidClosed() {
    CGDirectDisplayID builtInDisplay = 0;
    CGDirectDisplayID activeDisplays[100];
    uint32_t numActiveDisplays;
    CGGetActiveDisplayList(100, activeDisplays, &numActiveDisplays);

    while (numActiveDisplays-- > 0) {
        if (CGDisplayIsBuiltin(activeDisplays[numActiveDisplays])) {
            builtInDisplay = activeDisplays[numActiveDisplays];
            break;
        }
    }

    return (builtInDisplay == 0);
}