Shader "Unlit/BasicFresnelReflection"
{
    Properties
    {
        _CubeMap("CubeMap", Cube) = ""{}
        _FresnelScale("FresnelScale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 normalWorldDir : NORMAL;
                fixed3 viewWorldDir : TEXCOORD0;
                fixed3 reflectionWorldDir : TEXCOORD1;
            };

            samplerCUBE _CubeMap;
            fixed _FresnelScale;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normalWorldDir = normalize(UnityObjectToWorldNormal(v.normal));
                float3 vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.viewWorldDir = normalize(UnityWorldSpaceViewDir(vertexWorldPos));
                o.reflectionWorldDir = reflect(-o.viewWorldDir, o.normalWorldDir);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // calculate Fresnel Reflection Index
                fixed fresnelReflectionIndex = _FresnelScale + (1-_FresnelScale) * pow(1-max(0,dot(i.viewWorldDir, i.normalWorldDir)), 5);
                return texCUBE(_CubeMap, i.reflectionWorldDir) * fresnelReflectionIndex;
            }
            ENDCG
        }
    }
}
