using UnityEngine;

namespace Testing
{
    [ExecuteInEditMode]
    public class VisualizeCrossProduct : MonoBehaviour
    {
        private void OnDrawGizmos()
        {
            Gizmos.matrix = transform.localToWorldMatrix;
            
            Gizmos.color = Color.blue;
            Gizmos.DrawRay(Vector3.zero, transform.forward * 3f);
            
            Gizmos.color = Color.green;
            Gizmos.DrawRay(Vector3.zero, transform.up * 3f);
            
            Gizmos.color = Color.red;
            Gizmos.DrawRay(Vector3.zero, transform.right * 3f);

            var t = Vector3.Cross(transform.up, transform.forward);
            var c = Vector3.Cross(transform.forward, t);
            
            Gizmos.color = Color.cyan;
            Gizmos.DrawRay(Vector3.zero, t * 1.5f);
            
            Gizmos.color = Color.magenta;
            Gizmos.DrawRay(Vector3.zero, c * 1.5f);
        }
    }
}
