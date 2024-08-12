using System;
﻿using System.Diagnostics;
using System.Text;
using Sedulous.OpenGLBindings;
using static Sedulous.OpenGLBindings.OpenGLNative;

namespace Sedulous.GAL.OpenGL
{
    internal static class OpenGLUtil
    {
        private static int32? MaxLabelLength;

        [Conditional("DEBUG")]
        [DebuggerNonUserCode]
        internal static void CheckLastError()
        {
            uint32 error = glGetError();
            if (error != 0)
            {
                if (Debugger.IsAttached)
                {
                    Debugger.Break();
                }

                throw new VeldridException("glGetError indicated an error: " + (ErrorCode)error);
            }
        }

        internal static void SetObjectLabel(ObjectLabelIdentifier identifier, uint32 target, string name)
        {
            if (HasGlObjectLabel)
            {
                int32 byteCount = Encoding.UTF8.GetByteCount(name);
                if (MaxLabelLength == null)
                {
                    int32 maxLabelLength = -1;
                    glGetIntegerv(GetPName.MaxLabelLength, &maxLabelLength);
                    CheckLastError();
                    MaxLabelLength = maxLabelLength;
                }
                if (byteCount >= MaxLabelLength)
                {
                    name = name.Substring(0, MaxLabelLength.Value - 4) + "...";
                    byteCount = Encoding.UTF8.GetByteCount(name);
                }

                Span<uint8> utf8bytes = stackalloc uint8[128];
                if(byteCount + 1 > 128) utf8bytes = new uint8[byteCount + 1];

                fixed (char* namePtr = name)
                fixed (uint8* utf8bytePtr = utf8bytes)
                {
                    int32 written = Encoding.UTF8.GetBytes(namePtr, name.Length, utf8bytePtr, byteCount);
                    utf8bytePtr[written] = 0;
                    glObjectLabel(identifier, target, (uint32)byteCount, utf8bytePtr);
                    CheckLastError();
                }
            }
        }

        internal static TextureTarget GetTextureTarget(OpenGLTexture glTex, uint32 arrayLayer)
        {
            if ((glTex.Usage & TextureUsage.Cubemap) == TextureUsage.Cubemap)
            {
                switch (arrayLayer % 6)
                {
                    case 0:
                        return TextureTarget.TextureCubeMapPositiveX;
                    case 1:
                        return TextureTarget.TextureCubeMapNegativeX;
                    case 2:
                        return TextureTarget.TextureCubeMapPositiveY;
                    case 3:
                        return TextureTarget.TextureCubeMapNegativeY;
                    case 4:
                        return TextureTarget.TextureCubeMapPositiveZ;
                    case 5:
                        return TextureTarget.TextureCubeMapNegativeZ;
                }
            }

            return glTex.TextureTarget;
        }
    }
}
