//
// Planet_Haze.fxh
//
// Planet haze attenuation.  This is all based on the idea of starlight energizing and being diffused by a planet's atmosphere.
// Therefore the haze is treated as a volumetric effect extending from the surface of the planet ONLY where light hits.
//

float3 HazeColour : Diffuse
<
	string UINAME = "Haze Colour";
> = { 1.0f, 1.0f, 1.0f };

float HazeIntensity
<
	string UINAME = "Haze Opacity";
> = 1.0f;

#define HAZE_INTENSITY		(HazeIntensity)	// The opacity of the haze at its strongest points.
#define HAZE_PROPAGATION	(0.17f)			// Larger values [0..1] make haze travel farther around the geometry.  (<0 diminishes the wraparound.)
#define HAZE_POWER			(2.0f)			// Larger values make the fogging less dense where the surface is viewed head-on.


// HAZE_ATTENUATE() computes the fog opacity (alpha value) for a point with the given parameters.
// HAZE_ATTENUATE_OBLIQUE() is the same except that it is simplified for dot(E,N)=0 (as is the case for the planet ring rendering).
//
//  E: Eye direction.
//  N: Surface normal.
//  L: Eye-to-lightsource direction.
//
#define HAZE_ATTENUATE(E,N,L)		saturate( saturate( dot(N,L) * HAZE_INTENSITY + HAZE_PROPAGATION ) - ((1-pow(1-dot(N,E),HAZE_POWER)) * HAZE_INTENSITY) )
#define HAZE_ATTENUATE_OBLIQUE(N,L)	saturate( dot(N,L) * HAZE_INTENSITY + HAZE_PROPAGATION )
