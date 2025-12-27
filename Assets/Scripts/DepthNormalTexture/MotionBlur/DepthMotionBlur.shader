Shader "Unlit/DepthMotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("BlurSize", Range(0,1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            // Post screen process
            ZTest Always
            ZWrite Off
            Cull Off
            
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
            // post screen process -- don't need to be applied
            // float4 _MainTex_ST;
            fixed _BlurSize;
            sampler2D _CameraDepthTexture;
            float4x4 _ClipToWorldMatrix;
            float4x4 _FrontWorldToClipMatrix;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // get the depth
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                // use uv and depth to constitute a point in Clip Space
                float4 pos = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depth * 2 - 1, 1);
                float4 posWorld = mul(_ClipToWorldMatrix, pos);
                // 进行齐次运算
                posWorld /= posWorld.w;
                float4 lastPos = mul(_FrontWorldToClipMatrix, posWorld);
                // 进行齐次运算
                lastPos /= lastPos.w;
                // move dir
                float2 moveDir = float2(pos.x - lastPos.x, pos.y - lastPos.y);
                // do blur operation
                float4 col = float4(0, 0, 0, 0);
                for (int index = 0; index<3; index++)
                {
                    col += tex2D(_MainTex, i.uv);
                    i.uv += moveDir * _BlurSize;
                }
                col /= 3;
                return fixed4(col.rgb, 1);
            }
            ENDCG
        }
    }
    Fallback Off
}
