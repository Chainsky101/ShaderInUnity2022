Shader "Unlit/DiffuseRefraction"
{
        Properties
    {
        _CubeMap("CubeMap", Cube) = "white"{}
        _Refractivity("Refractivity", Range(0, 1)) = 1
        _RefractiveIndex1("RefractiveIndex1", Range(1, 2)) = 1
        _RefractiveIndex2("RefractiveIndex2", Range(1, 2)) = 1.3
        _Color("MainColor", Color) = (1,1,1,1)
        _RefractColor("RefractColor", Color) = (1,1,1,1)
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
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                fixed3 refractWorldDir : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 vertexWorldPos : TEXCOORD1;
                fixed3 normalWorldDir : NORMAL;
                SHADOW_COORDS(2)
            };

            samplerCUBE _CubeMap;
            fixed _Refractivity;
            fixed _RefractiveIndex1;
            fixed _RefractiveIndex2;
            fixed4 _Color;
            fixed4 _RefractColor;
            

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normalWorldDir = UnityObjectToWorldNormal(v.normal);
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex); 
                fixed3 viewWorldDir = normalize(UnityWorldSpaceViewDir(o.vertexWorldPos));
                o.refractWorldDir = refract(-viewWorldDir, o.normalWorldDir, _RefractiveIndex1/_RefractiveIndex2);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 lightWorldDir = normalize(UnityWorldSpaceViewDir(i.vertexWorldPos));
                // calculate light attenuation
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertexWorldPos)
                fixed3 diffuseColor = _LightColor0.rgb * _Color.rgb * max(0, dot(lightWorldDir, i.normalWorldDir));
                fixed3 cubemapColor = texCUBE(_CubeMap, i.refractWorldDir).rgb * _RefractColor.rgb;
                fixed3 color =UNITY_LIGHTMODEL_AMBIENT.rgb + lerp(diffuseColor, cubemapColor, _Refractivity) * attenuation;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    Fallback "Legacy Shaders/Reflective/VertexLit"
}
