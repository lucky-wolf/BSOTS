#include "Shared/TransformState.fxh"
#include "Shared/Common.fxh"

bool Opaque = false;

texture Layer1Map
<
    string UIName = "Base Additive";
>;

#define Layer1PosScale 0.0167311
#define Layer1TxScale -1.0/3.1
#define Layer1TyScale -1.0/2.247

texture Layer2Map
< 
    string UIName = "Modulation";
>;

#define Layer2PosScale 0.020
#define Layer2TxScale  1.0/4.1379
#define Layer2TyScale -1.0/3.5

half Scale
<
	string UIName = "Effect Scale";
> = 1.0;

half4x4	World : WORLD;
half		Phase = 0;
half		FadeAmount = 1;

struct VS_OUTPUT
{
    half4 Position		: POSITION;
    half4 Diffuse		: COLOR;
    half3 Layer1Coord	: TEXCOORD0;
    half3 Layer2Coord	: TEXCOORD1;
};

VS_OUTPUT VS( half3 Position : POSITION,
			  half3 Normal : NORMAL,
			  half3 TexCoord : TEXCOORD0,
			  half4 Colour : COLOR )
{   
	VS_OUTPUT Out = (VS_OUTPUT)0;
	half t = Time + Phase;

	//half4 P = mul( half4( Position, 1 ), World );	
	half4x4 wvp = mul(mul(World, View), Projection);
	
	Out.Position = mul( half4( Position, 1 ), wvp );
    
    Out.Diffuse = half4(1,1,1, Colour.a * FadeAmount);
    
    Out.Layer1Coord = Position * Layer1PosScale * Scale;
    Out.Layer1Coord.x += t * Layer1TxScale;
    Out.Layer1Coord.y += t * Layer1TyScale;
    
    Out.Layer2Coord.x = Position.y * Scale;
    Out.Layer2Coord.y = Position.x * Scale;
    Out.Layer2Coord = Out.Layer2Coord * Layer2PosScale;
    Out.Layer2Coord.x += t * Layer2TxScale;
    Out.Layer2Coord.y += t * Layer2TyScale;
    
    return Out;
}  

technique TVertexShader
<
	string level = "Low";
>
{
    pass P0
    {
        VertexShader = compile vs_1_1 VS();
        PixelShader = Null;

		Lighting = false;		
        ColorVertex	= True;

		cullmode = none;
		zenable = true;
		zwriteenable = true;
		
        DiffuseMaterialSource = Material;
  		SpecularMaterialSource = Material;
  		AmbientMaterialSource = Material;
  		EmissiveMaterialSource = Material;

		AlphaBlendEnable = True;
		SrcBlend = SrcAlpha;
		DestBlend = One;//InvSrcAlpha;

        Texture[0] = <Layer1Map>;
        AddressU[0] = Wrap;
        AddressV[0] = Wrap;
        MinFilter[0] = (minFilter);
        MagFilter[0] = (magFilter);
        MipFilter[0] = (mipFilter);
        ColorOp[0] = Modulate;//Add;
        ColorArg1[0] = Diffuse;
        ColorArg2[0] = Texture;
        AlphaOp[0] = SelectArg1;
        AlphaArg1[0] = Diffuse;

        Texture[1] = <Layer2Map>;
        AddressU[1] = Wrap;
        AddressV[1] = Wrap;
        MinFilter[1] = (minFilter);
        MagFilter[1] = (magFilter);
        MipFilter[1] = (mipFilter);
        ColorOp[1] = Modulate;
        ColorArg1[1] = Current;
        ColorArg2[1] = Texture;
        AlphaOp[1] = Modulate;
        AlphaArg1[1] = Current;
        AlphaArg2[1] = Texture;
    }
}
