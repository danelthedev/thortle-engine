package main

import "base:runtime"
import "core:os/os2"
import "core:os"
import "core:fmt"
import "core:c"
import "core:dynlib"

import gl "vendor:OpenGL"
import "vendor:glfw"

import "engine"


main :: proc() {	

	window, err := engine.init(engine.WindowSettings{
		width = 1280,
		height = 720,
		title = "Thortle engine",
	})

	if err {
		os.exit(1)
	}

	engine.run(window)
}