Shader "Unlit/ProceduralTexture"
{
    Properties
    {
        _CountRowColumn("CountOfRowColumn", Float) = 8
        _Color1("Color1", Color) = (1,1,1,1)
        _Color2("Color2", Color) = (0,0,0,1)
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

            
            float _CountRowColumn;
            fixed4 _Color1;
            fixed4 _Color2;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = i.uv * _CountRowColumn;
                fixed2 gridIndex = floor(uv);
                // fixed4 col;
                // if((gridIndex.x + gridIndex.y) % 2 == 0)
                //     col = _Color1;
                // else
                // {
                //     col = _Color2;
                // }
                fixed value = (gridIndex.x + gridIndex.y) % 2;
                return lerp(_Color1, _Color2, value);
            }
            ENDCG
        }
    }
}
