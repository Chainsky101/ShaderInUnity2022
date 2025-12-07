Shader "Unlit/SemiLambertFragment"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
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
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
            };

            float4 _MainColor;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 inputLight = normalize(_WorldSpaceLightPos0);
                fixed3 color = _MainColor.rgb * _LightColor0.rgb * (dot(inputLight,i.normal)*0.5 + 0.5);
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}