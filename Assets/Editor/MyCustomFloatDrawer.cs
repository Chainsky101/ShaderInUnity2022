using UnityEditor;
using UnityEngine;

namespace Advance.CustomMaterialPanel.StudyMaterialPropertyDrawer
{
    // Point 1: The class inherited from MaterialPropertyDrawer must end with "Drawer".
    // Point 2: This type of class always applied independently.
    //          This means that this class is directly used in Shader file.(Sometimes it will throw error.)
    public class MyCustomFloatDrawer : MaterialPropertyDrawer
    {
        private float _min;
        private float _max;

        public MyCustomFloatDrawer(float min, float max)
        {
            _max = max;
            _min = min;
        }
        
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            // base.OnGUI(position, prop, label, editor);
            if (prop.type != MaterialProperty.PropType.Float)
            {
                EditorGUILayout.LabelField(label, "Only float type can ues this drawer, please try another.");
            }

            prop.floatValue = EditorGUILayout.Slider(label, prop.floatValue, _min, _max);
        }
    }
}