#include "Shared/LightingState.fxh"
#include "Shared/TransformState.fxh"
#include "Shared/Common.fxh"

float4x4	World		: WORLD;
half4		Ambient		: MATERIALAMBIENT = {1, 1, 1, 1};
float		GlowThickness = 0.05f;

struct VSGLOW_OUTPUT
{
    float4 Position : POSITION;
    float4 Diffuse  : COLOR;
};

// draws a transparent hull of the unskinned object.
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
    P = mul(float4(P, 1) , View) + GlowThickness * N;    // displaced position (view space)
    
    float3 A = float3(0, 0, 1);                                 // glow axis

    float power;

    power  = dot(N, A);
    power *= power;
    power -= 1;
    power *= power;     // Power = (1 - (N.A)^2)^2 [ = ((N.A)^2 - 1)^2 ]

	float4 matDiffuse2 = Diffuse;
	matDiffuse2 *= 0.5f;
	    
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
        PixelShader  = Null;
        
        // no texture
        Texture[0] = NULL;

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
