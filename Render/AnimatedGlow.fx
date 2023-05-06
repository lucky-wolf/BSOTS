#include "Shared/TransformState.fxh"

texture GlowMap
< 
    string name = "glow.tga"; 
    string UIName = "Glow Map";
>;

texture DiffuseMap
<
	string Name = "alphalayer.tga";
	string UIName = "Diffuse Map";
>;

float4x4	World	: WORLD;
float		Time	: TIME;

struct VS_OUTPUT
{
    float4 Position		: POSITION;
    float3 GlowCoord	: TEXCOORD0;
    float3 TexCoord		: TEXCOORD1;
};

VS_OUTPUT VS(	float3 Position : POSITION,
				float3 Normal   : NORMAL,
				float3 TexCoord	: TEXCOORD0	)
{   
	VS_OUTPUT Out = (VS_OUTPUT)0;
	
	float4x4 wvp = mul(mul(World, View), Projection);
	
	Out.Position = mul( float4( Position, 1 ), wvp );
    Out.TexCoord = TexCoord;
    Out.GlowCoord = Position * 0.1f;
    Out.GlowCoord.y += Time;
    
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
		
        Texture[0] = <GlowMap>;
        AddressU[0] = Wrap;
        AddressV[0] = Wrap;
        MinFilter[0] = Linear;
        MagFilter[0] = Linear;
        ColorOp[0] = SelectArg1;
        ColorArg1[0] = Texture;

        Texture[1] = <DiffuseMap>;
        AddressU[1] = Wrap;
        AddressV[1] = Wrap;
        MinFilter[1] = Linear;
        MagFilter[1] = Linear;
        ColorOp[1] = BlendTextureAlpha;
        ColorArg1[1] = Texture;
        ColorArg2[1] = Current;
    }
}
