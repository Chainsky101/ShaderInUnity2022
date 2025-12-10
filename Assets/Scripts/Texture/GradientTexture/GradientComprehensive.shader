Shader "Unlit/GradientComprehensive"
{
        Properties
    {
    	// 主纹理
        _MainTex ("Texture", 2D) = "white" {}
    	// 法线纹理
    	_BumpMap("BumpMap", 2D) = "white"{}
    	// 凸块缩放
    	_BumpScale("BumpScale", Range(-10,10)) = 1
    	// 渐变纹理
    	_GradientTex("GradientTex",2D) = "white"{}
    	// 漫反射颜色
    	_MainColor("MainColor", Color) = (1,1,1,1)
    	// 高光反射颜色
    	_SpecularColor("SpecularColor", Color) = (1,1,1,1)
    	// 高光反射系数
    	_SpecularFactor("SpecularFactor", Range(0,40)) = 10
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
				float4 vertex : SV_POSITION;
				// also can declare one float4 to record two uvs
				// float4 uv : TEXCOORD0
				// uv.xy = uvTex
				// uv.zw = uvBump
				float2 uvTex : TEXCOORD0;
				float2 uvBump : TEXCOORD1;
				fixed3 lightTangentSpaceDir : TEXCOORD2;
				fixed3 viewTangentSpaceDir : TEXCOORD3;
			};

			sampler2D _MainTex; // 颜色纹理
			float4 _MainTex_ST; // 颜色纹理的平移和缩放
			sampler2D _BumpMap; // 法线纹理
			float4 _BumpMap_ST; // 法线纹理的平移和缩放
			float _BumpScale;	// 法线凹凸程度
			sampler2D _GradientTex; // 渐变纹理
			float4 _GradientTex_ST; // 渐变纹理的平移和缩放
			fixed4 _MainColor;	// 漫反射颜色
			fixed4 _SpecularColor;	// 高光反射颜色
			float _SpecularFactor;	// 光泽度
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				// how to differentiate texcoord and texcoord1?
				// direct use the same texcoord
				o.uvTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uvBump = v.texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
				fixed3 lightModelSpaceDir = normalize(ObjSpaceLightDir(v.vertex));
				fixed3 viewModelSpaceDir = normalize(ObjSpaceViewDir(v.vertex));
				// get the transfer matrix from model space to tangent space
				fixed3 xAxis = normalize(v.tangent);
				fixed3 zAxis = normalize(v.normal);
				// use v.tangent.w to get the real y-Axis direction
				fixed3 yAxis = cross(xAxis, zAxis) * v.tangent.w;
				fixed3x3 Matrix_MtoT = {xAxis,yAxis,zAxis};
				o.lightTangentSpaceDir = normalize(mul(Matrix_MtoT, lightModelSpaceDir));
				o.viewTangentSpaceDir = normalize(mul(Matrix_MtoT, viewModelSpaceDir));
				return o;
			}

			fixed3 getAmbientColor(in fixed3 albedo)
			{
				return UNITY_LIGHTMODEL_AMBIENT * albedo;
			}

			fixed3 getLambertDiffuseLightColor(in fixed3 normalTangentDir, in fixed3 lightTangentDir, in fixed3 albedo)
			{
				return _LightColor0 * albedo * max(0,dot(normalTangentDir, lightTangentDir));
			}

			fixed3 getSpecularLightColor(in fixed3 semi_light_view, in fixed3 normalTangentDir)
			{
				return _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(semi_light_view, normalTangentDir)), _SpecularFactor);
			}

			fixed3 getSemiLambertDiffuseLightColor(in fixed3 albedo, in fixed3 gradientColor)
			{
				return _LightColor0 * albedo * gradientColor;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// get the color representation of normal, and then unpack it.
				// normal in tangent world
				fixed3 normal = UnpackNormal(tex2D(_BumpMap, i.uvBump));
				normal.xy *= _BumpScale;
				normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
				// main texture color
				fixed3 textureColor = tex2D(_MainTex, i.uvTex);
				// albedo
				fixed3 blendingColor = textureColor * _MainColor.rgb;
				// claculate the semi_light_view in tangentSpace
				fixed3 semi_light_view = normalize(i.lightTangentSpaceDir + i.viewTangentSpaceDir);
				// gradient color
				fixed semiLambertFactor = dot(normal, i.lightTangentSpaceDir) * 0.5 + 0.5;
				fixed3 gradientColor = tex2D(_GradientTex,fixed2(semiLambertFactor,semiLambertFactor));
				
				fixed3 color = getAmbientColor(blendingColor)	// 环境光颜色
					+ getSemiLambertDiffuseLightColor(blendingColor, gradientColor)		//漫反射光颜色
					+ getSpecularLightColor(semi_light_view, normal);		//高光反射光颜色
				return fixed4(color,1);
			}
			ENDCG
        }
    }
}