package renderer

import glm "core:math/linalg/glsl"

Camera :: struct {
    transform : Transform3D,
    fov : f32,
    near : f32,
    far : f32,
    aspect_ratio : f32,

    up : [3]f32,
    right : [3]f32,

    is_active : bool
}

create_camera :: proc(transform: Transform3D, fov: f32 = 90.0, near: f32 = 0.1, far: f32 = 1000.0, aspect_ratio: f32 = 16.0/9.0) -> Camera {
    camera := Camera{
        transform = Transform3D{
            translation = transform.translation,
            rotation = transform.rotation,
            scaling = transform.scaling,
        },
        fov = fov,
        near = near,
        far = far,
        aspect_ratio = aspect_ratio,
        up = {0, 1, 0},
        right = {1, 0, 0},
        is_active = true,
    }

    return camera
}

get_view_matrix :: proc(camera: ^Camera) -> glm.mat4 {
    // Create rotation matrices for each axis
    rx := glm.mat4Rotate([3]f32{1, 0, 0}, camera.transform.rotation.x)
    ry := glm.mat4Rotate([3]f32{0, 1, 0}, camera.transform.rotation.y)
    rz := glm.mat4Rotate([3]f32{0, 0, 1}, camera.transform.rotation.z)

    // Combine rotations
    rot_mat := rz * ry * rx

    // Get forward vector from rotation
    forward := glm.vec3{
        -rot_mat[0][2],
        -rot_mat[1][2], 
        -rot_mat[2][2],
    }
    forward = glm.normalize(forward)

    camera.right = glm.normalize(glm.cross(forward, camera.up))
    new_up := glm.normalize(glm.cross(camera.right, forward))
    
    view := glm.mat4LookAt(
        glm.vec3(camera.transform.translation), 
        glm.vec3(camera.transform.translation + forward), 
        glm.vec3(new_up)
    )

    scale_mat := glm.mat4Scale(camera.transform.scaling)
    return view * scale_mat
}

get_projection_matrix :: proc(camera: ^Camera) -> glm.mat4 {
    return glm.mat4Perspective(
        glm.radians(camera.fov),
        camera.aspect_ratio,
        camera.near,
        camera.far
    )
}