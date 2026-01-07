Shader "Unlit/DissolveEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        _SpecularFactor("SpecularFactor", Range(0,40)) = 40
        _BumpMap ("BumpMap", 2D) = "white" {}
        _BumpScale ("BumpScale", Range(-10, 10)) = 1
        // Dissolve Related
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        _GradientTex ("GradientTex", 2D) = "white" {}
        _DissolveFactor ("DissolveFactor", Range(0, 1)) = 0
        _Range ("Range", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        // handle color and receive shadow
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 firstRowMatrix : TEXCOORD1;
                float4 secondRowMatrix : TEXCOORD2;
                float4 thirdRowMatrix : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _SpecularColor;
            float _SpecularFactor;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            sampler2D _NoiseTex;
            sampler2D _GradientTex;
            half _DissolveFactor;
            half _Range;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                TRANSFER_SHADOW(o)
                // 计算从切线空间到世界空间的转换矩阵
                half3 normal = normalize(UnityObjectToWorldNormal(v.normal));
                half3 xAxis = normalize(UnityObjectToWorldDir(v.tangent));
                half3 yAxis = normalize(cross(normal, xAxis) * v.tangent.w);
                float3 vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.firstRowMatrix = float4(xAxis, vertexWorldPos.x);
                o.secondRowMatrix = float4(yAxis, vertexWorldPos.y);
                o.thirdRowMatrix = float4(normal, vertexWorldPos.z);
                return o;
            }

            fixed3 getAmbientLightColor(in fixed3 albedo)
            {
                return UNITY_LIGHTMODEL_AMBIENT * albedo;
            }

            fixed3 getLambertDiffuseLightColor(in fixed3 normal, in fixed3 albedo)
            {
                return _LightColor0.rgb * albedo * max(0, dot(normal, normalize(_WorldSpaceLightPos0.xyz))); 
            }

            fixed3 getSpecularLightColor(in fixed3 normal, in fixed3 viewWorldDir)
            {
                fixed3 semi_light_view = normalize(viewWorldDir + normalize(_WorldSpaceLightPos0.xyz));
                return _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(normal, semi_light_view)), _SpecularFactor);
            }

            
            fixed4 frag (v2f i) : SV_Target
            {
                // 测试是否丢弃此像素
                // 灰度图的rgb是相同的
                half colorValue = tex2D(_NoiseTex, i.uv.xy).r;
                // clip(x) x<0时才剔除，否则不剔除
                // 修改2：处理_DissolveFactor为1时，消融修改残留的问题——此时，参数直接设为负值
                clip(_DissolveFactor == 1 ? -1 :colorValue - _DissolveFactor);

                // 计算颜色
                float3 vertexWorldPos = float3(i.firstRowMatrix.w, i.secondRowMatrix.w, i.thirdRowMatrix.w);
                // transfer normal got from BumpMap in Tangent space to it in World space
                half3 normalTangentDir = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                normalTangentDir.xy *= _BumpScale;
                normalTangentDir.z = sqrt(1.0-saturate(dot(normalTangentDir.xy, normalTangentDir.xy)));
                half3 normalWorldDir = half3(
                    dot(i.firstRowMatrix.xyz, normalTangentDir),
                    dot(i.secondRowMatrix.xyz, normalTangentDir),
                    dot(i.thirdRowMatrix.xyz, normalTangentDir)
                );
                UNITY_LIGHT_ATTENUATION(attenuation, i, vertexWorldPos);
                // get albedo
                fixed3 textureColor = tex2D(_MainTex, i.uv.xy);
                fixed3 albedo = textureColor * _Color.rgb;

                // view dir in world space
                fixed3 viewWorldDir = normalize(_WorldSpaceCameraPos - vertexWorldPos);
                // fixed3 viewWorldDir = normalize(UnityWorldSpaceViewDir(i.vertexWorldPos));
                
                //get final color
                fixed3 col = getAmbientLightColor(albedo)
                    + getLambertDiffuseLightColor(normalWorldDir, albedo) * attenuation
                    + getSpecularLightColor(normalWorldDir, viewWorldDir) * attenuation;

                // 计算消融效果相关变量
                half factor = 1 - smoothstep(0.0, _Range, colorValue - _DissolveFactor);
                fixed3 gradientColor = tex2D(_GradientTex, fixed2(factor, 0.5));
                
                // 对消融渐变颜色和col颜色进行插值lerp
                // 修改1：_DissolveFactor为0时，不出声消融效果——此时让factor为0
                fixed3 finalCol = lerp(col, gradientColor, factor * step(0.00001, _DissolveFactor));
                return fixed4(finalCol, 1);
            }
            ENDCG
        }
        // handle project shadow
        Pass
        {
            Tags {"LightMode"="ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _DissolveFactor;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                V2F_SHADOW_CASTER;
            };
            
            v2f vert(appdata_base v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.texcoord, _NoiseTex);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Clip off
                half colorValue = tex2D(_NoiseTex, i.uv).r;
                clip(colorValue - _DissolveFactor);
                
                SHADOW_CASTER_FRAGMENT(o);
            }
            ENDCG
        }
    }
}
