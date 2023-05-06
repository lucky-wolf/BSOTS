#include "../../Render/Shared/Common.fxh"
#include "../../Render/Shared/TransformState.fxh"

texture Texture0;
float4x4 World : WORLD;

struct VS_OUTPUT
{
    float4 Position : POSITION;
    float3 Tex		: TEXCOORD0;
};

VS_OUTPUT VS( 
			float3 Position : POSITION,
			float3 Tex : TEXCOORD0 )
{
	VS_OUTPUT Out = (VS_OUTPUT)0;
	
	float4x4 wvp = mul(mul(World, View), Projection);
    Out.Position = mul(float4(Position, 1), wvp);
	Out.Tex = Tex;
    return Out;
}

sampler Sampler = sampler_state
{
    Texture   = (Texture0);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};

float4 PS( float2 Tex : TEXCOORD0 ) : COLOR
{
    float4 Out = tex2D(Sampler,Tex);
    return Out;
}

technique VS_1_1_PS_1_1
<
	string level = "Medium";
>
{
    pass p0
    {
		ColorVertex 		= True;
        VertexShader        = compile vs_1_1 VS();
        PixelShader         = compile ps_1_1 PS();
        ZEnable				= False;
        ZWriteEnable		= False;
        CullMode			= CW;

		AlphaBlendEnable = True;
		SrcBlend = One;
		DestBlend = One;
    }
}

technique FixedFunc
<
	string level = "Low";
>
{
    pass p0
    {
        VertexShader        = NULL;
        PixelShader			= NULL;
    
        Lighting			= True;
        ZEnable				= False;
        ZWriteEnable		= False;
        CullMode			= CW;
        
        WorldTransform[0]	= <World>;
        ViewTransform		= <View>;
        ProjectionTransform	= <Projection>;

        ColorOp[0]          = SelectArg1;
        ColorArg0[0]        = Texture;
        AlphaOp[0]          = Modulate;
        AlphaArg0[0]		= Texture;
        Texture[0]          = <Texture0>;

		MinFilter[0] = (minFilter);
		MagFilter[0] = (magFilter);
		MipFilter[0] = (mipFilter);
		AddressU[0]  = CLAMP;
		AddressV[1]  = CLAMP;
    }
}
