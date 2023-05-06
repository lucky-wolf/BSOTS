#include "Shared/Common.fxh"
#include "Shared/TransformState.fxh"

texture Texture0;	// Star texture
texture Texture1;   // Center of star texture

half4x4 World : WORLD;

struct VS_OUTPUT
{
    half4 Position : POSITION;
    half4 Colour	: COLOR0;
    half2 Tex0		: TEXCOORD0;
    half2 Tex1		: TEXCOORD1;
};

VS_OUTPUT VS( 
			half3 Position : POSITION,
			half4 Colour : COLOR0,
			half3 Tex : TEXCOORD0 )
{
	VS_OUTPUT Out = (VS_OUTPUT)0;
	
	half4x4 wvp = mul(mul(World, View), Projection);
	
    Out.Position = mul(half4(Position, 1), wvp);
    Out.Colour = Colour;
	Out.Tex0 = Tex;
	Out.Tex1 = Tex;
	
    return Out;
}

sampler Star = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

sampler StarCenter = sampler_state
{
    Texture   = (Texture1);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

half4 PS( half4 Colour : COLOR0,
		   half2 Tex0 : TEXCOORD0,
		   half2 Tex1 : TEXCOORD1 ) : COLOR
{
    half4 star = tex2D( Star, Tex0 );
    half4 center = tex2D( StarCenter, Tex1 );
    center.rgb *= center.a * Colour.a;
    center.a = 0;

	half4 Out = ( star * Colour ) + center;
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
        ZEnable				= True;
        ZWriteEnable		= False;
        CullMode			= NONE;
        AlphaBlendEnable	= True;
		SrcBlend			= SrcAlpha;
		DestBlend			= One;
    }
}

technique FixedFunc
<
	string level = "Low";
>
{
    pass p0
    {
        VertexShader        = Null;
        PixelShader			= Null;
    
        Lighting			= False;
        ZEnable				= True;
        ZWriteEnable		= False;
        CullMode			= NONE;

        ColorVertex			= True;

        WorldTransform[0]	= <World>;
        ViewTransform		= <View>;
        ProjectionTransform	= <Projection>;

		ColorOp[0]			= Modulate;
		ColorArg0[0]		= Current;
		ColorArg1[0]		= Texture;
		ColorArg2[0]		= Diffuse;
		AlphaOp[0]			= Modulate;
		AlphaArg1[0]		= Current;
		AlphaArg2[0]		= Texture;
		Texture[0]			= <Texture1>;
		MinFilter[0]		= (minFilter);
		MagFilter[0]		= (magFilter);
		MipFilter[0]		= (mipFilter);

		ColorOp[1]			= disable;
		AlphaOp[1]			= disable;
		
        AlphaBlendEnable	= True;
		SrcBlend			= SrcAlpha;
		DestBlend			= InvSrcAlpha;
    }

    pass p1
    {
        VertexShader        = Null;
        PixelShader			= Null;
    
        Lighting			= False;
        ZEnable				= True;
        ZWriteEnable		= False;
        CullMode			= NONE;

        ColorVertex			= True;

        WorldTransform[0]	= <World>;
        ViewTransform		= <View>;
        ProjectionTransform	= <Projection>;

		ColorOp[0]			= Modulate2x;
		ColorArg0[0]		= Current;
		ColorArg1[0]		= Texture;
		ColorArg2[0]		= Diffuse;
		AlphaOp[0]			= SelectArg2;
		AlphaArg1[0]		= Current;
		AlphaArg2[0]		= Texture;
		Texture[0]			= <Texture1>;
		MinFilter[0]		= (minFilter);
		MagFilter[0]		= (magFilter);
		MipFilter[0]		= (mipFilter);

		ColorOp[1]			= disable;
		AlphaOp[1]			= disable;
		
        AlphaBlendEnable	= True;
		SrcBlend			= SrcAlpha;
		DestBlend			= One;
	}
}
