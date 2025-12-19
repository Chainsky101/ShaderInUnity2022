Shader "Unlit/EdgeDetect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeColor("EdgeColor", Color) = (1,1,1,1)
        // background color
        _BackgroundColor("BackgroundColor", Color) = (1,1,1,1)
        _BackgroundExtent("BackgroundExtent", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            ZWrite Off
            ZTest On
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                half2 uv[9]: TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            fixed _BackgroundExtent;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 center = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv[0] = center + _MainTex_TexelSize.xy * float2(-1, 1);
                o.uv[1] = center + _MainTex_TexelSize.xy * float2(0, 1);
                o.uv[2] = center + _MainTex_TexelSize.xy * float2(1, 1);
                o.uv[3] = center + _MainTex_TexelSize.xy * float2(-1, 0);
                o.uv[4] = center + _MainTex_TexelSize.xy * float2(0, 0);
                o.uv[5] = center + _MainTex_TexelSize.xy * float2(1, 0);
                o.uv[6] = center + _MainTex_TexelSize.xy * float2(-1, -1);
                o.uv[7] = center + _MainTex_TexelSize.xy * float2(0, -1);
                o.uv[8] = center + _MainTex_TexelSize.xy * float2(1, -1);
                return o;
            }

            half getLuminace(fixed3 col)
            {
                return 0.2126 * col.r + 0.7152 * col.g + 0.0722 * col.b;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half grayValue;
                fixed3 col;
                fixed3 texColor;
                fixed grayXFactor[9] ={-1,-2,-1,0,0,0,1,2,1};
                fixed grayYFactor[9] ={-1,0,1,-2,0,2,-1,0,1};
                half grayX = 0, grayY = 0;

                // calculate gradient
                for (int index = 0; index < 9; index++)
                {
                    col = tex2D(_MainTex, i.uv[index]);
                    if(index == 4)
                        texColor = col;
                    grayValue = getLuminace(col);
                    grayX += grayValue * grayXFactor[index];
                    grayY += grayValue * grayYFactor[index];
                }
                
                half grayFinalValue = abs(grayX) + abs(grayY);
                // 对纹理颜色进行插值
                fixed3 originalColorWithEdge = lerp(texColor, _EdgeColor, grayFinalValue);
                fixed3 prueColorWithEdge = lerp(_BackgroundColor, _EdgeColor, grayFinalValue);
                fixed3 color = lerp(originalColorWithEdge, prueColorWithEdge, _BackgroundExtent);
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    Fallback Off
}
