Shader "Unlit/AlphaTestShadow"
{
   Properties
    {
        // 材质颜色
        _Color("MainColor", Color) = (1,1,1,1)
        // 高光颜色
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        // 高光幂系数
        _SpecularFactor("SpecularFactor", Range(0,50)) = 3.5
        // 主纹理
        _MainTex("MainTexture", 2D) = "white"{}
        // 透明度测试
        _Cutoff("Cutoff", Range(0, 1)) = 0
        
    }
    SubShader
    {
        Tags {
            "Queue"="AlphaTest"
            "IgnoreProjector"="Ture"
            "RenderType"="TransparentCutout"
        }
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // let the material to receive shadow
            // 1. add the compile command multi_compile_fwdbase to compile all variants and secure all
            // attenuation-related light variable can be assigned correctly.
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            // 2. add header file AutoLight.cginc
            #include "AutoLight.cginc"
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
                float3 vertexWorldPos : TEXCOORD1;
                // 3. add the shadow variable
                SHADOW_COORDS(2)
            };

            float4 _Color;
            float4 _SpecularColor;
            float _SpecularFactor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            //透明度测试——片元alpha小于该值的片元直接透明（不渲染）
            fixed _Cutoff;

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
                o.pos = UnityObjectToClipPos(v.vertex);
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                // 4. calculate transfered shadow
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed3 textureColor = tex2D(_MainTexture, i.uv);
                // need get the alpha from texture
                fixed4 textureColor = tex2D(_MainTex, i.uv);
                // two solutions to do alphaTest
                // solution 1: manual calculate
                if(textureColor.a < _Cutoff)
                    discard;
                // solution 2: use clip(float x) -> if(x < 0) discard;
                clip(textureColor.a - _Cutoff);

                // 5. calculate light attenuation
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertexWorldPos)
                // float attenuation = 1;
                fixed3 blendingColor = _Color.rgb * textureColor.rgb;
                fixed3 color = (getLambertDiffuseLightColor(i.normal, blendingColor)
                    + getSpecularLightColor(i.vertexWorldPos, i.normal)) * attenuation
                    + getAmbientLightColor(blendingColor);
                
                return fixed4(color,1);
            }
            ENDCG
        }
    }
    // let the material to project shadow
    Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}
