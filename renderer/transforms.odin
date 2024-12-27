package renderer

import glm "core:math/linalg/glsl"
import "core:math"

Transform3D :: struct {
    position: [3]f32,
    scale: [3]f32,
    rotation: [3]f32,
    
    transform_matrix: matrix[4, 4]f32,
}

calculate_transform_matrix :: proc(trans: ^Transform3D) {
    trans.transform_matrix = glm.mat4(1.0)

    trans.transform_matrix *= glm.mat4Translate(trans.position)
    trans.transform_matrix *= glm.mat4Rotate({1.0, 0.0, 0.0}, trans.rotation[0])
    trans.transform_matrix *= glm.mat4Rotate({0.0, 1.0, 0.0}, trans.rotation[1])
    trans.transform_matrix *= glm.mat4Rotate({0.0, 0.0, 1.0}, trans.rotation[2])
    trans.transform_matrix *= glm.mat4Scale(trans.scale)
}