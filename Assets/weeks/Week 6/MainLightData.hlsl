#ifndef MAIN_LIGHT_DATA_INCLUDED
#define MAIN_LIGHT_DATA_INCLUDED
#ifndef SHADERGRAPH_PREVIEW
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#endif
void MainLightData_float(
out float3 Direction,
out float3 Color)
{
#if defined(SHADERGRAPH_PREVIEW)
Direction = normalize(float3(0.5, 0.5, 0.5));
Color = float3(1.0, 1.0, 1.0);
#else
Light mainLight = GetMainLight();
Direction = normalize(mainLight.direction);
Color = mainLight.color.rgb;
#endif
}
#endif