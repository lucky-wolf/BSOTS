#include "../Render/Shared/TransformState.fxh"
#include "../Render/Shared/LightingState.fxh"

#include "../Render/Shared/Common.fxh"

texture Texture0;
float4x4 World : WORLD;

technique tec0
<
	string level = "Low";
>
{
	pass p0
	{
        VertexShader        = Null;
        PixelShader         = Null;
    
		Lighting            = TRUE;
		SpecularEnable		= True;
		//SpecularMaterialSource = Material;
		ColorVertex			= True;
        
        LightEnable[0]      = True;
        LightAmbient[0]     = <LightAmbient>;
        LightDiffuse[0]     = <Light1Diffuse>;
        LightSpecular[0]    = <Light1Specular>;
        LightDirection[0]   = <Light1Dir>;
        LightType[0]        = Directional;

        LightEnable[1]      = True;
        LightAmbient[1]     = <LightAmbient>;//{1,1,1,1};
        LightDiffuse[1]     = <Light2Diffuse>;
        LightSpecular[1]    = <Light2Specular>;
        LightDirection[1]   = <Light2Dir>;
        LightType[1]        = Directional;

        MaterialAmbient     = <Ambient_>;
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
        AlphaArg1[0]		= Texture;
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
