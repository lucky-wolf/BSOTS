string description = "Planet rendering";

#include "../../Render/Shared/TransformState.fxh"
#include "../../Render/Shared/LightingState.fxh"
#include "../../Render/Shared/Common.fxh"
#include "Planet_Haze.fxh"

// transforms
half4x4 World		: WORLD;

half4x4 TextureTransform_Atmosphere : TEXTURETRANSFORM0PARAM; //TextureTransform0Param;
half4x4 TextureTransform_Noise      : TEXTURETRANSFORM1PARAM;
half4x4 TextureTransform2Param      : TEXTURETRANSFORM2PARAM; // PlanetShift

#define PLANET_LIGHTSCALE (2.0f)	// Super-saturation of the light intensity for a sharper hemisphere.

texture Texture_Noise : TEXTURE0PARAM
<
	string ResourceName = "Noise.tga";
>;
texture Texture_Surface : TEXTURE1PARAM
<
	string ResourceName = "DefaultSurface.tga";
>;
texture Texture_Population : TEXTURE2PARAM
<
	string ResourceName = "DefaultPopulation.tga";
>;
texture Texture_Atmosphere : TEXTURE3PARAM
<
	string ResourceName = "Human_atmosphere_poor.tga";
>;

half4 materialAmbient : Ambient
<
	string UIName = "Material 0 Ambient";
> = { 1.0f, 1.0f, 1.0f, 1.0f };

half4 materialDiffuse : Diffuse
<
	string UIName = "Material 0 Diffuse";
> = { 1.0f, 1.0f, 1.0f, 1.0f };

half4 materialEmissive : Emissive
<
	string UIName = "Material 0 Emissive";
>  = { 0.0f, 0.0f, 0.0f, 1.0f };

half materialPower : SpecularPower
<
    string UIWidget = "slider";
    half UIMin = 1.0;
    half UIMax = 128.0;
    half UIStep = 1.0;
    string UIName = "Material 0 Specular Power";
> = 10.0;

half4 materialSpecular : Specular
<
	string UIName = "Material 0 Specular";
> = { 0.37f, 0.37f, 0.37f, 1.0f };

half Radius : PLANETRADIUS
<
	string UIName = "Glow ring inside radius";
> = 1350.0f;

half PlanetScale : PLANETSCALE
<
	string UIName = "Value with which to scale the planet";
> = 1.0f;

//------------------------------------
struct vertexInput {
    half3 position				: POSITION;
    half3 normal				: NORMAL;
    half4 texCoordDiffuse		: TEXCOORD0;
};

struct vertexOutput {
    half4 hPosition		: POSITION;
    half4 diffAmbColor		: COLOR0;
    half4 specCol_dot		: COLOR1;
    half2 surfaceTexCoord	: TEXCOORD0;
    half2 nightTexCoord	: TEXCOORD1;
    half2 cloudTexCoord	: TEXCOORD2;
    half4 noiseTexCoord	: TEXCOORD3;
    half4 hazeColour		: TEXCOORD4;
};

struct lowVertexOutput {
    half4 hPosition		: POSITION;
    half4 diffAmbColor		: COLOR0;
    half4 specCol			: COLOR1;
    half2 surfaceTexCoord	: TEXCOORD0;
    half2 nightTexCoord	: TEXCOORD1;
    half2 cloudTexCoord	: TEXCOORD2;
    half4 noiseTexCoord	: TEXCOORD3;
    half4 hazeColour		: TEXCOORD4;
};

