Shader "Unlit/SketchEffect"
{
    Properties
    {
        // 整体颜色叠加
        _Color ("Color", Color) = (1,1,1,1)
        // 平铺系数
        _TileFactor ("TileFactor", Float) = 1
        // 6张纹理
        _Sketch1 ("Sketch1", 2D) = "white" {}
        _Sketch2 ("Sketch2", 2D) = "white" {}
        _Sketch3 ("Sketch3", 2D) = "white" {}
        _Sketch4 ("Sketch4", 2D) = "white" {}
        _Sketch5 ("Sketch5", 2D) = "white" {}
        _Sketch6 ("Sketch6", 2D) = "white" {}
        
        _EdgeSize ("EdgeSize", Float) = 0.1
        _EdgeColor ("EdgeColor", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            half4 _EdgeColor;
            half _EdgeSize;

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };
            v2f vert(appdata_base v)
            {
                v2f o;
                float3 pos = v.vertex + normalize(v.normal) * _EdgeSize;
                o.vertex = UnityObjectToClipPos(pos); 
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _EdgeColor;
            }
            ENDCG
        }
        
        Pass
        {
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            struct v2f
            {
                float4 vertex : SV_POSITION;
                half2 uv : TEXCOORD0;
                fixed3 weight1 : TEXCOORD1;
                fixed3 weight2 : TEXCOORD2;
                SHADOW_COORDS(3)
                float3 vertexWorldPos : TEXCOORD4;
            };

            half4 _Color;
            float _TileFactor;
            sampler2D _Sketch1;
            sampler2D _Sketch2;
            sampler2D _Sketch3;
            sampler2D _Sketch4;
            sampler2D _Sketch5;
            sampler2D _Sketch6;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _TileFactor;
                // calculate diffuse factor
                o.vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                half3 lightWorldDir = normalize(UnityWorldSpaceLightDir(o.vertexWorldPos));
                half3 normalWorldDir = UnityObjectToWorldNormal(v.normal);
                float diffuseFactor =  max(0, dot(normalWorldDir, lightWorldDir)) * 7;
                o.weight1 = fixed3(0, 0, 0);
                o.weight2 = fixed3(0, 0, 0);
                if(diffuseFactor < 1)
                {
                    o.weight2.y = diffuseFactor;
                    o.weight2.z = 1 - o.weight2.y;
                }else if(diffuseFactor < 2)
                {
                    o.weight2.x = diffuseFactor - 1;
                    o.weight2.y = 1 - o.weight2.x;
                }else if(diffuseFactor < 3)
                {
                    o.weight1.z = diffuseFactor - 2;
                    o.weight2.x = 1 - o.weight1.z;
                }else if(diffuseFactor < 4)
                {
                    o.weight1.y = diffuseFactor - 3;
                    o.weight1.z = 1 - o.weight1.y;
                }else if(diffuseFactor < 5)
                {
                    o.weight1.x = diffuseFactor - 4;
                    o.weight1.y = 1 - o.weight1.x;
                }else if(diffuseFactor < 6)
                    o.weight1.x = diffuseFactor - 5;
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // six sketches color
                half3 sketchColor1 = tex2D(_Sketch1, i.uv) * i.weight1.x;
                half3 sketchColor2 = tex2D(_Sketch2, i.uv) * i.weight1.y;
                half3 sketchColor3 = tex2D(_Sketch3, i.uv) * i.weight1.z;
                half3 sketchColor4 = tex2D(_Sketch4, i.uv) * i.weight2.x;
                half3 sketchColor5 = tex2D(_Sketch5, i.uv) * i.weight2.y;
                half3 sketchColor6 = tex2D(_Sketch6, i.uv) * i.weight2.z;
                half3 whiteColor = half3(1,1,1) *
                    (1-i.weight1.x-i.weight1.y-i.weight1.z-i.weight2.x-i.weight2.y-i.weight2.z);
                half3 col = sketchColor1 + sketchColor2 + sketchColor3 + sketchColor4 +
                            sketchColor5 + sketchColor6 + whiteColor;
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertexWorldPos)
                col *= attenuation * _Color.rgb;
                // sample the texture
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
    Fallback "Legacy Shaders/Diffuse"
}
