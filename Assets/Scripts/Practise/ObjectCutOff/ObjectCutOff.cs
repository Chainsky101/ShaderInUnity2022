using System;
using System.Collections;
using System.Collections.Generic;
using ScreenPostProcess;
using UnityEngine;

[ExecuteInEditMode]
public class ObjectCutOff : MonoBehaviour
{
    public Transform cutOffObject;
    public int cutOffDir = 0;
    public int invert = -1;
    private Material _material;
    // private Vector3 _nowCutOffPos;
    // private int _nowDir = 0;
    // private int _nowInvert = -1;
    private void Start()
    {
        Renderer renderer = GetComponent<Renderer>();
        _material = renderer.sharedMaterial;
        // _nowCutOffPos = cutOffObject.position;
    }

    private void Update()
    {
        if(cutOffObject != null)
            _material.SetVector("_CutOffPos", cutOffObject.position);
        _material.SetFloat("_CutOffDir", cutOffDir);
        _material.SetFloat("_Invert", invert);
            
        // if (cutOffObject.position != _nowCutOffPos)
        // {
        //     _nowCutOffPos = cutOffObject.position;
        //     _material.SetVector("_CutOffPos", _nowCutOffPos);
        // }
        //
        // if (cutOffDir != _nowDir)
        // {
        //     _nowDir = cutOffDir;
        //     _material.SetFloat("_CutOffDir", _nowDir);
        // }
        //
        // if (invert != _nowInvert)
        // {
        //     _nowInvert = invert;
        //     _material.SetFloat("_Invert", _nowInvert);
        // }
    }
}
