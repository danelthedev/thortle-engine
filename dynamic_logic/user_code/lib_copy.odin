package user_code

import "core:fmt"

@export
run :: proc(args: ..any) -> (err: bool) {
    fmt.println("my_lib_foo_copy");
    return false
}