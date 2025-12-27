Shader "Unlit/BumpTextureInWorldSpace"
{
    Properties
    {
        _MainTexture("MainTexture", 2D) = "white"{}
        _BumpMap("BumpMap", 2D) = "white"{}
        _BumpScale("BumpScale", Range(-10,10)) = 1
        _MainColor("MainColor", Color) = (1,1,1,1)
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        _SpecularFactor("SpecularFactor", Range(0, 40)) = 10
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                    "LightMode"="ForwardBase"
    //            "Queue"="AlphaTest"
    //            "IgnoreProjector"="Ture"
    //            "RenderType"="TransparentCutout"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                // uv.xy used to record the uv of _MainTexture
                // uv.wz used to record the uv of _BumpMap
                float4 uv : TEXCOORD0;
                // xAxisWorldDir.xyz used to record dir of x-Axis
                // xAxisWorldDir.w used to specify the dir of y-Axis
                /*
                 *calculate transfer matrix from tangent space to world space in frag callback fuction
                 *fixed4 xAxisWorldDir : TEXCOORD2;
                 *fixed3 zAxisWorldDir : TEXCOORD3;
                 */
                
                // float4 vertexWorldPos : TEXCOORD1;
                // fixed3x3 Matrix_TtoW : TEXCOORD2;
                //optimization: used three float4 datatype to store vertexWorldPos and Matrix_TtoW
                float4 MatrixFirst : TEXCOORD1;
                float4 MatrixSecond : TEXCOORD2;
                float4 MatrixThird : TEXCOORD3;
                UNITY_FOG_COORDS(4)
            };

            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _MainColor;
            fixed4 _SpecularColor;
            float _SpecularFactor;

            v2f vert(appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTexture);
                o.uv.zw = v.texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 vertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                /*
                 *calculate transfer matrix from tangent space to world space in frag callback fuction
                 *o.xAxisWorldDir.xyz = UnityObjectToWorldDir(v.tangent);
                 *o.xAxisWorldDir.w = v.tangent.w;
                 *o.zAxisWorldDir = UnityObjectToWorldNormal(v.normal);
                 */
                
                fixed3 xAxisWorldDir = UnityObjectToWorldDir(v.tangent);
                fixed3 zAxisWorldDir = UnityObjectToWorldNormal(v.normal);
                fixed3 yAxisWorldDir = cross(zAxisWorldDir, xAxisWorldDir) * v.tangent.w;
                fixed3x3 Matrix_TtoW = fixed3x3(xAxisWorldDir, yAxisWorldDir, zAxisWorldDir);
                o.MatrixFirst = fixed4(Matrix_TtoW[0], vertexWorldPos.x);
                o.MatrixSecond = fixed4(Matrix_TtoW[1], vertexWorldPos.y);
                o.MatrixThird = fixed4(Matrix_TtoW[2], vertexWorldPos.z);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed3 getAmbientLightColor(in fixed3 albedo)
            {
                return UNITY_LIGHTMODEL_AMBIENT * albedo;
            }

            fixed3 getLambertDiffuseLightColor(in fixed3 normal, in fixed3 albedo)
            {
                return _LightColor0.rgb * albedo * max(0, dot(normal, normalize(_WorldSpaceLightPos0.xyz))); 
            }

            fixed3 getSpecularLightColor(in fixed3 normal, in fixed3 viewWorldDir)
            {
                fixed3 semi_light_view = normalize(viewWorldDir + normalize(_WorldSpaceLightPos0.xyz));
                return _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(normal, semi_light_view)), _SpecularFactor);
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                //solution2: calculate matix in frag callback function
                // get the transfer matrix from tangent space to world space
                // fixed3 yAxisWorldDir = cross(i.xAxisWorldDir.xyz, i.zAxisWorldDir) * i.xAxisWorldDir.w;
                // fixed3x3 Matrix_TtoW = { i.xAxisWorldDir.xyz,yAxisWorldDir,i.zAxisWorldDir };
                // Matrix_TtoW = transpose(Matrix_TtoW);

                // handle the data from v2f
                // direct to multiply normalTangentDir
                // fixed3x3 Matrix_TtoW = fixed3x3(
                //     i.MatrixFirst.xyz,
                //     i.MatrixSecond.xyz,
                //     i.MatrixThird.xyz);
                float3 vertexWorldPos = float3(i.MatrixFirst.w, i.MatrixSecond.w, i.MatrixThird.w);
                // calculate normal direction in World space
                float3 normalTangentDir = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                // transfer normal dir from tangent space to world space
                // do BumpScale in the tangent world
                normalTangentDir.xy *= _BumpScale;
                normalTangentDir.z = sqrt(1.0 - saturate(dot(normalTangentDir.xy, normalTangentDir.xy)));
                // float3 normalTangentDir = UnpackScaleNormal(tex2D(_BumpMap, i.uv.zw), _BumpScale);
                fixed3 normalWorldDir = normalize(float3(
                    dot(i.MatrixFirst.xyz, normalTangentDir),
                    dot(i.MatrixSecond.xyz, normalTangentDir),
                    dot(i.MatrixThird.xyz, normalTangentDir)
                    ));
                
                // get albedo
                fixed3 textureColor = tex2D(_MainTexture, i.uv.xy);
                fixed3 albedo = textureColor * _MainColor.rgb;

                // view dir in world space
                fixed3 viewWorldDir = normalize(_WorldSpaceCameraPos - vertexWorldPos);
                // fixed3 viewWorldDir = normalize(UnityWorldSpaceViewDir(i.vertexWorldPos));
                
                //get final color
                fixed3 col = getAmbientLightColor(albedo)
                    + getLambertDiffuseLightColor(normalWorldDir, albedo)
                    + getSpecularLightColor(normalWorldDir, viewWorldDir);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(col, 1);
            }
            ENDCG
        }
        // 简化版DepthNormals Pass（通常这就够了）
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
                float3 normal : TEXCOORD0;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                // 计算视图空间法线
                o.normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                o.normal = normalize(o.normal);
                
                return o;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                // 归一化法线
                float3 normal = normalize(i.normal);
                
                // 只编码法线，深度部分让Unity自动处理
                // 这是Unity Standard Shader的做法
                float scale = 1.7777;
                float2 enc = normal.xy / (normal.z + 1.0);
                enc /= scale;
                enc = enc * 0.5 + 0.5;
                
                // 返回编码的法线，深度部分设为0
                return float4(enc, 0.0, 0.0);
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