//------------------------------------
vertexOutput VS_TransformAndTexture(vertexInput IN ) 
{
    vertexOutput OUT;

    matrix VP = mul(View, Projection);

	half3 direction = normalize(IN.position).xyz;
	half3 tempPos = direction * ( Radius * PlanetScale );

	half4 pos = mul( half4( tempPos, 1 ), World );
	OUT.hPosition = mul( pos, VP );
    OUT.surfaceTexCoord = IN.texCoordDiffuse;
    OUT.nightTexCoord = IN.texCoordDiffuse;
	// reverse the direction that the atmosphere moves...
    half4 cloudPos = half4( -IN.texCoordDiffuse.x, IN.texCoordDiffuse.y, 0, 1 );
    cloudPos = mul( cloudPos, TextureTransform_Atmosphere );
    OUT.cloudTexCoord = cloudPos.xy;
    OUT.noiseTexCoord = IN.texCoordDiffuse * 11;

	//calculate our vectors N, E, L, and H
	half3 N = normalize(pos - World[3]);
    half3 E = normalize(InvView[3].xyz - pos); //eye vector
    half3 L = normalize( -Light1Dir.xyz ); //light vector
    half3 H = normalize(E + L); //half angle vector

	//calculate the diffuse and specular contributions
	half nDotL = dot( N, L );
    half diff = max(0 , dot(N,L));
    half  spec = pow( max(0 , dot(N,H) ) , materialPower );
    if( diff <= 0 )
    {
        spec = 0;
    }

	half4 Light1DiffuseScaled = PLANET_LIGHTSCALE*Light1Diffuse;
	half4 Light1SpecularScaled = PLANET_LIGHTSCALE*Light1Specular;
	
	//output diffuse
    half4 ambColor = materialDiffuse * LightAmbient;
    half4 diffColor = materialDiffuse * diff * Light1DiffuseScaled;
    OUT.diffAmbColor.rgb = ( diffColor + ambColor ).rgb;
    OUT.diffAmbColor.a = ( diff * Light1DiffuseScaled ).r;

	//output specular
    half4 specColor = materialSpecular * Light1SpecularScaled * spec;
    OUT.specCol_dot.rgb = specColor.rgb;
	OUT.specCol_dot.a = ( nDotL + 1 ) * 0.5f;

	OUT.hazeColour.rgb = HazeColour;
	OUT.hazeColour.a = HAZE_ATTENUATE(E,N,L);
    return OUT;
}

//------------------------------------
lowVertexOutput VS_LowTransformAndTexture(vertexInput IN ) 
{
    lowVertexOutput OUT;

    matrix VP = mul(View, Projection);

	half3 direction = normalize(IN.position).xyz;
	half3 tempPos = direction * ( Radius * PlanetScale );

	half4 pos = mul( half4( tempPos, 1 ), World );
	OUT.hPosition = mul( pos, VP );
    OUT.surfaceTexCoord = IN.texCoordDiffuse;
    OUT.nightTexCoord = IN.texCoordDiffuse;
    half4 cloudPos = half4( -IN.texCoordDiffuse.x, IN.texCoordDiffuse.y, 0, 1 );
    cloudPos = mul( cloudPos, TextureTransform_Atmosphere );
    OUT.cloudTexCoord = cloudPos.xy;
    OUT.noiseTexCoord = IN.texCoordDiffuse * 11;

	//calculate our vectors N, E, L, and H
	half3 N = normalize(pos - World[3]);
    half3 E = normalize(InvView[3].xyz - pos); //eye vector
    half3 L = normalize( -Light1Dir.xyz ); //light vector
    half3 H = normalize(E + L); //half angle vector

	//calculate the diffuse and specular contributions
	half nDotL = dot( N, L );
    half diff = max(0 , dot(N,L));
    half  spec = pow( max(0 , dot(N,H) ) , materialPower );
    if( diff <= 0 )
    {
        spec = 0;
    }

	half4 Light1DiffuseScaled = PLANET_LIGHTSCALE*Light1Diffuse;
	half4 Light1SpecularScaled = PLANET_LIGHTSCALE*Light1Specular;
	
	//output diffuse
    half4 ambColor = materialDiffuse * LightAmbient;
    half4 diffColor = materialDiffuse * diff * Light1DiffuseScaled;
    OUT.diffAmbColor = diffColor + ambColor;

	//output specular
    half4 specColor = materialSpecular * Light1SpecularScaled * spec;
    OUT.specCol = specColor;

	OUT.hazeColour.rgb = HazeColour;
	OUT.hazeColour.a = HAZE_ATTENUATE(E,N,L);
    return OUT;
}


