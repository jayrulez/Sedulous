using System;

namespace Sedulous.GAL
{
    /// <summary>
    /// Describes a <see cref="CommandList"/>, for creation using a <see cref="ResourceFactory"/>.
    /// </summary>
    public struct CommandListDescription : IEquatable<CommandListDescription>
    {
        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="other">The instance to compare to.</param>
        /// <returns>True if all elements are equal; false otherswise.</returns>
        public bool Equals(CommandListDescription other)
        {
            return true;
        }
    }
}