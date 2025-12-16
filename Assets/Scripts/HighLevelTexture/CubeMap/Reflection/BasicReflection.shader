Shader "Unlit/BasicReflection"
{
    Properties
    {
        _CubeMap("CubeMap", Cube) = "white"{}
        _Reflectivity("Reflectivity", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "Forwardbase"
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            samplerCUBE _CubeMap;
            fixed _Reflectivity;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 reflectWorldDir : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                fixed3 normal = UnityObjectToWorldNormal(v.normal);
                float3 vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                fixed3 viewWorldDir = UnityWorldSpaceViewDir(vertexWorldPos);
                // viewWorldDir's direction is from vertex to camera, need to be reverted
                o.reflectWorldDir = normalize(reflect(-viewWorldDir, normal));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 texColor = texCUBE(_CubeMap, i.reflectWorldDir);
                return  texColor* _Reflectivity;
            }
            ENDCG
        }
    }
}
