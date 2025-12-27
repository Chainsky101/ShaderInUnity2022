Shader "Unlit/GetDepth"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white"{}
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

            sampler2D _CameraDepthTexture;
            sampler2D _MainTex;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // [0, 1]的非线性深度
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                // 方法1：转换为[0,1]范围的线性深度
                fixed linearDepth = Linear01Depth(depth);
                return fixed4(linearDepth, linearDepth, linearDepth,1);
                // 测试2：尝试采样深度
                // float depth = tex2D(_CameraDepthTexture, i.uv).r;
                //
                // // 测试3：输出原始深度值
                // if (depth == 0) {
                //     return float4(1, 0, 0, 1); // 红色：深度值为0
                // } else if (depth == 1) {
                //     return float4(0, 1, 0, 1); // 绿色：深度值为1
                // } else {
                //     return float4(depth, depth, depth, 1); // 灰度：有效深度
                // }
            }
            ENDCG
        }
    }
    Fallback Off
}
