#include "Shared/LightingState.fxh"
#include "Shared/TransformState.fxh"
#include "Shared/Common.fxh"

bool Opaque = false;

half TarkasEngineGlow = 0.0f;

texture Texture0 : DIFFUSEMAP < string UIName = "Texture"; >;

half4x4	World : WORLD;

struct VS_OUTPUT
{
    half4 pos  : POSITION;
    half4 col	: COLOR0;
    half2 clipping : TEXCOORD0;
    half2 tex1 : TEXCOORD1;
    half4 ghostCol	: TEXCOORD2;  
};

VS_OUTPUT VS(
    half3 pos  : POSITION, 
    half3 col	: COLOR,
    half3 norm : NORMAL, 
    half2 tex  : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

	half4 worldPoint = mul( pos, World );

	half4x4 worldView = mul(World, View);
	
    half4 P = mul(pos, worldView);
    half3 V = -normalize(P.xyz);                                    // view direction (view space)
    half3 N = normalize(mul(norm, (half3x3)worldView));

	Out.pos = mul( P, Projection );
	Out.tex1 = tex;

    half4 ghostColour = ghostColor_f * ( 1 - dot( N, V ) ) * cloakInterp;
    half invCloakInterp = 1.0f - cloakInterp;
    
    Out.col = invCloakInterp;
    
	Out.clipping = half2(1, 1);
	if ( enabledClipPlanes > 0 )
	{
		half dist = clipPlane0.w - dot( worldPoint, clipPlane0.xyz );
		Out.clipping = dist;
	}	
	
	return Out;
}

sampler Sampler0 = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler Sampler1 = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler Sampler2 = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

half4 PS(
    VS_OUTPUT input,
    uniform half fadeAmount ) : COLOR
{
	half4 texColour = tex2D( Sampler1, input.tex1 );
	half4 Out = texColour;// * input.col;

    return Out;
}

technique tec0
<
	string level = "Low";
>
{
	pass p0
	{
		// Setup: Shaders
		VertexShader = Null;
		PixelShader = Null;

		Lighting = False;
		ColorVertex = True;
		CullMode = NONE;
		FillMode = Solid;

		AlphaBlendEnable = True;
		SrcBlend = One;
		DestBlend = One;

		ZEnable = True;
		ZWriteEnable = False;

		AlphaTestEnable = False;

		Texture[0] = <Texture0>;
		TextureFactor = half4( manualFadeAmount, manualFadeAmount, manualFadeAmount, manualFadeAmount );
		ColorOp[0] = Modulate;
		ColorArg1[0] = Texture;
		ColorArg2[0] = TFactor;
		AlphaOp[0] = Modulate;
		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;

		ColorOp[1] = Disable;
		AlphaOp[1] = Disable;

		MinFilter[0] = (minFilter);
		MagFilter[0] = (magFilter);
		MipFilter[0] = (mipFilter);

        WorldTransform[0]   = <World>;

	}
}
