Shader "Unlit/Lesson110_DepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            ZWrite Off
            ZTest On
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
            //������������ ����������
            sampler2D _CameraDepthTexture;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //�����Ե� �ü��ռ��µ����ֵ
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                //�õ�һ�����Ե� 0~1 ��������ֵ
                fixed linearDepth = Linear01Depth(depth);
                //�����ֵ��ΪRGB��ɫ���� Խ�ӽ����� �ͳ��ֳ���ɫ ԽԶ������� �ͳ��ֳ���ɫ �м���ǻ�ɫ ����ͻ���ֳ���ǳ��
                return fixed4(linearDepth,linearDepth,linearDepth,1);
            }
            ENDCG
        }
    }
    Fallback Off
}
