#version 330 core
out vec4 FragColor;

in vec2 vTexCoord;
in vec3 vColor;

uniform sampler2D vTexture1;
uniform sampler2D vTexture2;

void main()
{
    FragColor = mix(texture(vTexture1, vTexCoord), texture(vTexture2, vTexCoord), 0.2);
}