#include "Shared/LightingState.fxh"
#include "Shared/TransformState.fxh"

#include "Shared/Common.fxh"

bool Opaque = false;
texture Texture0 < string name = ""; >;
half4x4	World : WORLD;
half4 glowColor_f = { 0.95, 0.48, 0.46, 1.0 };

struct VS_OUTPUT
{
    half4 Position		: POSITION;
    half4 Diffuse		: COLOR0;
    half3 Specular		: COLOR1;
    half2 TexCoord		: TEXCOORD0;
    half3 TexCoord2		: TEXCOORD1;
    half4 PlayerCol		: TEXCOORD3;
};

struct VS_INPUT
{
    half3 Position  : POSITION;
    half4 Color     : COLOR0;
    half3 Normal    : NORMAL;
    half2 TexCoord  : TEXCOORD0;
};
 
VS_OUTPUT VS( VS_INPUT In )
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // R is reflection vector (view space)

	half4x4 worldView = mul(World, View);
	
    half3 P = mul(half4(In.Position, 1), worldView);
    half3 V = -normalize(P);                                    // view direction (view space)
    half3 N = normalize(mul(In.Normal, (half3x3)worldView));
    half3 L1 = -mul(half3(Light1Dir),(half3x3)View);
    half3 L2 = -mul(half3(Light2Dir),(half3x3)View);
    half3 R1 = normalize(2 * dot(N, L1) * N - L1);
    half3 R2 = normalize(2 * dot(N, L2) * N - L2);

    // Diffuse lighting contribution  
    half4 Dl = Ambient_ * LightAmbient;
    Dl += Light1Diffuse * max(0, dot(N, L1));
    Dl += Light2Diffuse * max(0, dot(N, L2));
    LightNorm( Dl );

    // Specular lighting contribution
    half4 Sl = (half4)0;
    Sl += Light1Specular * pow( max(0,dot(R1,V)), Power );
    Sl += Light2Specular * pow( max(0,dot(R2,V)), Power );
    
    Out.Diffuse     = Diffuse * In.Color * Dl;
    Out.Position    = mul(half4(P, 1), Projection);
    Out.Specular    = ( Specular * Sl + Emissive );
    Out.PlayerCol	= playerColour_f;
	Out.TexCoord2.x = usePlayerColour > 0;
	Out.TexCoord	= In.TexCoord;

    return Out;
}

sampler Sampler = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

half4 PS( VS_OUTPUT input ) : COLOR
{
    half4 texColour = tex2D( Sampler, input.TexCoord );
    half4 Out = texColour * input.Diffuse + half4( input.Specular, 0 );

    if ( input.TexCoord2.x && ( texColour.a < 1 ) ) 
    {
        Out.rgb = lerp( input.PlayerCol, Out, texColour.a );
        Out.a = 1;
    }

	Out.rgb += glowColor_f.rgb;
	Out.a *= glowColor_f.a;
    
    return Out;
}

technique VS_1_1_PS_1_4
<
	string level = "Medium";
>
{
    pass p0
    {
        VertexShader        = compile vs_1_1 VS();
        PixelShader         = compile ps_1_4 PS();

        CullMode            = CW;

        ZEnable             = True;
        ZWriteEnable        = True;
        
        AlphaBlendEnable = TRUE;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
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
int fade[] = { 0, 1 };

technique FixedFunc_WithPlayerColour
<
	string level = "Low";
>
{
    pass p0
    {
        VertexShader        = Null;
        PixelShader         = Null;
    
        Lighting            = True;
        
        LightEnable[0]      = True;
        LightAmbient[0]     = <LightAmbient>;
        LightDiffuse[0]     = <Light1Diffuse>;
        LightSpecular[0]    = <Light1Specular>;
        LightDirection[0]   = <Light1Dir>;
        LightType[0]        = Directional;

        LightEnable[1]      = True;
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
        ViewTransform        = <View>;
        ProjectionTransform = <Projection>;
        CullMode            = CW;

		TextureFactor		= (playerColour);
        ColorOp[0]          = Modulate;
        ColorArg1[0]        = Diffuse;
        ColorArg2[0]        = ( textureOrFactor[usePlayerColour] );
        AlphaOp[0]          = Modulate;
        AlphaArg1[0]        = TFactor;
        AlphaArg2[0]        = ( diffuseOrTextureComplement[usePlayerColour] );
        Texture[0]          = <Texture0>;
        TexCoordIndex[0]	= 0;
        ColorOp[1]			= Disable;
        AlphaOp[1]			= Disable;

        AlphaBlendEnable = ( fade[ glowColor_f.a < 1 ] );
        //SrcBlend = SRCALPHA;
        //DestBlend = INVSRCCOLOR;
        
        AlphaTestEnable = True;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = 0x08;

        ZEnable                = True;
        ZWriteEnable        = True;
    }

    pass p1
    {
        VertexShader        = Null;
        PixelShader         = Null;
    
        Lighting            = True;
        
        LightEnable[0]      = True;
        LightAmbient[0]     = <LightAmbient>;
        LightDiffuse[0]     = <Light1Diffuse>;
        LightSpecular[0]    = <Light1Specular>;
        LightDirection[0]   = <Light1Dir>;
        LightType[0]        = Directional;

        LightEnable[1]      = True;
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
        ViewTransform        = <View>;
        ProjectionTransform = <Projection>;
        CullMode            = CW;

		TextureFactor		= (playerColour);
        ColorOp[0]          = Modulate;
        ColorArg1[0]        = Current;
        ColorArg2[0]        = Texture;
        AlphaOp[0]          = Modulate;
        AlphaArg1[0]        = TFactor;
        AlphaArg2[0]        = Texture;
        Texture[0]          = <Texture0>;
        TexCoordIndex[0]	= 0;
        ColorOp[1]			= Disable;
        AlphaOp[1]			= Disable;

        AlphaBlendEnable	= True;
        SrcBlend			= SRCALPHA;
        DestBlend			= INVSRCALPHA;
        
        ZEnable                = True;
        ZWriteEnable        = True;
    }
}
