#include "Shared/TransformState.fxh"

shared int minFilter = 1;
shared int magFilter = 1;
shared int mipFilter = 0;

half4x4 World : WORLD;

texture Texture0 : TEXTURE;
half4 Colour : COLOR;

struct VS_OUTPUT
{
    half4 Position : POSITION;
    half4 Colour	: COLOR0;
    half2 Tex0		: TEXCOORD0;
};

struct VS_INPUT
{
	half3 Position	: POSITION;
	half3 Tex		: TEXCOORD0;
};

VS_OUTPUT VS( VS_INPUT IN )
{
	VS_OUTPUT Out = (VS_OUTPUT)0;
	half4 pos = mul( half4( IN.Position, 1 ), World );
	pos = mul( pos, View );
    Out.Position = mul( pos, Projection );
    Out.Colour = Colour;
	Out.Tex0 = IN.Tex;
    return Out;
}

sampler LineTex = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

half4 PS( half4 Colour : COLOR0,
		   half2 Tex0 : TEXCOORD0 ) : COLOR
{
    half4 Out = tex2D( LineTex, Tex0 );
    Out *= Colour;
    
    return Out;
}

technique VS_1_1_PS_1_1
<
	string level = "Medium";
>
{
    pass p0
    {
        VertexShader        = compile vs_1_1 VS();
        PixelShader         = compile ps_1_1 PS();
        ZEnable				= False;
        ZWriteEnable		= False;
        CullMode			= NONE;
        AlphaBlendEnable	= True;
		SrcBlend			= SrcAlpha;
		DestBlend			= InvSrcAlpha;
    }
}

technique tec0
<
	string level = "Low";
>
{
	pass p0
	{
		VertexShader = Null;
		PixelShader = Null;
		Lighting = True;
		CullMode = None;
		
		ColorVertex = False;
        DiffuseMaterialSource = Material;
  		SpecularMaterialSource = Material;
  		AmbientMaterialSource = Material;
  		EmissiveMaterialSource = Material;

		AlphaBlendEnable = True;
		SpecularEnable = False;
		MaterialAmbient = {1,1,1,1};
		MaterialDiffuse = half4(0,0,0,Colour.a);
		MaterialEmissive = <Colour>;
		MaterialSpecular = {0,0,0,1};

		ColorOp[0] = Modulate;
        ColorArg1[0] = Texture;
        ColorArg2[0] = Diffuse;
        AlphaOp[0] = Modulate;
        AlphaArg1[0] = Texture;
        AlphaArg2[0] = Diffuse;

		ColorOp[1] = Disable;
		AlphaOp[1] = Disable;
		
        Texture[0]          = <Texture0>;
		MipFilter[0]		= (mipFilter);
		MinFilter[0]		= (minFilter);
		MagFilter[0]		= (magFilter);
		AddressU[0]			= WRAP;
		AddressV[0]			= WRAP;

		WorldTransform[0]	= <World>;
		ViewTransform = <View>;
		ProjectionTransform = <Projection>;

        ZEnable				= False;
        ZWriteEnable		= False;
	}
}
