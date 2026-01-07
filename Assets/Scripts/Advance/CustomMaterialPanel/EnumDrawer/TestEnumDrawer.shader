Shader "Unlit/TestEnumDrawer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Enum(Tex, 0, Red, 1, Green, 2, Blue, 3)]_TestEnum ("TestEnum", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _TestEnum;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = fixed4(0,0,0,0);
                if(_TestEnum == 0)
                    col = tex2D(_MainTex, i.uv);
                else if(_TestEnum == 1)
                    col = fixed4(1,0,0,1);
                else if(_TestEnum == 2)
                    col = fixed4(0,1,0,1);
                else if(_TestEnum == 3)
                    col = fixed4(0,0,1,1);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}