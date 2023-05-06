#include "../Render/Shared/Common.fxh"

technique tec0
<
	string level = "Low";
>
{
	pass p0
	{
		Lighting = False;
		ColorVertex = True;
		CullMode = None;
		FillMode = Solid;

		AlphaBlendEnable = True;
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;

		ZEnable = True;
		ZWriteEnable = True;
		ZFunc = LessEqual;
		DepthBias = 0;

		AlphaTestEnable = True;
		AlphaFunc = Greater;
		AlphaRef = 0x08;

		ColorOp[0] = Modulate;
		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		AlphaOp[0] = Modulate;
		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;

		ColorOp[1] = Disable;
		AlphaOp[1] = Disable;

		MinFilter[0] = (minFilter);
		MagFilter[0] = (magFilter);
		MipFilter[0] = (mipFilter);

		AddressU[0] = Clamp;
		AddressV[0] = Clamp;

		// Setup: Shaders
		VertexShader = NULL;
		PixelShader = NULL;  
	}
}
