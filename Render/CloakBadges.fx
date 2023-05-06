#include "../Render/Shared/LightingState.fxh"
#include "../Render/Shared/TransformState.fxh"
#include "../Render/Shared/Common.fxh"

bool Opaque = false;

texture     Texture0 < string name = ""; >;

half cloakInterp_ = 0.0;
half4 ghostColor_
<
   string UIName = "ghostColour";
   string UIWidget = "Color";
> = { 0.0980, 1.0000, 0.6198, 1.00 };
half intangInterp_ = 1.0;

half4 toGreyScale = { 0.3, 0.59, 0.11, 0.0 };

struct VS_OUTPUT
{
    half4 Position   : POSITION;
    half4 Diffuse    : COLOR0;
    half3 Specular   : COLOR1;
    half2 TexCoord   : TEXCOORD0;
    half3 Clipping	  : TEXCOORD1;
};

struct VS_INPUT
{
    half3 Position  : POSITION;
    half4 Color     : COLOR0;
    half3 Normal    : NORMAL;
    half2 TexCoord  : TEXCOORD0;
};

VS_OUTPUT Decal_VS( VS_INPUT In )
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // R is reflection vector (view space)
	half4 worldPoint = half4( In.Position, 1 );
	
	half4x4 worldView = View;
	
    half3 P = mul(half4(In.Position, 1), worldView);
    //half3 V = -normalize(P);                                    // view direction (view space)
    half3 N = normalize(mul(In.Normal, (half3x3)worldView));
    half3 L1 = -mul(half3(Light1Dir),(half3x3)View);
    half3 L2 = -mul(half3(Light2Dir),(half3x3)View);
    //half3 R1 = normalize(2 * dot(N, L1) * N - L1);
    //half3 R2 = normalize(2 * dot(N, L2) * N - L2);

    // Diffuse lighting contribution  
    half4 Dl = Ambient_ * LightAmbient;
    if ( numLights > 0 )
    {
	    Dl += Light1Diffuse * max(0, dot(N, L1));
		if ( numLights > 1 )
		{
		    Dl += Light2Diffuse * max(0, dot(N, L2));
		}
	}	
    LightNorm( Dl );

	Dl.a = 1.0f;
    
    Out.Diffuse      = Diffuse * In.Color * Dl;
    Out.Position     = mul(half4(P, 1), Projection);
    Out.Specular     = half3(0,0,0);//Specular * Sl + Emissive;
    Out.TexCoord     = In.TexCoord;

	Out.Clipping	 = CalculateClipping( worldPoint );

    return Out;
}

sampler Sampler : register(s0) = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
};

half4 Decal_PS(
    half4 Diff : COLOR0,
    half3 Spec : COLOR1,
    half2 Tex  : TEXCOORD0,
    half3 Clip : TEXCOORD1 ) : COLOR
{
	clip( Clip );
    half4 texColour = tex2D( Sampler, Tex );
    half value = dot( texColour, toGreyScale );
    half4 greyTex = ghostColor_f * value;
    texColour.a = texColour.a * Diff.a * manualFadeAmount;
    greyTex.a = manualFadeAmount;
    return lerp( texColour, greyTex, cloakInterp );
}

half4 Decal_PS_1_1_Ghost( 
	half4 Diff : COLOR0,
	half3 Spec : COLOR1,
	half2 Tex  : TEXCOORD0,
	half3 Clip : TEXCOORD1 ) : COLOR
{
  clip( Clip );
  half4 diffuseTexture = tex2D( Sampler, Tex );
  half value = dot( diffuseTexture, toGreyScale );
  half4 greyTex = ghostColor_f * value;
  greyTex.a = diffuseTexture.a * manualFadeAmount * Diff.a;
  return greyTex * cloakInterp;
}

