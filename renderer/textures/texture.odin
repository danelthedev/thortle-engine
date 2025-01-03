package textures

import "core:c"
import "core:fmt"
import "core:strings"
import "base:runtime"

import stbi "vendor:stb/image"

import gl "vendor:OpenGL"
import "vendor:glfw"


Texture :: struct {
    id: u32,
    width: i32,
    height: i32,
    nr_channels: i32,
}

create_texture_from_image :: proc(image_path: string) -> Texture {
    texture := Texture{}

    gl.GenTextures(1, &texture.id)
    gl.BindTexture(gl.TEXTURE_2D, texture.id)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
        
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    width, height, nr_channels: i32

    stbi.set_flip_vertically_on_load(1);
    data := stbi.load(strings.clone_to_cstring(image_path), &texture.width, &texture.height, &texture.nr_channels, 0)

    // fmt.println("width: ", texture.width, " height: ", texture.height, " nr_channels: ", texture.nr_channels, " data: ", data)

    if data == nil {
        fmt.println("Failed to load texture")
        return texture
    }
    else {
        if texture.nr_channels == 3 {
            gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, texture.width, texture.height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
        }
        else if texture.nr_channels == 4 {
            gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, texture.width, texture.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, data)
        }
        else {
            fmt.println("Texture format not supported")
            return texture
        }
        gl.GenerateMipmap(gl.TEXTURE_2D)
    }

    stbi.image_free(data)

    return texture
}