#include "Shared/LightingState.fxh"
#include "Shared/TransformState.fxh"
#include "Shared/Common.fxh"

technique tec0
<
    string level = "Low";
>
{
    pass p0
    {
        cullmode = NONE;
        VertexShader        = Null;
        PixelShader            = Null;
        Lighting            = True;
        SpecularEnable        = True;
        AlphaBlendEnable    = True;
        SrcBlend            = SRCALPHA;
        DestBlend            = INVSRCALPHA;
        ColorOp[0]            = Modulate;
        ColorArg1[0]        = Texture;
        ColorArg2[0]        = Diffuse;
        AlphaOp[0]            = Modulate;
        AlphaArg1[0]        = Texture;
        AlphaArg2[0]         = Diffuse;
        MinFilter[0]         = (minFilter);
        MagFilter[0]         = (magFilter);
        MipFilter[0]         = (mipFilter);
    }
}
