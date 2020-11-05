#version 450

#ifdef GL_ES
precision highp float;
#endif


layout (location = 0) out vec4 rtFragColor;

//Recieve final requrements
in vec4 vNormal;
in vec4 vTexcoord;
void main(){

vec4 N = normalize(vNormal);
//rtFragColor = vec4(N.xyz * 0.5 + 0.5, 1.0);

rtFragColor = vec4(vTexcoord);
}