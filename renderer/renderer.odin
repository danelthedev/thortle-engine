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
        translation = {0.0, 0.0, 2},
        rotation = {0.0, 0.0, 0.0},
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
            },
            // remaining vertices to form a cube
            {
                translation = {0.5, 0.5, -1.0},
                color = {1.0, 0.0, 0.0},
                tex_coords = {1.0, 1.0},
                normal = {0.0, 0.0, -1.0}
            },
            {
                translation = {0.5, -0.5, -1.0},
                color = {0.0, 1.0, 0.0},
                tex_coords = {1.0, 0.0},
                normal = {0.0, 0.0, -1.0}
            },
            {
                translation = {-0.5, -0.5, -1.0},
                color = {0.0, 0.0, 1.0},
                tex_coords = {0.0, 0.0},
                normal = {0.0, 0.0, -1.0}
            },
            {
                translation = {-0.5, 0.5, -1.0},
                color = {1.0, 1.0, 0.0},
                tex_coords = {0.0, 1.0},
                normal = {0.0, 0.0, -1.0}
            }
        }, 
        indices = []u32{
            // front face
            0, 1, 3,
            1, 2, 3,
            // back face
            4, 5, 7,
            5, 6, 7,
            // right face
            0, 1, 4,
            1, 5, 4,
            // left face
            2, 3, 7,
            2, 7, 6,
            // top face
            0, 4, 7,
            0, 7, 3,
            // bottom face
            1, 5, 6,
            1, 6, 2,
        },

        render_mode = gl.FILL
    }

    renderable1 := create_renderable(mesh1, shader_program, {
        create_texture_from_image("resources/wall.jpg"),
        create_texture_from_image("resources/awesomeface.png")
    })

    set_renderable_transform(&renderable1, Transform3D{
        translation = {0.0, 0.0, 0.0},
        scaling = {1.0, 1.0, 1.0},
        rotation = {math.PI / 6, math.PI / 12, math.PI / 6},
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

    set_renderable_translation(&renderable2, [3]f32{0.0, 0.0, 1.0})

    append(&renderables, renderable2)

    return renderables
}

render_frame :: proc(renderables: [dynamic]Renderable) {

    for renderable, i in renderables {
        renderable := renderable

        if i == 0 {
            time := glfw.GetTime()
            rotate_increment :f32 = auto_cast math.sin(time) * 4.0
            rotate_renderable(&renderable, [3]f32{0, rotate_increment, 0})
        }

        bind_renderable(renderable, &editor_camera)
        gl.DrawElements(gl.TRIANGLES, auto_cast len(renderable.mesh.indices), gl.UNSIGNED_INT, nil)
    }

}