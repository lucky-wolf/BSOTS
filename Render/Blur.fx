//**************************************************************//
//  Effect File exported by RenderMonkey
//
//  - Although many improvements were made to RenderMonkey FX  
//    file export, there are still situations that may cause   
//    compilation problems once the file is exported, such as  
//    occasional naming conflicts for methods, since FX format 
//    does not support any notions of name spaces. You need to 
//    try to create workspaces in such a way as to minimize    
//    potential naming conflicts on export.                    
//    
//  - Note that to minimize resulting name collisions in the FX 
//    file, RenderMonkey will mangle names for passes, shaders  
//    and function names as necessary to reduce name conflicts. 
//**************************************************************//
//--------------------------------------------------------------//
// Effect Group 1
//--------------------------------------------------------------//
//--------------------------------------------------------------//
// PS2_0Blur
//--------------------------------------------------------------//

//--------------------------------------------------------------//
// BlurHorizontal
//--------------------------------------------------------------//

const float blurScale : BlurScale
<
	string UIName = "Amount to scale blur colours";
> = 1.2f;

texture renderTexture1_Tex : RenderColorTarget
<
   float Width=512;
   float Height=512;
   string Format="D3DFMT_A8R8G8B8";
   float  ClearDepth=1.000000;
   int    ClearColor=-16777216;
>;

texture Texture0 : RenderColorTarget
<
    string type = "2D"; 
    string name = "YellowGlass.tga"; 
    string UIName = "Map";
>;
sampler2D Tex0 = sampler_state
{
   Texture = (Texture0);
   MipFilter = NONE;
   MinFilter = POINT;
   MagFilter = POINT;
   AddressU = CLAMP;
   AddressV = CLAMP;
};

texture Texture1 : RenderColorTarget
<
    string type = "2D"; 
    string name = "YellowGlass.tga"; 
    string UIName = "Map";
>;
sampler2D Tex1 = sampler_state
{
	Texture = (Texture1);
	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
	AddressU = CLAMP;
	AddressV = CLAMP;
};
texture Texture2 : RenderColorTarget
<
    string type = "2D"; 
    string name = "YellowGlass.tga"; 
    string UIName = "Map";
>;
sampler2D Tex2 = sampler_state
{
   Texture = (Texture2);
   MipFilter = NONE;
   MinFilter = LINEAR;
   MagFilter = LINEAR;
   AddressU = CLAMP;
   AddressV = CLAMP;
};

struct VS_OUTPUT
{
   float4 pos       : POSITION0;
   float2 texCoord  : TEXCOORD0;
};

VS_OUTPUT BlurHorizontal_vs_main( float4 inPos: POSITION )
{
   VS_OUTPUT o = (VS_OUTPUT) 0;

   inPos.xy = sign( inPos.xy);
   o.pos = float4( inPos.xy, 0.0f, 1.0f);

   // get into range [0,1]
   o.texCoord = (float2(o.pos.x, -o.pos.y) + 1.0f)/2.0f;
   return o;
}

float4 AlphaOut_ps_main( float4 inDiffuse : COLOR0,
						 float2 inTexCoord : TEXCOORD0 ) : COLOR0
{
	float4 colour = tex2D(Tex0, inTexCoord);
	colour.rgb *= 1.0f - colour.a;
	colour.a = 1.0f;

	return colour;
}

//float texelWidth = 0.001953125f;  // 1 / 512
float texelWidth = 0.0078125f;      // 1 / 128

float gauss_width = 7;
//float gauss_fact[7] = { 0.015625, 0.09375, 0.234375, 0.3125, 0.234375, 0.09375, 0.015625 };
float gauss_fact[7] = 
{ 
	0.1063, 
	0.1403, 
	0.1658, 
	0.1752, 
	0.1658, 
	0.1403, 
	0.1063 
};

const int gaussIndex[7] = 
{ 
	-3, 
	-2, 
	-1, 
	0, 
	1, 
	2, 
	3 
};

float4 BlurHorizontal_ps_main( float4 inDiffuse : COLOR0,
							   float2 inTexCoord : TEXCOORD0 ) : COLOR0
{
   float2 texCoord = inTexCoord;
   float4 colour = 0;
   colour.a = 1.0f;
   
   float halfatexel = 0.5 * texelWidth;
   
   for (int i = 0; i < gauss_width; ++i)
   {
      texCoord.x = inTexCoord.x + (gaussIndex[i] * texelWidth) + halfatexel;
      float4 image = tex2D(Tex1, texCoord);
      colour += image * gauss_fact[i];
      //colour.a -= image.a;
   }

   return colour * blurScale;
}

