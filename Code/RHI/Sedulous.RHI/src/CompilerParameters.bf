using System.IO;

namespace Sedulous.RHI;

/// <summary>
/// This struct represents the parameters used by the shader compiler.
/// </summary>
public struct CompilerParameters
{
	/// <summary>
	/// The available device capabilities. See <see cref="T:Sedulous.RHI.GraphicsProfile" />.
	/// </summary>
	public GraphicsProfile Profile;

	/// <summary>
	/// The compiler mode. See <see cref="F:Sedulous.RHI.CompilerParameters.CompilationMode" />.
	/// </summary>
	public CompilationMode CompilationMode;

	/// <summary>
	/// Gets the default values for CompilerParameters.
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
	/// Default values for CompilerParameters.
	/// </summary>
	public void SetDefault() mut
	{
		Profile = /*GraphicsProfile*/.Level_10_0;
		CompilationMode = /*CompilationMode*/.None;
	}
}
