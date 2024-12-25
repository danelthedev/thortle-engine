package renderer

import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"

import gl "vendor:OpenGL"
import "vendor:glfw"

init_shaders :: proc() -> u32 {
    // vertex shader
    vert_shader_bytes, ok_vert := os.read_entire_file("shaders/vertex.vert", context.allocator)
	if !ok_vert {
		// could not read file
        fmt.println("error reading file")
		return 1
	}
	defer delete(vert_shader_bytes)

    // fmt.println("vert_shader_bytes:\n", string(vert_shader_bytes[:]))
    
    vert_shader_code := strings.clone_to_cstring(string(vert_shader_bytes[:]))

    vertex_shader: u32;
    vertex_shader = gl.CreateShader(gl.VERTEX_SHADER);
    
    gl.ShaderSource(vertex_shader, 1, &vert_shader_code, nil);
    gl.CompileShader(vertex_shader);

    // check for shader compile errors
    success: i32;
    info_log: [512]u8
    
    gl.GetShaderiv(vertex_shader, gl.COMPILE_STATUS, &success);
    if success == 0 {
        gl.GetShaderInfoLog(vertex_shader, 512, nil, raw_data(info_log[:]))

        fmt.println("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n", string(info_log[:]));
    }

    // fragment shader
    frag_shader_bytes, ok_frag := os.read_entire_file("shaders/fragment.frag", context.allocator)
	if !ok_frag {
		// could not read file
        fmt.println("error reading file")
		return 1
	}
	defer delete(frag_shader_bytes)
    
    // fmt.println("frag_shader_bytes:\n", string(frag_shader_bytes[:]))

    frag_shader_code := strings.clone_to_cstring(string(frag_shader_bytes[:]))
    
    fragment_shader: u32;
    fragment_shader = gl.CreateShader(gl.FRAGMENT_SHADER);
    
    gl.ShaderSource(fragment_shader, 1, &frag_shader_code, nil);
    gl.CompileShader(fragment_shader);
    
    // check for shader compile errors
    gl.GetShaderiv(fragment_shader, gl.COMPILE_STATUS, &success);
    if success == 0 {
        gl.GetShaderInfoLog(fragment_shader, 512, nil, raw_data(info_log[:]))

        fmt.println("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n", string(info_log[:]));
    }

    // link shaders
    shader_program: u32;
    shader_program = gl.CreateProgram();
    gl.AttachShader(shader_program, vertex_shader);
    gl.AttachShader(shader_program, fragment_shader);
    gl.LinkProgram(shader_program);

    // check for linking errors
    gl.GetProgramiv(shader_program, gl.LINK_STATUS, &success);
    if success == 0 {
        gl.GetProgramInfoLog(shader_program, 512, nil, raw_data(info_log[:]))

        fmt.println("ERROR::SHADER::PROGRAM::LINKING_FAILED\n", string(info_log[:]));
    }

    gl.DeleteShader(vertex_shader);
    gl.DeleteShader(fragment_shader);

    return shader_program
}

init_buffers :: proc() -> u32{
    vertices := []f32{
         0.5,  0.5, 0.0, // top right
         0.5, -0.5, 0.0, // bottom right
        -0.5, -0.5, 0.0, // bottom left
        -0.5,  0.5, 0.0  // top left 
    }

    indices := []u32{
        0, 1, 3,
        1, 2, 3
    }

    VAO, VBO, EBO: u32

    // init vertex array object
    gl.GenVertexArrays(1, &VAO)
    gl.GenBuffers(1, &VBO)
    gl.GenBuffers(1, &EBO)

    gl.BindVertexArray(VAO)

    gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(vertices[0]), raw_data(vertices), gl.STATIC_DRAW)

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO);
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices) * size_of(indices[0]), raw_data(indices), gl.STATIC_DRAW)

    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), uintptr(0))
    gl.EnableVertexAttribArray(0)

    gl.BindBuffer(gl.ARRAY_BUFFER, 0); 
    
    gl.BindVertexArray(0); 

    return VAO
}

render_frame :: proc(shader_program: u32, VAO: u32) {
    gl.UseProgram(shader_program)
    gl.BindVertexArray(VAO)
    gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
}