using UnityEngine;

namespace ScreenPostProcess
{
    public class EditShader : MonoBehaviour
    {
        public Color color = Color.red;
        public float fresnelScale = 0.5f;

        private Renderer render;

        private Material _material;
        // Start is called before the first frame update
        void Start()
        {
            render = GetComponent<Renderer>();
            _material = render.material;
        }

        // Update is called once per frame
        void Update()
        {
            if (render is not null)
            {
                _material.SetColor("_Color", color);
                _material.SetFloat("_FresnelScale", fresnelScale);
            }
        
        }
    }
}
