package renderer

import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:math"

import gl "vendor:OpenGL"
import "vendor:glfw"

import "shaders"

init_buffers :: proc() -> [dynamic]Renderable{
    shader_program := shaders.create_shader_program("shaders/vertex.vert", "shaders/fragment.frag")
    shader_program2 := shaders.create_shader_program("shaders/vertex.vert", "shaders/fragment2.frag")
	
    renderables: [dynamic]Renderable

    mesh1 := Mesh{
        vertices=[]Vertex{
            {
                position = {0.5, 0.5, 0.0},
                color = {1.0, 0.0, 0.0},
                tex_coords = {1.0, 1.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                position = {0.5, -0.5, 0.0},
                color = {0.0, 1.0, 0.0},
                tex_coords = {1.0, 0.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                position = {-0.5, -0.5, 0.0},
                color = {0.0, 0.0, 1.0},
                tex_coords = {0.0, 0.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                position = {-0.5, 0.5, 0.0},
                color = {1.0, 1.0, 0.0},
                tex_coords = {0.0, 1.0},
                normal = {0.0, 0.0, 1.0}
            }
        }, 
        indices = []u32{
            0, 1, 3,
            1, 2, 3
        },

        render_mode = gl.FILL
    }

    renderable1 := create_renderable(mesh1, shader_program)
    
    // TODO: Find more elegant way to append textures

    append(&renderable1.textures, create_texture_from_image("resources/wall.jpg"))
    append(&renderable1.textures, create_texture_from_image("resources/awesomeface.png"))
    shaders.add_uniform(renderable1.shader_program, "vTexture", cast(i32) renderable1.textures[0].id)
    shaders.add_uniform(renderable1.shader_program, "vTexture2", cast(i32) renderable1.textures[1].id)
    
    append(&renderables, renderable1)

    mesh2 := Mesh{
        vertices = []Vertex{
            {
                position = {0.25, 0.25, 0.0},
                color = {0.0, 1.0, 0.0},
                tex_coords = {1.0, 1.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                position = {0.25, -0.25, 0.0},
                color = {1.0, 1.0, 0.0},
                tex_coords = {1.0, 0.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                position = {-0.25, -0.25, 0.0},
                color = {0.0, 1.0, 1.0},
                tex_coords = {0.0, 0.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                position = {-0.25, 0.25, 0.0},
                color = {1.0, 1.0, 0.0},
                tex_coords = {0.0, 1.0},
                normal = {0.0, 0.0, 1.0}
            }
        }, 
        indices = []u32{
            0, 1, 3,
            1, 2, 3
        },

        render_mode = gl.FILL
    }

    renderable2 := create_renderable(mesh2, shader_program2)
    append(&renderable2.textures, create_texture_from_image("resources/wall.jpg"))
    append(&renderable2.textures, create_texture_from_image("resources/awesomeface.png"))
    shaders.add_uniform(renderable2.shader_program, "vTexture", cast(i32) renderable2.textures[0].id)
    shaders.add_uniform(renderable2.shader_program, "vTexture2", cast(i32) renderable2.textures[1].id)

    append(&renderables, renderable2)

    return renderables
}

render_frame :: proc(renderables: [dynamic]Renderable) {
    
    for renderable in renderables {
        bind_renderable(renderable)
        gl.DrawElements(gl.TRIANGLES, auto_cast len(renderable.mesh.indices), gl.UNSIGNED_INT, nil)
    }

}