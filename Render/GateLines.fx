#include "Shared/TransformState.fxh"

shared int minFilter = 1;
shared int magFilter = 1;
shared int mipFilter = 0;

half4x4 World : WORLD;

half4 Emissive;

texture Texture0;

technique tec0
<
	string level = "Low";
>
{
	pass p0
	{ 
		VertexShader = Null;
		PixelShader = Null;
		Lighting = False;
		CullMode = None;
		
        DiffuseMaterialSource = Material;
  		SpecularMaterialSource = Material;
  		AmbientMaterialSource = Material;
  		EmissiveMaterialSource = Material;

		AlphaBlendEnable = True;
		SpecularEnable = False;
		MaterialAmbient = {0,0,0,1};
		MaterialDiffuse = {1,1,1,1};
		MaterialEmissive = <Emissive>;
		MaterialSpecular = {0,0,0,1};

		ColorOp[0] = Modulate;
        ColorArg1[0] = Texture;
        ColorArg2[0] = Diffuse;
        AlphaOp[0] = Modulate;
        AlphaArg1[0] = Texture;
        AlphaArg2[0] = Diffuse;

		WorldTransform[0]	= <World>;
		ViewTransform = <View>;
		ProjectionTransform = <Projection>;

        Texture[0]          = <Texture0>;
		MipFilter[0]		= <mipFilter>;
		MinFilter[0]		= <minFilter>;
		MagFilter[0]		= <magFilter>;
		AddressU[0]			= WRAP;
		AddressV[0]			= WRAP;

        ZEnable				= False;
        ZWriteEnable		= False;

		AlphaBlendEnable = TRUE;
		DestBlend = One;
		SrcBlend = SrcAlpha;
	}
}
