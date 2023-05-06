#define UI_DIFFUSE
#define UI_SPECULAR
#define UI_POWER
#define UI_EMISSIVE

#include "Shared/LightingState.fxh"
#include "Shared/TransformState.fxh"
#include "Shared/Common.fxh"

texture Texture0 : DIFFUSEMAP < string UIName = "Texture"; >;
half4x4 World : WORLD;
bool Opaque = true;

struct VS_INPUT
{
	half3 Position : POSITION;
    half3 Normal : NORMAL;
    half2 TexCoord : TEXCOORD0;
};

struct VS_OUTPUT
{
    half4 Position : POSITION;
    half4 Diffuse  : COLOR0;
    half3 Specular : COLOR1;
    half2 TexCoord : TEXCOORD0;
};

sampler Sampler = sampler_state
{
    Texture   = (Texture0);
    MipFilter = point;
    MinFilter = point;
    MagFilter = point;
};

VS_OUTPUT VS( VS_INPUT In, uniform bool useSpecular )
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // R is reflection vector (view space)

	half4 worldPoint = mul( half4( In.Position, 1 ), World );

	float4x4 worldView = mul(World, View);
	
    half3 P = mul(half4(In.Position, 1), worldView);
    half3 V = -normalize(P);                                    // view direction (view space)
    half3 N = normalize(mul(In.Normal, (float3x3)worldView));
    half3 L1 = -mul(half3(Light1Dir),(float3x3)View);
    half3 L2 = -mul(half3(Light2Dir),(float3x3)View);
    half3 R1 = normalize(2 * dot(N, L1) * N - L1);
    half3 R2 = normalize(2 * dot(N, L2) * N - L2);

    // Diffuse lighting contribution  
    half4 Dl = Ambient_ * LightAmbient;
    if ( numLights > 0 )
    {
	    Dl += Light1Diffuse * max(0, dot(N, L1));
		if ( numLights > 1 )
		{
			Dl += Light2Diffuse * max(0, dot(N, L2));
		}
	}
    LightNorm( Dl );

    // Specular lighting contribution
    half4 Sl = (half4)0;
    if ( useSpecular && ( numLights > 0 ) )
    {
	    Sl += Light1Specular * pow( max(0,dot(R1,V)), Power );
		if ( numLights > 1 )
		{
			Sl += Light2Specular * pow( max(0,dot(R2,V)), Power );
		}
    }

	Out.Diffuse		= Diffuse * Dl;
    Out.Position	= mul(half4(P, 1), Projection);
    Out.Specular	= Specular * Sl + Emissive;
    Out.TexCoord	= In.TexCoord;

    return Out;
}

float4 PS( VS_OUTPUT input ) : COLOR
{
    half4 texColour = tex2D( Sampler, input.TexCoord );
    half4 Out = texColour * input.Diffuse + half4( input.Specular, 0 );
    Out.a *= manualFadeAmount;
    return Out;
}

technique tec0
<
	string level = "Low";
>
{
	pass p0
	{
        VertexShader        = compile vs_1_1 VS( useSpecular > 0 );
        PixelShader         = compile ps_2_0 PS();

        CullMode            = CW;

        ZEnable             = True;
        ZWriteEnable        = True;
        
        AlphaTestEnable = True;
        AlphaFunc = GreaterEqual;
        AlphaRef = 0x01;

        AlphaBlendEnable = False;	// ?
        //SrcBlend = SRCALPHA;
        //DestBlend = INVSRCALPHA;
	}
}
