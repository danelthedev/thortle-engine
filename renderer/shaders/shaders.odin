package shaders

import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"

import gl "vendor:OpenGL"

compile_shader :: proc(shader_path: string, shader_type: u32) -> u32 {
    shader_bytes, ok := os.read_entire_file(shader_path, context.allocator)
    if !ok {
        // could not read file
        fmt.println("error reading file")
        return 1
    }
    defer delete(shader_bytes)

    shader_code := strings.clone_to_cstring(string(shader_bytes[:]))

    shader: u32;
    shader = gl.CreateShader(shader_type);
    
    gl.ShaderSource(shader, 1, &shader_code, nil);
    gl.CompileShader(shader);

    // check for shader compile errors
    success: i32;
    info_log: [512]u8
    
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success);
    if success == 0 {
        gl.GetShaderInfoLog(shader, 512, nil, raw_data(info_log[:]))

        fmt.println("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n", string(info_log[:]));
    }

    return shader
}

create_shader_program :: proc(vertex_shader_path: string, fragment_shader_path: string) -> u32 {

    vertex_shader := compile_shader(vertex_shader_path, gl.VERTEX_SHADER)
    fragment_shader := compile_shader(fragment_shader_path, gl.FRAGMENT_SHADER)

    // link shaders
    shader_program: u32;
    shader_program = gl.CreateProgram();
    gl.AttachShader(shader_program, vertex_shader);
    gl.AttachShader(shader_program, fragment_shader);
    gl.LinkProgram(shader_program);

    // check for linking errors
    success: i32;
    info_log: [512]u8

    gl.GetProgramiv(shader_program, gl.LINK_STATUS, &success);
    if success == 0 {
        gl.GetProgramInfoLog(shader_program, 512, nil, raw_data(info_log[:]))

        fmt.println("ERROR::SHADER::PROGRAM::LINKING_FAILED\n", string(info_log[:]));
    }

    gl.DeleteShader(vertex_shader);
    gl.DeleteShader(fragment_shader);

    return shader_program
}

add_uniform :: proc(shader_program: u32, name: string, value: $T) {
    value := value

    location := gl.GetUniformLocation(shader_program, strings.clone_to_cstring(name));
    if location == -1 {
        fmt.println("Uniform not found: ", name)
        return
    }

    gl.UseProgram(shader_program)

    // get type of value
    uniform_type := typeid_of(type_of(value))
    
    switch uniform_type {
        case typeid_of(i32): {
            v := (cast(^i32)(&value))^
            gl.Uniform1i(location, v)
        }
        case typeid_of(f32): {
            v := (cast(^f32)(&value))^
            gl.Uniform1f(location, v)
        }
        case typeid_of([2]f32): 
        {
            v := (cast(^[2]f32)(&value))^
            gl.Uniform2f(location, v.x, v.y)
        }
        case typeid_of([3]f32): {
            v := (cast(^[3]f32)(&value))^
            gl.Uniform3f(location, v.x, v.y, v.z)
        }
        case typeid_of([4]f32): {
            v := (cast(^[4]f32)(&value))^
            gl.Uniform4f(location, v.x, v.y, v.z, v.w)
        }
        case: {
            fmt.println("Unsupported uniform type: ", uniform_type)
        }
    }
}