package dynamic_logic

import "core:os/os2"
import "core:os"
import "core:strings"
import "core:dynlib"
import "core:time"
import "core:fmt"

UserProcedure :: #type proc(args: ..any) -> (err: bool)  // For fixed 2 return values

compile_file :: proc(file: string) -> (procedures: [dynamic]UserProcedure, library: dynlib.Library, err: bool) {
    file_array := strings.split(file, "/")
    file_with_extension := file_array[len(file_array) - 1]
    file_name := strings.split(file_with_extension, ".")[0]
    temp_dir := "compilations/"

    command := strings.concatenate({"odin build ", file, " -file -build-mode:dll -out:", temp_dir, file_name, ".dll"})
	
	//create a process to run the command
	process_description := os2.Process_Desc{
		command = strings.split(command, " ")
	}

	state, stdout, stderr, _err := os2.process_exec(process_description, context.allocator)

	if _err != nil {
		fmt.println("Failed to execute process")
		return nil, nil, true
	}

	if !state.success {
		fmt.println("Process failed")
		return nil, nil, true
	}

	if len(stderr) > 0 {
		fmt.println("Process failed with error: {}", stderr)
		return nil, nil, true
	}

	fmt.println("File compiled successfully")

	// Load the newly created DLL
	dll_path := strings.concatenate({temp_dir, file_name, ".dll"})

	lib, ok := dynlib.load_library(dll_path)
	if !ok {
		fmt.eprintln("Failed to load library")
		return nil, nil, true
	}

	// Get and call the procedure

	run_ptr := dynlib.symbol_address(lib, "run")
	if run_ptr == nil {
		fmt.eprintln("Failed to get procedure address")
		return nil, nil, true
	}

	run := cast(UserProcedure)run_ptr

    dynamic_procedures := [dynamic]UserProcedure{}
    append(&dynamic_procedures, run)
    
    return dynamic_procedures, lib, len(dynamic_procedures) == 0
}

// compiles all odin files from a folder and returns all procedures and libraries
/*
	usage example:

	procedures, libs, err := compile_directory("user_code/")

	defer os2.remove_all("temp")
	defer{
		for lib in libs do dynlib.unload_library(lib)
	}

	if err {
		fmt.println("Error during extraction of libraries")
		return
	}
	fmt.println("Extracted libraries: ", len(libs))

	fmt.println("Extracted procedure groups: ", len(procedures))

	for procedure_group, i in procedures{
		fmt.println("Extracted procedures in group ", i, ": ", len(procedure_group))
		for procedure in procedure_group{
			_err := procedure(12)
			if err {
				fmt.println("Error in run")
			}
		}
	}
*/ 

compile_directory :: proc(dir_path: string) -> (procedures: [dynamic][dynamic]UserProcedure, libraries: [dynamic]dynlib.Library, err: bool) {

	f, _err := os.open(dir_path)
	if _err != nil {
		fmt.eprintln("Failed to open directory")
		return nil, nil, true
	}
    defer os.close(f)

    entries, read_err := os.read_dir(f, 0, context.allocator)
    if read_err != os.ERROR_NONE{
        fmt.eprintln("Failed to read directory")
        return nil, nil, true
    }
    
	defer delete(entries)
    
	procedures = make([dynamic][dynamic]UserProcedure)
    libraries = make([dynamic]dynlib.Library)

    for entry in entries {
        if entry.mode != os.File_Mode_Dir  && strings.has_suffix(entry.name, ".odin") {
            file_path := strings.concatenate({dir_path, "/", entry.name})
            procs, lib, compile_err := compile_file(file_path)
            
            if compile_err {
                fmt.eprintln("Failed to compile:", file_path)
                continue
            }
            
            append(&procedures, procs)
            append(&libraries, lib)
        }
    }

    return procedures, libraries, len(procedures) == 0
}


