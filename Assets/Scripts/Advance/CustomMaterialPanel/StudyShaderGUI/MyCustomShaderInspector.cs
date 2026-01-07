using UnityEditor;
using UnityEngine;

// This file should be placed in Editor folder in order to encounter problems in Packaging.
// Point 1: inherit ShaderGUI
public class MyCustomShaderInspector : ShaderGUI
{
    private Material _material;

    // private MyCustomFloatDrawer _floatDrawer = new MyCustomFloatDrawer(-3.0f, 3.0f);
    // private float _valueF;
    private bool _isShow;
    // Point 2: override OnGUI method to render Inspector panel
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // ShaderGUI already implement a default display for us   
        // base.OnGUI(materialEditor, properties);
        _material = materialEditor.target as Material;
        if (GUILayout.Button(_isShow ? "Hide Properties" : "Display Properties"))
            _isShow = !_isShow;

        if (GUILayout.Button("Reset Properties"))
        {
            _material.SetTexture("_MainTex", null);
            _material.SetFloat("_TestFloat", 0f);
        }
        _material.renderQueue = EditorGUILayout.IntField("RenderQueue", _material.renderQueue);
        
        if (_isShow)
        {
            foreach (var item in properties)
            {
                if (item.displayName == "TestFloat")
                {
                    // solution 1: use Editor development to set the properties' value
                    // _valueF = EditorGUILayout.Slider(item.displayName, _valueF, -1f, 2f);
                    // _material.SetFloat(item.name, _valueF);
                    
                    // solution 2: use the value in MaterialProperty to directly set the properties' value
                    item.floatValue = EditorGUILayout.Slider(item.displayName, item.floatValue, -1f, 1f);
                    
                    // solution 3: use the custom MaterialPropertyDrawer to display and set properties' value
                    // DON't Prefer this method : This solution just encapsulate logic again.
                    // _floatDrawer.OnGUI(EditorGUILayout.GetControlRect(), item, item.displayName, materialEditor);
                }
                else
                {
                    // this is the build-in method to display Shader properties
                    materialEditor.ShaderProperty(item, item.displayName);
                }
            }
        }

    }
}
