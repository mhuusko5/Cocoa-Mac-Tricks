#include "DrawingView.h"

#ifndef LeapCDrawing_InputHandler_h
#define LeapCDrawing_InputHandler_h

typedef struct {
	int x;
	int y;
	int z;
} point;

void *InputHandler_create(void (*_passInput)(cursor cursorSet[], int cursorSetLength));
void InputHandler_destroy();
void InputHandler_receivePointSet(point pointSet[], int pointSetLength);

#endif
