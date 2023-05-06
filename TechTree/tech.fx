#include "../Render/Shared/TransformState.fxh"
#include "../Render/Shared/LightingState.fxh"

shared int mipFilter = 0;
shared int minFilter = 1;
shared int magFilter = 1;

float4 Ambient : MATERIALAMBIENT = { 0.1,0.1,0.1,1 };
float4 Diffuse : MATERIALDIFFUSE = { 1,1,1,1 };
float4 Specular : MATERIALSPECULAR = { 0,0,0,1 };
float4 Emissive : MATERIALEMISSIVE = { 0,0,0,1 };
float Power;
texture Texture0;
float4x4 World : WORLD;

float4 Colour = { 0.0f, 0.0f, 0.0f, 1.0f };

struct VS_INPUT
{
	float4 position : POSITION;
	float4 colour	: COLOR0;
	float2 uv		: TEXCOORD0;
};

struct VS_OUTPUT
{
	float4 position : POSITION;
	float4 colour	: COLOR0;
	float2 uv		: TEXCOORD0;
};

VS_OUTPUT VS( VS_INPUT input )
{
	VS_OUTPUT output = (VS_OUTPUT)0;
	
	matrix worldViewProj = mul( World, View );
	worldViewProj = mul( worldViewProj, Projection );
	
	output.position = mul( input.position, worldViewProj );
	output.colour = Diffuse;
	output.uv = input.uv;
	
	return output;
}

technique tec0
<
	string level = "Low";
>
{
	pass p0
	{
        VertexShader        = Null;//compile vs_1_1 VS();
        PixelShader         = Null;
    
		Lighting            = True;
        ColorVertex			= False;
        
        LightEnable[0]      = False;
        LightEnable[1]      = False;

        DiffuseMaterialSource = Material;
  		SpecularMaterialSource = Material;
  		AmbientMaterialSource = Material;
  		EmissiveMaterialSource = Material;

        MaterialAmbient     = <Ambient>;
        MaterialDiffuse     = <Diffuse>;
        MaterialSpecular    = <Specular>;
        MaterialEmissive    = <Emissive>;
        MaterialPower       = <Power>;
        WorldTransform[0]   = <World>;
        ViewTransform		= <View>;
        ProjectionTransform = <Projection>;
        CullMode			= CW;

		AlphaBlendEnable	= True;
		
        ColorOp[0]          = Modulate;
        ColorArg1[0]        = Diffuse;
        ColorArg2[0]		= Texture;
        AlphaOp[0]          = Modulate;
        AlphaArg1[0]        = Diffuse;
        AlphaArg2[0]        = Texture;
        ColorOp[1]			= Disable;
        AlphaOp[1]			= Disable;
        Texture[0]          = <Texture0>;
		MipFilter[0]		= (mipFilter);
		MinFilter[0]		= (minFilter);
		MagFilter[0]		= (magFilter);
		AddressU[0]			= WRAP;
		AddressV[0]			= WRAP;

        ZEnable				= True;
        ZWriteEnable		= True;
	}
}
