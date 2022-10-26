using System;
using System.Runtime.InteropServices;
using Unity.Collections.LowLevel.Unsafe;
using UnityEngine;

namespace Rendering
{
    [Serializable]
    public class MeshDistributor : IDisposable
    {
        private const string KernelName = "CSMain";
        
        private static readonly int VertsProperty = Shader.PropertyToID("_TargetVertices");
        private static readonly int IndicesProperty = Shader.PropertyToID("_TargetIndices");
        private static readonly int TrianglesProperty = Shader.PropertyToID("_TargetTriangleCount");
        private static readonly int InstancesProperty = Shader.PropertyToID("_Instances");
        private static readonly int ScaleProperty = Shader.PropertyToID("_ObjScale");
        private static readonly int TargetTRSMatrixProperty = Shader.PropertyToID("_TargetTRSMatrix");
        private static readonly int DensityProperty = Shader.PropertyToID("_Density");
        private static readonly int CameraPositionProperty = Shader.PropertyToID("_CameraPosition");
        private static readonly int CameraFrustumProperty = Shader.PropertyToID("_CameraFrustumPlanes");
        private static readonly int PlacementMapProperty = Shader.PropertyToID("_PlacementMap");
        
        [SerializeField] private ComputeShader _computeShader;
        [SerializeField] private float _scale = 1f;
        [SerializeField] private int _density = 1;
        [SerializeField] private Texture2D _placementMap;

        private ComputeBuffer _vertsBuffer;
        private ComputeBuffer _indicesBuffer;

        private int _kernel;

        private Plane[] _frustumPlanes = new Plane[6];
        private Vector4[] _frustumArray = new Vector4[6];

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        private struct Vertex
        {
            public Vector3 Position;
            public Vector3 Normal;
            public Vector2 UV;
            
            public Vertex(Vector3 pos, Vector3 norm, Vector2 uv)
            {
                Position = pos;
                Normal = norm;
                UV = uv;
            }
        }

        public void Initialize(Mesh targetMesh)
        {
            _kernel = _computeShader.FindKernel(KernelName);

            if (!_placementMap)
            {
                _placementMap = Texture2D.whiteTexture;
            }
            
            CreateMeshBuffers(targetMesh);
        }
        
        public void Execute(Camera camera, ObjectsBuffer buffer, Matrix4x4 trsMatrix)
        {
            var triangles = _indicesBuffer.count / 3;

            GeometryUtility.CalculateFrustumPlanes(camera, _frustumPlanes);
            for (var i = 0; i < _frustumPlanes.Length; i++)
            {
                _frustumArray[i] = UnsafeUtility.As<Plane, Vector4>(ref _frustumPlanes[i]);
            }
            
            _computeShader.SetBuffer(_kernel, VertsProperty, _vertsBuffer);
            _computeShader.SetBuffer(_kernel, IndicesProperty, _indicesBuffer);
            
            _computeShader.SetInt(TrianglesProperty, triangles);
            _computeShader.SetFloat(ScaleProperty, _scale);
            _computeShader.SetInt(DensityProperty, _density);

            _computeShader.SetBuffer(_kernel, InstancesProperty, buffer.Buffer);
            _computeShader.SetMatrix(TargetTRSMatrixProperty, trsMatrix);
            
            _computeShader.SetTexture(_kernel, PlacementMapProperty, _placementMap);
            
            _computeShader.SetVector(CameraPositionProperty, camera.transform.position);
            _computeShader.SetVectorArray(CameraFrustumProperty, _frustumArray);

            buffer.Buffer.SetCounterValue(0);
            _computeShader.Dispatch(_kernel, Mathf.CeilToInt(triangles / 64f), 1, 1);

            buffer.Resize();
        }
        
        public void Dispose()
        {
            _vertsBuffer?.Dispose();
            _vertsBuffer = null;
            
            _indicesBuffer?.Dispose();
            _indicesBuffer = null;
        }

        private void CreateMeshBuffers(Mesh targetMesh)
        {
            var verts = targetMesh.vertices;
            var norms = targetMesh.normals;
            var indices = targetMesh.GetIndices(0);
            var uvs = targetMesh.uv;
            
            var targetVerts = new Vertex[verts.Length];
            
            for (var i = 0; i < verts.Length; i++)
            {
                targetVerts[i] = new Vertex(verts[i], norms[i], uvs[i]);
            }
            
            _vertsBuffer = new ComputeBuffer(verts.Length, UnsafeUtility.SizeOf<Vertex>(), ComputeBufferType.Structured);
            _vertsBuffer.SetData(targetVerts);
            
            _indicesBuffer = new ComputeBuffer(indices.Length, sizeof(int), ComputeBufferType.Structured);
            _indicesBuffer.SetData(indices);
        }
    }
}
