Shader "Unlit/CartoonStyleEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientTex ("GradientTex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _SpecularColor ("SpecularColor", Color) = (1,1,1,1)
        _EdgeColor ("EdgeColor", Color) = (0,0,0,0)
        _EdgeSize ("EdgeSize", Float) = 1
        _SpecularScale ("SpecularScale", Range(0,1)) = 0.3
        _BumpMap ("BumpMap", 2D) = "white" {}
        
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        // Pass 1: render the back side and translate vertex
        // 
        Pass
        {
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            half4 _EdgeColor;
            half _EdgeSize;
            v2f vert(appdata_base v)
            {
                v2f o;
                float3 newPos = v.vertex + v.normal * _EdgeSize;
                o.vertex = UnityObjectToClipPos(newPos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _EdgeColor;
            }
            ENDCG
        }

        // Pass 2: normal cartoon render effect
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 normalWorldDir : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GradientTex;
            half4 _SpecularColor;
            half _SpecularScale;
            half4 _Color;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normalWorldDir = UnityObjectToWorldNormal(v.normal);  
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half uv = dot(i.normalWorldDir, normalize(_WorldSpaceLightPos0)) * 0.5 + 0.5;
                half3 diffuseColor = unity_LightColor0.rgb * _Color.rgb *
                                    tex2D(_GradientTex,half2(uv, uv));
                half3 viewWorldDir = normalize(UnityWorldSpaceViewDir(i.vertex));
                half3 semiViewLightDir = normalize(viewWorldDir + normalize(_WorldSpaceLightPos0));
                fixed spec = dot(i.normalWorldDir, semiViewLightDir);
                spec = step(_SpecularScale, spec);
                half3 specularColor = _SpecularColor.rgb * spec;
                // sample the texture
                half3 col = UNITY_LIGHTMODEL_AMBIENT.rgb + diffuseColor + specularColor;
                col += tex2D(_MainTex, i.uv).rgb;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}