using System;

namespace SDL2Native
{
	[CRepr, Union]
	struct SDL_Event
	{
		public SDL_EventType type;

		public SDL_CommonEvent common;

		public SDL_WindowEvent window;

		public SDL_KeyboardEvent key;

		public SDL_TextEditingEvent edit;

		public SDL_TextInputEvent text;

		public SDL_MouseMotionEvent motion;

		public SDL_MouseButtonEvent button;

		public SDL_MouseWheelEvent wheel;

		public SDL_JoyAxisEvent jaxis;

		public SDL_JoyBallEvent jball;

		public SDL_JoyHatEvent jhat;

		public SDL_JoyButtonEvent jbutton;

		public SDL_JoyDeviceEvent jdevice;

		public SDL_ControllerAxisEvent caxis;

		public SDL_ControllerButtonEvent cbutton;

		public SDL_ControllerDeviceEvent cdevice;

		public SDL_QuitEvent quit;

		public SDL_UserEvent user;

		public SDL_TouchFingerEvent tfinger;

		public SDL_MultiGestureEvent mgesture;

		public SDL_DollarGestureEvent dgesture;

		public SDL_DropEvent drop;
	}
}