//------------------------------------
sampler nightSampler = sampler_state
{
	texture = <Texture_Population>;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
    MIPFILTER = (mipFilter);
    MINFILTER = (minFilter);
    MAGFILTER = (magFilter);
};

sampler surfaceSampler = sampler_state
{
	texture = <Texture_Surface>;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
    MIPFILTER = (mipFilter);
    MINFILTER = (minFilter);
    MAGFILTER = (magFilter);
};

sampler cloudSampler = sampler_state
{
	texture = <Texture_Atmosphere>;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
    MIPFILTER = (mipFilter);
    MINFILTER = (minFilter);
    MAGFILTER = (magFilter);
};

sampler noiseSampler = sampler_state
{
	texture = <Texture_Noise>;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
    MIPFILTER = (mipFilter);
    MINFILTER = (minFilter);
    MAGFILTER = (magFilter);
};

//-----------------------------------
half4 PS_Textured( vertexOutput IN): COLOR
{
	half diff = IN.diffAmbColor.a;
	half invDiff = 1.0f - diff;
	half4 surfaceTex = tex2D( surfaceSampler, IN.surfaceTexCoord );
	half surfaceAlpha = surfaceTex.a;
	surfaceTex *= IN.diffAmbColor;
	half3 spec = IN.specCol_dot.rgb * surfaceAlpha;
	half3 noiseTex = tex2D( noiseSampler, IN.noiseTexCoord ) / 2 + 0.5f;
	half3 surfaceColour = surfaceTex.rgb * noiseTex;
	half3 waterColour = surfaceTex.rgb + spec;
	half3 dayColour = lerp( surfaceColour, waterColour, surfaceAlpha ) * diff;
	half3 nightColour = tex2D( nightSampler, IN.nightTexCoord ).rgb * invDiff;
	half4 cloudTex = tex2D( cloudSampler, IN.cloudTexCoord );
	half3 cloudColor = cloudTex * diff;
	half3 planetColour = dayColour + nightColour;
	half3 planet_cloud = lerp( planetColour, cloudColor, cloudTex.a );// UNCOMMENT FOR MORE OPAQUE CLOUDS: 1-((1-cloudTex.a)*(1-cloudTex.a)) );
	half3 result = lerp( planet_cloud, IN.hazeColour.rgb, IN.hazeColour.a );
	return half4( result, 1 );
}


//-----------------------------------
technique textured
<
	string level = "High";
>
{
    pass p0 
    {		
		VertexShader = compile vs_1_1 VS_TransformAndTexture();
		PixelShader  = compile ps_2_0 PS_Textured();

    	CullMode = CW;

        ZEnable = True;
        ZWriteEnable = True;
    }
}

technique MultiTexturePlanet
<
	string level="Medium";
