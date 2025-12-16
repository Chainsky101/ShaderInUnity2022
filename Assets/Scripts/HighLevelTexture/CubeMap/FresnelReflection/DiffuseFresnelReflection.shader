Shader "Unlit/DiffuseFresnelReflection"
{
    Properties
    {
        _CubeMap("CubeMap", Cube) = ""{}
        _FresnelScale("FresnelScale", Range(0,1)) = 1
        _Color("MainColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 vertexWorldPos : TEXCOORD0;
                fixed3 normalWorldDir : NORMAL;
                fixed3 viewWorldDir : TEXCOORD1;
                fixed3 reflectionWorldDir : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            samplerCUBE _CubeMap;
            fixed _FresnelScale;
            fixed4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normalWorldDir = normalize(UnityObjectToWorldNormal(v.normal));
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.viewWorldDir = normalize(UnityWorldSpaceViewDir(o.vertexWorldPos));
                o.reflectionWorldDir = reflect(-o.viewWorldDir, o.normalWorldDir);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // calculate light Dir in World Space
                fixed3 lightWorldDir = normalize(UnityWorldSpaceLightDir(i.vertexWorldPos));
                // calculate Fresnel Reflection Index
                fixed fresnelReflectionIndex = _FresnelScale + (1-_FresnelScale) * pow(1-max(0,dot(i.viewWorldDir, i.normalWorldDir)), 5);
                // calculate cubemap color
                fixed3 cubemapColor = texCUBE(_CubeMap, i.reflectionWorldDir).rgb;
                // calculate lambert diffuse color
                fixed3 lambertDiffuseColor = _LightColor0.rgb * _LightColor0 * max(0, dot(i.normalWorldDir, lightWorldDir));
                // calculate light attenuation
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertexWorldPos);
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + lerp(lambertDiffuseColor, cubemapColor, fresnelReflectionIndex) * attenuation;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    Fallback "Legacy Shaders/Reflective/VertexLit"
}
