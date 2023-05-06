#include "Shared/TransformState.fxh"

half4x4 World : WORLD;

struct VS_OUTPUT
{
    half4 Position  : POSITION;
    half4 Color	 : COLOR0;
};

struct VS_INPUT
{
    half3 Position  : POSITION;
    half4 Color     : COLOR0;
};

VS_OUTPUT VS( VS_INPUT In )
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
  
    half3 P = mul(half4(In.Position, 1), World);
	
    Out.Color		= In.Color;
    Out.Position	= mul(mul(half4(P, 1), View), Projection);
		
    return Out;
}

half4 PS( half4 Color : COLOR0 ) : COLOR
{
    return Color;
}
