#version 330 core
out vec4 FragColor;

in vec2 vTexCoord;
in vec3 vColor;

uniform sampler2D vTexture;
uniform sampler2D vTexture2;

void main()
{
    FragColor = mix(texture(vTexture, vTexCoord), texture(vTexture2, vTexCoord), 0.8);
}