using System;
using System.Collections;
using System.Collections.Generic;
using ScreenPostProcess;
using UnityEngine;

public class DebugPageShiftEffect : PostProcessBase
{
    public float angleProgress = 0;
    protected override void UpdateProperty()
    {
        if(Material == null)
            return;
        Debug.Log(Material.GetFloat("_AngleProgress"));
    }

    // private void Update()
    // {
    //     if(Material == null)
    //         return;
    //     angleProgress += Time.deltaTime * 10;
    //     Material.SetFloat("_AngleProgress", angleProgress);
    // }
}