>
{
    pass SurfaceWater
    {
    	CullMode = CW;
        // Setup:  VertexPipe States
        Lighting = True;
        SpecularEnable = True;
        ColorVertex = False;
        FillMode = Solid;
        NormalizeNormals = False;

        AmbientMaterialSource = MATERIAL;
        DiffuseMaterialSource = MATERIAL;
        EmissiveMaterialSource = MATERIAL;
        SpecularMaterialSource = MATERIAL;

        // Setup: Light States
        Ambient = {0.0f, 0.0f, 0.0f, 1.0f};

        LightType[0]      = DIRECTIONAL;
        LightDiffuse[0]   = <Light1Diffuse>;//{3.0, 3.0, 3.0, 0.0};
        LightSpecular[0]  = <Light1Specular>;//{0.5, 0.5, 0.5, 0.0}; 
        LightAmbient[0]   = <LightAmbient>;//{0.1, 0.1, 0.1, 0.0};
        LightDirection[0] = <Light1Dir>;
        LightType[0] = DIRECTIONAL;
        LightEnable[0] = True;

        // Setup: Material States
        MaterialAmbient = <materialAmbient>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        MaterialDiffuse = <materialDiffuse>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        MaterialEmissive = <materialEmissive>;//{ 0.0f, 0.0f, 0.0f, 1.0f };
        MaterialPower = <materialPower>;//20.0f;
        MaterialSpecular = <materialSpecular>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        
        // Setup: Texture Stage States

        ColorOp[0]   = MODULATE;
        ColorArg0[0] = DIFFUSE;
        ColorArg1[0] = TEXTURE;
        AlphaOp[0]   = DISABLE;
        AlphaArg1[0] = TEXTURE;
        AlphaArg2[0] = DIFFUSE;
        TexCoordIndex[0] = 0;
        TextureTransformFlags[ 0 ] = DISABLE;
        
        ColorOp[1] = DISABLE;
        AlphaOP[1] = DISABLE;

        // Setup: Pixel Pipe Render States
        AlphaBlendEnable = False;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
        
        AlphaTestEnable = True;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = 0x08;
        
        ColorWriteEnable = RED|GREEN|BLUE|ALPHA;
        
        ZEnable = True;
        ZWriteEnable = True;
        
        
        // Setup: Sampler Stage States
		MIPFILTER[0] = <mipFilter>;
		MINFILTER[0] = <minFilter>;
		MAGFILTER[0] = <magFilter>;
        
        
        // Setup: Shaders
		VertexShader = compile vs_1_1 VS_LowTransformAndTexture();
        PixelShader = NULL;
        
        // Setup: Transform
        WorldTransform[0] = <World>;
        
        // Setup: Texture
        Texture[0] = <Texture_Surface>;        
    }

    pass SurfaceLand
    {
        // Setup:  VertexPipe States
        Lighting = True;
        SpecularEnable = FALSE;
        ColorVertex = False;
        FillMode = Solid;
        NormalizeNormals = False;

        AmbientMaterialSource = MATERIAL;
        DiffuseMaterialSource = MATERIAL;
        EmissiveMaterialSource = MATERIAL;
        SpecularMaterialSource = MATERIAL;


        // Setup: Light States
        Ambient = {0.0f, 0.0f, 0.0f, 1.0f};
     

        LightType[0]      = DIRECTIONAL;
        LightDiffuse[0]   = <Light1Diffuse>;//{3.0, 3.0, 3.0, 0.0};
        LightSpecular[0]  = <Light1Specular>;//{0.5, 0.5, 0.5, 0.0}; 
        LightAmbient[0]   = <LightAmbient>;//{0.1, 0.1, 0.1, 0.0};
        LightDirection[0] = <Light1Dir>;
        LightType[0] = DIRECTIONAL;
        LightEnable[0] = True;

        // Setup: Material States
        MaterialAmbient  = <materialAmbient>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        MaterialDiffuse  = <materialDiffuse>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        MaterialEmissive = <materialEmissive>;//{ 0.0f, 0.0f, 0.0f, 1.0f };
        MaterialPower    = <materialPower>;//20.0f;
        MaterialSpecular = <materialSpecular>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        
        // Setup: Texture Stage States

        ColorOp[0]   = LERP;
        ColorArg0[0] = TEXTURE | ALPHAREPLICATE;
        ColorArg1[0] = DIFFUSE;
        ColorArg2[0] = TEXTURE;

        AlphaOp[0]   = MODULATE;
        AlphaArg1[0] = TEXTURE | COMPLEMENT;
        AlphaArg2[0] = DIFFUSE;
        TexCoordIndex[0] = 0;
        TextureTransformFlags[ 0 ] = DISABLE;
        
        ColorOp[1] = LERP;
        ColorArg0[1] = DIFFUSE;
        ColorArg1[1] = CURRENT;
        ColorArg2[1] = TEXTURE;
        AlphaOp[1] = DISABLE;
        TexCoordIndex[1] = 0;
        TextureTransformFlags[ 1 ] = DISABLE;
        
        ColorOp[2] = MODULATE;
        ColorArg0[2] = CURRENT;
        ColorArg1[2] = TEXTURE;
        AlphaOp[2] = DISABLE;
        TexCoordIndex[2] = PassThru;
        TextureTransformFlags[ 2 ] = Count2;
        TextureTransform[2] = <TextureTransform_Noise>;

        ColorOp[3] = DISABLE;
        AlphaOP[3] = DISABLE;
        // Setup: Pixel Pipe Render States
        AlphaBlendEnable = True;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
        
        AlphaTestEnable = True;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = 0x08;
        
        ColorWriteEnable = RED|GREEN|BLUE|ALPHA;
        
        ZEnable = True;
        ZWriteEnable = False;
        
        
        // Setup: Sampler Stage States
		MIPFILTER[0] = <mipFilter>;
		MINFILTER[0] = <minFilter>;
		MAGFILTER[0] = <magFilter>;
		MIPFILTER[1] = <mipFilter>;
		MINFILTER[1] = <minFilter>;
		MAGFILTER[1] = <magFilter>;
		MIPFILTER[2] = <mipFilter>;
		MINFILTER[2] = <minFilter>;
		MAGFILTER[2] = <magFilter>;
        
        
        // Setup: Shaders
		VertexShader = compile vs_1_1 VS_LowTransformAndTexture();
        PixelShader = NULL;
        
        // Setup: Transform
        WorldTransform[0] = <World>;
        
        // Setup: Texture
        Texture[0] = <Texture_Surface>;        
        Texture[1] = <Texture_Population>;
        Texture[2] = <Texture_Noise>;
        Texture[3] = <Texture_Atmosphere>;
        //Texture[0] = (Tex0);
    }

    pass Atmosphere
    {
        // Setup: VertexPipe States
        Lighting = True;
        SpecularEnable = True;
        ColorVertex = False;
        FillMode = Solid;
        NormalizeNormals = False;
        
        AmbientMaterialSource = MATERIAL;
        DiffuseMaterialSource = MATERIAL;
        EmissiveMaterialSource = MATERIAL;
        SpecularMaterialSource = MATERIAL;


        // Setup: Light States
        Ambient = {0.0f, 0.0f, 0.0f, 1.0f};
        

        LightType[0]      = DIRECTIONAL;
        LightDiffuse[0]   = <Light1Diffuse>;//{1.0, 1.0, 1.0, 1.0};
        LightSpecular[0]  = <Light1Specular>;//{0.0, 0.0, 0.0, 0.0}; 
        LightAmbient[0]   = <LightAmbient>;//{1.0, 1.0, 1.0, 1.0};
        LightDirection[0] = <Light1Dir>;
        LightType[0] = DIRECTIONAL;
        LightEnable[0] = True;
        

        // Setup: Material States
        MaterialAmbient  = <materialAmbient>;//{ 0.2f, 0.2f, 0.2f, 1.0f };
        MaterialDiffuse  = <materialDiffuse>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        MaterialEmissive = <materialEmissive>;//{ 0.0f, 0.0f, 0.0f, 0.0f };
        MaterialPower    = <materialPower>;//10.0f;
        MaterialSpecular = <materialSpecular>;//{ 0.0f, 0.0f, 0.0f, 0.0f };
        
        // Setup: Texture Stage States
        ColorOp[0]   = MODULATE;
        ColorArg1[0] = TEXTURE;
        ColorArg2[0] = DIFFUSE;
        AlphaOp[0]   = SELECTARG1;
        AlphaArg1[0] = TEXTURE;
        AlphaArg2[0] = DIFFUSE;

        ColorOp[1] = Disable;
        AlphaOp[1] = Disable;
  
        // Setup: Pixel Pipe Render States
        AlphaBlendEnable = True;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
        
        AlphaTestEnable = True;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = 0x08;
        
        ColorWriteEnable = RED|GREEN|BLUE|ALPHA;
        
        ZEnable = True;
        ZWriteEnable = False;
        
        // Setup: Sampler Stage States
		MIPFILTER[0] = <mipFilter>;
		MINFILTER[0] = <minFilter>;
		MAGFILTER[0] = <magFilter>;
        
        // Setup: Shaders
		VertexShader = compile vs_1_1 VS_LowTransformAndTexture();
        PixelShader = NULL;
        
        // Setup: Transform
        WorldTransform[0] = <World>;

        // Setup texture transform
        TexCoordIndex[0] = PassThru;
        TextureTransformFlags[ 0 ] = Count2;
        TextureTransform[0] = <TextureTransform_Atmosphere>;
    
        ADDRESSU[0] = wrap;
        ADDRESSV[0] = wrap;
        
        // Setup: Texture
        Texture[0] = <Texture_Atmosphere>;
    }

}

