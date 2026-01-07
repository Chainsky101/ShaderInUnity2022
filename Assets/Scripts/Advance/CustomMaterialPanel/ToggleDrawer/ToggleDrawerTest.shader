Shader "Unlit/ToggleDrawerTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // solution 1: Use property and control flow
        // solution 2: Use keyword and compile command
        //             you can customize keyword to match with shader variant
        [Toggle(_MY_TEX)] _ShowTex ("ShowTex", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma shader_feature _MY_TEX

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
            fixed _ShowTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(1,1,1,1);
                // solution 1: control flow
                // if(_ShowTex == 1)
                //     col = tex2D(_MainTex, i.uv);

                // solution 2: compile command
                #ifdef _MY_TEX
                col = tex2D(_MainTex, i.uv);
                #endif
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
