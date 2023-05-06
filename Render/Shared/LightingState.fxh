// LightingState.fxh - globally shared lighting params

shared half4	LightAmbient	: COLOR			= { 0.1, 0.1, 0.1, 1 };

shared half4	Light1Diffuse	: COLOR         = {  1.000f,  1.000f,  1.000f, 1 };
shared half4	Light1Specular	: COLOR         = {  1.000f,  1.000f,  1.000f, 1 };
shared half3	Light1Dir		: DIRECTION     = {  0.577f,  0.577f, -0.577f    };

shared half4	Light2Diffuse	: COLOR         = {  0.800f,  0.880f,  1.000f, 1 };
shared half4	Light2Specular	: COLOR         = {  0.400f,  0.440f,  0.500f, 1 };
shared half3	Light2Dir		: DIRECTION     = { -0.577f, -0.577f,  0.577f    };
