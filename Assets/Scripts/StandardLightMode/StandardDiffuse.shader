Shader "Unlit/StandardDiffuse"
{
    // this diffuse LightMode get shadow, multi-source and light attenuation without specular light
   Properties
    {
        // need to correspond with variable name in header file 
        _MainTex("MainTexture", 2D) = "white"{}
        _BumpMap("BumpMap", 2D) = "white"{}
        _BumpScale("BumpScale", Range(-10,10)) = 1
        // need to correspond with variable name in header file 
        _Color("MainColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        
        // Base Pass
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                // need to correspond with variable name in header file 
                float4 pos : SV_POSITION; 
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
                SHADOW_COORDS(4)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Color;
       

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
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
                fixed3 yAxisWorldDir = cross(xAxisWorldDir, zAxisWorldDir) * v.tangent.w;
                fixed3x3 Matrix_TtoW = fixed3x3(xAxisWorldDir, yAxisWorldDir, zAxisWorldDir);
                Matrix_TtoW = transpose(Matrix_TtoW);
                o.MatrixFirst = fixed4(Matrix_TtoW[0], vertexWorldPos.x);
                o.MatrixSecond = fixed4(Matrix_TtoW[1], vertexWorldPos.y);
                o.MatrixThird = fixed4(Matrix_TtoW[2], vertexWorldPos.z);

                TRANSFER_SHADOW(o)
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
                fixed3 textureColor = tex2D(_MainTex, i.uv.xy);
                fixed3 albedo = textureColor * _Color.rgb;

                // view dir in world space
                // fixed3 viewWorldDir = normalize(_WorldSpaceCameraPos - vertexWorldPos);
                // fixed3 viewWorldDir = normalize(UnityWorldSpaceViewDir(i.vertexWorldPos));

                // calculate light and shadow attenuation
                UNITY_LIGHT_ATTENUATION(attenuation, i, vertexWorldPos)
                
                //get final color
                fixed3 col = getAmbientLightColor(albedo)
                    + getLambertDiffuseLightColor(normalWorldDir, albedo) * attenuation;
                return fixed4(col, 1);
            }
            ENDCG
        }
        
        // Additional Pass
        Pass
        {
            Tags
            {
                "LightMode"="ForwardAdd"
            }
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
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
                SHADOW_COORDS(4)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Color;
       

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
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
                fixed3 yAxisWorldDir = cross(xAxisWorldDir, zAxisWorldDir) * v.tangent.w;
                fixed3x3 Matrix_TtoW = fixed3x3(xAxisWorldDir, yAxisWorldDir, zAxisWorldDir);
                Matrix_TtoW = transpose(Matrix_TtoW);
                o.MatrixFirst = fixed4(Matrix_TtoW[0], vertexWorldPos.x);
                o.MatrixSecond = fixed4(Matrix_TtoW[1], vertexWorldPos.y);
                o.MatrixThird = fixed4(Matrix_TtoW[2], vertexWorldPos.z);

                TRANSFER_SHADOW(o)
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
                fixed3 textureColor = tex2D(_MainTex, i.uv.xy);
                fixed3 albedo = textureColor * _Color.rgb;

                // view dir in world space
                // fixed3 viewWorldDir = normalize(_WorldSpaceCameraPos - vertexWorldPos);
                // fixed3 viewWorldDir = normalize(UnityWorldSpaceViewDir(i.vertexWorldPos));

                // calculate light and shadow attenuation
                UNITY_LIGHT_ATTENUATION(attenuation, i, vertexWorldPos)
                
                //get final color
                fixed3 col = getAmbientLightColor(albedo)
                    + getLambertDiffuseLightColor(normalWorldDir, albedo) * attenuation;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
    Fallback "Legacy Shaders/Bumped Diffuse"
}
