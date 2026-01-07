Shader "Unlit/ShaderVariant"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            // define shader variant
            // solution 1: 该编译指令声明的关键字，只有关键词启用时才会生成对应Shader变体
            // #pragma shader_feature _Test_One _Test_Two

            // solution 2: 该编译指令声明的关键字，不管是否启用都会生成对应Shader变体
            #pragma multi_compile _Test_One _Test_Two
            
            
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
                // use Compile Command to fulfill different Shader Variants
                #ifdef _Test_One
                // sample the texture
                col = tex2D(_MainTex, i.uv);
                #endif
                
                #ifdef _Test_Two
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                #endif
                
                return col;
            }
            ENDCG
        }
    }
}
