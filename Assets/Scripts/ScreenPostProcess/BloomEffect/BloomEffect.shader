Shader "Unlit/BloomEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSpread("BlurSpread", Range(0,5)) = 0.5
        // 大于1的部分在HDR中有效果
        _LuminanceThreshold("LuminaceThreshold", Range(0, 5)) = 0.2
        _Bloom("Bloom", 2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
                // 用于包裹代码之后在pass中可以使用
        CGINCLUDE
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float _BlurSpread;
            float4 _MainTex_TexelSize;
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
        ENDCG

        ZWrite Off
        ZTest Always
        Cull Off
        // Pass 1: extract Brightness 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            float _LuminanceThreshold;
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed getLuminance(in fixed3 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed luminance = getLuminance(col);
                fixed val = clamp(luminance - _LuminanceThreshold, 0, 1);
                return col * val;
            }
            ENDCG
        }
        
        //Pass 2: blur horizontal
        UsePass "Unlit/GaussianBlur/BLURHORIZONTAL"
        //Pass 3: blur vertical
        UsePass "Unlit/GaussianBlur/BLURVERTICAL"

        // Pass 4 : aggregation
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            sampler2D _Bloom;

            struct v2fBloom
            {
                float4 vertex : SV_POSITION;
                // uv.xy used to represent _MainTex;
                // uv.zw used to represent _Bloom;
                // cause _Bloome is assigned from a RenderTexture in C# which need to check yAxis flip
                half4 uv : TEXCOORD0;
            };
            v2fBloom vert (appdata_base v)
            {
                v2fBloom o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord;
                o.uv.zw = v.texcoord;

                #if UNITY_UV_STARTS_AT_TOP
                    if(_MainTex_TexelSize.y < 0)
                        o.uv.w = 1 - o.uv.w;
                #endif
                
                return o;
            }

            fixed4 frag (v2fBloom i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                fixed4 bloomColor = tex2D(_Bloom, i.uv.zw);
                return fixed4(col.rgb + bloomColor.rgb, 1) ;
            }

            ENDCG
        }

        
        
    }
}
