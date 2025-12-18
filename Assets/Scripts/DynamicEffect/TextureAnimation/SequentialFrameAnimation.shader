Shader "Unlit/SequentialFrameAnimation"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white"{}
        _RowCount("RowCount", Float) = 8
        _ColumnCount("ColumnCount", Float) = 8
        _FrameExchangeTime("FrameExchangeTime", Float) = 1
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "Queue"="Transparent"
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
            float _RowCount;
            float _ColumnCount;
            float _FrameExchangeTime;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 1.calculate frame index
                int index = floor(_Time.y * _FrameExchangeTime) % (_RowCount * _RowCount);
                // 2. calculate uv start point
                int rowIndex = floor(index / _RowCount);
                int columnIndex = index % _RowCount;
                float gridHeight = 1 / _RowCount;
                float gridWidth = 1 / _ColumnCount;
                fixed2 frameUVLeftDownPoint = fixed2(
                    columnIndex * gridWidth,
                    (_RowCount - 1 - rowIndex) * gridHeight);
                fixed2 uv = frameUVLeftDownPoint + fixed2(i.uv.x * gridWidth, i.uv.y * gridHeight);
                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
}
