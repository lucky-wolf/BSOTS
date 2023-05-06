#include "Shared/TransformState.fxh"
#include "Shared/Common.fxh"

half4x4 World : WORLD;
half4 Color : COLOR = { 0, 1, 0, 0.5 };
half4 lineColour : LINECOLOUR = { 0, 0, 0, 1 };

texture Texture0 : TEXTURE;

sampler Sampler = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

struct VS_OUT
{
    half4 position   : POSITION;
    half2 texCoord   : TEXCOORD0;
};

VS_OUT VS( half3 position : POSITION,
		   half2 texCoord : TEXCOORD0 )
{
	VS_OUT output = (VS_OUT)0;
	
    half3 P = mul(half4(position, 1), World);
    matrix VP = mul(View, Projection);

    output.position = mul(half4(P, 1), VP);
    output.texCoord = texCoord;

    return output;
}

half4 PS( half2 texCoord : TEXCOORD0 ) : COLOR
{
    half4 texColour = tex2D( Sampler, texCoord );
    texColour.a = 1;
    half4 outColor = texColour * Color;

    return outColor;
}

technique VS_1_1_PS_1_1
<
	string level = "Medium";
>
{
	pass p0
	{
		VertexShader	= compile vs_1_1 VS();
		PixelShader		= compile ps_1_1 PS();
		
		CullMode		= CW;

		ZEnable			= True;
		ZWriteEnable	= True;

        SpecularEnable = False;
        AlphaTestEnable = False;
        AlphaBlendEnable = True;
        
        ColorWriteEnable = RED|GREEN|BLUE|ALPHA;
	}
}

technique FixedFunction
<
	string level = "Low";
>
{
    pass p0
    {
        VertexShader        = Null;
        PixelShader         = Null;
    
        Lighting            = False;
        ColorVertex			= True;

        DiffuseMaterialSource = Material;
  		SpecularMaterialSource = Material;
  		AmbientMaterialSource = Material;
  		EmissiveMaterialSource = Material;

        WorldTransform[0]   = <World>;
        ViewTransform       = <View>;
        ProjectionTransform = <Projection>;
        CullMode            = CW;

		TextureFactor		= (Color);
        ColorOp[0]          = Modulate;
        ColorArg1[0]        = Diffuse;
        ColorArg2[0]        = TFactor;
        AlphaOp[0]          = SelectArg2;
        AlphaArg1[0]        = Diffuse;
        AlphaArg2[0]        = Texture;
        Texture[0]          = <Texture0>;
        TexCoordIndex[0]	= 0;
        ColorOp[1]			= Disable;
        AlphaOp[1]			= Disable;

		MinFilter[0]		= (minFilter);
		MagFilter[0]		= (magFilter);
		MipFilter[0]		= (mipFilter);
		
        AlphaBlendEnable	= True;
        ZEnable             = True;
        ZWriteEnable        = True;
    }
}
