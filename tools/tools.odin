package tools

import rl "vendor:raylib"
import "../parser"
import "core:math/linalg/glsl"
import "core:fmt"


draw_node :: proc(node: ^parser.Node, level: int, horizontal_offset: int) {
    x := i32(horizontal_offset)
    y := i32(level*150)
    rl.DrawRectangle(x, y, 100, 100, rl.GREEN)
    rl.DrawText(rl.TextFormat("type: %v", node.type), x, y, 12, rl.BLACK)
    rl.DrawText(rl.TextFormat("value: %v", node.value), x, y+30, 12, rl.BLACK)
}

dfs :: proc(node: ^parser.Node, level: int, horizontal_offset: int) {
    if node == nil {
        return;
    }

    draw_node(node, level, horizontal_offset)

    if node.left != nil {
        rl.DrawLine(i32(horizontal_offset+50), i32((level*150)+100), i32(horizontal_offset-120), i32((level+1)*150), rl.BLACK)
        dfs(node.left, level+1, horizontal_offset-160)
    }

    if node.right != nil {
        rl.DrawLine(i32(horizontal_offset+50), i32(100+(level*150)), i32(horizontal_offset+200), i32((level+1)*150), rl.BLACK)
        dfs(node.right, level+1, horizontal_offset+160)
    }
}

visualise_ast :: proc(starting_nodes: ^[dynamic]parser.Node) {
    rl.InitWindow(1280, 720, "visualise AST")

    vertical_offset : f32 = 0
    horizontal_offset : f32 = 0
    zoom : f32 = 1

    for !rl.WindowShouldClose() {
        if rl.IsKeyDown(.LEFT) {
            horizontal_offset -= 400*rl.GetFrameTime()
        }
        if rl.IsKeyDown(.RIGHT) {
            horizontal_offset += 400*rl.GetFrameTime()
        }
        if rl.IsKeyDown(.UP) {
            vertical_offset += 400*rl.GetFrameTime()
        }
        if rl.IsKeyDown(.DOWN) {
            vertical_offset -= 400*rl.GetFrameTime()
        }
        if rl.IsKeyDown(.ENTER) || rl.IsKeyDown(.SPACE) {
            zoom += 0.8*rl.GetFrameTime()
        }
        if rl.IsKeyDown(.BACKSPACE) {
            zoom -= 0.8*rl.GetFrameTime()
        }

        rl.BeginDrawing()
        camera := rl.Camera2D {
            zoom = zoom,
            target = {horizontal_offset, vertical_offset}
        }
        rl.BeginMode2D(camera)
        rl.ClearBackground(rl.WHITE)
        rl.SetWindowState({.WINDOW_RESIZABLE})

        offset := 500
        for &node in starting_nodes {
            dfs(&node, 0, offset)
            offset += 700
        }


        rl.EndMode2D()

        rl.EndDrawing()
    }

    rl.CloseWindow()
}
