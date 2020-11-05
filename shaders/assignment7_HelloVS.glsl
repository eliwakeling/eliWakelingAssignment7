#version 450

// Somewhat of a guide from: https://www.mathematik.uni-marburg.de/~thormae/lectures/graphics1/code/WebGLShaderLightMat/ShaderLightMat.html

layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec4 aTexcoord;
out vec4 vColor;

// asPoint: promote a 3D vector into a 4D vector representing a point (w=1)
//    point: input 3D vector
vec4 asPoint(in vec3 point)
{
    return vec4(point, 1.0);
}

float lengthSq(vec3 x)
{
    return dot(x, x);
    //return dot(x, x); // for consistency with others
}

//Transform Uniforms
uniform mat4 uModel;
uniform mat4 uViewMat;
uniform mat4 uProjMat;
uniform mat4 uModelMat;
uniform mat4 uViewProjMat;
uniform sampler2D uTexture;

out vec4 vNormal;
out vec4 vTexcoord;

struct sLight
{
	vec4 center;
    vec4 color;
    float intensity;

};

bool initLight(out sLight light, in vec3 center,  in float intensity, in vec4 color){
	
    //set light centerpoint and color.
    light.center = asPoint(center);
    light.color = color;
    
    if (intensity > 0.0){
    	light.intensity = intensity;
    	return true;
    }
    //Set Intensity for the user if invalid.
    light.intensity = 1.0;
    return false;

}

//diffuseCoef: find the diffuse coefficient between the light and the sphere.
// normal: the surface  of the sphere.
// position: the position of the sphere.
// lightCenter: the position of the light.
float diffuseCoef(in vec3 normal, in vec3 position, in vec3 lightCenter) {
    
    //Calculate Light Vector.
    //vec3 lightVec = position - lightCenter;
    vec3 lightVec = normalize(lightCenter - position);
    //Calculate the diffuse Coefficient;
    return max(0.0, dot(normal, lightVec));
}
    
//attinuation: find the factor from which light fades according to distance between the object and the light.
// intensity: the intensity of the light.
// dist: the distance between the object and the light.
float attinuation (in float intensity, in float dist) {
   //Establish proper order of opperations.
   float dist1 = dist / intensity;
   float dist2 = (dist * dist) / (intensity * intensity);
   //Find the final Attinuation.
   return 1.0 / (1.0 + dist1 + dist2);
}

//finalColor: combine the diffuse coeficient, the attinuation, and factor in the surface and light colors.
//diffcoef: the diffusal coefficient of the objects and lights.
//attinu: the attinuation factor of the objects and lights.
//surfaceColor: the color of the rendered object.
//lightColor: the color of the rendered light.
vec3 finalColor(in float diffcoef, in float attinu, in vec3 surfaceColor, in vec3 lightColor) {
    //Find the final color of the object in lambert.
    float diffIntense = diffcoef * attinu;
    return diffIntense * surfaceColor * lightColor;
}

//phongSpecCoef: Calculates the specular coeficient
//viewport: The viewport viewing the scene.
// position: the position of the sphere
//lightVec: The lightvector being used.
// normal: the surface  of the sphere.
float phongSpecCoef(vec4 viewport, vec3 position, vec3 lightVec, vec3 normal) {

    //Set Vectors
    vec3 viewVector = normalize(viewport.xyz - position);
    //vec3 lightVec = normalize(position - lightCenter);
    vec3 refLightVec = reflect(-lightVec, normal);
    float specCoef = max(0.0, dot(viewVector, normal));
    
    return specCoef;
}

//phongColor calculates the final surface color for phong shading.
//globAmbInt: Global ambient intensity. Sets the intensity for ambient light.
//globAmbCol: Global ambient color. Sets the color for ambient light.
//diffuseInt: The precalculated Diffuse Intesnity.
//surfColor: The surface color of the object.
//specIntensity: the precalculated specular intensity of the object.
//specRefCol: The specular reference color.
//lightCol: The light's color.

vec3 phongColor(float globAmbInt, in vec3 globAmbCol, in float diffuseInt, in vec3 surfColor, in float specIntensity, in vec3 specRefCol, in vec3 lightColor)
{

    //Set Order of opperations.
    vec3 combinedDiffuse = surfColor * diffuseInt;
    vec3 combinedSpecular = specIntensity * specRefCol;
    vec3 combinedAmbience = globAmbCol * globAmbInt;
    
    //Calculate the color of the scene.
    vec3 finalColor = combinedAmbience + (combinedDiffuse + combinedSpecular) * lightColor;
    
    return finalColor;

}





void main(){


    sLight lights[3];
    // Initialize lights in array FOR VERTEX SHADER PHONG!
    initLight(lights[0], vec3(2.0,1.0, 0.2), 10.0, vec4(1.0, 1.0, 1.0, 1.0));
    initLight(lights[1], vec3(3.0,2.0, 1.2), 10.0, vec4(1.0, 1.0, 1.0, 1.0));
    initLight(lights[2], vec3(1.0,1.0, 2.2), 10.0, vec4(1.0, 1.0, 1.0, 1.0));
        vec3 finalSphereColor = vec3(0.0);

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
vec3 lightingInstensitySum = vec3(0.0);
float globalAmbientIntensity = 0.05;
vec3 globalAmbientColor = vec3(1.0, 1.0, 1.0);
vColor = vec4(aNormal * 0.5 + 0.5, 1.0);

//PHONG INDEX
       // for (int i = lights.length() - 1; i >= 0; --i) {
        
       ////ATTEMPT TO INITIALIZE PHONG EQUATION PARTS
       // vec4 vertPos4 = vec4(uModel) + vec4(aPosition);
       // vec3 vertPos = vec3(vertPos4.xyz) / vertPos4.w;
       // vec4 lightDir = normalize(lights[i].center - vec4(uModel));
       // vec3 refDir = reflect(-lightDir.xyz - vec3(aNormal));
       // vec3 viewPos = normalize(-vertPos);
        
       ////CALCULATE LAMBERT SHADING
       // float lambertian = max(dot(lightDir, normal), 0.0);
       // float specular = 0.0;
        
       ////APPLY PHONG IF APPLICABLE
       // if(lambertian > 0.0) {
       // float specAngle = max(dot(reflectDir, viewDir), 0.0);
       // specular = pow(specAngle, 16.0);
       //}

/*
            float lightDiffuseCoef, lightAttenuation, specCoef;

            vec3 LightVector = lights[i].center.xyz - aPosition.xyz;
            float d = sqrt(lengthSq(LightVector));

            lightDiffuseCoef = diffuseCoef(vNormal.xyz, pos_clip.xyz, lights[i].center.xyz);
            lightAttenuation = attinuation(lights[i].intensity, d);
            
            float diffuseIntensity = lightDiffuseCoef * lightAttenuation;
            
            specCoef = phongSpecCoef(pos_camera, pos_clip.xyz, LightVector, vNormal.xyz);
            float specularInt = 16;
            // Sum the lights
            lightingInstensitySum += phongColor(globalAmbientIntensity, globalAmbientColor, diffuseIntensity, uv_atlas.xyz, specularInt, vec3(1.0,1.0,1.0), lights[i].color.xyz)      
       // */ }

        //vColor = vec4(lambertian*diffuseColor + specular*specColor, 1.0);

       // float globalAmbientIntensity = 0.05;
       // vec3 globalAmbientColor = vec3(1.0, 1.0, 1.0);
        //finalSphereColor = (globalAmbientIntensity * globalAmbientColor) + min(lightingInstensitySum, 1.0);

//gl_position = uProjMat * modelViewMat * aTexcoord;

//}