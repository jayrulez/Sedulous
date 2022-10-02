using System;

namespace Sedulous.Foundation.Mathematics
{
    /// <summary>
    /// Represents a frustum and provides methods for determining whether other bounding volumes intersect with it.
    /// </summary>    
    //[Serializable]
    struct BoundingFrustum : IEquatable<BoundingFrustum>, IEquatable, IHashable
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="BoundingFrustum"/> class.
        /// </summary>
        /// <param name="value">The view/projection matrix which defines the frustum.</param>
        //[JsonConstructor]
        public this(Matrix value)
        {
            this.matrix = default;
			this.Matrix = matrix;
        }

        /// <inheritdoc/>
        public override void ToString(String outStr) => 
            outStr.Append(scope $"{{Near:{Near} Far:{Far} Left:{Left} Right:{Right} Top:{Top} Bottom:{Bottom}}}");

        /// <summary>
        /// Gets the corner with the specified index.
        /// </summary>
        /// <param name="index">The index of the corner to retrieve.</param>
        /// <returns>The corner with the specified index.</returns>
        public Vector3 GetCorner(int32 index)
        {
            GetCorner(index, var result);
            return result;
        }

        /// <summary>
        /// Gets the corner with the specified index.
        /// </summary>
        /// <param name="index">The index of the corner to retrieve.</param>
        /// <param name="result">The corner with the specified index.</param>
        public void GetCorner(int32 index, out Vector3 result)
        {
            Contract.EnsureRange(index >= 0 && index < CornerCount, nameof(index));

            result = corners[index];
        }

