package renderer

import "core:fmt"
import "core:strings"
import "core:strconv"

import gl "vendor:OpenGL"

import "shaders"

Vertex :: struct {
    position: [3]f32,
    color: [3]f32,
    tex_coords: [2]f32,
    normal: [3]f32
}

Mesh :: struct {
    vertices: []Vertex,
    indices: []u32,
    render_mode: int
}

Renderable :: struct {
    mesh: Mesh,
    shader_program: u32,
    textures: [dynamic]Texture,

    vao: u32,
    vbo: u32,
    ebo: u32,
}        

create_renderable :: proc(mesh: Mesh, shader_program: u32) -> Renderable {
    renderable := Renderable{
        mesh = mesh,
        shader_program = shader_program,
    }

    gl.GenVertexArrays(1, &renderable.vao)
    gl.GenBuffers(1, &renderable.vbo)
    gl.GenBuffers(1, &renderable.ebo)

    gl.BindVertexArray(renderable.vao)

    gl.BindBuffer(gl.ARRAY_BUFFER, renderable.vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(mesh.vertices) * size_of(mesh.vertices[0]), raw_data(mesh.vertices), gl.STATIC_DRAW)

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, renderable.ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(mesh.indices) * size_of(mesh.indices[0]), raw_data(mesh.indices), gl.STATIC_DRAW)

    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(mesh.vertices[0]), uintptr(0))
    gl.EnableVertexAttribArray(0)

    gl.VertexAttribPointer(1, 3, gl.FLOAT, false, size_of(mesh.vertices[0]), uintptr(size_of(mesh.vertices[0].position)))
    gl.EnableVertexAttribArray(1)

    gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(mesh.vertices[0]), uintptr(size_of(mesh.vertices[0].position) + size_of(mesh.vertices[0].color)))
    gl.EnableVertexAttribArray(2)

    gl.VertexAttribPointer(3, 3, gl.FLOAT, false, size_of(mesh.vertices[0]), uintptr(size_of(mesh.vertices[0].position) + size_of(mesh.vertices[0].color) + size_of(mesh.vertices[0].tex_coords)))
    gl.EnableVertexAttribArray(3)

    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    gl.BindVertexArray(0)
    
    return renderable
}

bind_renderable :: proc(renderable: Renderable) {
    gl.PolygonMode(gl.FRONT_AND_BACK, auto_cast renderable.mesh.render_mode)
    gl.UseProgram(renderable.shader_program)
    if len(renderable.textures) != 0 {
        for texture in renderable.textures {
            gl.ActiveTexture(gl.TEXTURE0 + texture.id)
            gl.BindTexture(gl.TEXTURE_2D, texture.id)
        }
    }
    gl.BindVertexArray(renderable.vao)
}