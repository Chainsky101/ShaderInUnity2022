using HighLevelTexture.ProceduralTexture;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace Editor
{
    [CustomEditor(typeof(GenerateProceduralTexture))]
    public class ProceduralExtend : UnityEditor.Editor
    {
        public override void OnInspectorGUI()
        {
            // base.OnInspectorGUI();
            DrawDefaultInspector();
            
            // get the script
            GenerateProceduralTexture obj = target as GenerateProceduralTexture;
            if (GUILayout.Button("UpdateTexture"))
            {
                obj.UpdateTexture();
            }
        }
    }
}