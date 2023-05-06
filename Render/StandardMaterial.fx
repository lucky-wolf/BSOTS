#include "Shared/LightingState.fxh"
#include "Shared/TransformState.fxh"

#include "Shared/Common.fxh"

texture     Texture0 < string name = ""; >;

float4x4	World			: WORLD;

struct VS_OUTPUT
{
    half4 Position	: POSITION0;
    half4 Diffuse	: COLOR0;
    half3 Specular	: COLOR1;
    half3 TexCoord	: TEXCOORD0;
    half3 Clipping	: TEXCOORD1;
    half4 GhostCol	: TEXCOORD2;  
    half3 Vars		: TEXCOORD3;
};

struct VS_INPUT
{
    half3 Position  : POSITION;
    half4 Color     : COLOR0;
    half3 Normal    : NORMAL;
    half2 TexCoord  : TEXCOORD0;
};

VS_OUTPUT VS( VS_INPUT In,
			  uniform bool useSpecular )
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // R is reflection vector (view space)

	half4 worldPoint = mul( half4( In.Position, 1 ), World );

	float4x4 worldView = mul(World, View);
	
    half3 P = mul(half4(In.Position, 1), worldView);
    half3 V = -normalize(P);                                    // view direction (view space)
    half3 N = normalize(mul(In.Normal, (float3x3)worldView));
    half3 L1 = -mul(half3(Light1Dir),(float3x3)View);
    half3 L2 = -mul(half3(Light2Dir),(float3x3)View);
    half3 R1 = normalize(2 * dot(N, L1) * N - L1);
    half3 R2 = normalize(2 * dot(N, L2) * N - L2);

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

    // Specular lighting contribution
    half4 Sl = (half4)0;
    if ( useSpecular && ( numLights > 0 ) )
    {
	    Sl += Light1Specular * pow( max(0,dot(R1,V)), Power );
		if ( numLights > 1 )
		{
			Sl += Light2Specular * pow( max(0,dot(R2,V)), Power );
		}
    }

    half4 ghostColour = ghostColor_f * ( 1 - dot( N, V ) ) * cloakInterp;
    half invCloakInterp = 1.0f - cloakInterp;
    
    Out.Diffuse      = Diffuse * In.Color * Dl * invCloakInterp;

    Out.Position     = mul(half4(P, 1), Projection);
    Out.Specular     = ( Specular * Sl + Emissive ) * invCloakInterp;
    Out.TexCoord.xy     = In.TexCoord;
    Out.TexCoord.z	 = intangInterp * manualFadeAmount;
    Out.GhostCol	 = ghostColour;

	Out.Clipping.xy = CalculateClipping( worldPoint );

	Out.Clipping.z = Out.GhostCol.a;
	Out.Vars = half3( usePlayerColour > 0, (1-cloakInterp) * (intangInterp) * manualFadeAmount, (1-cloakInterp) );

    return Out;
}

sampler Sampler1 : register(s0) = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler Sampler2 : register(s1) = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler Sampler3 : register(s2) = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler Sampler4 : register(s3) = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

float4 PS( VS_OUTPUT input ) : COLOR
{
	clip( input.Clipping.xy );
	
    half4 texColour = tex2D( Sampler1, input.TexCoord );
    half4 Out = texColour * input.Diffuse + half4( input.Specular, 0 );

    if ( ( input.Vars.x > 0 ) && ( 1-texColour.a > 0 ) )
    {
		Out.rgb = lerp( playerColour_f, Out, texColour.a ) * input.Vars.z;
        Out.a = input.Vars.z;
    }

    Out += input.GhostCol;
    
    Out.a *= ( intangInterp * manualFadeAmount );

    return Out;
}

float4 PS_1_4( VS_OUTPUT input ) : COLOR
{
	clip( input.Clipping );
	
    half4 texColour = tex2D( Sampler1, input.TexCoord.xy );
    half4 Out = texColour * input.Diffuse + half4( input.Specular, 0 );

    if ( input.Vars.x > 0  && texColour.a < 1 )
	{
		Out.rgb = lerp( playerColour_f, Out, texColour.a ) * input.Vars.z;
		Out.a = input.Vars.z;
	}

	Out.a *= input.TexCoord.z;
    
    return Out;
}

half4 PS_1_4Cloak(
    VS_OUTPUT input,
    uniform half alpha ) : COLOR
{
	clip( input.Clipping );
	
	half4 Out;
	Out.rgb = input.GhostCol.rgb;
	Out.a = input.Clipping.z;
	Out.a *= alpha;
	
	return Out;
}

//
// input.Vars.x = usePC -> 0 if this fragment doesn't use player colour, 1 otherwise
// input.Vars.y = alpha -> the full user alpha, ie., cloak alpha * intang alpha * manual alpha
// input.Vars.z = cloak -> just the cloak alpha from above
half4 PS_1_1( VS_OUTPUT input ) : COLOR
{
	clip( input.Clipping );
	
    half4 texColour = tex2D( Sampler1, input.TexCoord );
    half4 Out = half4( playerColour_f.rgb * (1.f - texColour.a), input.Vars.x );
    
    return Out;
}

half4 PS_1_1Tex( VS_OUTPUT input ) : COLOR
{
	clip( input.Clipping );
	
    half4 texColour = tex2D( Sampler1, input.TexCoord );
    half4 Out = texColour * input.Diffuse + half4( input.Specular, 0 );
	
	// Player color fragment causes alpha to be reinterpreted as player color saturation
	// in place of transparency.
	if (input.Vars.x > 0)
		Out.a = 1.f;
	
    return Out;
}

