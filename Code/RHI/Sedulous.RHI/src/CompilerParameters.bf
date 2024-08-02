using System.IO;

namespace Sedulous.RHI;

/// <summary>
/// This struct represent the parameters used by the shader compiler.
/// </summary>
public struct CompilerParameters
{
	/// <summary>
	/// The available device capabilities, <see cref="T:Sedulous.RHI.GraphicsProfile" />.
	/// </summary>
	public GraphicsProfile Profile;

	/// <summary>
	/// The compiler mode, <see cref="F:Sedulous.RHI.CompilerParameters.CompilationMode" />.
	/// </summary>
	public CompilationMode CompilationMode;

	/// <summary>
	/// Gets default values for CompilerParameters.
	/// </summary>
	public static CompilerParameters Default
	{
		get
		{
			CompilerParameters defaultInstance = default(CompilerParameters);
			defaultInstance.SetDefault();
			return defaultInstance;
		}
	}

	/// <summary>
	/// Default CompilerParameters values.
	/// </summary>
	public void SetDefault() mut
	{
		Profile = /*GraphicsProfile*/.Level_10_0;
		CompilationMode = /*CompilationMode*/.None;
	}
}
