using Sedulous.Foundation.Messaging;
using SDL2;
using System;
namespace Sedulous.SDL.Messages;

/// <summary>
/// Represents the message data for an SDL2Event message.
/// </summary>
[Reflect(.DefaultConstructor), AlwaysInclude(AssumeInstantiated=true)]
public sealed class SDLEventMessageData : MessageData
{
	public this() : base()
	{
	}

	/// <summary>
	/// Gets or sets the SDL event data.
	/// </summary>
	public SDL.Event Event { get; set; }
}