//--------------------------------------------------------------//
// BlurVertical
//--------------------------------------------------------------//
VS_OUTPUT BlurVertical_vs_main( float4 inPos: POSITION )
{
   VS_OUTPUT o = (VS_OUTPUT) 0;

   inPos.xy = sign( inPos.xy);
   o.pos = float4( inPos.xy, 0.0f, 1.0f);

   // get into range [0,1]
   o.texCoord = (float2(o.pos.x, -o.pos.y) + 1.0f)/2.0f;
   return o;
}

float4 BlurVertical_ps_main( float4 inDiffuse : COLOR0,
    						 float2 inTexCoord : TEXCOORD0 ) : COLOR0
{
   float2 texCoord = inTexCoord;
   float4 colour = 0;
   colour.a = 1.0f;
   
   float halfatexel = 0.5 * texelWidth;
   
   for (int i = 0; i < gauss_width; ++i)
   {
      texCoord.y = inTexCoord.y + (gaussIndex[i] * texelWidth) + halfatexel;
      float4 image = tex2D(Tex2, texCoord);
      colour += image * gauss_fact[i];
      //colour.a -= image.a;
   }
      
   return colour * blurScale;
}

float4x4 World : WORLD;
//--------------------------------------------------------------//
// Technique Section for Effect Group 1
//--------------------------------------------------------------//
/*
technique DX7_Blur
{
   pass AlphaOut
   {
		ZENABLE = FALSE;
		LIGHTING = FALSE;

		VertexShader = compile vs_1_1 BlurHorizontal_vs_main();
		PixelShader = compile ps_2_0 AlphaOut_ps_main();
   }
   
	pass p0
	{
    	CullMode = CW;
        // Setup:  VertexPipe States
        SpecularEnable = false;

        ColorOp[0]   = BLENDTEXTUREALPHA;
        ColorArg2[0] = TFACTOR;
        ColorArg1[0] = TEXTURE;
        AlphaOp[0]   = SELECTARG1;
        AlphaArg1[0] = TEXTURE;
        AlphaArg2[0] = DIFFUSE;
        TexCoordIndex[0] = 0;
        TextureTransformFlags[ 0 ] = DISABLE;
        
        ColorOp[1] = DISABLE;
        AlphaOP[1] = DISABLE;

        // Setup: Pixel Pipe Render States
        AlphaBlendEnable = true;
        SrcBlend = ONE;
        DestBlend = ONE;
        
        AlphaTestEnable = False;
        //AlphaFunc = GREATEREQUAL;
        //AlphaRef = 0x08;
        
        ColorWriteEnable = RED|GREEN|BLUE|ALPHA;
        
        ZEnable = false;
        ZWriteEnable = True;
        
        
        // Setup: Sampler Stage States
        MinFilter[0] = linear;
        MagFilter[0] = linear;
        MipFilter[0] = Linear;
        
        // Setup: Shaders
        // single texture/one directional light shader
        VertexShader = compile vs_1_1 BlurHorizontal_vs_main();
        PixelShader = NULL;
        
        WorldTransform[0] = <World>;
        
        // Setup: Texture
        Texture[0] = <Texture0>;        
	}
}
*/
technique PS2_0Blur
<
	string level = "high";
>
{
   pass AlphaOut
   {
		ALPHABLENDENABLE = FALSE;

		ZENABLE = FALSE;
		LIGHTING = FALSE;

		VertexShader = compile vs_1_1 BlurHorizontal_vs_main();
		PixelShader = compile ps_2_0 AlphaOut_ps_main();
   }
   
   pass BlurHorizontal_1
   {
		ZENABLE = FALSE;
		LIGHTING = FALSE;

		VertexShader = compile vs_2_0 BlurHorizontal_vs_main();
		PixelShader = compile ps_2_0 BlurHorizontal_ps_main();
   }

   pass BlurVertical_1
   {
		ALPHABLENDENABLE = TRUE;
		DESTBLEND = ONE;
		SRCBLEND = ONE;

		ZENABLE = FALSE;
		LIGHTING = FALSE;

		VertexShader = compile vs_1_1 BlurVertical_vs_main();
		PixelShader = compile ps_2_0 BlurVertical_ps_main();
   }
/*
   pass BlurHorizontal_2
   {
		ZENABLE = FALSE;

		VertexShader = compile vs_2_0 BlurHorizontal_vs_main();
		PixelShader = compile ps_2_0 BlurHorizontal_ps_main();
   }

   pass BlurVertical_2
   {
		ALPHABLENDENABLE = TRUE;
		DESTBLEND = ONE;
		SRCBLEND = ONE;

		ZENABLE = FALSE;

		VertexShader = compile vs_1_1 BlurVertical_vs_main();
		PixelShader = compile ps_2_0 BlurVertical_ps_main();
   }
*/
}

