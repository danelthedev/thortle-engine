package renderer

import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:math"
import glm "core:math/linalg/glsl"

import gl "vendor:OpenGL"
import "vendor:glfw"

import "shaders"
import "textures"

editor_camera : Camera

init_buffers :: proc() -> [dynamic]Renderable{
    using textures

    editor_camera = create_camera(Transform3D{
        translation = {0.5, 0.0, 0.1},
        rotation = {0.0, -0.7, 0.0},
        scaling = {1.0, 1.0, 1.0}
    })

    renderables: [dynamic]Renderable

    shader_program := shaders.create_shader_program("shaders/vertex.vert", "shaders/fragment.frag")
	
    mesh1 := Mesh{
        vertices=[]Vertex{
            {
                translation = {0.5, 0.5, 0.0},
                color = {1.0, 0.0, 0.0},
                tex_coords = {1.0, 1.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                translation = {0.5, -0.5, 0.0},
                color = {0.0, 1.0, 0.0},
                tex_coords = {1.0, 0.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                translation = {-0.5, -0.5, 0.0},
                color = {0.0, 0.0, 1.0},
                tex_coords = {0.0, 0.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                translation = {-0.5, 0.5, 0.0},
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

    renderable1 := create_renderable(mesh1, shader_program, {
        create_texture_from_image("resources/wall.jpg"),
        create_texture_from_image("resources/awesomeface.png")
    })

    set_renderable_transform(&renderable1, Transform3D{
        translation = {0.25, 0.0, -0.1},
        scaling = {0.25, 0.5, 1.0},
        rotation = {0.0, 0.0, -math.PI / 3.0},
        transform_matrix = glm.mat4(1.0)
    }) 

    append(&renderables, renderable1)

    shader_program2 := shaders.create_shader_program("shaders/vertex.vert", "shaders/fragment2.frag")

    mesh2 := Mesh{
        vertices = []Vertex{
            {
                translation = {0.25, 0.25, 0.0},
                color = {0.0, 1.0, 0.0},
                tex_coords = {1.0, 1.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                translation = {0.25, -0.25, 0.0},
                color = {1.0, 1.0, 0.0},
                tex_coords = {1.0, 0.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                translation = {-0.25, -0.25, 0.0},
                color = {0.0, 1.0, 1.0},
                tex_coords = {0.0, 0.0},
                normal = {0.0, 0.0, 1.0}
            },
            {
                translation = {-0.25, 0.25, 0.0},
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

    renderable2 := create_renderable(mesh2, shader_program2, {
        create_texture_from_image("resources/wall.jpg"),
        create_texture_from_image("resources/awesomeface.png")
    })

    append(&renderables, renderable2)

    return renderables
}

render_frame :: proc(renderables: [dynamic]Renderable) {

    for renderable in renderables {
        bind_renderable(renderable, &editor_camera)
        gl.DrawElements(gl.TRIANGLES, auto_cast len(renderable.mesh.indices), gl.UNSIGNED_INT, nil)
    }

}