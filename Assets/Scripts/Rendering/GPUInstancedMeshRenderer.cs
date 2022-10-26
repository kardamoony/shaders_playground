using UnityEngine;

namespace Rendering
{
    [RequireComponent(typeof(MeshFilter))]
    public class GPUInstancedMeshRenderer : MonoBehaviour
    {
        [SerializeField] private MeshDistributor _distribution;
        [SerializeField] private ObjectsRenderer _renderer;

        private ObjectsBuffer _buffer;
        private Transform _transform;
        private Mesh _mesh;

        private void Awake()
        {
            _mesh = GetComponent<MeshFilter>().sharedMesh;
            _transform = transform;
            _buffer = _renderer.CreateBuffer();
            _distribution.Initialize(_mesh);
        }

        private void Update()
        {
            _distribution.Execute(Camera.main, _buffer, _transform.localToWorldMatrix);
            _renderer.Render(_buffer, new Bounds(_transform.position, _mesh.bounds.size));
        }

        private void OnDestroy()
        {
            _buffer.Dispose();
            _distribution.Dispose();
        }
    }
}
