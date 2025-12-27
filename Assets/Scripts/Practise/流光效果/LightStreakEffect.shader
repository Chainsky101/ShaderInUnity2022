Shader "Unlit/LightStreakEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FlowXSpeed ("FlowXSpeed", Float) = 1
        _FlowYSpeed ("FlowYSpeed", Float) = 1
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "Queue"="Transparent"
        }
            ZWrite Off
            blend One One
            Cull Off
            
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
            float _FlowXSpeed;
            float _FlowYSpeed;
            half4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 uv = i.uv + half2(_FlowXSpeed, _FlowYSpeed) * _Time.y; 
                // sample the texture
                fixed4 col = tex2D(_MainTex, uv);
                col.rgb = col * _Color.rgb;
                return fixed4(col.rgb, 1);
            }
            ENDCG
        }
    }
}
