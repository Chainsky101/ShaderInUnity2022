Shader "Unlit/SemiLambertVertex"
{
    Properties
    {
        _MainColor("MainColor",Color) = (1,1,1,1)
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
                float3 color : COLOR;
            };

            float4 _MainColor;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed3 normal = UnityObjectToWorldNormal(v.normal);
                fixed3 inputLight = normalize(_WorldSpaceLightPos0);
                o.color = _LightColor0.rgb * _MainColor.rgb * (dot(normal,inputLight)*0.5 + 0.5);
                o.color += UNITY_LIGHTMODEL_AMBIENT.rgb;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color,1);
            }
            ENDCG
        }
    }
}
