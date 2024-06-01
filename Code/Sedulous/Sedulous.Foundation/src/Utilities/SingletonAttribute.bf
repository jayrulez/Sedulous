using System;
namespace Sedulous.Foundation.Utilities;

[AttributeUsage(.Class)]
struct SingletonAttribute : Attribute, IOnTypeInit
{
	[Comptime]
	public void OnTypeInit(Type type, Self* prev)
	{
		String typeName = type.GetName(.. scope .());

		Compiler.EmitTypeBody(type, scope $"""
			
			/*private this()
			{{

			}}*/

			private static {typeName} mInstance = null;

			public static {typeName} Instance
			{{
				get
				{{
					if (mInstance == null)
						mInstance = new {typeName}();

					return mInstance;
				}}
			}}
			""");
	}
}