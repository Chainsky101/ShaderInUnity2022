Shader "Unlit/EdgeDetectionWithDepthNormal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SampleDistance("SampleDistance", Float) = 1
        _EdgeOnly ("EdgeOnly", Range(0, 1)) = 0
        _EdgeColor ("EdgeColor", Color) = (0,0,0,0)
        _BackgroundColor ("BackgroundColor", Color) = (1,1,1,1)
        _SensitivityDepth ("SensitivityDepth", Float) = 1
        _SensitivityNormal ("SensitivityNormal", Float) = 1
    }
    SubShader
    {
        Pass
        {
            // Post process Render Setup
            ZTest Always
            ZWrite Off
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex : SV_POSITION;
                // float2 uv_depth : TEXCOORD1;
                float4 uv_slash : TEXCOORD2;
                float4 uv_backSlash : TEXCOORD3;
            };

            sampler2D _MainTex;
            //纹素的大小
            float4 _MainTex_TexelSize;
            float _SampleDistance;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            float _SensitivityDepth;
            float _SensitivityNormal;
            // 摄像机生成的深度和法线纹理
            sampler2D _CameraDepthNormalsTexture; 

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv_slash.xy = o.uv + fixed2(-1, -1) * _MainTex_TexelSize.xy * _SampleDistance;
                o.uv_slash.zw = o.uv + fixed2(1, 1) * _MainTex_TexelSize.xy * _SampleDistance;
                o.uv_backSlash.xy = o.uv + fixed2(-1, 1) * _MainTex_TexelSize.xy * _SampleDistance;
                o.uv_backSlash.zw = o.uv + fixed2(1, -1) * _MainTex_TexelSize.xy * _SampleDistance;
                return o;
            }

            // 此函数用两个点的法线和深度来判断此线是否在边缘上
            fixed isOnInternal(in half4 depthNormal1, in half4 depthNormal2)
            {
                float depth1, depth2;
                float2 normal1, normal2;
                // DecodeDepthNormal(depthNormal1, depth1, normal1);
                // DecodeDepthNormal(depthNormal2, depth2, normal2);
                depth1 = DecodeFloatRG(depthNormal1.zw);
                depth2 = DecodeFloatRG(depthNormal2.zw);
                normal1 = depthNormal1.xy;
                normal2 = depthNormal2.xy;
                // check the diff between normal
                float2 diffNormal = abs(normal1 - normal2) * _SensitivityNormal;
                int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
                // check whether this line is edged or not
                float diffDepth = abs(depth1 - depth2) * _SensitivityDepth;
                int isSameDepth = diffDepth < 0.1 * depth1;
                return isSameDepth + isSameNormal == 2;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float4 depthNormal1 = tex2D(_CameraDepthNormalsTexture, i.uv_slash.xy);
                float4 depthNormal2 = tex2D(_CameraDepthNormalsTexture, i.uv_slash.zw);
                float4 depthNormal3 = tex2D(_CameraDepthNormalsTexture, i.uv_backSlash.xy);
                float4 depthNormal4 = tex2D(_CameraDepthNormalsTexture, i.uv_backSlash.zw);
                // isOnInternal
                half isOnInternalValue = 1;
                isOnInternalValue *= isOnInternal(depthNormal1, depthNormal2);
                isOnInternalValue *= isOnInternal(depthNormal3, depthNormal4);

                //color
                half4 texWithEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv), isOnInternalValue);
                half4 backgroundWithEdgeColor = lerp(_EdgeColor, _BackgroundColor, isOnInternalValue);
                return lerp(texWithEdgeColor, backgroundWithEdgeColor, _EdgeOnly);
            }
            ENDCG
        }
    }
    Fallback Off
}
