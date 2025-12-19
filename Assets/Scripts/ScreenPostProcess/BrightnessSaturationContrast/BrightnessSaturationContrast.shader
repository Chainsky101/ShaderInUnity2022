Shader "Unlit/BrightnessSaturationContrast"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness("Brightness", Float) = 1
        _Saturation("Saturation", Float) = 1
        _Contrast("Contrast", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            // Post process configure
            ZTest On
            Cull Off
            ZWrite Off
            
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
            float _Brightness;
            float _Saturation;
            float _Contrast;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // handle brightness
                col *= _Brightness;
                // handle saturation
                fixed grayIndex = 0.2126 * col.r + 0.7152 * col.g + 0.0722 * col.b;
                fixed3 grayColor = fixed3(grayIndex, grayIndex, grayIndex);
                col.rgb = lerp(grayColor, col.rgb, _Saturation);
                // handle constract
                fixed3 midGreyColor = fixed3(0.5, 0.5, 0.5);
                col.rgb = lerp(midGreyColor, col.rgb, _Contrast);
                return col;
            }
            ENDCG
        }
    }
    Fallback Off
}
