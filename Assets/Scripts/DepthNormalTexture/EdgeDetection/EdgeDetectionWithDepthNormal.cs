using System.Collections;
using System.Collections.Generic;
using ScreenPostProcess;
using UnityEngine;
using UnityEngine.Serialization;

public class EdgeDetectionWithDepthNormal : PostProcessBase
{
    public float sampleDistance = 1f;
    [Range(0, 1)]
    public float edgeOnly = 0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    public float sensitivityDepth = 0.4f;
    public float sensitivityNormal = 0.4f;
    // Start is called before the first frame update
    void Start()
    {
        Camera.main.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    protected override void UpdateProperty()
    {
        if(Material == null)
            return;
        Material.SetFloat("_SampleDistance", sampleDistance);
        Material.SetFloat("_EdgeOnly", edgeOnly);
        Material.SetFloat("_SensitivityDepth", sensitivityDepth);
        Material.SetFloat("_SensitivityNormal",sensitivityNormal);
        Material.SetColor("_EdgeColor", edgeColor);
        Material.SetColor("_BackgroundColor", backgroundColor);
    }
}
