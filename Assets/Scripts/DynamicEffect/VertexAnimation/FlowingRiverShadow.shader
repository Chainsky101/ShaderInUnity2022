Shader "Unlit/FlowingRiverShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _WaveAmplitude("WaveAmplitude", Float) = 1
        _WaveFrequency("WaveFrequency", Float) = 1
        _InvWaveLength("InvWaveLength", Float) = 1
        _UVSpeed("UVSpeed", Float) = 0.1
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "DisableBatching"="True"
        }
        Pass
        {
            ZWrite Off
            blend SrcAlpha OneMinusSrcAlpha
            
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
            float4 _MainTex_ST;
            fixed4 _Color;
            float _WaveAmplitude;
            float _WaveFrequency;
            float _InvWaveLength;
            float _UVSpeed;

            v2f vert (appdata_base v)
            {
                v2f o;
                // make offset in vertex
                v.vertex.x += sin(_Time.y * _WaveFrequency + v.vertex.z * _InvWaveLength) * _WaveAmplitude;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                // make offset in uv
                o.uv += float2(0, _Time.y * _UVSpeed);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= _Color;
                return col;
            }
            ENDCG
        }
        // Shadow Pass -- used to project shadow
        Pass
        {
            // 1. set LightMode equals to ShadowCaster
            Tags {"LightMode"="ShadowCaster"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 2. add compile command -- multi_compile_shadowcaster
            #pragma multi_compile_shadowcaster

            // 3. add header file
            #include "UnityCG.cginc"
            float _WaveAmplitude;
            float _WaveFrequency;
            float _InvWaveLength;
            

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                // make offset in vertex
                v.vertex.x += sin(_Time.y * _WaveFrequency + v.vertex.z * _InvWaveLength) * _WaveAmplitude;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            fixed4 frag(v2f o) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(o);
            }

            ENDCG
        }
    }
    
//    Fallback "Legacy Shaders/Specular" // can only display the original vertex
}
