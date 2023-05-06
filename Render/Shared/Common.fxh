// Common.fxh - shared params for standard lighting

shared half4      Ambient_        = { 1, 1, 1, 1 };    // ie. NOT used

shared half4 Diffuse : MATERIALDIFFUSE
#ifdef UI_DIFFUSE
<
	string UIName = "Diffuse";
>
#endif
= { 1, 1, 1, 1 };

shared half4 Specular : MATERIALSPECULAR 
#ifdef UI_SPECULAR
<
	string UIName = "Specular";
>
#endif
= { 0, 0, 0, 1 };

shared half Power : MATERIALPOWER
#ifdef UI_POWER
<
	string UIName = "Specular Power";
>
#endif
= 10.f;

shared half4 Emissive : MATERIALEMISSIVE
#ifdef UI_EMISSIVE 
<
	string UIName = "Emissive";
>
#endif
= { 0, 0, 0, 1 };

shared int magFilter = 1;
shared int minFilter = 1;
shared int mipFilter;

half4	   playerColour_f = { 1, 0, 1, 1 };

// For the fixed-function pipeline, the current fade amount (for cloaking or intangibility)
// is encoded into the alpha channel of the player colour.  The alpha is ignored in the 
// programmable pipeline...
//					  ARGB
int playerColour = 0xffff00ff;

int usePlayerColour = 0;

// By default, we use specular lighting.  This can be changed in Effect::SceneParams
shared int useSpecular = 0;
// By default, we use 2 lights.  This can be changed in Effect::SceneParams
shared int numLights = 2;

half cloakInterp = 0.0;
half4 ghostColor_f
<
   string UIWidget = "Color";
> = { 0.0980, 1.0000, 0.6198, 0.00 };

half intangInterp = 1.0;

half manualFadeAmount = 1.0f;

int enabledClipPlanes = 0;
half4 clipPlane0;

shared float Time : TIME = 0;

void LightNorm( inout half4 l )
{
    half c = max( max( l[0], l[1] ), l[2] );

    if ( c > 1 )
    {
        c = 1.0 / c;
        l[0] *= c;
        l[1] *= c;
        l[2] *= c;
    }
}

void LightClamp( inout half4 l )
{
    l = min( l, half4(1,1,1,1) );
}

// Given a point in world space, calculates it's distance from clipPlane0
// Result can be passed to the clip intrinsic function to kill the pixel.
float CalculateClipping( half4 worldPoint )
{
	float clipping = 1;
	if ( enabledClipPlanes > 0 )
	{
		float dist = clipPlane0.w - dot( worldPoint, clipPlane0.xyz );
		clipping = dist;
	}	
	
	return clipping;
}	



