Shader "Unlit/BackgroundRoll"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _UAxisSpeed ("UAxisSpeed", Float) = 1
        _VAxisSpeed ("VAxisSpeed", Float) = 1
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "Queue"="Transparent"
        }

        Pass
        {
            ZWrite Off
            blend SrcAlpha OneMinusSrcAlpha
            
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
            float _UAxisSpeed;
            float _VAxisSpeed;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 delta = fixed2(_UAxisSpeed * _Time.y, _VAxisSpeed * _Time.y);
                fixed2 uv = frac(i.uv + delta);
                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
}
