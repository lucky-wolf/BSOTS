#include "../../Render/Shared/Common.fxh"
#include "../../Render/Shared/TransformState.fxh"

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

float Scale
<
	string UIName = "Effect Scale";
> = 1.0;

float4x4	World : WORLD;
float		Phase		 	= 0;

struct VS_OUTPUT
{
    float4 Position		: POSITION;
    float3 Diffuse		: COLOR;
    float3 Layer1Coord	: TEXCOORD0;
    float3 Layer2Coord	: TEXCOORD1;
};

VS_OUTPUT VS( float3 Position : POSITION,
			  float3 Normal : NORMAL )
{   
	VS_OUTPUT Out = (VS_OUTPUT)0;
	float t = Time + Phase;
	
	float4x4 wvp = mul(mul(World, View), Projection);
	
	Out.Position = mul( float4( Position, 1 ), wvp );
    
    Out.Diffuse = float3(0,0,0);
    
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
        PixelShader = NULL;
		
		cullmode = none;
		zenable = true;
		zwriteenable = false;
		
		AlphaBlendEnable = True;
		SrcBlend = One;
		DestBlend = One;

        Texture[0] = <Layer1Map>;
        AddressU[0] = Wrap;
        AddressV[0] = Wrap;
        MinFilter[0] = Linear;
        MagFilter[0] = Linear;
        ColorOp[0] = Add;
        ColorArg1[0] = Diffuse;
        ColorArg2[0] = Texture;

        Texture[1] = <Layer2Map>;
        AddressU[1] = Wrap;
        AddressV[1] = Wrap;
        MinFilter[1] = Linear;
        MagFilter[1] = Linear;
        ColorOp[1] = Modulate;
        ColorArg1[1] = Current;
        ColorArg2[1] = Texture;
    }
}
