#version 450

#ifdef GL_ES
precision highp float;
#endif
uniform sampler2D uTexture;

// Somewhat of a guide from: https://www.mathematik.uni-marburg.de/~thormae/lectures/graphics1/code/WebGLShaderLightMat/ShaderLightMat.html


layout (location = 0) out vec4 rtFragColor;

//Recieve final requrements
in vec4 vNormal;
in vec4 vTexcoord;

in vec3 normalInterp;
in vec3 vertPos;

void main(){
	
	vec3 lights[3];
	
	lights[0] = vec3(2.0,1.0, 0.2);
	lights[1] = vec3(3.0,2.0, 1.2);
	lights[2] = vec3(1.0,1.0, 2.2);
	
	const vec3 diffuseColor = vec3(0.5, 0.0, 0.0);
    const vec3 specColor = vec3(1.0, 1.0, 1.0);
	
	for (int i = lights.length() - 1; i >= 0; --i) {

	vec3 lightPos = lights[i];
	
    vec3 normal = normalize(normalInterp);
    vec3 lightDir = normalize(lightPos - vertPos);

    float lambertian = max(dot(lightDir,normal), 0.0);
    float specular = 0.0;
    
       if(lambertian > 0.0) {
       vec3 reflectDir = reflect(-lightDir, normal);
       vec3 viewDir = normalize(-vertPos);
        
       float specAngle = max(dot(reflectDir, viewDir), 0.0);
       specular = pow(specAngle, 4.0);
       }
    
    //rtFragColor =vec4( lambertian*vTexcoord + specular*vec4(specColor,1));
    }
    
vec4 N = normalize(vNormal);


rtFragColor = vec4(vTexcoord);
}