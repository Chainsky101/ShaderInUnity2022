Shader "Unlit/Blinn_Phong_PerVertex"
{
    Properties
    {
        // 材质颜色
        _MainColor("MainColor", Color) = (1,1,1,1)
        // 高光颜色
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        // 高光幂系数
        _SpecularFactor("SpecularFactor", Range(0,50)) = 3.5
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
                fixed3 color : COLOR;
            };

            float4 _MainColor;
            float4 _SpecularColor;
            float _SpecularFactor;
            

            fixed3 getLambertDiffuseLightColor(fixed3 normalWorldVec)
            {
                return _LightColor0 * _MainColor * max(0, dot(normalWorldVec,normalize(_WorldSpaceLightPos0)));
            }

            fixed3 getSpecularLightColor(float3 vertexWorldPos, fixed3 normalWorldVec)
            {
                float3 semi_input_view = normalize(normalize(_WorldSpaceLightPos0) + normalize(_WorldSpaceCameraPos - vertexWorldPos));
                return _LightColor0 * _SpecularColor * pow(max(0, dot(normalWorldVec, semi_input_view)), _SpecularFactor);
            }

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                fixed3 normalWorldVec = UnityObjectToWorldNormal(v.normal);
                o.color = UNITY_LIGHTMODEL_AMBIENT;
                o.color += getLambertDiffuseLightColor(normalWorldVec) + getSpecularLightColor(vertexWorldPos, normalWorldVec);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color,1);
            }
            ENDCG
        }
    }
}