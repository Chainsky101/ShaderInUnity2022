Shader "Unlit/PerFragment"
{
    Properties
    {
        _MainColor("MainColor",Color) = (1,1,1,1)
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
                float3 normalWorldVec : NORMAL;
                float3 vertexWorldPos : TEXCOORD0;
            };

            float4 _MainColor;
            float4 _SpecularColor;
            float _SpecularFactor;

            // get color of diffuse reflection 
            fixed3 getLambertColor(fixed3 normal)
            {
                return _MainColor * _LightColor0 * max(0,dot(normal,_WorldSpaceLightPos0));
            }

            // get color of specular
            fixed3 getSpecularColor(float3 vertexWorldPos, fixed3 normalWorldVec)
            {
                //normalized reflect ray
                fixed3 reflectVec = normalize(reflect(-_WorldSpaceLightPos0,normalWorldVec));
                //normalized view ray
                fixed3 viewVec = normalize(_WorldSpaceCameraPos - vertexWorldPos);
                //Phong speculat light mode
                return _SpecularColor * _LightColor0 * pow(max(0, dot(reflectVec, viewVec)), _SpecularFactor);
            }
            
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
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT;
                color += getLambertColor(i.normalWorldVec) + getSpecularColor(i.vertexWorldPos,i.normalWorldVec);
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}