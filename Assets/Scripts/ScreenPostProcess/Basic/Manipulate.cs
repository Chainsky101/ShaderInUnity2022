using UnityEngine;

namespace ScreenPostProcess
{
    public class Manipulate : MonoBehaviour
    {
        public Color color = Color.black;
        private Renderer _renderer;

        private Material _material;
        // Start is called before the first frame update
        void Start()
        {
            _renderer = GetComponent<Renderer>();
            _material = _renderer.material;
        }

        // Update is called once per frame
        void Update()
        {
            if (_renderer is not null)
            {   
                _material.SetColor("_AddColor", color);
                
            }
        }
    }
}
