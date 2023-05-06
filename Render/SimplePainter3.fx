#include "SimplePainterBase.fxh"

float4x4    Ident4 = { 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 };

technique VS_1_1_PS_2_0
<
	string level = "High";
>
{
    pass p0
    {
        VertexShader        = compile vs_1_1 VS();
        PixelShader         = compile ps_2_0 PS();
        CullMode            = none;
        ZEnable				= True;
        ZWriteEnable		= True;
        AlphaBlendEnable	= True;
        SrcBlend			= SrcAlpha;
        DestBlend			= InvSrcAlpha;
    }
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
        CullMode            = none;
        ZEnable				= True;
        ZWriteEnable		= True;
        AlphaBlendEnable	= True;
        SrcBlend			= SrcAlpha;
        DestBlend			= InvSrcAlpha;
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
        CullMode            = none;

        ColorOp[0]          = SelectArg1;
        ColorArg1[0]        = Diffuse;
        ColorArg2[0]        = Texture;
        AlphaOp[0]          = SelectArg1;
        AlphaArg1[0]        = Diffuse;
        AlphaArg2[0]        = Texture;
        ColorOp[1]			= Disable;
        AlphaOp[1]			= Disable;

        AlphaBlendEnable	= FALSE;
        ZEnable             = True;
        ZWriteEnable        = True;
    }
}