        /// <summary>
        /// Populates the specified array with the set of points that describe the frustum's corners.
        /// </summary>
        /// <param name="array">The array to populate.</param>
        public void GetCorners(ref Vector3[CornerCount] array)
        {
            Contract.Require(array, nameof(array));
            Contract.Ensure(array.Count >= 8, nameof(array));

			for(int i = 0; i < this.corners.Count; i++){
				array[i] = this.corners[i];
			}
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> contains the specified point.
        /// </summary>
        /// <param name="point">A <see cref="Vector3"/> which represents the point to evaluate.</param>
        /// <returns>A <see cref="ContainmentType"/> value representing the relationship between this frustum and the evaluated point.</returns>
        public ContainmentType Contains(Vector3 point)
        {
            for (var plane in planes)
            {
                var dot = plane.Normal.X * point.X + plane.Normal.Y * point.Y + plane.Normal.Z + point.Z;
                if (MathUtil.IsApproximatelyGreaterThan(dot + plane.D, 0.0f))
                    return ContainmentType.Disjoint;
            }
            return ContainmentType.Contains;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> contains the specified point.
        /// </summary>
        /// <param name="point">A <see cref="Vector3"/> which represents the point to evaluate.</param>
        /// <param name="result">A <see cref="ContainmentType"/> value representing the relationship between this frustum and the evaluated point.</param>
        public void Contains(ref Vector3 point, out ContainmentType result)
        {
            for (var plane in planes)
            {
                var dot = plane.Normal.X * point.X + plane.Normal.Y * point.Y + plane.Normal.Z + point.Z;
                if (MathUtil.IsApproximatelyGreaterThan(dot + plane.D, 0.0f))
                {
                    result = ContainmentType.Disjoint;
                    return;
                }
            }
            result = ContainmentType.Contains;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> contains the specified frustum.
        /// </summary>
        /// <param name="frustum">A <see cref="BoundingFrustum"/> which represents the frustum to evaluate.</param>
        /// <returns>A <see cref="ContainmentType"/> value representing the relationship between this frustum and the evaluated frustum.</returns>
        public ContainmentType Contains(BoundingFrustum frustum)
        {
            Contains(frustum, var result);
            return result;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> contains the specified frustum.
        /// </summary>
        /// <param name="frustum">A <see cref="BoundingFrustum"/> which represents the frustum to evaluate.</param>
        /// <param name="result">A <see cref="ContainmentType"/> value representing the relationship between this frustum and the evaluated frustum.</param>
        public void Contains(BoundingFrustum frustum, out ContainmentType result)
        {
            Contract.Require(frustum, nameof(frustum));

            if (frustum == this)
            {
                result = ContainmentType.Contains;
                return;
            }

            var intersection = false;

            for (int i = 0; i < PlaneCount; i++)
            {
				var plane = this.planes[i];
                frustum.Intersects(ref plane, var intersectionType);

                if (intersectionType == PlaneIntersectionType.Front)
                {
                    result = ContainmentType.Disjoint;
                    return;
                }

                if (intersectionType == PlaneIntersectionType.Intersecting)
                    intersection = true;
            }

            result = intersection ? ContainmentType.Intersects : ContainmentType.Contains;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> contains the specified sphere.
        /// </summary>
        /// <param name="sphere">A <see cref="BoundingSphere"/> which represents the sphere to evaluate.</param>
        /// <returns>A <see cref="ContainmentType"/> value representing the relationship between this frustum and the evaluated sphere.</returns>
        public ContainmentType Contains(BoundingSphere sphere)
        {
			var sphere;
            Contains(ref sphere, var result);
            return result;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> contains the specified sphere.
        /// </summary>
        /// <param name="sphere">A <see cref="BoundingSphere"/> which represents the sphere to evaluate.</param>
        /// <param name="result">A <see cref="ContainmentType"/> value representing the relationship between this frustum and the evaluated sphere.</param>
        public void Contains(ref BoundingSphere sphere, out ContainmentType result)
        {
            var intersection = false;

            for (int i = 0; i < PlaneCount; i++)
            {
				var plane = this.planes[i];
                sphere.Intersects(ref plane, var planeIntersectionType);

                switch (planeIntersectionType)
                {
                    case PlaneIntersectionType.Front:
                        result = ContainmentType.Disjoint;
                        return;

                    case PlaneIntersectionType.Intersecting:
                        intersection = true;
                        break;

				default: break;
                }
            }

            result = intersection ? ContainmentType.Intersects : ContainmentType.Contains;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> contains the specified bounding box.
        /// </summary>
        /// <param name="box">A <see cref="BoundingBox"/> which represents the box to evaluate.</param>
        /// <returns>A <see cref="ContainmentType"/> value representing the relationship between this frustum and the evaluated box.</returns>
        public ContainmentType Contains(BoundingBox @box)
        {
			var b = @box;
            Contains(ref b, var result);
            return result;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> contains the specified bounding box.
        /// </summary>
        /// <param name="box">A <see cref="BoundingBox"/> which represents the box to evaluate.</param>
        /// <param name="result">A <see cref="ContainmentType"/> value representing the relationship between this frustum and the evaluated box.</param>
        public void Contains(ref BoundingBox @box, out ContainmentType result)
        {
            var intersects = false;

            for (int i = 0; i < PlaneCount; i++)
            {
				var plane = this.planes[i];
                @box.Intersects(ref plane, var planeIntersectionType);

                switch (planeIntersectionType)
                {
                    case PlaneIntersectionType.Front:
                        result = ContainmentType.Disjoint;
                        return;

                    case PlaneIntersectionType.Intersecting:
                        intersects = true;
                        break;
				default: break;
                }
            }

            result = intersects ? ContainmentType.Intersects : ContainmentType.Contains;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> intersects the specified ray.
        /// </summary>
        /// <param name="ray">A <see cref="Ray"/> which represents the ray to evaluate.</param>
        /// <returns>The distance along the ray at which it intersects this frustum, or <see langword="null"/> if there is no intersection.</returns>
        public float? Intersects(Ray ray)
        {
			var ray;
            Contains(ref ray.Position, var rayPositionContainmentType);

            if (rayPositionContainmentType == ContainmentType.Contains)
                return 0f;
            
            var max = float.MinValue;
            var min = float.MaxValue;

            for (var plane in planes)
            {
                var normal = plane.Normal;
                Vector3.Dot(ref ray.Direction, ref normal, var dirDotNormal);
                Vector3.Dot(ref ray.Position, ref normal, var posDotNormal);
                posDotNormal += plane.D;

                if (MathUtil.IsApproximatelyNonZero(dirDotNormal))
                {
                    var value = -posDotNormal / dirDotNormal;

                    if (dirDotNormal < 0f)
                    {
                        if (value > min)
                            return null;

                        if (value > max)
                            max = value;
                    }
                    else
                    {
                        if (value < max)
                            return null;

                        if (value < min)
                            min = value;
                    }
                }
                else
                {
                    if (posDotNormal > 0f)
                        return null;
                }
            }

            var distance = max >= 0 ? max : min;
            if (distance < 0)
                return null;

            return distance;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> intersects the specified ray.
        /// </summary>
        /// <param name="ray">A <see cref="Ray"/> which represents the ray to evaluate.</param>
        /// <param name="result">The distance along the ray at which it intersects this frustum, or <see langword="null"/> if there is no intersection.</param>
        public void Intersects(ref Ray ray, out float? result)
        {
            Contains(ref ray.Position, var rayPositionContainmentType);

            if (rayPositionContainmentType == ContainmentType.Contains)
            {
                result = 0f;
                return;
            }
            
            result = null;

            var max = float.MinValue;
            var min = float.MaxValue;

            for (var plane in planes)
            {
                var normal = plane.Normal;
                Vector3.Dot(ref ray.Direction, ref normal, var dirDotNormal);
                Vector3.Dot(ref ray.Position, ref normal, var posDotNormal);
                posDotNormal += plane.D;

                if (MathUtil.IsApproximatelyNonZero(dirDotNormal))
                {
                    var value = -posDotNormal / dirDotNormal;

                    if (dirDotNormal < 0f)
                    {
                        if (value > min)
                            return;

                        if (value > max)
                            max = value;
                    }
                    else
                    {
                        if (value < max)
                            return;

                        if (value < min)
                            min = value;
                    }
                }
                else
                {
                    if (posDotNormal > 0f)
                        return;
                }
            }

            var distance = max >= 0 ? max : min;
            if (distance < 0)
                return;

            result = distance;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> intersects the specified plane.
        /// </summary>
        /// <param name="plane">A <see cref="Plane"/> which represents the plane to evaluate.</param>
        /// <returns>A <see cref="PlaneIntersectionType"/> value which describes the relationship between this frustum and the evaluated plane.</returns>
        public PlaneIntersectionType Intersects(Plane plane)
        {
			var plane;
            var intersectFront = false;
            var intersectBack = false;

            for (int i = 0; i < CornerCount; i++)
            {
				var corner = corners[i];
                Vector3.Dot(ref corner, ref plane.Normal, var cornerDotNormal);
                if (cornerDotNormal + plane.D > 0f)
                {
                    intersectFront = true;
                }
                else
                {
                    intersectBack = true;
                }

                if (intersectFront && intersectBack)
                    return PlaneIntersectionType.Intersecting;
            }

            return intersectFront ? PlaneIntersectionType.Front : PlaneIntersectionType.Back;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> intersects the specified plane.
        /// </summary>
        /// <param name="plane">A <see cref="Plane"/> which represents the plane to evaluate.</param>
        /// <param name="result">A <see cref="PlaneIntersectionType"/> value which describes the relationship between this frustum and the evaluated plane.</param>
        public void Intersects(ref Plane plane, out PlaneIntersectionType result)
        {
            var intersectFront = false;
            var intersectBack = false;

            for (int i = 0; i < CornerCount; i++)
            {
				var corner = corners[i];
                Vector3.Dot(ref corner, ref plane.Normal, var cornerDotNormal);
                if (cornerDotNormal + plane.D > 0f)
                {
                    intersectFront = true;
                }
                else
                {
                    intersectBack = true;
                }

                if (intersectFront && intersectBack)
                {
                    result = PlaneIntersectionType.Intersecting;
                    return;
                }
            }

            result = intersectFront ? PlaneIntersectionType.Front : PlaneIntersectionType.Back;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> intersects the specified frustum.
        /// </summary>
        /// <param name="frustum">A <see cref="BoundingFrustum"/> which represents the frustum to evaluate.</param>
        /// <returns><see langword="true"/> if this frustum intersects the evaluated frustum; otherwise, <see langword="false"/>.</returns>
        public bool Intersects(BoundingFrustum frustum)
        {
            return Contains(frustum) != ContainmentType.Disjoint;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> intersects the specified frustum.
        /// </summary>
        /// <param name="frustum">A <see cref="BoundingFrustum"/> which represents the frustum to evaluate.</param>
        /// <param name="result"><see langword="true"/> if this frustum intersects the evaluated frustum; otherwise, <see langword="false"/>.</param>
        public void Intersects(BoundingFrustum frustum, out bool result)
        {
            result = Contains(frustum) != ContainmentType.Disjoint;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> intersects the specified sphere.
        /// </summary>
        /// <param name="sphere">A <see cref="BoundingSphere"/> which represents the sphere to evaluate.</param>
        /// <returns><see langword="true"/> if this frustum intersects the evaluated sphere; otherwise, <see langword="false"/>.</returns>
        public bool Intersects(BoundingSphere sphere)
        {
			var sphere;
            Contains(ref sphere, var containment);
            return (containment != ContainmentType.Disjoint);
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> intersects the specified sphere.
        /// </summary>
        /// <param name="sphere">A <see cref="BoundingSphere"/> which represents the sphere to evaluate.</param>
        /// <param name="result"><see langword="true"/> if this frustum intersects the evaluated sphere; otherwise, <see langword="false"/>.</param>
        public void Intersects(ref BoundingSphere sphere, out bool result)
        {
            Contains(ref sphere, var containment);
            result = (containment != ContainmentType.Disjoint);
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> intersects the specified bounding box.
        /// </summary>
        /// <param name="box">A <see cref="BoundingBox"/> which represents the box to evaluate.</param>
        /// <returns><see langword="true"/> if this frustum intersects the evaluated box; otherwise, <see langword="false"/>.</returns>
        public bool Intersects(BoundingBox @box)
        {
			var b = @box;
            Intersects(ref b, var result);
            return result;
        }

        /// <summary>
        /// Gets a value indicating whether this <see cref="BoundingFrustum"/> intersects the specified bounding box.
        /// </summary>
        /// <param name="box">A <see cref="BoundingBox"/> which represents the box to evaluate.</param>
        /// <param name="result"><see langword="true"/> if this frustum intersects the evaluated box; otherwise, <see langword="false"/>.</param>
        public void Intersects(ref BoundingBox @box, out bool result)
        {
			var b = @box;
            Contains(ref b, var containment);
            result = (containment != ContainmentType.Disjoint);
        }

        /// <summary>
        /// The number of corners in a <see cref="BoundingFrustum"/>.
        /// </summary>
        public const int32 CornerCount = 8;

        /// <summary>
        /// The number of planes in a <see cref="BoundingFrustum"/>.
        /// </summary>
        public const int32 PlaneCount = 6;

        /// <summary>
        /// The frustum's near plane.
        /// </summary>
        public Plane Near => planes[0];

        /// <summary>
        /// The frustum's far plane.
        /// </summary>
        public Plane Far => planes[1];

        /// <summary>
        /// The frustum's left plane.
        /// </summary>
        public Plane Left => planes[2];

        /// <summary>
        /// The frustum's right plane.
        /// </summary>
        public Plane Right => planes[3];

        /// <summary>
        /// The frustum's top plane.
        /// </summary>
        public Plane Top => planes[4];

        /// <summary>
        /// The frustum's bottom plane.
        /// </summary>
        public Plane Bottom => planes[5];

        /// <summary>
        /// The matrix which describes the frustum.
        /// </summary>
        public Matrix Matrix
        {
            get { return matrix; }
            set mut
            {
                this.matrix = value;

                this.planes[0] = Plane(
                    -this.matrix.M13,
                    -this.matrix.M23,
                    -this.matrix.M33,
                    -this.matrix.M43);

                this.planes[1] = Plane(
                    this.matrix.M13 - this.matrix.M14,
                    this.matrix.M23 - this.matrix.M24,
                    this.matrix.M33 - this.matrix.M34,
                    this.matrix.M43 - this.matrix.M44);

                this.planes[2] = Plane(
                    -this.matrix.M14 - this.matrix.M11,
                    -this.matrix.M24 - this.matrix.M21,
                    -this.matrix.M34 - this.matrix.M31,
                    -this.matrix.M44 - this.matrix.M41);

                this.planes[3] = Plane(
                    this.matrix.M11 - this.matrix.M14,
                    this.matrix.M21 - this.matrix.M24,
                    this.matrix.M31 - this.matrix.M34,
                    this.matrix.M41 - this.matrix.M44);

                this.planes[4] = Plane(
                    this.matrix.M12 - this.matrix.M14,
                    this.matrix.M22 - this.matrix.M24,
                    this.matrix.M32 - this.matrix.M34,
                    this.matrix.M42 - this.matrix.M44);

                this.planes[5] = Plane(
                    -this.matrix.M14 - this.matrix.M12,
                    -this.matrix.M24 - this.matrix.M22,
                    -this.matrix.M34 - this.matrix.M32,
                    -this.matrix.M44 - this.matrix.M42);

                NormalizePlane(ref this.planes[0]);
                NormalizePlane(ref this.planes[1]);
                NormalizePlane(ref this.planes[2]);
                NormalizePlane(ref this.planes[3]);
                NormalizePlane(ref this.planes[4]);
                NormalizePlane(ref this.planes[5]);

                CalculatePlaneIntersection(ref this.planes[0], ref this.planes[2], var intersectionNearLeft);
                CalculatePlaneIntersection(ref this.planes[3], ref this.planes[0], var intersectionRightNear);
                CalculatePlaneIntersection(ref this.planes[2], ref this.planes[1], var intersectionLeftFar);
                CalculatePlaneIntersection(ref this.planes[1], ref this.planes[3], var intersectionFarRight);

                CalculatePlaneIntersection(ref this.planes[4], ref intersectionNearLeft, out this.corners[0]);
                CalculatePlaneIntersection(ref this.planes[4], ref intersectionRightNear, out this.corners[1]);
                CalculatePlaneIntersection(ref this.planes[5], ref intersectionRightNear, out this.corners[2]);
                CalculatePlaneIntersection(ref this.planes[5], ref intersectionNearLeft, out this.corners[3]);
                CalculatePlaneIntersection(ref this.planes[4], ref intersectionLeftFar, out this.corners[4]);
                CalculatePlaneIntersection(ref this.planes[4], ref intersectionFarRight, out this.corners[5]);
                CalculatePlaneIntersection(ref this.planes[5], ref intersectionFarRight, out this.corners[6]);
                CalculatePlaneIntersection(ref this.planes[5], ref intersectionLeftFar, out this.corners[7]);
            }
        }

        /// <summary>
        /// Gets the frustum's internal array of corners.
        /// </summary>
        internal Vector3[CornerCount] CornersInternal => corners;

        /// <summary>
        /// Gets the frustum's internal array of planes.
        /// </summary>
        internal Plane[PlaneCount] PlanesInternal => planes;

        /// <summary>
        /// Normalizes the specified frustum plane.
        /// </summary>
        private static void NormalizePlane(ref Plane p)
        {
            var length = p.Normal.Length();
            p.Normal /= length;
            p.D /= length;
        }

        /// <summary>
        /// Finds the ray that represents the intersection of the specified planes.
        /// </summary>
        private static void CalculatePlaneIntersection(ref Plane p1, ref Plane p2, out Ray result)
        {
			result = default;
            result.Direction = Vector3.Cross(p1.Normal, p2.Normal);
            result.Position = Vector3.Cross(-p1.D * p2.Normal + p2.D * p1.Normal, result.Direction) / result.Direction.LengthSquared();
        }

        /// <summary>
        /// Finds the point where the specified ray intersects the specified plane.
        /// </summary>
        private static void CalculatePlaneIntersection(ref Plane p, ref Ray r, out Vector3 result)
        {
            var distance = (-p.D - Vector3.Dot(p.Normal, r.Position)) / Vector3.Dot(p.Normal, r.Direction);
            result = r.Position + r.Direction * distance;
        }

        // Property values.
        private Vector3[CornerCount] corners = .();
        private Plane[PlaneCount] planes = .();
        private Matrix matrix;
    }
}
