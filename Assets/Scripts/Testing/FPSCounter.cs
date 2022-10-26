using System;
using TMPro;
using UnityEngine;

namespace Testing
{
    public class FPSCounter : MonoBehaviour
    {
        [SerializeField] private TextMeshProUGUI _text;

        private int _frameRate;

        private void Awake()
        {
            InvokeRepeating(nameof(RefreshFps), 1, 1 );
        }
        
        private void RefreshFps()
        {
            _frameRate = (int)(1f / Time.unscaledDeltaTime);
            _text.text = _frameRate.ToString();
        }
    }
}
