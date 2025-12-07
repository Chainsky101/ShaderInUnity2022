Shader "Unlit/Lambert_Pixel"
{
    Properties
    {
        _MainColor("MainColor",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "lightMode"="ForwardBase"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            float4 _MainColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 inputLight = normalize(_WorldSpaceLightPos0);
                // 漫反射光颜色 = 材质漫反射光颜色 * 光照 * cos α
                fixed3 col = _MainColor.rgb * _LightColor0.rgb * max(0, dot(inputLight,i.normal));
                col += UNITY_LIGHTMODEL_AMBIENT.rgb;
                return fixed4(col,1);
            }
            ENDCG
        }
    }
}