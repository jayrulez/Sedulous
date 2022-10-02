using System;
namespace Sedulous.Foundation;

enum ErrorCode
{
	Unspecified = 0,
	Argument,
	ArgumentNull,
	ArgumentOutOfRange,
	InvalidOperation,
	ObjectDisposed
}

struct Error
{
	public readonly ErrorCode Code { get; set mut; }
	public readonly String Message { get; set mut; }

	public this()
	{
		Code = .Unspecified;
		Message = null;
	}

	public this(ErrorCode code, String message = null)
	{
		Code = code;
		Message = message;
	}

	public static Error Argument(String message = null)
	{
		return .(.Argument, message);
	}

	public static Error ArgumentNull(String message = null)
	{
		return .(.ArgumentNull, message);
	}

	public static Error ArgumentOutOfRange(String message = null)
	{
		return .(.ArgumentOutOfRange, message);
	}

	public static Error InvalidOperation(String message = null)
	{
		return .(.InvalidOperation, message);
	}

	public static Error ObjectDisposed(String message = null)
	{
		return .(.ObjectDisposed, message);
	}
}

/// <summary>
/// Contains methods for enforcing code contracts and establishing invariants.
/// </summary>
static class Contract
{
	public static Result<void, Error> EnsureRange(bool condition, String message)
	{
		if (!condition)
			return .Err(.ArgumentOutOfRange(message));

		return .Ok;
	}

	public static Result<void, Error> Ensure(bool condition, String message)
	{
		if (!condition)
			return .Err(.InvalidOperation(message));

		return .Ok;
	}

	public static Result<void, Error> Ensure<TErrorCode>(bool condition, String message = null) where TErrorCode : const ErrorCode
	{
		if (!condition)
			return .Err(.(TErrorCode, message));

		return .Ok;
	}

	public static Result<void, Error> EnsureNot(bool condition, String message)
	{
		if (condition)
			return .Err(.InvalidOperation(message));

		return .Ok;
	}

	public static Result<void, Error> EnsureNot<TErrorCode>(bool condition, String message = null) where TErrorCode : const ErrorCode
	{
		if (condition)
			return .Err(.(TErrorCode, message));

		return .Ok;
	}

	public static Result<void, Error> EnsureNotDisposed<T>(T obj, bool disposed, String message = null) where T : IDisposable
	{
		if (obj == null)
			return .Err(.ArgumentNull(nameof(obj)));

		if (disposed)
			return .Err(.ObjectDisposed(message));

		return .Ok;
	}

	public static Result<void, Error> Require(void* argument, String message)
	{
		if (argument == null)
			return .Err(.ArgumentNull(message));

		return .Ok;
	}

	public static Result<void, Error> Require<T>(T argument, String message)
	{
		if (argument == null)
			return .Err(.ArgumentNull(message));

		return .Ok;
	}

	public static Result<void, Error> RequireNotEmpty(String argument, String message)
	{
	    if (argument == null)
			return .Err(.ArgumentNull(message));
	    if (argument == String.Empty)
			return .Err(.Argument(message));
		
		return .Ok;
	}

	public static Result<void, Error> RequireNotEmpty<T>(Span<T> argument, String message)
	{
	    if (argument.Ptr == null)
			return .Err(.ArgumentNull(message));
	    if (argument.Length == 0)
			return .Err(.Argument(message));
		
		return .Ok;
	}
}