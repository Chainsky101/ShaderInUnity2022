Shader "Unlit/NoiseFogEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogDensity ("FogDensity", Float) = 1
        _FogColor ("FogColor", Color) = (1,1,1,1)
        _Start ("Start", Float) = 0
        _End ("End", Float) = 5
//        _XSpeed("XSpeed", Range(-1,1))= 0.1
//        _YSpeed("YSpeed", Range(-1,1))= 0.1
//        _NoiseAmount ("NoiseAmount", Float) = 2
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        
        Pass
        {
            ZWrite On
            ZTest Off
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            // 纹素的大小
            float4 _MainTex_TexelSize;
            float _FogDensity;
            fixed4 _FogColor;
            float _Start;
            float _End;
            float _XSpeed;
            float _YSpeed;
            float4x4 _VertexDirMatrix;
            sampler2D _CameraDepthTexture;
            sampler2D _NoiseTex;
            float _NoiseAmount;

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half2 uv_depth : TEXCOORD1;
                float4 ray : TEXCOORD2;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv_depth = v.texcoord;
                // 0 - leftDown  1 - rightDown  2 - rightUp  3 - leftUp
                int index;
                if(o.uv.x < 0.5 && o.uv.y < 0.5)
                    index = 0;
                else if(o.uv.x > 0.5 && o.uv.y < 0.5)
                    index = 1;
                else if(o.uv.x > 0.5 && o.uv.y > 0.5)
                    index = 2;
                else
                    index = 3;

                // 检测坐标是否反转
                #if UNITY_UV_STARTS_AT_TOP
                    if(_MainTex_TexelSize.y < 0)
                    {
                        o.uv_depth.y = 1 - o.uv_depth.y;
                        index = 3 - index;                        
                    }
                #endif
                o.ray = _VertexDirMatrix[index];
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 雾效移动速度
                float2 speed = float2(_XSpeed, _YSpeed) * _Time.y;
                float noise = (tex2D(_NoiseTex, i.uv + speed).r - 0.5) * _NoiseAmount;
                // depth
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
                depth = LinearEyeDepth(depth);
                float3 posWorld = _WorldSpaceCameraPos + i.ray * depth;
                // f = (end - distance) / end - start
                // 采用高度相关的雾效
                fixed f = (_End - posWorld.y) / (_End - _Start);
                f = saturate(f * _FogDensity * (1+noise));
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = (1-f) * col.rgb + f * _FogColor.rgb;
                // col.rgb = lerp(col.rgb, _FogColor.rgb, f);
                return fixed4(col.rgb, 1);
            }
            ENDCG
        }
    }
    Fallback Off
}