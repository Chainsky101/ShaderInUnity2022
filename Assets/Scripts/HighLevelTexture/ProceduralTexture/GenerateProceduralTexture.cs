using UnityEngine;

namespace HighLevelTexture.ProceduralTexture
{
    public class GenerateProceduralTexture : MonoBehaviour
    {
        public int widthTexture = 256;
        public int heightTexture = 256;
        public int countRowColumn = 8;
        public Color color1 = Color.white;
        public Color color2 = Color.black;
        // Start is called before the first frame update
        void Start()
        {
            UpdateTexture();
        }

        public void UpdateTexture()
        {
            Texture2D texture2D = new Texture2D(widthTexture, heightTexture);
            int xGridIndex, yGridIndex;
            int widthGrid = widthTexture / countRowColumn;
            int heightGrid = heightTexture / countRowColumn;
            for (int y = 0; y < heightTexture; y++)
            {
                for (int x = 0; x < widthTexture; x++)
                {
                    // calculate grid index
                    xGridIndex = x / widthGrid;
                    yGridIndex = y / heightGrid;
                    if((xGridIndex + yGridIndex) % 2 == 0)
                        texture2D.SetPixel(x, y, color1);
                    else
                    {
                        texture2D.SetPixel(x, y, color2);
                    }
                }
            }

            // apply the changes
            texture2D.Apply();
            
            // get MeshRenderer component
            MeshRenderer renderer = GetComponent<MeshRenderer>();

            if (renderer is not null)
            {
                renderer.sharedMaterial.mainTexture = texture2D;
            }

        }
    }
}
