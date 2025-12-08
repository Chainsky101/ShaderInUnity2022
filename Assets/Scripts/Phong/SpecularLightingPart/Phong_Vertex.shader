Shader "Unlit/Phong_Vertex"
{
    Properties
    {
        _MainColor("MainColor",Color) = (1,1,1,1)
        _MainHighLightFactor("MainHighLightFactor",Range(0,40)) = 1.5
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

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
                fixed3 color : COLOR;
            };

            fixed4 _MainColor;
            float _MainHighLightFactor;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //高光反射光照颜色 = 光源的颜色 * 材质的漫反射颜色 * max( 0, 反射光线和视角光线的余弦值) ^ n
                //计算反射光线
                fixed3 reflectV = normalize(reflect(-_WorldSpaceLightPos0,UnityObjectToWorldNormal(v.normal)));
                //计算视角光线
                fixed3 worldPos = mul(UNITY_MATRIX_M,v.vertex);
                fixed3 viewV = normalize(_WorldSpaceCameraPos - worldPos);
                o.color = _LightColor0.rgb * _MainColor.rgb * pow(max(0, dot(reflectV,viewV)),_MainHighLightFactor);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color,1);
                // fixed3 viewDir = normalize(_WorldSpaceCameraPos - i.wVertexPos);
                // fixed3 reflectDir = normalize(reflect(-_WorldSpaceLightPos0,i.wNormal));
                // fixed3 col = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(viewDir, reflectDir)), _SpecularFactor);
                // return fixed4(col,1);
            }
            ENDCG
        }
    }
}
