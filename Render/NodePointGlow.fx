#include "Shared/TransformState.fxh"
#include "Shared/LightingState.fxh"
#include "Shared/Common.fxh"

bool Opaque = false;

texture Texture_Glow : TEXTURE0PARAM
<
	string ResourceName = "glow.tga";
>;

half4 HazeColour = { 1, 0, 0, 1 };

half Radius
<
	string UIName = "Glow ring inside radius";
> = 1.0f;

half HazeIntensity = 1.0f;

half GlowWidth
<
	string UIName = "Glow ring width (percentage of radius)";
//> = 0.045f;
> = 50.0f;

half3 Origin
<
	string UIName = "Position of ring";
> = { 0.0f, 0.0f, 0.0f };

half4x4 NewWorld;

//------------------------------------
#define RING_INNER_RADIUS_SCALE	(0.99f)			// Slightly <1x to eliminate gaps between geometries.
#define RING_THICKNESS_SCALE	(GlowWidth)
	

//------------------------------------
struct VS_INPUT
{
	half4 position : POSITION;
    half3 normal 	: NORMAL;
    half2 texCoord : TEXCOORD0;
    half4 diffuse	: COLOR0;
};

struct VS_OUTPUT
{
    half4 position : POSITION;        // vertex position
    half4 diffuse  : COLOR0;        // vertex diffuse colour
    half2 texCoord : TEXCOORD0;    // vertex texture coords
};

//------------------------------------
VS_OUTPUT RingVS( VS_INPUT input, uniform half radius)
{
	//**********************************************************************
	// TODO: Move W and possibly E out of vertex shader because there is no 
	// variance per vertex and they are rather expensive to compute.
	//**********************************************************************

    VS_OUTPUT output;

    matrix VP = mul(View, Projection);
	half4x3 W;												// W: World transform (orients ring to face the viewer, like a point sprite).
	W[0] = InvView[0];
	W[1] = InvView[1];
	W[2] = InvView[2];
	W[3] = Origin;
    half3 N = normalize( mul( input.position.xyz, W ) );	// N: World surface normal.

    output.texCoord.x = 0.0f;
    output.texCoord.y = 1.0f - input.texCoord.y;
	output.diffuse.xyz = HazeColour;
	output.diffuse.a = HazeIntensity;

	// k is the distance along N from Origin to place the vertex.
	half k = radius * ( RING_INNER_RADIUS_SCALE + RING_THICKNESS_SCALE * input.texCoord.y );
	output.position = mul( half4( k*N + W[3], 1 ), VP );
	
    return output;
}

//-----------------------------------
technique RingWithVertexShader
<
	string level = "Low";
>
{
    pass Ring
    {		
		CullMode = NONE;
		
		VertexShader = compile vs_1_1 RingVS( Radius );
        PixelShader  = NULL;

        // sampler states
        MinFilter[0] = <minFilter>;
        MagFilter[0] = <magFilter>;
        MipFilter[0] = <mipFilter>;
        AddressU[0] = CLAMP;
        AddressV[0] = CLAMP;
        AddressW[0] = CLAMP;

        // set up texture stage states for single texture modulated by diffuse 
        ColorOp[0]   = MODULATE;
        ColorArg1[0] = DIFFUSE;
        ColorArg2[0] = TEXTURE;
        AlphaOp[0]   = MODULATE;
        AlphaArg1[0] = DIFFUSE;
        AlphaArg2[0] = TEXTURE;

        ColorOp[1]   = DISABLE;
        AlphaOp[1]   = DISABLE;

        Texture[0] = <Texture_Glow>;        

        AlphaBlendEnable = True;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;

        AlphaTestEnable = False;

        ZEnable = True;
        ZWriteEnable = False;
    }
}
