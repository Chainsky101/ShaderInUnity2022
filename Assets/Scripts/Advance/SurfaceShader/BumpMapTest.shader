Shader "Custom/BumpMapTest"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("BumpMap", 2D) = "white" {}
//        _MyEmission ("MyEmission", Color) = (1,1,1,1)
        _Metallic ("Metallic", Range(0,1)) = 0.2
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _ExpandSize ("ExpandSize", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vertexFunc //finalcolor:finalcolorFunc

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color;
        sampler2D _BumpMap;
        // fixed4 _MyEmission;
        fixed _Metallic;
        fixed _Smoothness;
        float _ExpandSize;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };


        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 col = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = col.rgb * _Color.rgb;
            o.Alpha = col.a * _Color.a;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Metallic = _Metallic;
            // o.Emission = _MyEmission;
            o.Smoothness = _Smoothness;
        }

        // vertex function
        void vertexFunc(inout appdata_full v)
        {
            v.vertex.xyz += v.normal * _ExpandSize;
        }

        // final color function
        // void finalcolorFunc(Input IN, in SurfaceOutputStandard o, inout fixed4 color)
        // {
        //     color.xyz = o.Albedo * _Color.xyz;
        // }
        ENDCG
    }
    FallBack "Diffuse"
}