package renderer

import "core:fmt"
import "core:strings"
import "core:strconv"
import glm "core:math/linalg/glsl"

import gl "vendor:OpenGL"

import "shaders"
import "textures"

Vertex :: struct {
    translation: [3]f32,
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
    textures: [dynamic]textures.Texture,

    vao: u32,
    vbo: u32,
    ebo: u32,

    transform: Transform3D,
    update_transform: bool
}        

create_renderable :: proc(mesh: Mesh, shader_program: u32, texs: []textures.Texture = nil) -> Renderable {
    renderable := Renderable{
        mesh = mesh,
        shader_program = shader_program,
        transform = Transform3D{
            translation = {0.0, 0.0, 0.0},
            scaling = {1.0, 1.0, 1.0},
            rotation = {0.0, 0.0, 0.0},
            transform_matrix = glm.mat4(1.0)
        }
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

    gl.VertexAttribPointer(1, 3, gl.FLOAT, false, size_of(mesh.vertices[0]), uintptr(size_of(mesh.vertices[0].translation)))
    gl.EnableVertexAttribArray(1)

    gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(mesh.vertices[0]), uintptr(size_of(mesh.vertices[0].translation) + size_of(mesh.vertices[0].color)))
    gl.EnableVertexAttribArray(2)

    gl.VertexAttribPointer(3, 3, gl.FLOAT, false, size_of(mesh.vertices[0]), uintptr(size_of(mesh.vertices[0].translation) + size_of(mesh.vertices[0].color) + size_of(mesh.vertices[0].tex_coords)))
    gl.EnableVertexAttribArray(3)

    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    gl.BindVertexArray(0)

    if texs != nil {
        for texture in texs {
            add_texture_to_renderable(&renderable, texture)
        }
    }

    // set the transform
    shaders.add_uniform(shader_program, "model", renderable.transform.transform_matrix)
    
    return renderable
}

bind_renderable :: proc(renderable: Renderable, camera: ^Camera = nil) {
    renderable := renderable

    gl.PolygonMode(gl.FRONT_AND_BACK, auto_cast renderable.mesh.render_mode)
    gl.UseProgram(renderable.shader_program)

    if renderable.update_transform {
        shaders.add_uniform(renderable.shader_program, "model", renderable.transform.transform_matrix)
        renderable.update_transform = false
    }

    if camera != nil {
        shaders.add_uniform(renderable.shader_program, "view", get_view_matrix(camera))
        shaders.add_uniform(renderable.shader_program, "projection", get_projection_matrix(camera))
    }

    if len(renderable.textures) != 0 {
        for texture in renderable.textures {
            gl.ActiveTexture(gl.TEXTURE0 + texture.id)
            gl.BindTexture(gl.TEXTURE_2D, texture.id)
        }
    }
    gl.BindVertexArray(renderable.vao)
}

add_texture_to_renderable :: proc(renderable: ^Renderable, texture: textures.Texture, name: string = "vTexture") {
    append(&renderable.textures, texture)

    vLen := len(renderable.textures)
    buf: [4]byte
    vLenStr := strconv.itoa(buf[:], vLen)
    
    shaders.add_uniform(renderable.shader_program, strings.concatenate({"vTexture", vLenStr}), cast(i32) renderable.textures[len(renderable.textures)-1].id)
}

set_renderable_rotation :: proc(renderable: ^Renderable, rotation: [3]f32) {
    set_rotation(&renderable.transform, rotation)
    renderable.update_transform = true
}

rotate_renderable :: proc(renderable: ^Renderable, rotation: [3]f32) {
    rotate(&renderable.transform, rotation)
    renderable.update_transform = true
}

set_renderable_translation :: proc(renderable: ^Renderable, translation: [3]f32) {
    set_translation(&renderable.transform, translation)
    renderable.update_transform = true
}

translate_renderable :: proc(renderable: ^Renderable, translation: [3]f32) {
    translate(&renderable.transform, translation)
    renderable.update_transform = true
}

set_renderable_scaling :: proc(renderable: ^Renderable, scaling: [3]f32) {
    set_scale(&renderable.transform, scaling)
    renderable.update_transform = true
}

scale_renderable :: proc(renderable: ^Renderable, scaling: [3]f32) {
    scale(&renderable.transform, scaling)
    renderable.update_transform = true
}

set_renderable_transform :: proc(renderable: ^Renderable, transform: Transform3D) {
    renderable.transform = transform
    calculate_transform_matrix(&renderable.transform)
    renderable.update_transform = true
}