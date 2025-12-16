Shader "Unlit/BumpGlass"
{
    Properties
    {
        // 主纹理
        _MainTex("MainTex", 2D) = "white"{}
        // 立方体纹理
        _CubeMap("CubeMap", Cube) = "white"{}
        //法线纹理
        _BumpMap("BumpMap", 2D) = "white"{}
        // 折射率 0~1 
        // 0：完全反射  1：完全折射
        _RefractionIndex("RefractionIndex", Range(0, 1)) = 0
        //控制折射的扭曲程度
        _Distortion("Distortion", Range(0, 10)) = 0
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
                fixed3 lightWorldDir : TEXCOORD0;
                // 储存从屏幕图像中采样的坐标
                float4 grabScreenPos : TEXCOORD1;
                // uv.xy -> mainTexture
                // uv.zw -> bumpMap
                fixed4 uv : TEXCOORD2;
                fixed3 firstRowMatrixTtoW : TEXCOORD3;
                fixed3 secondRowMatrixTtoW : TEXCOORD4;
                fixed3 thirdRowMatrixTtoW : TEXCOORD5;
            };

            samplerCUBE _CubeMap;
            fixed _RefractionIndex;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            // GrabPass render texture
            sampler2D _GrabTextureTest;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed _Distortion;
            
            v2f vert(appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.lightWorldDir = normalize(UnityWorldSpaceLightDir(vertexWorldPos));
                fixed3 normalWorldDir = UnityObjectToWorldNormal(v.normal);
                fixed3 tangentWorldDir = UnityObjectToWorldDir(v.tangent);
                fixed3 yAxisWorldDir = cross(normalWorldDir, tangentWorldDir) * v.tangent.w;
                o.firstRowMatrixTtoW = fixed3(tangentWorldDir.x, yAxisWorldDir.x, normalWorldDir.x);
                o.secondRowMatrixTtoW = fixed3(tangentWorldDir.y, yAxisWorldDir.y, normalWorldDir.y);
                o.thirdRowMatrixTtoW = fixed3(tangentWorldDir.z, yAxisWorldDir.z, normalWorldDir.z);
                // o.reflectWorldDir = reflect(lightWorldDir, normalWorldDir);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                o.grabScreenPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // calculate reflect
                float3 normalTangentDir = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                float3 normalWorldDir = float3(
                    dot(normalTangentDir, i.firstRowMatrixTtoW),
                    dot(normalTangentDir, i.secondRowMatrixTtoW),
                    dot(normalTangentDir, i.thirdRowMatrixTtoW)
                    );
                float3 reflectWorldDir = reflect(-i.lightWorldDir, normalWorldDir);
                
                // reflect color
                fixed4 textureColor = tex2D(_MainTex, i.uv.xy);
                fixed4 cubeMapColor = texCUBE(_CubeMap, reflectWorldDir);
                fixed4 reflectColor = textureColor * cubeMapColor;

                // 设置折射偏移
                float2 offset =  normalTangentDir.xy * _Distortion;
                i.grabScreenPos.xy = i.grabScreenPos.xy + offset * i.grabScreenPos.z;
                
                // refract color
                // 透视除法
                fixed2 screenUV = i.grabScreenPos.xy / i.grabScreenPos.w;
                fixed4 refractColor = tex2D(_GrabTextureTest, screenUV);
                // 0：完全反射  1：完全折射
                fixed4 color = reflectColor * (1-_RefractionIndex) + refractColor * _RefractionIndex;
                return color;
            }
            ENDCG
        }
    }
}
