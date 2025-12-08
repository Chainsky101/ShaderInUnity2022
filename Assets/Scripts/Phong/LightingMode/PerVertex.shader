Shader "Unlit/PerVertex"
{
    Properties
    {
        _MainColor("MainColor",Color) = (1,1,1,1)
        _SpecularColor("SpecularColor",Color) = (1,1,1,1)
        _SpecularFactor("SpecularFactor",Range(0,50)) = 1.5
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
                fixed3 color : COLOR;
            };

            float4 _MainColor;
            float4 _SpecularColor;
            float _SpecularFactor;

            //Lambert漫反射光颜色—— Lambert Light Mode
            fixed3 getLambertLightColor(in fixed3 normalWorldVec)
            {
                return _LightColor0 * _MainColor * max(0,dot(normalWorldVec,normalize(_WorldSpaceLightPos0)));
            }

            //phong高光反射光颜色
            fixed3 getPhongSpecularLightColor(in float4 vertex,in fixed3 normalWorldVec)
            {
                //世界空间下的发射反射光方向
                fixed3 reflectWorldVec = normalize(reflect(-_WorldSpaceLightPos0,normalWorldVec));
                //时间空间下的视口方向
                // fixed3 viewWorldVec = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld,v.vertex));
                fixed3 viewWorldVec = normalize(_WorldSpaceCameraPos - mul(UNITY_MATRIX_M,vertex));
                return _LightColor0 * _SpecularColor * pow(max(0,dot(reflectWorldVec,viewWorldVec)),_SpecularFactor);
            }
            
            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed3 normalWorldVec = UnityObjectToWorldNormal(v.normal);
                // 环境光颜色
                o.color = UNITY_LIGHTMODEL_AMBIENT;
                //漫反射光颜色—— Lambert Light Mode
                o.color += getLambertLightColor(normalWorldVec);
                //世界空间下的发射反射光方向
                fixed3 reflectWorldVec = normalize(reflect(-_WorldSpaceLightPos0,normalWorldVec));
                //时间空间下的视口方向
                // fixed3 viewWorldVec = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld,v.vertex));
                fixed3 viewWorldVec = normalize(_WorldSpaceCameraPos - mul(UNITY_MATRIX_M,v.vertex));
                o.color += getPhongSpecularLightColor(v.vertex,normalWorldVec);
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