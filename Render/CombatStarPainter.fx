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

        CullMode            = None;
		FillMode			= Solid;

		ColorOp[0] = Modulate;
		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		AlphaOp[0] = Modulate;
		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;

		ColorOp[1] = Disable;
		AlphaOp[1] = Disable;

//		ColorOp[0]          = SelectArg1;
//		ColorArg1[0]        = Diffuse;
//		AlphaOp[0]          = SelectArg1;
//		AlphaArg1[0]        = Diffuse;
//		ColorOp[1]			= Disable;
//		AlphaOp[1]			= Disable;

        AlphaBlendEnable	= True;
        ZEnable             = False;
        ZWriteEnable        = False;
    }
}
