using UnityEditor;
using UnityEngine;
using UnityEngine.Windows;

// enum E_NoiseTexture
// {
//     Perlin,
//     Simple,
//     Random,
//     Fractal,
//     Worley
// }
public class GenerateNoiseTextureTool : EditorWindow
{
    private int _width = 512;
    private int _height = 512;
    private int _scale = 20;
    private string _nameTex = "TextureName";

    private int _type = 0;
    // private string path = "/Asset/Art/RandomNoise/";
    [MenuItem("GenerateTexture/Berlin Noise Texture")]
    private static void OpenWindow()
    {
        GetWindow<GenerateNoiseTextureTool>().Show();
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("Perlin Noise Texture Settings:");
        _width = EditorGUILayout.IntField("Texture Width", _width);
        _height = EditorGUILayout.IntField("Texture Height", _height);
        _height = EditorGUILayout.IntField("Texture Height", _height);
        _scale = EditorGUILayout.IntField("Texture Scale", _scale);
        _type = EditorGUILayout.Popup("Noise Texture Type", _type,new string[]{"Perlin","Simple","Random","Fractal","Worley"});
        _nameTex = EditorGUILayout.TextField("Texture Name", _nameTex);
        if (GUILayout.Button("Generate Berlin Noise Texture"))
        {
            Texture2D texture = null;
            switch (_type)
            {
                case 0:
                    texture = GeneratePerlinNoiseTexture(_width, _height);
                    break;
                case 1:
                    break;
                case 2:
                    break;
                case 3:
                    break;
                case 4:
                    break;
            }
            // save the file
            string path = EditorUtility.SaveFilePanel("Save Texture", "Assets/Art/RandomNoise/", _nameTex, "png");
            File.WriteAllBytes(path, texture.EncodeToPNG());
            AssetDatabase.Refresh();

            EditorUtility.DisplayDialog("Result", "Generate Noise Texture Success", "sure", "close");
        }
    }

    private Texture2D GeneratePerlinNoiseTexture(int width, int height)
    {
        Texture2D texture = new Texture2D(_width, _height);
        float factor = 0;
        for (int j = 0; j < _height; j++)
        {
            for (int i = 0; i < _width; i++)
            {
                factor = Mathf.PerlinNoise((float)i / _width * _scale, (float)j / _height * _scale);
                // set pixels color
                texture.SetPixel(i, j, factor * new Color(1,1,1));
                // texture.SetPixel(i, j, color);
            }
        }
        // apply the edit in the texture
        texture.Apply();
        return texture;
    }
}
