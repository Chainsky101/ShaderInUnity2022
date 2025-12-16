Shader "Unlit/DiffuseReflection"
{
    Properties
    {
        _CubeMap("CubeMap", Cube) = "white"{}
        _Reflectivity("Reflectivity", Range(0, 1)) = 1
        //diffuse color
        _Color("MainColor", Color) = (1,1,1,1)
        //reflect color
        _ReflectColor("ReflectColor", Color) = (1,1,1,1)
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
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            samplerCUBE _CubeMap;
            fixed _Reflectivity;
            fixed4 _Color;
            fixed4 _ReflectColor;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 reflectWorldDir : TEXCOORD0;
                float3 vertexWorldPos : TEXCOORD1;
                fixed3 normalWorldDir : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normalWorldDir = UnityObjectToWorldNormal(v.normal);
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                fixed3 viewWorldDir = UnityWorldSpaceViewDir(o.vertexWorldPos);
                // viewWorldDir's direction is from vertex to camera, need to be reverted
                o.reflectWorldDir = normalize(reflect(-viewWorldDir, o.normalWorldDir));
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed3 getLambertDiffuseColor(fixed3 normalWorldDir, fixed3 lightWorldDir)
            {
                return _Color.rgb * _LightColor0.rgb * max(0, dot(normalWorldDir, lightWorldDir));
            }
            fixed4 frag(v2f i) : SV_Target
            {
                // get the light Direction
                // #ifdef (DIRECTIONAL)
                //     fixed3 lightWorldDir = normalize(_WorldSpaceLightPos0);
                // #else
                //     #if defined(POINT) || defined(SPOT)
                //         fixed3 lightWorldDir = normalize(_WorldSpaceLightPos0 - i.vertexWorldPos);
                //     #else
                //         fixed3 lightWorldDir = normalize(_WorldSpaceLightPos0);
                //     #endif
                // #endif
                fixed3 lightWorldDir = normalize(UnityWorldSpaceLightDir(i.vertexWorldPos));
                // calculate light attenuation
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertexWorldPos)
                // diffuse color
                fixed3 lambertDiffuseColor = getLambertDiffuseColor(i.normalWorldDir, lightWorldDir);
                // sampling cubeMap
                fixed3 cubemapColor = texCUBE(_CubeMap, i.reflectWorldDir).rgb * _ReflectColor.rgb;
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT + lerp(lambertDiffuseColor, cubemapColor, _Reflectivity) * attenuation;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    Fallback "Legacy Shaders/Reflective/VertexLit"
}
