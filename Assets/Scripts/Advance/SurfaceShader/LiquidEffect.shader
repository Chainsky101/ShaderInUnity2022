Shader "Custom/LiquidEffect"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _LiquidHeight ("LiquidHeight", Float) = 0
        _WaveFrequency ("WaveFrequency", Float) = 1
        _InverseWaveLength ("InverseWaveLength", Float) = 1
        _WaveAmplitude ("WaveAmplitude", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        Blend DstColor SrcColor
        ZWrite Off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard noshadow 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        float _LiquidHeight;
        float _WaveFrequency;
        float _InverseWaveLength;
        float _WaveAmplitude;
        fixed4 _Color;
        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };
        void surf (Input IN, inout SurfaceOutputStandard o) {
            // check the point
            float3 central = mul(unity_ObjectToWorld, float4(0,0,0,1));
            float distance = central.y - IN.worldPos.y + _LiquidHeight * 0.01;
            float ripple = sin(_Time.y *_WaveFrequency + IN.worldPos.x * _InverseWaveLength) * _WaveAmplitude;
            distance += ripple;
            half isClip = step(0, distance);
            clip(isClip-0.01);
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
