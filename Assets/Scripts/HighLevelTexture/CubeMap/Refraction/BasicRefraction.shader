Shader "Unlit/BasicRefraction"
{
    Properties
    {
        _CubeMap("CubeMap", Cube) = "white"{}
        _Refractivity("Refractivity", Range(0, 1)) = 1
        _RefractiveIndex1("RefractiveIndex1", Range(1, 2)) = 1
        _RefractiveIndex2("RefractiveIndex2", Range(1, 2)) = 1.3
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"

            struct v2f
            {
                fixed3 refractWorldDir : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            samplerCUBE _CubeMap;
            fixed _Refractivity;
            fixed _RefractiveIndex1;
            fixed _RefractiveIndex2;
            

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                fixed3 normal = UnityObjectToWorldNormal(v.normal);
                float3 vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex); 
                fixed3 viewWorldDir = normalize(UnityWorldSpaceViewDir(vertexWorldPos));
                o.refractWorldDir = refract(-viewWorldDir, normal, _RefractiveIndex1/_RefractiveIndex2);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return texCUBE(_CubeMap, i.refractWorldDir) * _Refractivity;
            }
            ENDCG
        }
    }
}
