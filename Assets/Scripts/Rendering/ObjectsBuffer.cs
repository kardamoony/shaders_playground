using System;
using Unity.Collections.LowLevel.Unsafe;
using UnityEngine;
using UnityEngine.Rendering;

namespace Rendering
{
    public struct ObjectInstance
    {
        public Matrix4x4 TRSMatrix;
        public float Variation;
    }

    public class ObjectsBuffer : IDisposable
    {
        private bool _isReadbackStarted;
        
        public ComputeBuffer Buffer { get; private set; }
        public ComputeBuffer CountBuffer { get; private set; }

        public ObjectsBuffer(int count, int meshIndicesCount, int startIndexLocation, int baseVertexLocation, int startInstanceLocation)
        {
            CountBuffer = CreateCountBuffer(meshIndicesCount, startIndexLocation, baseVertexLocation, startInstanceLocation);
            Buffer = CreateObjectsBuffer(count);
        }

        public void Dispose()
        {
            Buffer?.Dispose();
            Buffer = null;
            
            CountBuffer?.Dispose();
            CountBuffer = null;
        }

        public void Resize()
        {
            ComputeBuffer.CopyCount(Buffer, CountBuffer, sizeof(int));
            
            if (_isReadbackStarted) return;
            AsyncGPUReadback.Request(CountBuffer, sizeof(int), sizeof(int), ReadbackHandler);
        }

        private void ReadbackHandler(AsyncGPUReadbackRequest readbackRequest)
        {
            _isReadbackStarted = false;
            if (Buffer == null || !Buffer.IsValid()) return;

            using var data = readbackRequest.GetData<int>();
            var count = data[0];
            if (count <= Buffer.count) return;
                
            Buffer?.Dispose();
            Buffer = CreateObjectsBuffer(count);
        }

        private ComputeBuffer CreateObjectsBuffer(int count)
        {
            return new ComputeBuffer(count, UnsafeUtility.SizeOf<ObjectInstance>(), ComputeBufferType.Append);
        }

        private ComputeBuffer CreateCountBuffer(int meshIndicesCount, int startIndexLocation, int baseVertexLocation, int startInstanceLocation)
        {
            var buffer = new ComputeBuffer(5, sizeof(int), ComputeBufferType.IndirectArguments);
            
            buffer.SetData(new []
            {
                meshIndicesCount, 0, startIndexLocation, baseVertexLocation, startInstanceLocation
            });

            return buffer;
        }
    }
}