package assembly

import "core:fmt"
import "core:os"
import "../parser"
import "core:strings"

file : os.Handle

indentation := 0

interpret_ast :: proc(nodes: ^[dynamic]parser.Node) {
    indentation = 0
    file_name := "output/milk.odin"
    temp_file, err := os.open(file_name, 2)
    if err != nil {
        fmt.eprintln("Error creating file:", err)
        return
    }
    file = temp_file
    os.flush(file)

    defer(os.close(file))

    write_preamble()

    for &node in nodes {
        write_node(&node)
    }

    write_postamble()
}

write_node :: proc(node: ^parser.Node) {
    #partial switch node.type {
        case parser.NodeType.ASSIGNMENT: handle_assignment_node(node)
        case parser.NodeType.CALL: handle_function_call(node)
        case parser.NodeType.PLUS_PLUS: handle_plus_plus(node)
        case parser.NodeType.PLUS_EQUALS: handle_plus_equals(node)

        case: {
            fmt.eprintln("Unexpected node type", node)
        }

    }
}

handle_plus_equals :: proc(node: ^parser.Node) {
    to_add := node.left.value;
    func_string := [3]string {node.value, " += ", to_add}
    str := strings.concatenate(func_string[:])
    write(str, true)
    return;
}

handle_plus_plus :: proc(node: ^parser.Node) {
    func_string := [2]string {node.value, " += 1"}
    str := strings.concatenate(func_string[:])
    write(str, true)
    return;
}

write :: proc(text: string, new_line: bool = false) {
    for i in 0..<indentation {
        os.write_string(file, " ")
    }
    os.write_string(file, text)
    if new_line {
        os.write_string(file, "\n")
    }
    delete(text)
}

plain_write :: proc(text: string, new_line: bool = false) {
    os.write_string(file, text)
    if new_line {
        os.write_string(file, "\n")
    }
}

write_preamble :: proc() {
    plain_write("package milk", true)
    plain_write("import \"core:fmt\"\n", true)
    plain_write("main :: proc() {", true)
    indentation = 4;
}

write_postamble :: proc() {
    plain_write("\n}")
}

handle_assignment_node :: proc(node: ^parser.Node) {
    assignment_string := [3]string {}
    value := node.right
    name := node.left.value
    assignment_string[0] = name
    assignment_string[1] = " := "
    assignment_string[2] = value.value
    str := strings.concatenate(assignment_string[:])
    write(str, true)
}

FMT_FUNCTION_NAMES :: []string{
    "println"
}
write_function :: proc(func_name: string) {
    for name in FMT_FUNCTION_NAMES {
        if name == func_name {
            func_string := [3]string {"fmt.", func_name, "("}
            str := strings.concatenate(func_string[:])
            write(str)
            return;
        }
    }
    func_string := [2]string {func_name, "("}
    write(strings.concatenate(func_string[:]))
}

handle_parameters :: proc(node: ^parser.Node) {
    if node.right == nil && node.left == nil { // no params
        plain_write(")", true)
        return
    }

    plain_write(node.left.value)

    if (node.right != nil) {
        plain_write(", ")
        handle_parameters(node.right)
    } else {
        plain_write(")", true)
    }
}

handle_function_call :: proc(node: ^parser.Node) {
    write_function(node.value)
    handle_parameters(node)
}