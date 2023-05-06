#include "Shared/LightingState.fxh"
#include "Shared/TransformState.fxh"
#include "Shared/Common.fxh"

float4x4	World		: WORLD;
half4		Ambient		: MATERIALAMBIENT = {1, 1, 1, 1};


technique tec0
<
    string level = "Low";
>
{
    pass Textured
    {
        VertexShader        = Null;
        PixelShader         = Null;
		ShadeMode			= GOURAUD;
		FillMode			= Wireframe;
		
        Lighting            = True;
        SpecularEnable		= True;
        
        LightEnable[0]      = True;
        LightAmbient[0]     = <LightAmbient>;
        LightDiffuse[0]     = <Light1Diffuse>;
        LightSpecular[0]    = <Light1Specular>;
        LightDirection[0]   = <Light1Dir>;
        LightType[0]        = Directional;

        LightEnable[1]      = False;

        MaterialAmbient     = <Ambient>;
        MaterialDiffuse     = <Diffuse>;
        MaterialSpecular    = <Specular>;
        MaterialEmissive    = <Emissive>;
        MaterialPower       = <Power>;
        Texture[0]          = Null;
        WorldTransform[0]   = <World>;
        ViewTransform       = <View>;
        ProjectionTransform = <Projection>;
        CullMode            = CCW;

		ColorOp[0]			= SelectArg1;
		ColorArg1[0]		= Diffuse;
		ColorArg2[0]		= Texture;
		AlphaOp[0]			= DISABLE;
        Texture[0]          = Null;
		MipFilter[0]		= (mipFilter);
		MinFilter[0]		= (minFilter);
		MagFilter[0]		= (magFilter);

		ColorOp[1] = DISABLE;
		AlphaOp[1] = DISABLE;		
		
        AlphaBlendEnable = False;
        AlphaTestEnable = False;

        ZEnable             = True;
        ZWriteEnable        = True;
        ZFunc				= LESSEQUAL;
		DepthBias			= 0;
    }
}
