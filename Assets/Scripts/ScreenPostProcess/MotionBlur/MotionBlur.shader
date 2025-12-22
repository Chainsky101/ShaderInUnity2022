Shader "Unlit/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurIndex ("BlurIndex", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGINCLUDE
            sampler2D _MainTex;
            float _BlurIndex;
            #include "UnityCG.cginc"
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
        ENDCG
        
        ZTest Always
        ZWrite Off
        Cull Off
        
        // Pass 1: used to blend rgb component of vertex
        Pass
        {
            // 设置混合因子和蒙板颜色
            blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = fixed4(tex2D(_MainTex, i.uv).rgb, _BlurIndex);
                return col;
            }
            
            ENDCG
        }

        // Pass 2: used to blend a component of vertex
        Pass
        {
            // 设置混合因子和蒙板颜色
            blend One Zero
            ColorMask A
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            fixed4 frag(v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            
            ENDCG
        }
    }
    Fallback Off
}
