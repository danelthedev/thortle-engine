package engine

import "core:c"
import "core:fmt"

import gl "vendor:OpenGL"
import "vendor:glfw"

GL_MAJOR_VERSION : c.int : 4
GL_MINOR_VERSION :: 6

running : b32 = true

WindowSettings :: struct {
	width, height: c.int,
	title: cstring,
}

//////////////////////////////////
// Initialization of the engine //
//////////////////////////////////

init :: proc(window_settings: WindowSettings) -> (window_ptr: glfw.WindowHandle, error: bool){
    // Initialize glfw
	// GLFW_TRUE if successful, or GLFW_FALSE if an error occurred
	if !glfw.Init(){
		fmt.println("Failed to initialize GLFW")
		return nil, true
	}

	// Set Window Hints
	glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION) 
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
	
	// Create the window
	// Return WindowHandle rawPtr
	window := glfw.CreateWindow(window_settings.width, window_settings.height, window_settings.title, nil, nil)

	// If the window pointer is invalid
	if window == nil {
		fmt.println("Unable to create window")
		return nil, true
	}
	
	glfw.MakeContextCurrent(window)
	
	// Enable vsync
	glfw.SwapInterval(1)

	// This function sets the key callback of the specified window, which is called when a key is pressed, repeated or released.
	glfw.SetKeyCallback(window, key_callback)

	// This function sets the framebuffer resize callback of the specified window, which is called when the framebuffer of the specified window is resized.
	glfw.SetFramebufferSizeCallback(window, size_callback)

	gl.load_up_to(int(GL_MAJOR_VERSION), GL_MINOR_VERSION, glfw.gl_set_proc_address)

    return window, false
}

// Called when glfw keystate changes
key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	// Exit program on escape pressed
	if key == glfw.KEY_ESCAPE {
		running = false
	}
}

// Called when glfw window changes size
size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	// Set the OpenGL viewport size
	gl.Viewport(0, 0, width, height)
}

////////////////////////
// Running the engine //
////////////////////////

run :: proc(window: glfw.WindowHandle) {
	defer glfw.Terminate()
	defer glfw.DestroyWindow(window)

	// Main loop
	for !glfw.WindowShouldClose(window) && running {
		glfw.PollEvents()
		
		update()
		draw()

		glfw.SwapBuffers(window)
	}
	
	exit()
}

update :: proc(){
	// Own update code here
}

draw :: proc(){
	gl.ClearColor(0.2, 0.3, 0.3, 1.0)
	// Clear the screen with the set clearcolor
	gl.Clear(gl.COLOR_BUFFER_BIT)

	// Own drawing code here
}

exit :: proc(){
	// Own termination code here
}
