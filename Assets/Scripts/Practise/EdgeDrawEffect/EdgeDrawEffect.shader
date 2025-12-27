Shader "Unlit/EdgeDrawEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeColor ("EdgeColor", Color) = (0,0,0,0)
        _EdgeSize ("EdgeSize", Range(0,0.1)) = 0.01
    }
    SubShader
    {
        Tags {
            "Queue"="Transparent"
            "RenderType"="Opaque"
        }
        
        // Pass 1:沿法线对顶点进行偏移
        Pass
        {
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };
            
            fixed4 _EdgeColor;
            float _EdgeSize;

            v2f vert (appdata_base v)
            {
                v2f o;
                float3 newVertex = v.vertex.xyz + v.normal * _EdgeSize; 
                o.vertex = UnityObjectToClipPos(float4(newVertex, 1));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _EdgeColor;
            }
            ENDCG
        }
        
        //Pass 2: 对原始模型进行着色
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
    Fallback "Legacy Shaders/Diffuse"
}
