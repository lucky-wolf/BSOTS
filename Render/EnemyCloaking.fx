#include "Shared/LightingState.fxh"
#include "Shared/TransformState.fxh"

bool Opaque = false;

texture     Texture0 < string name = ""; >;

float cloakInterp
<
   string UIName = "cloakInterp";
   string UIWidget = "Numeric";
   float UIMin = 0.00;
   float UIMax = 1.00;
> = 0.0f;

float4x4 World : WORLD;

float4      Ambient_        = { 1, 1, 1, 1 };    // ie. NOT used
float4      Diffuse_            : MATERIALDIFFUSE  = { 1, 1, 1, 1 };    // ie. NOT used
float4      Specular        : MATERIALSPECULAR = { 0, 0, 0, 1 };
float4      Emissive        : MATERIALEMISSIVE = { 0, 0, 0, 1 };
float       Power           : MATERIALPOWER    = 10;

struct VS_OUTPUT
{
    float4 Position    : POSITION;
    float4 Diffuse     : COLOR0;
    float3 Specular    : COLOR1;
    float2 TexCoord    : TEXCOORD0;
    float2 GhostCol_rg : TEXCOORD1;  
    float2 GhostCol_ba : TEXCOORD2;
};

struct VS_INPUT
{
    float3 Position  : POSITION;
    float4 Color     : COLOR0;
    float3 Normal    : NORMAL;
    float2 TexCoord  : TEXCOORD0;
};

void LightNorm( inout float4 l )
{
    float c = max( max( l[0], l[1] ), l[2] );

    if ( c > 1 )
    {
        c = 1.0 / c;
        l[0] *= c;
        l[1] *= c;
        l[2] *= c;
    }
}

void LightClamp( inout float4 l )
{
    l = min( l, float4(1,1,1,1) );
}

float4 lightGreen
<
   string UIName = "lightGreen";
   string UIWidget = "Color";
> = { 0.0980, 1.0000, 0.6198, 1.00 };

VS_OUTPUT VS( VS_INPUT In )
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // R is reflection vector (view space)

	float4x4 worldView = mul(World, View);
	
    float3 P = mul(float4(In.Position, 1), (float4x4)worldView);
    float3 V = -normalize(P);                                    // view direction (view space)
    float3 N = normalize(mul(In.Normal, (float3x3)worldView));
    float3 L1 = -mul(float3(Light1Dir),(float3x3)View);
    float3 L2 = -mul(float3(Light2Dir),(float3x3)View);
    float3 R1 = normalize(2 * dot(N, L1) * N - L1);
    float3 R2 = normalize(2 * dot(N, L2) * N - L2);

    // Diffuse lighting contribution  
    float4 Dl = Ambient_ * LightAmbient;
    Dl += Light1Diffuse * max(0, dot(N, L1));
    Dl += Light2Diffuse * max(0, dot(N, L2));
    LightNorm( Dl );

    // Specular lighting contribution
    float4 Sl = (float4)0;
    Sl += Light1Specular * pow( max(0,dot(R1,V)), Power );
    Sl += Light2Specular * pow( max(0,dot(R2,V)), Power );
    
    Out.Diffuse      = Diffuse_ * In.Color * Dl;

    Out.Position     = mul(float4(P, 1), Projection);
    Out.Specular     = ( Specular * Sl + Emissive );
    Out.TexCoord     = In.TexCoord;
    
    return Out;
}

sampler Sampler = sampler_state
{
    Texture   = (Texture0);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float4 PS(float2 texCoord: TEXCOORD0,
            float2 ghostColrg: TEXCOORD1, 
            float2 ghostColba: TEXCOORD2,
            float4 diff : COLOR0,
            float3 spec : COLOR1 ) : COLOR 
{
	float v = 1.0f - cloakInterp;
	
   float4 tex = tex2D( Sampler, texCoord.xy );
   float4 texColour = ( tex * diff + float4(spec, 0) ) * v;
   
   return texColour;
}


technique VS_1_1_PS_1_1
<
	string level = "Low";
>
{
    pass p0
    {
        VertexShader        = compile vs_1_1 VS();
        PixelShader         = compile ps_1_1 PS();

        CullMode            = CW;

        ZEnable                = True;
        ZWriteEnable        = True;
    }
}
