#include "Shared/LightingState.fxh"
#include "Shared/TransformState.fxh"
#include "Shared/Common.fxh"

float4x4	World		: WORLD;
half4		Ambient		: MATERIALAMBIENT = {1, 1, 1, 1};
float		WaveSize = 2.f;
texture		Texture;

sampler Sampler = sampler_state
{
    Texture   = (Texture);
    MipFilter = (mipFilter);
    MinFilter = (minFilter);
    MagFilter = (magFilter);
};

struct VSGLOW_OUTPUT
{
    float4 Position : POSITION;
    float4 Diffuse  : COLOR;
    float2 TexCoord : TEXCOORD0;
};

float4 PSGlow(VSGLOW_OUTPUT input) : COLOR
{
	float4 diffuseTexture = tex2D(Sampler, input.TexCoord);
	float3 output = diffuseTexture.rgb * input.Diffuse.rgb;
	return float4(output, 1.f);
}

VSGLOW_OUTPUT VSGlow
    (
    float4 Position : POSITION, 
    float3 Normal   : NORMAL
    )
{
    VSGLOW_OUTPUT Out = (VSGLOW_OUTPUT)0;

    float3 N = mul(Normal, (float3x3)World);     // normal (view space)
    N = normalize(mul(N, (float3x3)View));     // normal (view space)
    float3 P = mul(Position, World);    // displaced position (view space)

	float uvScale = 0.01f;
	Out.TexCoord.xy = float2(
				sin(uvScale * Position.x + 0.8 * Time) * sin(uvScale * Position.y + 2.3 * Time) * sin(uvScale * Position.z + 1.1 * Time), 
				cos(uvScale * Position.x + 1.2 * Time) * cos(uvScale * Position.y + 1.4 * Time) * cos(uvScale * Position.z + 1.4 * Time));

    P = mul(float4(P, 1) , View);    // displaced position (view space)
	P += (sin(Position.x + Position.y + Position.z + Time) * WaveSize) * N;
	
    float3 A = float3(0, 0, 1);                                 // glow axis

    float power;

    power  = 1 - dot(N, A);
    power *= power;
    power -= 1;
    power *= power;     // Power = (1 - (N.A)^2)^2 [ = ((N.A)^2 - 1)^2 ]

	float4 matDiffuse2;
	matDiffuse2.rgb = (sin(Position.x + Position.y + Position.z + Time * 2.3f) + 1.0f) * 0.5f * Diffuse.rgb;
	matDiffuse2.rgb *= 0.5f;
	matDiffuse2.a = 1.0f;
	    
	float4 matAmbient2 = float4(0,0,0,0);
	
    Out.Position = mul(float4(P, 1), Projection);   // projected position
    Out.Diffuse  = matDiffuse2 * power + matAmbient2; // modulated glow color + glow ambient

	
    return Out;    
}


technique tglow
<
	string level = "Low";
>
{
	pass pglow
	{
        // glow shader
        VertexShader = compile vs_1_1 VSGlow();
        PixelShader  = compile ps_1_1 PSGlow();
		ZEnable			= false;
		ZWriteEnable	= true;
        
        AddressU[0] = Wrap;
        AddressV[0] = Wrap;
        
        // enable alpha blending
        AlphaBlendEnable = TRUE;
        SrcBlend         = ONE;
        DestBlend        = ONE;

        // set up texture stage states to use the diffuse color
        ColorOp[0]   = SELECTARG2;
        ColorArg2[0] = DIFFUSE;
        AlphaOp[0]   = SELECTARG2;
        AlphaArg2[0] = DIFFUSE;

        ColorOp[1]   = DISABLE;
        AlphaOp[1]   = DISABLE;
	}
}
