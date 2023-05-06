#include "Shared/LightingState.fxh"
#include "Shared/TransformState.fxh"
#include "Shared/Common.fxh"

texture Texture0 : DIFFUSEMAP < string UIName = "Texture"; >;

half4x4 World			: WORLD;

bool Opaque = false;

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

//------------------------------------
struct VS_INPUT
{
	half4 position : POSITION;
    half3 normal 	: NORMAL;
    half2 texCoord : TEXCOORD0;
    half4 diffuse	: COLOR0;
};

struct VS_OUTPUT
{
    half4 position : POSITION;        // vertex position
    half4 diffuse  : COLOR0;        // vertex diffuse colour
    half2 texCoord : TEXCOORD0;    // vertex texture coords
    half2 Clip		: TEXCOORD1;
};

//------------------------------------
VS_OUTPUT 
VS( VS_INPUT input )
{
    VS_OUTPUT output;

	half4 worldPoint = mul( input.position, World );
    matrix VP = mul(View, Projection);
    
    output.position = mul( worldPoint, VP );
    output.texCoord = input.texCoord;
    output.diffuse = input.diffuse;
    
	output.Clip = CalculateClipping( worldPoint );

    output.texCoord.x = input.texCoord.x + ( Time * uvSpeed * uDirection );
    output.texCoord.y = input.texCoord.y + ( Time * uvSpeed * vDirection );

    return output;
}

sampler Sampler = sampler_state
{
    Texture   = (Texture0);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
};

half4 PS(
    half4 diffuse  : COLOR0,
    half2 texCoord : TEXCOORD0,
    half3 Clip     : TEXCOORD1 ) : COLOR
{
	clip( Clip );
    half4 texColour = tex2D( Sampler, texCoord );
    return texColour * diffuse * manualFadeAmount;
}

technique tec0
<
	string level = "Low";
>
{
	pass p0
	{
		Lighting = False;
		ColorVertex = True;
		CullMode = NONE;
		FillMode = Solid;

		AlphaBlendEnable = True;
		SrcBlend = One;
		DestBlend = One;

		ZEnable = True;
		ZWriteEnable = False;
		ZFunc = LESSEQUAL;

		AlphaTestEnable = False;

		Texture[0] = <Texture0>;

		TextureFactor = half4( manualFadeAmount, manualFadeAmount, manualFadeAmount, manualFadeAmount );
		ColorOp[0] = Modulate;
		ColorArg1[0] = Texture;
		ColorArg2[0] = TFactor;
		AlphaOp[0] = Modulate;
		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;

		ColorOp[1] = Disable;
		AlphaOp[1] = Disable;

		MinFilter[0] = (minFilter);
		MagFilter[0] = (magFilter);
		MipFilter[0] = (mipFilter);

        WorldTransform[0]   = <World>;

		// Setup: Shaders
		VertexShader = compile vs_1_1 VS();
		PixelShader = NULL;//compile ps_1_1 PS();    
	}
}
