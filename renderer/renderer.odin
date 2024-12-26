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
	
    renderables: [dynamic]Renderable

    mesh1 := Mesh{
        vertices=[]Vertex{
            {
                position = {0.5, 0.5, 0.0},
                color = {1.0, 0.0, 0.0}
            },
            {
                position = {0.5, -0.5, 0.0},
                color = {0.0, 1.0, 0.0}
            },
            {
                position = {-0.5, -0.5, 0.0},
                color = {0.0, 0.0, 1.0}
            },
            {
                position = {-0.5, 0.5, 0.0},
                color = {1.0, 1.0, 0.0}
            }
        }, 
        indices = []u32{
            0, 1, 3,
            1, 2, 3
        },

        render_mode = gl.LINE
    }
    
    append(&renderables, create_renderable(mesh1, shader_program))

    mesh2 := Mesh{
        vertices = []Vertex{
            {
                position = {0.25, 0.25, 0.0},
                color = {0.0, 1.0, 0.0}
            },
            {
                position = {0.25, -0.25, 0.0},
                color = {1.0, 1.0, 0.0}
            },
            {
                position = {-0.25, -0.25, 0.0},
                color = {0.0, 1.0, 1.0}
            },
            {
                position = {-0.25, 0.25, 0.0},
                color = {1.0, 1.0, 0.0}
            }
        }, 
        indices = []u32{
            0, 1, 3,
            1, 2, 3
        },

        render_mode = gl.FILL
    }

    append(&renderables, create_renderable(mesh2, shader_program))

    return renderables
}

render_frame :: proc(renderables: [dynamic]Renderable) {
    
    for renderable in renderables {
        bind_renderable(renderable)
        gl.DrawElements(gl.TRIANGLES, auto_cast len(renderable.mesh.indices), gl.UNSIGNED_INT, nil)
    }

}