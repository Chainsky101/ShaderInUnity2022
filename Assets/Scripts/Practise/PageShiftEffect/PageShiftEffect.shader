Shader "Unlit/PageShiftEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CoverTex ("CoverTex", 2D) = "white" {}
        _Amplitude ("Amplitude", Float) = 3
        _WaveLength ("WaveLength", Range(0, 1)) = 1
        _Scale ("Scale", Range(0,1)) = 0.2
        _WidthTex ("WidthTex", Float) = 128
        _MoveSpeed ("MoveSpeed", Float) = 4
//        _AngleProgress ("AngleProgress", Float) = 0
        _Open ("IsOpen", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        
        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CoverTex;
            float _WidthTex;
            float _Amplitude;
            float _WaveLength;
            half _Scale;
            half _Open; // 1 -> open book   0-> close book
            float _MoveSpeed;
            float _AngleProgress = 0;

            v2f vert (appdata_base v)
            {
                v2f o;
                // translate the vertex
                // tranfer x and y
                // if(_Open == 1)
                // {
                //     _AngleProgress += _Time.w*_MoveSpeed;
                //     if(_AngleProgress > 180)
                //         _Open = 0;
                // }
                // else
                // {
                //     _AngleProgress -= _Time.w*_MoveSpeed;
                //     if(_AngleProgress < 0)
                //         _Open = 1;
                // }
                // translate and rotate
                // translate half width to positive infinite of x axis
                _AngleProgress = sin(_Time.y * _MoveSpeed) * 90.0 + 90.0;
                v.vertex.x += _WidthTex / 2;
                // 波动感
                half factor = 1 - abs(90 - _AngleProgress) / 90;
                v.vertex.x -= v.vertex.x *factor*_Scale;
                v.vertex.y += sin(v.vertex.x * _WaveLength) * factor * _Amplitude;
                float s = sin(radians(_AngleProgress));
                float c = cos(radians(_AngleProgress));
                // rotate around z axis
                 float4x4 Matrix = fixed4x4(
                     c, -s, 0, 0,
                     s, c, 0, 0,
                     0, 0, 1, 0,
                     0, 0, 0, 1
                 );
                float4 pos = mul(Matrix, v.vertex);
                // translate half width back
                pos.x -= _WidthTex / 2;
                o.vertex = UnityObjectToClipPos(pos);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i, half face : VFACE) : SV_Target
            {
                return face < 0 ? tex2D(_MainTex, i.uv) : tex2D(_CoverTex, i.uv);
            }
            ENDCG
        }
    }
}
