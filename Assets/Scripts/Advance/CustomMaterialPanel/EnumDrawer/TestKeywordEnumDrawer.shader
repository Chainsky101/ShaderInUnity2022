Shader "Unlit/TestKeywordEnumDrawer"
{
   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // generate Keyword : _属性名_枚举名
        //_TESTENUM_TEX, _TESTENUM_RED, _TESTENUM_GREEN, _TESTENUM_BLUE
        [KeywordEnum(Tex, Red, Green, Blue)]_TestEnum ("TestEnum", Float) = 0
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
            #pragma shader_feature _TESTENUM_TEX _TESTENUM_RED _TESTENUM_GREEN _TESTENUM_BLUE

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
                #ifdef _TESTENUM_TEX
                    col = tex2D(_MainTex, i.uv);
                #elif _TESTENUM_RED
                    col = fixed4(1,0,0,1);
                #elif _TESTENUM_GREEN
                    col = fixed4(0,1,0,1);
                #elif _TESTENUM_BLUE
                    col = fixed4(0,0,1,1);
                #endif
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    } 
}