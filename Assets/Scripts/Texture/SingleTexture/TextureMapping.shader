Shader "Unlit/TextureMapping"
{
    Properties
    {
        _MainTexture("MainTexture", 2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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

            sampler2D _MainTexture;
            float4 _MainTexture_ST;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
                // o.uv = TRANSFORM_TEX(v.texcoord, _MainTexture);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTexture, i.uv);
                return color;
            }
            ENDCG
        }
    }
}
