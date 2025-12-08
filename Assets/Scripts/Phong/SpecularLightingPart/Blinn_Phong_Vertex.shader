Shader "Unlit/Blinn_Phong_Vertex"
{
    Properties
    {
        _SpecularColor("SpecularColor",Color) = (1,1,1,1)
        _SpecularFactor("SpecularFactor",Range(0,50)) = 1.5
    }
    SubShader
    {
        

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 color : COLOR;
            };

            float4 _SpecularColor;
            float _SpecularFactor;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed3 normalWorldVec = UnityObjectToWorldNormal(v.normal);
                fixed3 viewVec = normalize(_WorldSpaceCameraPos - mul(UNITY_MATRIX_M, v.vertex));
                fixed3 semi_Input_View = normalize(viewVec + normalize(_WorldSpaceLightPos0));  // 计算入射光和视口光线的角平分线
                o.color = _SpecularColor * _LightColor0 * pow(max(0,dot(semi_Input_View,normalWorldVec)),_SpecularFactor);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color,1);
            }
            ENDCG
        }
    }
}