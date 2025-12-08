Shader "Unlit/Phong_Fragment"
{
    Properties
    {
        _SpecularColor("SpecularColor",Color) = (1,1,1,1)
        _SpecularFactor("SpecularFactor",Range(0,40)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "LightMode"="ForwardBase"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 wNormal : NORMAL;//世界空间下的法线
                float3 wVertexPos:TEXCOORD0;//世界空间下的顶点位置
            };

            fixed4 _SpecularColor;
            float _SpecularFactor;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wNormal = UnityObjectToWorldNormal(v.normal);
                o.wVertexPos = mul(UNITY_MATRIX_M,v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //将顶点裁剪空间的坐标转换为世界坐标
                // float factor = determinant(UNITY_MATRIX_VP);
                // float4x4 reverseVP = transpose(UNITY_MATRIX_VP/factor);
                // float3 surfaceWorldSpace = mul(reverseVP,i.vertex);
                // fixed3 viewDir = normalize(_WorldSpaceCameraPos - surfaceWorldSpace);
                //UNITY_MATRIX_I_V
                // UNITY_MATRIX_IT_MV
                fixed3 viewDir = normalize(_WorldSpaceCameraPos - i.wVertexPos);
                fixed3 reflectDir = normalize(reflect(-_WorldSpaceLightPos0,i.wNormal));
                fixed3 col = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(viewDir, reflectDir)), _SpecularFactor);
                return fixed4(col,1);
            }
            ENDCG
        }
    }
}