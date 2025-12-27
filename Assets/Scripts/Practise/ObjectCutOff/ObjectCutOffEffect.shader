Shader "Unlit/ObjectCutOffEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _InternalTex("InternalTex", 2D) = "white"{}
        // x -- 0, y -- 1, z -- 2
        _CutOffDir ("CutOffDir", Float) = 0
        // 1 -- invert, -1 -- don't Invert
        _Invert ("Invert", Float) = -1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
                float3 vertexWorldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _InternalTex;
            float3 _CutOffPos;
            half _CutOffDir;
            half _Invert;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                return o;
            }

            half isClip(in float3 pos)
            {
                // cut off x axis
                if(_CutOffDir == 0)
                {
                    if((_CutOffPos.x - pos.x) * _Invert > 0)
                        return 1;
                }
                // cut off y axis
                else if(_CutOffDir == 1)
                {
                    if((_CutOffPos.y - pos.y) * _Invert > 0)
                        return 1;
                }
                // cut off z axis
                else if(_CutOffDir == 2)
                {
                    if((_CutOffPos.z - pos.z) * _Invert > 0)
                        return 1;
                }
                return 0;
            }
            
            fixed4 frag (v2f i, fixed face : VFACE) : SV_Target
            {
                // check out clip
                if(isClip(i.vertexWorldPos))
                    clip(-1);
                // sample the texture
                fixed4 col = face > 0? tex2D(_MainTex, i.uv) : tex2D(_InternalTex, i.uv) ;
                return col;
            }
            ENDCG
        }
    }
    Fallback "Legacy Shaders/Diffuse"
}
