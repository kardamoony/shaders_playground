using System;
using UnityEngine;

namespace Rendering
{
    [Serializable]
    public class ObjectsRenderer
    {
        private static readonly int InstancesProperty = Shader.PropertyToID("_Instances");
        
        [SerializeField] private Material _material;
        [SerializeField] private Mesh _mesh;
        
        public ObjectsBuffer CreateBuffer()
        {
            var subMesh = _mesh.GetSubMesh(0);
            return new ObjectsBuffer(100, subMesh.indexCount, subMesh.indexStart, subMesh.baseVertex, 0);
        }

        public void Render(ObjectsBuffer buffer, in Bounds bounds)
        {
            _material.SetBuffer(InstancesProperty, buffer.Buffer);
            Graphics.DrawMeshInstancedIndirect(_mesh, 0, _material, bounds, buffer.CountBuffer);
        }
    }
}