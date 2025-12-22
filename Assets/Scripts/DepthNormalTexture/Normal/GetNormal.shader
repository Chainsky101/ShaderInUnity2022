Shader "Unlit/GetNormal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}

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
            sampler2D _CameraDepthNormalsTexture;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth;
                float3 normal;
                float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
                // 得到观察空间下的法线，裁剪空间下的深度
                DecodeDepthNormal(depthNormal, depth, normal);
                return fixed4(normal*0.5+fixed3(0.5,0.5,0.5), 1);
            }
            ENDCG
        }
    }
    Fallback Off
}
