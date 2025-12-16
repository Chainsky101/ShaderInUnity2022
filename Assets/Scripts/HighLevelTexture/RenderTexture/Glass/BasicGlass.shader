Shader "Unlit/BasicGlass"
{
    Properties
    {
        // 主纹理
        _MainTex("MainTex", 2D) = "white"{}
        // 立方体纹理
        _CubeMap("CubeMap", Cube) = "white"{}
        // 折射率 0~1 
        // 0：完全反射  1：完全折射
        _RefractionIndex("RefractionIndex", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            // 让玻璃对象滞后渲染
            "Queue" = "Transparent"
        }

        GrabPass {"_GrabTextureTest"}
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                // 世界空间下的反射向量，用于立方体纹理采样
                fixed3 reflectWorldDir : TEXCOORD0;
                // 储存从屏幕图像中采样的坐标
                float4 vertexScreenPos : TEXCOORD1;
                fixed2 uv : TEXCOORD2;
            };

            samplerCUBE _CubeMap;
            fixed _RefractionIndex;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            // GrabPass render texture
            sampler2D _GrabTextureTest;
            
            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                fixed3 lightWorldDir = normalize(UnityWorldSpaceLightDir(vertexWorldPos));
                fixed3 normalWorldDir = UnityObjectToWorldNormal(v.normal);
                o.reflectWorldDir = reflect(lightWorldDir, normalWorldDir);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.vertexScreenPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // reflect color
                fixed4 textureColor = tex2D(_MainTex, i.uv);
                fixed4 cubeMapColor = texCUBE(_CubeMap, i.reflectWorldDir);
                fixed4 reflectColor = textureColor * cubeMapColor;

                // 设置折射偏移
                fixed offset =  1-_RefractionIndex;
                i.vertexScreenPos = i.vertexScreenPos - offset * 0.1;
                
                // refract color
                // 透视除法
                fixed2 screenUV = i.vertexScreenPos.xy / i.vertexScreenPos.w;
                fixed4 refractColor = tex2D(_GrabTextureTest, screenUV);
                // 0：完全反射  1：完全折射
                fixed4 color = reflectColor * (1-_RefractionIndex) + refractColor * _RefractionIndex;
                return color;
            }
            ENDCG
        }
    }
}