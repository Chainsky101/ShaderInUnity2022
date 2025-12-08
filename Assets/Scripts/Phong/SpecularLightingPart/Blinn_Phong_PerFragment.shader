Shader "Unlit/Blinn_Phong_PerFragment"
{
    Properties
    {
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        _SpecularFactor("SpecularFactor", Range(0,50)) = 4
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
                float3 normalWorldVec : NORMAL;
                float3 vertexWorldPos : TEXCOORD0;
            };

            float4 _SpecularColor;
            float _SpecularFactor;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normalWorldVec = UnityObjectToWorldNormal(v.normal);
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 halfVector = normalize(normalize(_WorldSpaceLightPos0) + normalize(_WorldSpaceCameraPos - i.vertexWorldPos));
                // 高亮光颜色 * 光源颜色 * (片元法线 与 入射光和视角的半角向量 的余弦值)的幂
                fixed3 col = _SpecularColor * _LightColor0 * pow(max(0, dot(halfVector,i.normalWorldVec)), _SpecularFactor);
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}