half4 Decal_PS_1_1_Texture( 
	half4 Diff : COLOR0,
	half3 Spec : COLOR1,
	half2 Tex  : TEXCOORD0,
	half3 Clip : TEXCOORD1 ) : COLOR
{
  clip( Clip );
  half4 diffuseTexture = tex2D( Sampler, Tex );
  diffuseTexture.a *= manualFadeAmount * Diff.a;
  return diffuseTexture * (1-cloakInterp);
}

technique VS_1_1_PS_1_4
<
	string level = "High";
>
{
    pass p0
    {
        VertexShader        = compile vs_1_1 Decal_VS();
        PixelShader         = compile ps_1_4 Decal_PS();

        Texture[0]          = <Texture0>;
        CullMode            = CW;
        ZEnable             = True;
        ZWriteEnable        = False;
        AlphaBlendEnable    = True;
        SrcBlend            = SrcAlpha;
        DestBlend           = InvSrcAlpha;
    }
}

technique textured2Pass
<
	string level = "Low";
>
{
	pass p0
	{
		VertexShader = compile vs_1_1 Decal_VS();
		PixelShader	 = compile ps_1_1 Decal_PS_1_1_Ghost();
		
		alphablendenable = true;
		srcblend = SrcAlpha;
		destblend = InvSrcAlpha;
	}
	pass p1
	{
		VertexShader = compile vs_1_1 Decal_VS();
		PixelShader	 = compile ps_1_1 Decal_PS_1_1_Texture();
		
		alphablendenable = true;
		srcblend = SrcAlpha;
		destblend = InvSrcAlpha;
	}
}

const half4x4 Ident = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };

technique FF_TwoPass
<
	string level = "VeryLow";
>
{
    pass Textured
    {
        VertexShader        = Null;
        PixelShader         = Null;
		ShadeMode			= GOURAUD;
		
        Lighting            = True;
        SpecularEnable		= ( useSpecular > 0 );
        
        LightEnable[0]      = ( numLights > 0 );
        LightAmbient[0]     = <LightAmbient>;
        LightDiffuse[0]     = <Light1Diffuse>;
        LightSpecular[0]    = <Light1Specular>;
        LightDirection[0]   = <Light1Dir>;
        LightType[0]        = Directional;

        LightEnable[1]      = ( numLights > 1 );
        LightAmbient[1]     = {0,0,0,1};
        LightDiffuse[1]     = <Light2Diffuse>;
        LightSpecular[1]    = <Light2Specular>;
        LightDirection[1]   = <Light2Dir>;
        LightType[1]        = Directional;

        MaterialAmbient     = <Ambient_>;
        MaterialDiffuse     = <Diffuse>;
        MaterialSpecular    = <Specular>;
        MaterialEmissive    = <Emissive>;
        MaterialPower       = <Power>;
        Texture[0]          = <Texture0>;
        WorldTransform[0]   = <Ident>;
        ViewTransform       = <View>;
        ProjectionTransform = <Projection>;
        CullMode            = CW;

		TextureFactor		= half4( toGreyScale.x, toGreyScale.y, toGreyScale.z, cloakInterp );
		
		ColorOp[0]			= Modulate;
		ColorArg1[0]		= Diffuse;
		ColorArg2[0]		= Texture;
		AlphaOp[0]			= Modulate;
		AlphaArg1[0]		= Diffuse;
		AlphaArg2[0]		= Texture;//TFactor;// | Complement;
        Texture[0]          = <Texture0>;
        TexCoordIndex[0]	= 0;
		MipFilter[0]		= (mipFilter);
		MinFilter[0]		= (minFilter);
		MagFilter[0]		= (magFilter);
		AddressU[0]			= WRAP;
		AddressV[0]			= WRAP;

		ColorOp[1] = DISABLE;
		AlphaOp[1] = DISABLE;		
		
        AlphaBlendEnable = TRUE;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
        
        AlphaTestEnable = False;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = 0x08;

        ZEnable             = True;
        ZWriteEnable        = False;
        ZFunc				= LESSEQUAL;

		DepthBias = -0.001;
		SlopeScaleDepthBias = -0.00;
    }
}
