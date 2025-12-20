Shader "Unlit/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSpread("BlurSpread", Range(0,5)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        // 用于包裹代码之后在pass中可以使用
        CGINCLUDE
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _BlurSpread;
            
            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vertBlurHorizontal (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uvCenter = v.texcoord;
                // 方便后续计算
                // 0  1 2  3 4
                // 0 -1 1 -2 2
                o.uv[0] = uvCenter + _MainTex_TexelSize.xy * float2(0, 0);
                o.uv[1] = uvCenter + _MainTex_TexelSize.xy * float2(-1, 0) * _BlurSpread;
                o.uv[2] = uvCenter + _MainTex_TexelSize.xy * float2(1, 0)  * _BlurSpread;
                o.uv[3] = uvCenter + _MainTex_TexelSize.xy * float2(-2, 0) * _BlurSpread;
                o.uv[4] = uvCenter + _MainTex_TexelSize.xy * float2(2, 0) * _BlurSpread;
                return o;
            }

            v2f vertBlurVertical (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uvCenter = v.texcoord;
                // 0  1 2  3 4
                // 0 -1 1 -2 2
                // 方便后续计算
                o.uv[0] = uvCenter + _MainTex_TexelSize.xy * float2(0, 0);
                o.uv[1] = uvCenter + _MainTex_TexelSize.xy * float2(0, -1 ) * _BlurSpread;
                o.uv[2] = uvCenter + _MainTex_TexelSize.xy * float2(0, 1 ) * _BlurSpread;
                o.uv[3] = uvCenter + _MainTex_TexelSize.xy * float2(0, -2) * _BlurSpread;
                o.uv[4] = uvCenter + _MainTex_TexelSize.xy * float2(0, 2) * _BlurSpread;
                return o;
            }
            
            float4 fragBlur(v2f o):SV_Target
            {
                // optimized: 不需要创建重复代码
                // float gaussianFactor[5] = {0.0545, 0.2442, 0.4026, 0.2442, 0.0545};
                float gaussianFactor[3] = {0.4026, 0.2442, 0.0545};
                float3 resColor = tex2D(_MainTex, o.uv[0])*gaussianFactor[0];
                for(int i = 1; i<3; i++)
                {
                    resColor += tex2D(_MainTex, o.uv[i*2-1]).rgb * gaussianFactor[i];
                    resColor += tex2D(_MainTex, o.uv[i*2]).rgb * gaussianFactor[i];
                }
                return float4(resColor, 1);
            }
        ENDCG

        Pass
        {
            Name "BlurHorizontal"
            ZWrite Off
            ZTest On
            Cull Off
            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur

            ENDCG
        }

        Pass
        {
            Name "BlurVertical"
            ZWrite Off
            ZTest On
            Cull Off
            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur

            ENDCG
        }
    }
    Fallback Off
}
