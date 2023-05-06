#include "Shared/TransformState.fxh"
#include "Shared/LightingState.fxh"
#include "Shared/Common.fxh"

//tell max to transpose the matrix
//bool RowMajor = true;
bool RowMajor = false;

//DxMaterial specific 
//half3 shadedColor : ColorOverride = half3(0.47,0.47,0.47);
//string bitmapOverride : BitmapOverride = "tiger.bmp";

bool hasLowerEndTechnique = true;

// light direction (view space)
half3 lightDir : Direction = {-0.577, -0.577, 0.577};

// light intensity
half4 I_a = { 0.1f, 0.1f, 0.1f, 1.0f };    // ambient
half4 I_d = { 1.0f, 1.0f, 1.0f, 1.0f };    // diffuse
half4 I_s = { 1.0f, 1.0f, 1.0f, 1.0f };    // specular

// material reflectivity
half4 k_a = half4( 0.47f, 0.47f, 0.47f, 1.0f );    // ambient
	
half4 k_d = half4( 0.47f, 0.47f, 0.47f, 1.0f );    // diffuse
	
half4 k_s = half4( 1.0f, 1.0f, 1.0f, 1.0f );    // diffuse    // specular

int n = 15;

half glowStrength = 1.0f;

half uvSpeed
<
	string UIName = "Speed of UV animation";
> = 0.0f;

// Direction of U travel:
// 0 - None
int uDirection
<
	string UIName = "Direction of U animation";
	string UIType = "IntSpinner";
	half UIMin = -1;
	half UIMax = 1;
> = 0;

// Direction of V travel:
// 0 - None
int vDirection
<
	string UIName = "Direction of V animation";
	string UIType = "IntSpinner";
	half UIMin = -1;
	half UIMax = 1;
> = 0;

half ShipSpeed : SHIPSPEED = 0;

// transformations
half4x4 World      : 		WORLD;


struct VS_OUTPUT
{
    half4 Pos  : POSITION;
    half4 col	: COLOR0;
    half3 ghostColour: COLOR1;
    half2 tex1 : TEXCOORD1;
    half3 Clip : TEXCOORD0;
};

VS_OUTPUT VS(
    half3 Pos  : POSITION, 
    half3  col	: COLOR,
    half3 Norm : NORMAL, 
    half2 Tex  : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    half3 L = -lightDir;

	half4 worldPos = mul( half4( Pos, 1 ), World );
	
	half4x4 worldView = mul(World, View);
	
    half3 P = mul(half4(Pos, 1), worldView);
    half3 N = normalize(mul(Norm, (half3x3)worldView));

    half3 R = normalize(2 * dot(N, L) * N - L);          // reflection vector (view space)
    half3 V = -normalize(P);                             // view direction (view space)

    Out.Pos  = mul(Projection,half4(P,1));    // position (projected)
    Out.Pos  = mul(half4(P, 1), Projection);
    
    half4 Diff = I_a * k_a + I_d * k_d * max(0, dot(N, L)); // diffuse + ambient
    half4 Spec = I_s * k_s * pow(max(0, dot(R, V)), n/4);   // specular
    
    half4 ghostColour = ghostColor_f * ( 1 - dot( N, V ) ) * cloakInterp;
    half invCloakInterp = 1.0f - cloakInterp;
    
    Out.col = ( Diff + Spec ) * invCloakInterp;

    Out.tex1.x = Tex.x + ( Time * uvSpeed * uDirection );
    Out.tex1.y = Tex.y + ( Time * uvSpeed * vDirection );

	half speed = ShipSpeed * uvSpeed;
	//Out.tex2.x = speed;
    //Out.tex2.x = Tex.x + ( time * speed * uDirection2 );
    //Out.tex2.y = Tex.y + ( time * speed * vDirection2 );
    
    Out.ghostColour = ghostColour.rgb;

	Out.Clip = CalculateClipping( worldPos );

    return Out;
}

texture regularTexture
<
    string name = "EngineGlow.tga"; 
    string UIName = "Texture";
>;

sampler2D Texture0 : register(s0) = sampler_state
{
	Texture = (regularTexture);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler2D Texture1 : register(s1) = sampler_state
{
	Texture = (regularTexture);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler2D Texture2 = sampler_state
{
	Texture = (regularTexture);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
    AddressU = WRAP;
    AddressV = WRAP;
};

// Whole texture glow pixel shader - Glow Strength is always full.
half4 WTG_PS(
    half4 Diff			: COLOR0,
    half3 ghostColour	: COLOR1,
    half2 Tex			: TEXCOORD1,
    half3 Clip			: TEXCOORD0,
    uniform half alpha ) : COLOR
{
	clip( Clip );
	//half4 c1 = tex2D( Texture1, Clip );
    half4 color = tex2D(Texture1, Tex);

	//color.a = 1.0f - ShipSpeed;

	color *= 1 - cloakInterp;
	color.rgb += ghostColour;
	
	//color.a *= alpha;
    
    return  color;
}

half4 WTG_PS_NOBLUR(
	half4 Diff : COLOR0,
	half4 Sped : COLOR1,
	half2 Tex	: TEXCOORD0,
	half2 Tex1 : TEXCOORD1 ) : COLOR
{
	half4 colour = tex2D( Texture0, Tex );
	colour += colour * ShipSpeed;
	colour.a = 1.0f;
	
	return colour;
}

technique WholeTextureGlow 
<
	string level = "High";
>
{
    pass P0
    {
        // shaders
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_1_2 WTG_PS( intangInterp * manualFadeAmount );
        AlphaBlendEnable = true;
        SrcBlend = ONE;
        DestBlend = ZERO;
        Texture[0]			= <regularTexture>;
        TexCoordIndex[0]	= 0;
        Texture[1]			= <regularTexture>;
        TexCoordIndex[1]	= 1;
        Texture[2]			= <regularTexture>;
        TexCoordIndex[2]	= 2;
        
        ZEnable = true;
        ZWriteEnable = true;
        
        CullMode = CW;
    }  
}

technique WholeTextureGlow_NOBLUR
<
	string level = "Medium";
>
{
    pass P0
    {
        // shaders
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_1_1 WTG_PS_NOBLUR();
        AlphaBlendEnable = true;
        SrcBlend = ONE;
        DestBlend = ZERO;
        
        ZEnable = true;
        ZWriteEnable = true;

        CullMode = CW;
    }  
}

technique WholeTexture
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
        ViewTransform        = <View>;
        ProjectionTransform = <Projection>;
        CullMode            = CW;

        ColorOp[0]          = Modulate;
        ColorArg1[0]        = Diffuse;
        ColorArg2[0]        = Texture;
        AlphaOp[0]          = Modulate;
        AlphaArg1[0]        = Diffuse;
        AlphaArg2[0]        = Texture;
        Texture[0]          = <regularTexture>;
        TexCoordIndex[0]	= 0;
        Texture[1]			= <regularTexture>;
        TexCoordIndex[1]	= 1;
        Texture[2]			= <regularTexture>;
        TexCoordIndex[2]	= 2;
        ColorOp[1]			= Disable;
        AlphaOp[1]			= Disable;

        AlphaBlendEnable = FALSE;
        ZEnable                = True;
        ZWriteEnable        = True;
    }
}