using System;
using UnityEngine;

namespace ScreenPostProcess
{
    // usually bound on camera
    public class PostProcess : MonoBehaviour
    {
        public Material material;
        // Start is called before the first frame update
        void Start()
        {
        
        }

        // Update is called once per frame
        void Update()
        {
        
        }

        private void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            // copy texture from source to destination
            // Graphics.Blit(source, destination);
            Graphics.Blit(source, destination, material);
            
        }
    }
}
