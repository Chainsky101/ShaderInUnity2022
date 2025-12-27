Shader "Unlit/XInputSemiTransparent"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _ReflectionRatio ("ReflectionRatio", Range(0, 1)) = 0.2
        _ReflectionExponent ("ReflectionExponent", Float) = 3
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        // Pass 1: 
        Pass
        {
            ZWrite Off
            ZTest Greater
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            struct v2f
            {
                float4 vertex : SV_POSITION;
                half3 normalWorldDir : NORMAL;
                half3 viewWorldDir : TEXCOORD0;
            };

            half4 _Color;
            half _ReflectionRatio;
            float _ReflectionExponent; 

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normalWorldDir = UnityObjectToWorldNormal(v.normal);
                o.viewWorldDir = normalize(UnityWorldSpaceViewDir(mul(UNITY_MATRIX_M, v.vertex)));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half alpha = _ReflectionRatio +
                            (1 - _ReflectionRatio) *
                            pow(1-dot(normalize(i.normalWorldDir), normalize(i.viewWorldDir)), _ReflectionExponent);
                return fixed4(_Color.rgb, alpha);
            }
            ENDCG
        }

        // Pass 2: do the sample
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
    Fallback "Legacy Shaders/Diffuse"
}