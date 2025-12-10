Shader "Unlit/GradientSimple"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        _GradientTexture("GradientTexture", 2D) = ""{}
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        _SpecularFactor("SpecularFactor", Range(1,40)) = 10
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
                float3 vertexWorldPos : TEXCOORD0;
                float3 normalWorldDir : TEXCOORD1;
                // fixed2 uvGradient : TEXCOORD2;
            };

            fixed4 _MainColor;
            sampler2D _GradientTexture;
            float4 _GradientTexture_ST;
            fixed4 _SpecularColor;
            float _SpecularFactor;
            

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.normalWorldDir = UnityObjectToWorldNormal(v.normal);
                // o.uvGradient = v.texcoord * _GradientTexture_ST.xy + _GradientTexture_ST.zw;
                return o;
            }

            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 lightWorldDir = normalize(_WorldSpaceLightPos0);
                // fixed3 viewWorldDir = normalize(_WorldSpaceCameraPos-i.vertexWorldPos);
                fixed3 viewWorldDir = normalize(UnityWorldSpaceViewDir(i.vertexWorldPos));
                fixed3 semi_light_view = normalize(lightWorldDir + viewWorldDir);
                // get the gradient color
                fixed uv = dot(lightWorldDir, i.normalWorldDir) * 0.5 + 0.5;
                fixed3 gradientColor = tex2D(_GradientTexture, fixed2(uv,uv));
                // use gradient color to calculate diffuse color
                fixed3 lambertLightColor = _LightColor0.rgb * _MainColor.rgb * gradientColor;
                fixed3 specularLightColor = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(semi_light_view, i.normalWorldDir)), _SpecularFactor);
                fixed3 col = UNITY_LIGHTMODEL_AMBIENT.rgb + lambertLightColor + specularLightColor;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
