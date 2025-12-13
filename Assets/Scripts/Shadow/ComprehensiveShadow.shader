Shader "Unlit/ComprehensiveShadow"
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
        // Base Pass
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 1. add the Compile Command
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc" // contains Shadow receive-related Macros

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 vertexWorldPos : TEXCOORD0;
                fixed3 normalWorldVec : NORMAL;
                SHADOW_COORDS(2) // defined shadow 
            };

            float4 _MainColor;
            float4 _SpecularColor;
            float _SpecularFactor;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.normalWorldVec = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o)
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
                fixed3 shadow = SHADOW_ATTENUATION(i);
                // dirctional light don't get the attenuation
                float attenuation = 1;
                fixed3 col = UNITY_LIGHTMODEL_AMBIENT + (getLambertDiffuseLightColor(i.normalWorldVec) +
                    getSpecularLightColor(i.vertexWorldPos,i.normalWorldVec)) * attenuation * shadow;
                return fixed4(col,1);
            }
            ENDCG
        }

        // Additional Pass
        Pass
        {
            Tags
            {
                // 1. edit the light mode into ForwardAdd
                "LightMode" = "ForwardAdd"
            }
            
            // 2. add the blending effect -- linear fade away 线性减淡
            Blend One One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //3. add the Compile Command
            #pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //4. add AutoLight.cginc to get the _lightTexture0, _LightTextureB0 and unity_WorldToLight transfer matrix
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 vertexWorldPos : TEXCOORD0;
                fixed3 normalWorldVec : NORMAL;
                SHADOW_COORDS(2)
                
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
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed3 getLambertDiffuseLightColor(in fixed3 normalWorldDir, in fixed3 lightWorldDir)
            {
                return _LightColor0 * _MainColor * max(0, dot(normalWorldDir,lightWorldDir));
            }

            fixed3 getSpecularLightColor(in float3 vertexWorldPos, in fixed3 normalWorldDir, in fixed3 lightWorldDir)
            {
                fixed3 viewWorldDir = normalize(UnityWorldSpaceViewDir(vertexWorldPos));
                float3 semi_input_view = normalize(lightWorldDir + viewWorldDir);
                return _LightColor0 * _SpecularColor * pow(max(0, dot(normalWorldDir, semi_input_view)), _SpecularFactor);
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                // 5. calculate the light direction in different light source
                #if defined(USING_DIRECTIONAL_LIGHT)
                    fixed3 lightWorldDir = normalize(_WorldSpaceLightPos0);
                #else
                    #if defined(POINT)
                        fixed3 lightWorldDir = normalize(_WorldSpaceLightPos0.xyz - i.vertexWorldPos);
                    #elif defined(SPOT)
                        fixed3 lightWorldDir = normalize(_WorldSpaceLightPos0.xyz - i.vertexWorldPos);
                    #else
                        fixed3 lightWorldDir = normalize(_WorldSpaceLightPos0);
                    #endif
                #endif

                // 6. calculate the light attenuation
                // #if defined(USING_DIRECTIONAL_LIGHT)
                //     fixed attenuation = 1;
                // #else
                //     #if defined(POINT)
                //         // vertex in world space transfered to light space
                //         float3 lightCoord = mul(unity_WorldToLight, float4(i.vertexWorldPos, 1)).xyz;
                //         fixed attenuation = tex2D(_LightTexture0, dot(lightCoord, lightCoord).xx).UNITY_ATTEN_CHANNEL;
                //     #elif defined(SPOT)
                //         // vertex in world space transfered to light space
                //         float4 lightCoord = mul(unity_WorldToLight, float4(i.vertexWorldPos, 1));
                //         fixed attenuation = (lightCoord.z > 0) *
                //             tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w *
                //             tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                //     #else
                //         fixed attenuation = 1;
                //     #endif
                // #endif

                // don't need to calculate light attenuation, because the UNITY_LIGHT_ATTENUATION already contain it.
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertexWorldPos)
                
                fixed3 col = (getLambertDiffuseLightColor(i.normalWorldVec, lightWorldDir) +
                    getSpecularLightColor(i.vertexWorldPos,i.normalWorldVec, lightWorldDir)) * attenuation;
                return fixed4(col,1);
            }
            ENDCG
        }
    }
    Fallback "Legacy Shaders/Specular"
}