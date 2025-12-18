Shader "Unlit/BillboardEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _VerticalBillboardRatio("VerticalBillboardRatio", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "DisableBatching"="True"
        }

        Pass
        {
            ZWrite Off
            blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _VerticalBillboardRatio;

            v2f vert (appdata_base v)
            {
                v2f o;
                // construct customized space
                float3 centerObjectPos = float3(0, 0, 0);
                // float3 centerWorldPos = mul(UNITY_MATRIX_M, centerObjectPos);
                // // solution1:calculate normal
                // float3 viewWorldDir = normalize(centerWorldPos - _WorldSpaceCameraPos);
                // // float3 viewWorldDir = normalize(UnityWorldSpaceViewDir(centerWorldPos));
                // fixed3 normalCustomized = UnityWorldToObjectDir(viewWorldDir);
                // solution2:calculate normal
                float3 cameraObjectPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1));
                fixed3 normalCustomized = normalize(cameraObjectPos - centerObjectPos);
                // construct Axis-around billboard
                // normalCustomized.y = 0;
                normalCustomized.y *= _VerticalBillboardRatio;
                //防止normalCustomized和预设的upAxisDir重合
                fixed3 upAxisDir = normalCustomized.y > 0.999? fixed3(0, 0, 1) : fixed3(0, 1, 0);
                fixed3 xAxisDir = normalize(cross(normalCustomized, upAxisDir));
                upAxisDir = normalize(cross(normalCustomized, xAxisDir));
                //get the new vertex in world space
                float3 offset = v.vertex - centerObjectPos;
                float3 newVertexObjectPos = centerObjectPos +
                    offset.x * xAxisDir + offset.y * upAxisDir + offset.z * normalCustomized;
                o.vertex = UnityObjectToClipPos(float4(newVertexObjectPos,1));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            // v2f vert (appdata_base v)
            // {
            //     v2f o;
            //     
            //     // 1. 获取模型中心在世界空间的位置
            //     float3 centerWorldPos = mul(UNITY_MATRIX_M, float4(0, 0, 0, 1)).xyz;
            //     
            //     // 2. 计算从中心指向相机的方向（相机→中心）
            //     float3 viewDir = normalize(centerWorldPos - _WorldSpaceCameraPos);
            //     
            //     // 3. 计算右向量和上向量（保持垂直方向）
            //     float3 up = float3(0, 1, 0);
            //     float3 right = normalize(cross(up, viewDir));
            //     up = normalize(cross(viewDir, right));  // 重新计算确保正交
            //     
            //     // 4. 获取顶点在模型空间的偏移
            //     float3 offset = v.vertex.xyz;
            //     
            //     // 5. 重建顶点（在模型空间或世界空间）
            //     // 这里需要在世界空间构建
            //     float3 worldPos = centerWorldPos + 
            //                      offset.x * right + 
            //                      offset.y * up + 
            //                      offset.z * viewDir;
            //     
            //     o.vertex = UnityWorldToClipPos(worldPos);
            //     o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            //     return o;
            // }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
