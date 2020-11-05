#version 450

layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec4 aTexcoord;
out vec4 vColor;


//Transform Uniforms
uniform mat4 uModel;
uniform mat4 uViewMat;
uniform mat4 uProjMat;
uniform mat4 uModelMat;
uniform mat4 uViewProjMat;

out vec4 vNormal;
out vec4 vTexcoord;

void main(){
//gl_position = aPosition;

//vec4 posWorld  uModelMat * aPosition;
//gl_position = pos_world;

//position in camera space.
//vec4 pos_camera = uViewMat + pos_world;

//gl_position = pos_camera


//Position in ClipSpace
mat4 modelViewMat = uViewMat * uModelMat;
vec4 pos_camera = modelViewMat * aPosition; 
vec4 pos_clip = uProjMat * pos_camera;
gl_Position = pos_clip;

// Normal Pipeline;
mat3 normalMatrix = inverse(transpose(mat3(modelViewMat)));
vec3 norm_camera = normalMatrix * aNormal;

// TexCoord Pipeline
mat4 atlasMat = mat4(0.5,0.0,0.0,0.0,
					 0.0,0.5,0.0,0.0,
					 0.0,0.0,1.0,0.0,
					 0.25,0.25,0.0,1.0);
vec4 uv_atlas = atlasMat * aTexcoord;

vColor = aPosition;

//DEBUGGING
vNormal = vec4(norm_camera ,0.0);
vTexcoord = aTexcoord;
//vColor = vec4(aNormal * 0.5 + 0.5, 1.0);

//gl_position = uProjMat * modelViewMat * aTexcoord;

}