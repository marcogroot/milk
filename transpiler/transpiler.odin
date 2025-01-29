package assembly

import "core:fmt"
import "core:os"
import "../parser"

file : os.Handle

interpret_ast :: proc(nodes: ^[dynamic]parser.Node) {
    file_name := "output/milk.odin"
    temp_file, err := os.open(file_name, 2)
    if err != nil {
        fmt.println("Error creating file:", err)
        return
    }
    file = temp_file

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


        case: {
            fmt.println("Unexpected node type", node)
        }

    }

}

write :: proc(text: string) {
    os.write_string(file, text)
}

write_preamble :: proc() {
    write("package milk\n")
    write("import \"core:fmt\"\n\n")
    write("main :: proc() {\n")
}

write_postamble :: proc() {
    write("\n}")
}

handle_assignment_node :: proc(node: ^parser.Node) {
    name := node.left.value
    write(name)
    write(" := ")
    value := node.right
    write(value.value)
    write("\n")
}

FMT_FUNCTION_NAMES :: []string{
    "println"
}
write_function :: proc(func_name: string) {
    for name in FMT_FUNCTION_NAMES {
        if name == func_name {
            write("fmt.")
            write(func_name)
            write("(")
            return;
        }
    }
    write(func_name)
    write("(")
}

handle_parameters :: proc(node: ^parser.Node) {
    fmt.println(node)
    if node.right == nil && node.left == nil { // no params
        write(")\n")
        return
    }

    write(node.left.value)

    if (node.right != nil) {
        write(", ")
        handle_parameters(node.right)
    } else {
        write(")\n")
    }
}

handle_function_call :: proc(node: ^parser.Node) {
    write_function(node.value)
    handle_parameters(node)
}