//---------------------------------------------------------------
// fixed function planet
technique ThreePassPlanet
<
	string level = "Low";
>
{
    pass specularWater
    {
        // Setup:  VertexPipe States
        Lighting = True;
        SpecularEnable = True;
        ColorVertex = False;
        FillMode = Solid;
        NormalizeNormals = False;

        AmbientMaterialSource = MATERIAL;
        DiffuseMaterialSource = MATERIAL;
        EmissiveMaterialSource = MATERIAL;
        SpecularMaterialSource = MATERIAL;


        // Setup: Light States
        Ambient = {0.0f, 0.0f, 0.0f, 1.0f};
        

        LightType[0]      = DIRECTIONAL;
        LightDiffuse[0]   = <Light1Diffuse>;//{3.0, 3.0, 3.0, 0.0};
        LightSpecular[0]  = <Light1Specular>;//{0.5, 0.5, 0.5, 0.0}; 
        LightAmbient[0]   = <LightAmbient>;//{0.1, 0.1, 0.1, 0.0};
        LightDirection[0] = <Light1Dir>;
        LightType[0] = DIRECTIONAL;
        LightEnable[0] = True;

        // Setup: Material States
        MaterialAmbient  = <materialAmbient>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        MaterialDiffuse  = <materialDiffuse>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        MaterialEmissive = <materialEmissive>;//{ 0.0f, 0.0f, 0.0f, 1.0f };
        MaterialPower    = <materialPower>;//20.0f;
        MaterialSpecular = <materialSpecular>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        
        // Setup: Texture Stage States

        ColorOp[0]   = MODULATE;
        ColorArg0[0] = DIFFUSE;
        ColorArg1[0] = TEXTURE;
        AlphaOp[0]   = DISABLE;
        TexCoordIndex[0] = 0;
        TextureTransformFlags[ 0 ] = DISABLE;
        
        ColorOp[1] = DISABLE;
        AlphaOP[1] = DISABLE;
        // Setup: Pixel Pipe Render States
        AlphaBlendEnable = True;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
        
        AlphaTestEnable = True;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = 0x08;
        
        ColorWriteEnable = RED|GREEN|BLUE|ALPHA;
        
        ZEnable = True;
        ZWriteEnable = True;
        
        
        // Setup: Sampler Stage States
        MinFilter[0] = linear;
        MagFilter[0] = linear;
        MipFilter[0] = Linear;
        
        
        // Setup: Shaders
        VertexShader = NULL;
        PixelShader = NULL;
        
        // Setup: Transform
        WorldTransform[0] = <World>;
        ViewTransform = <View>;
        ProjectionTransform = <Projection>;
        
        // Setup: Texture
        Texture[0] = <Texture_Surface>;        
    }

    pass p0//surface
    {       
        // Setup: VertexPipe States
        Lighting = True;
        SpecularEnable = false;
        ColorVertex = False;
        FillMode = Solid;
        NormalizeNormals = False;
        
        AmbientMaterialSource = MATERIAL;
        DiffuseMaterialSource = MATERIAL;
        EmissiveMaterialSource = MATERIAL;
        SpecularMaterialSource = MATERIAL;


        // Setup: Light States
        Ambient = {0.0f, 0.0f, 0.0f, 1.0f};
        

        LightType[0]      = DIRECTIONAL;
        LightDiffuse[0]   = <Light1Diffuse>;//{3.0, 3.0, 3.0, 0.0};
        LightSpecular[0]  = <Light1Specular>;//{0.0, 0.0, 0.0, 0.0}; 
        LightAmbient[0]   = <LightAmbient>;//{0.1, 0.1, 0.1, 0.0};
        LightDirection[0] = <Light1Dir>;
        LightType[0] = DIRECTIONAL;
        LightEnable[0] = True;
        

        // Setup: Material States
        MaterialAmbient  = <materialAmbient>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        MaterialDiffuse  = <materialDiffuse>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        MaterialEmissive = <materialEmissive>;//{ 0.0f, 0.0f, 0.0f, 1.0f };
        MaterialPower    = <materialPower>;//20.0f;
        MaterialSpecular = <materialSpecular>;//{ 1.0f, 1.0f, 1.0f, 1.0f };

        ColorOp[0]   = MODULATE;
        ColorArg0[0] = DIFFUSE;
        ColorArg1[0] = TEXTURE;
        AlphaOp[0]   = SELECTARG1;
        AlphaArg0[0] = TEXTURE | COMPLEMENT;
        AlphaArg1[0] = DIFFUSE;
        TexCoordIndex[0] = 0;
        TextureTransformFlags[ 0 ] = DISABLE;
        
        ColorOp[1] = Disable;
        AlphaOp[1] = Disable;
        
  
        // Setup: Pixel Pipe Render States
        AlphaBlendEnable = True;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
        
        AlphaTestEnable = True;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = 0x08;
        
        ColorWriteEnable = RED|GREEN|BLUE|ALPHA;
        
        ZEnable = True;
        ZWriteEnable = True;
        
        
        // Setup: Sampler Stage States
        MinFilter[0] = Linear;
        MagFilter[0] = Linear;
        MipFilter[0] = Linear;
        
        
        // Setup: Shaders
        VertexShader = NULL;
        PixelShader = NULL;
        
        // Setup: Transform
       WorldTransform[0] = <World>;
        ViewTransform = <View>;
        ProjectionTransform = <Projection>;
        
        // Setup: Texture
        Texture[0] = <Texture_Surface>;        
        //Texture[0] = (Tex0);
    }

    pass p1 //population
    {       
        // Setup: VertexPipe States
        Lighting = True;
        SpecularEnable = False;
        ColorVertex = False;
        FillMode = Solid;
        NormalizeNormals = False;
        
        AmbientMaterialSource = MATERIAL;
        DiffuseMaterialSource = MATERIAL;
        EmissiveMaterialSource = MATERIAL;
        SpecularMaterialSource = MATERIAL;


        // Setup: Light States
        Ambient = {0.0f, 0.0f, 0.0f, 1.0f};
        

        LightType[0]      = DIRECTIONAL;
        LightDiffuse[0]   = {10.0, 10.0, 10.0, 0.0};
        LightSpecular[0]  = {0.0, 0.0, 0.0, 0.0}; 
        LightAmbient[0]   = {0.0, 0.0, 0.0, 0.0};
        LightDirection[0] = <-Light1Dir>;
        LightType[0] = DIRECTIONAL;
        LightEnable[0] = True;
        

        // Setup: Material States
        MaterialAmbient = { 1.0f, 1.0f, 1.0f, 0.0f };
        MaterialDiffuse = { 15.0f, 15.0f, 15.0f, 1.0f };
        MaterialEmissive = { 0.0f, 0.0f, 0.0f, 1.0f };
        MaterialPower = 10.0f;
        
        // Setup: Texture Stage States
        ColorOp[0]   = MODULATE;
        ColorArg1[0] = TEXTURE;
        ColorArg2[0] = DIFFUSE;
        AlphaOp[0]   = MODULATE;
        AlphaArg1[0] = TEXTURE;
        AlphaArg2[0] = DIFFUSE;
        TexCoordIndex[0] = 0;
        TextureTransformFlags[ 0 ] = DISABLE;
                
        ColorOp[1] = Disable;
        AlphaOp[1] = Disable;
        
  
        // Setup: Pixel Pipe Render States
        AlphaBlendEnable = True;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCCOLOR;
        
        AlphaTestEnable = True;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = 0x08;
        
        ColorWriteEnable = RED|GREEN|BLUE|ALPHA;
        
        ZEnable = True;
        ZWriteEnable = True;
        
        
        // Setup: Sampler Stage States
        MinFilter[0] = Linear;
        MagFilter[0] = Linear;
        MipFilter[0] = Linear;
        
        
        // Setup: Shaders
        VertexShader = NULL;
        PixelShader = NULL;
        
        
        // Setup: Transform
        WorldTransform[0] = <World>;
        ViewTransform = <View>;
        ProjectionTransform = <Projection>;
        
        // Setup: Texture
        Texture[0] = <Texture_Population>;        
        //Texture[0] = (Tex1);
    }

    pass p2 //atmosphere
    {       
        // Setup: VertexPipe States
        Lighting = True;
        SpecularEnable = TRUE;
        ColorVertex = False;
        FillMode = Solid;
        NormalizeNormals = False;
        
        AmbientMaterialSource = MATERIAL;
        DiffuseMaterialSource = MATERIAL;
        EmissiveMaterialSource = MATERIAL;
        SpecularMaterialSource = MATERIAL;


        // Setup: Light States
        Ambient = {0.0f, 0.0f, 0.0f, 1.0f};
        

        LightType[0]      = DIRECTIONAL;
        LightDiffuse[0]   = <Light1Diffuse>;//{1.0, 1.0, 1.0, 1.0};
        LightSpecular[0]  = <Light1Specular>;//{0.0, 0.0, 0.0, 0.0}; 
        LightAmbient[0]   = <LightAmbient>;//{1.0, 1.0, 1.0, 1.0};
        LightDirection[0] = <Light1Dir>;
        LightType[0] = DIRECTIONAL;
        LightEnable[0] = True;
        

        // Setup: Material States
        MaterialAmbient  = <materialAmbient>;//{ 0.2f, 0.2f, 0.2f, 1.0f };
        MaterialDiffuse  = <materialDiffuse>;//{ 1.0f, 1.0f, 1.0f, 1.0f };
        MaterialEmissive = <materialEmissive>;//{ 0.0f, 0.0f, 0.0f, 0.0f };
        MaterialPower    = <materialPower>;//10.0f;
        MaterialSpecular = <materialSpecular>;//{ 0.0f, 0.0f, 0.0f, 0.0f };

        
        // Setup: Texture Stage States
        ColorOp[0]   = MODULATE;
        ColorArg1[0] = TEXTURE;
        ColorArg2[0] = DIFFUSE;
        AlphaOp[0]   = SELECTARG1;
        AlphaArg1[0] = TEXTURE;
        AlphaArg2[0] = DIFFUSE;
       
        ColorOp[1] = Disable;
        AlphaOp[1] = Disable;
        
        // Setup: Pixel Pipe Render States
        AlphaBlendEnable = True;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
        
        AlphaTestEnable = True;
        AlphaFunc = GREATEREQUAL;
        AlphaRef = 0x08;
        
        ColorWriteEnable = RED|GREEN|BLUE|ALPHA;
        
        ZEnable = True;
        ZWriteEnable = True;
        
        
        // Setup: Sampler Stage States
        MinFilter[0] = Linear;
        MagFilter[0] = Linear;
        MipFilter[0] = Linear;
        
        
        // Setup: Shaders
        VertexShader = NULL;
        PixelShader = NULL;
        
        
        // Setup: Transform
        WorldTransform[0] = <World>;
        ViewTransform = <View>;
        ProjectionTransform = <Projection>;

        // Setup texture transform
        TexCoordIndex[0] = PassThru;
        TextureTransformFlags[ 0 ] = Count2;
        TextureTransform[0] = <TextureTransform_Atmosphere>;
    
        ADDRESSU[0] = wrap;
        ADDRESSV[0] = wrap;
        
        // Setup: Texture
        Texture[0] = <Texture_Atmosphere>;        
        //Texture[0] = (Tex2);
    }
}