half4 PS_1_1Cloak(
    VS_OUTPUT input,
    uniform half alpha ) : COLOR
{
	clip( input.Clipping );
	
	half4 Out;
	Out.rgb = input.GhostCol.rgb;
	Out.a = cloakInterp * alpha;
	
	return Out;
}

technique VS_1_1_PS_2_0
<
	string level = "High";
>
{
    pass p0
    {
        VertexShader        = compile vs_1_1 VS( useSpecular > 0 );
        PixelShader         = compile ps_2_0 PS();

        CullMode            = CW;

        ZEnable             = True;
        ZWriteEnable        = True;
        
        AlphaBlendEnable = TRUE;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
    }
}

technique VS_1_1_PS_1_4
<
	string level = "Medium";
>
{
    pass p0
    {
        VertexShader        = compile vs_1_1 VS( useSpecular > 0 );
        PixelShader         = compile ps_1_4 PS_1_4();

        CullMode            = CW;

        ZEnable             = True;
        ZWriteEnable        = True;
        
        AlphaBlendEnable = TRUE;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
    }
   
    pass cloak
    {
		VertexShader		= compile vs_1_1 VS( useSpecular > 0 );
		PixelShader			= compile ps_1_4 PS_1_4Cloak( ( 1- intangInterp ) * manualFadeAmount );

        CullMode            = CW;

        ZEnable             = True;
        ZWriteEnable        = False;
        ZFunc				= LessEqual;

        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
    }
}

technique VS_1_1_PS_1_1
<
	string level = "Low";
>
{
    pass p0
    {
        VertexShader        = compile vs_1_1 VS( useSpecular > 0 );
        PixelShader         = compile ps_1_1 PS_1_1Tex();

        CullMode            = CW;

        ZEnable             = True;
        ZWriteEnable        = True;
        ZFunc				= LessEqual;

        AlphaBlendEnable = TRUE;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
    }

    pass p1
    {
        VertexShader        = compile vs_1_1 VS( useSpecular > 0 );
        PixelShader         = compile ps_1_1 PS_1_1();

        CullMode            = CW;

        ZEnable             = True;
        ZWriteEnable        = false;
        ZFunc				= LessEqual;

        AlphaBlendEnable = TRUE;
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
    }

    pass cloak
    {
		VertexShader		= compile vs_1_1 VS( useSpecular > 0 );
		PixelShader			= compile ps_1_1 PS_1_1Cloak( ( 1- intangInterp ) * manualFadeAmount );

        CullMode            = CW;

        ZEnable             = True;
        ZWriteEnable        = False;
        ZFunc				= LessEqual;

        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
    }
}

//							 TEXTURE     TFACTOR
int textureOrFactor[]	= { 0x00000002, 0x00000003 };
//                           SELECT1       ADD
int addOrSelect1[]		= { 0x00000002, 0x00000007 };
//							 CONSTANT    CURRENT
int constantOrCurrent[]	= { 0x00000006, 0x00000001 };
//                           DIFFUSE     CURRENT
int diffuseOrCurrent[]	= { 0x00000000, 0x00000001 };
int diffuseOrTextureComplement[] = { 0x00000010, 0x00000012 };//Diffuse | Complement, Texture | Complement
//                           DISABLE     MODULATE
int disableOrModulate[] = { 0x00000001, 0x00000004 };
//                         SELECTARG1   BLENDTEXTUREALPHA
int selectArg1OrBlend[] = { 0x00000002, 13 };

int modulateOrSelectArg1[] = { 0x00000004, 0x00000002 };

int fade[] = { 0, 1 };
int colourMask[] = { 0x00000000, 0x0000000F };

technique FixedFunc_WithPlayerColour
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
        WorldTransform[0]   = <World>;
        ViewTransform       = <View>;
        ProjectionTransform = <Projection>;
        CullMode            = CW;

		TextureFactor		= ( playerColour_f );//playerColour_f.x, playerColour_f.y, playerColour_f.z, 1.0 );
		
		ColorOp[0]			= Modulate;
		ColorArg1[0]		= Diffuse;
		ColorArg2[0]		= Texture;
		AlphaOp[0]			= Modulate;
		AlphaArg1[0]		= Diffuse;
		AlphaArg2[0]		= TFactor;// | Complement;
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
        ZWriteEnable        = True;
        ZFunc				= LESSEQUAL;
		DepthBias			= 0;
    }

    pass Cloak
    {
        VertexShader        = Null;
        PixelShader         = Null;
    
        Lighting            = False;
        ColorVertex			= True;
        
        Texture[0]          = <Texture0>;
        WorldTransform[0]   = <World>;
        ViewTransform       = <View>;
        ProjectionTransform = <Projection>;
        CullMode            = CW;

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

		TextureFactor		= (ghostColor_f);
        ColorOp[0]          = SelectArg1;
        ColorArg1[0]        = TFactor;
        ColorArg2[0]        = TFactor | AlphaReplicate;
        AlphaOp[0]          = SelectArg1;
        AlphaArg1[0]        = TFactor;
        AlphaArg2[0]        = Texture;
        Texture[0]          = <Texture0>;
        TexCoordIndex[0]	= 0;
        ColorOp[1]			= Disable;
        AlphaOp[1]			= Disable;

        AlphaBlendEnable	= True;
        SrcBlend			= SRCALPHA;
        DestBlend			= INVSRCALPHA;
        
        ZEnable             = True;
        ZWriteEnable        = False;
        ZFunc				= LESSEQUAL;
		DepthBias			= -0.00001;
    }
}
