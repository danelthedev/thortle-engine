package renderer

import glm "core:math/linalg/glsl"
import "core:math"

Transform3D :: struct {
    translation: [3]f32,
    scaling: [3]f32,
    rotation: [3]f32,
    
    transform_matrix: matrix[4, 4]f32,
}

calculate_transform_matrix :: proc(trans: ^Transform3D) {
    trans.transform_matrix = glm.mat4(1.0)

    trans.transform_matrix *= glm.mat4Translate(trans.translation)
    trans.transform_matrix *= glm.mat4Rotate({1.0, 0.0, 0.0}, trans.rotation[0])
    trans.transform_matrix *= glm.mat4Rotate({0.0, 1.0, 0.0}, trans.rotation[1])
    trans.transform_matrix *= glm.mat4Rotate({0.0, 0.0, 1.0}, trans.rotation[2])
    trans.transform_matrix *= glm.mat4Scale(trans.scaling)
}

set_rotation :: proc(transform: ^Transform3D, rotation: [3]f32) {
    transform.rotation = rotation
    calculate_transform_matrix(transform)
}

rotate :: proc(transform: ^Transform3D, rotation: [3]f32) {
    transform.rotation += rotation
    calculate_transform_matrix(transform)
}

set_translation :: proc(transform: ^Transform3D, translation: [3]f32) {
    transform.translation = translation
    calculate_transform_matrix(transform)
}

translate :: proc(transform: ^Transform3D, translation: [3]f32) {
    transform.translation += translation
    calculate_transform_matrix(transform)
}

set_scale :: proc(transform: ^Transform3D, scaling: [3]f32) {
    transform.scaling = scaling
    calculate_transform_matrix(transform)
}

scale :: proc(transform: ^Transform3D, scaling: [3]f32) {
    transform.scaling *= scaling
    calculate_transform_matrix(transform)
}
