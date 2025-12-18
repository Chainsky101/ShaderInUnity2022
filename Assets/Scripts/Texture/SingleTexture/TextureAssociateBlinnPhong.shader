Shader "Unlit/TextureAssociateBlinnPhong"
{
    Properties
    {
        // 材质颜色
        _MainColor("MainColor", Color) = (1,1,1,1)
        // 高光颜色
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        // 高光幂系数
        _SpecularFactor("SpecularFactor", Range(0,50)) = 3.5
        // 主纹理
        _MainTex("MainTexture", 2D) = "white"{}
        // 叠加颜色
        _AddColor("AddColor", Color) = (0,0,0,1)
        
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "LightMode" = "ForwardBase"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
                float3 vertexWorldPos : TEXCOORD1;
            };

            float4 _MainColor;
            float4 _SpecularColor;
            float _SpecularFactor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _AddColor;

            fixed3 getAmbientLightColor(in fixed3 blendingColor)
            {
                return UNITY_LIGHTMODEL_AMBIENT.rgb * blendingColor;
            }
            
            fixed3 getLambertDiffuseLightColor(in fixed3 normalWorldVec, in fixed3 blendingColor)
            {
                return _LightColor0 * blendingColor * max(0, dot(normalWorldVec,normalize(_WorldSpaceLightPos0)));
            }

            fixed3 getSpecularLightColor(in float3 vertexWorldPos, in fixed3 normalWorldVec)
            {
                float3 semi_input_view = normalize(normalize(_WorldSpaceLightPos0) + normalize(_WorldSpaceCameraPos - vertexWorldPos));
                return _LightColor0 * _SpecularColor * pow(max(0, dot(normalWorldVec, semi_input_view)), _SpecularFactor);
            }
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
               
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 textureColor = tex2D(_MainTex, i.uv);
                fixed3 blendingColor = _MainColor.rgb * textureColor;
                fixed3 color = getLambertDiffuseLightColor(i.normal, blendingColor) +getAmbientLightColor(blendingColor)
                    + getSpecularLightColor(i.vertexWorldPos, i.normal);
                
                return fixed4(color,1) + _AddColor;
            }
            ENDCG
        }
    }
}
