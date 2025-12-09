Shader "Unlit/Blinn_Phong_PerFragment"
{
    Properties
    {
        // 材质颜色
        _MainColor("MainColor", Color) = (1,1,1,1)
        // 高光颜色
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        // 高光幂系数
        _SpecularFactor("SpecularFactor", Range(0,50)) = 10
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 vertexWorldPos : TEXCOORD0;
                fixed3 normalWorldVec : NORMAL;
            };

            float4 _MainColor;
            float4 _SpecularColor;
            float _SpecularFactor;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.normalWorldVec = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed3 getLambertDiffuseLightColor(fixed3 normalWorldVec)
            {
                return _LightColor0 * _MainColor * max(0, dot(normalWorldVec,normalize(_WorldSpaceLightPos0)));
            }

            fixed3 getSpecularLightColor(float3 vertexWorldPos, fixed3 normalWorldVec)
            {
                fixed3 viewWorldVec = normalize(UnityWorldSpaceViewDir(vertexWorldPos));
                float3 semi_input_view = normalize(normalize(_WorldSpaceLightPos0) + viewWorldVec);
                return _LightColor0 * _SpecularColor * pow(max(0, dot(normalWorldVec, semi_input_view)), _SpecularFactor);
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 col = UNITY_LIGHTMODEL_AMBIENT + getLambertDiffuseLightColor(i.normalWorldVec) +
                    getSpecularLightColor(i.vertexWorldPos,i.normalWorldVec);
                return fixed4(col,1);
            }
            ENDCG
        }
    }
}