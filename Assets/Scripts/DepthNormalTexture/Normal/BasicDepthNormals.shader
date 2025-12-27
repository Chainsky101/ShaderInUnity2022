Shader "Custom/SimpleDepthNormals_Fixed"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "Queue"="Geometry"
        }
        
        // Pass 1: 主渲染Pass（ForwardBase）
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                SHADOW_COORDS(2)
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o)
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed4 col = texColor * _Color;
                
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed diff = max(0, dot(worldNormal, worldLight));
                fixed3 diffuse = _LightColor0.rgb * col.rgb * diff;
                
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * col.rgb;
                
                fixed3 finalColor = ambient + diffuse * shadow;
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
        
        // Pass 2: DepthNormals Pass（修正版）
        Pass
        {
            Name "DepthNormals"
            Tags { "LightMode" = "DepthNormals" }
            
            ZWrite On
            ZTest LEqual
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 viewNormal : TEXCOORD0;
                float depth : TEXCOORD1;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                // 计算视图空间法线
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, worldNormal);
                o.viewNormal = normalize(viewNormal);
                
                // 计算线性深度（视图空间深度）
                // 注意：视图空间中相机看向-Z方向
                float3 viewPos = mul(UNITY_MATRIX_MV, v.vertex).xyz;
                o.depth = -viewPos.z;  // 线性深度
                
                return o;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                // 归一化法线
                float3 normal = normalize(i.viewNormal);
                
                // 法线编码（RG通道）
                // Unity的标准编码方式
                float2 encodedNormal;
                float scale = 1.7777;
                encodedNormal = normal.xy / (normal.z + 1.0);
                encodedNormal /= scale;
                encodedNormal = encodedNormal * 0.5 + 0.5;
                
                // 深度编码（BA通道）
                // 将线性深度映射到[0,1]范围
                float depth01 = i.depth / _ProjectionParams.z;  // _ProjectionParams.z是远裁剪面
                depth01 = saturate(depth01);
                
                // 16位浮点编码
                float2 encodedDepth;
                encodedDepth = float2(1.0, 255.0) * depth01;
                encodedDepth = frac(encodedDepth);
                encodedDepth.x -= encodedDepth.y * (1.0 / 255.0);
                
                // 返回完整的深度法线编码
                return float4(encodedNormal, encodedDepth);
            }
            ENDCG
        }
        
        // Pass 3: Shadow Caster Pass
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            ZWrite On
            ZTest LEqual
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            
            #include "UnityCG.cginc"
            
            struct v2f {
                V2F_SHADOW_CASTER;
            };
            
            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }
            
            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    
    Fallback "Standard"
}