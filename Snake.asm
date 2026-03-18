; Project: Snake Game
; 24L-3031  ,  24L-3035
; BSE-3A

org 0x100

jmp start
    ; Game constants
    SCREEN_WIDTH equ 80
    SCREEN_HEIGHT equ 25
    GAME_WIDTH equ 78
    GAME_HEIGHT equ 22
    
    ; Colors
    COLOR_BORDER equ 0x0E    ; Yellow
    COLOR_SNAKE equ 0x0A     ; Light Green
    COLOR_FOOD equ 0x0C      ; Light Red
    COLOR_TEXT equ 0x0F      ; White
    COLOR_TITLE equ 0x0B     ; Cyan
    
    ; Direction constants
    DIR_UP equ 0
    DIR_RIGHT equ 1
    DIR_DOWN equ 2
    DIR_LEFT equ 3
    
    ; Game variables
    snake_length dw 3
    direction db DIR_RIGHT
    next_direction db DIR_RIGHT
    game_over db 0
    score dw 0
    
    ; Snake body array (max 200 segments)
    snake_x times 200 db 0
    snake_y times 200 db 0
    
    ; Food position
    food_x db 0
    food_y db 0
    
    ; Random seed
    seed dw 0
    
    ; Temp variables for movement
    new_head_x db 0
    new_head_y db 0
    
    ; Messages 
    msg_title db 'S N A K E   G A M E'
    msg_controls db 'Arrow Keys / WASD - Move    ESC - Quit'
    msg_score_label db 'Score: $'
    msg_game_over db 'GAME OVER!'
    msg_final_score db 'Final Score: '
    msg_press_key db 'Press any key to exit...'           

    wel1 db " __        __   __                           __            $"
    wel2 db " \ \      / /__| | ___ ___  _ __ ___   ___  | |_ ___$"
    wel3 db "  \ \ /\ / / _ \ |/ __/ _ \| '_ ` _ \ / _ \ | __/ _ \$"
    wel4 db "   \ V  V /  __/ | (_| (_) | | | | | |  __/ | || (_) |$"
    wel5 db "    \_/\_/ \___|_|\___\___/|_| |_|_|_|\___|  \__\___/$"
    wel6 db " / ___| _ __   __ _| | _____   / ___| __ _ _ __ ___   ___$"
    wel7 db " \___ \| '_ \ / _` | |/ / _ \ | |  _ / _` | '_ ` _ \ / _ \$"
    wel8 db "  ___) | | | | (_| |   <  __/ | |_| | (_| | | | | | |  __/$"
    wel9 db " |____/|_| |_|\__,_|_|\_\___|  \____|\__,_|_| |_| |_|\___|$"
	wel10 db " Press any key to start the game! $"

start:
    call draw_welcome
    mov ah,0
    int 0x16
    call init_game
    
game_loop:
    ; Check if game over
    mov al, [game_over]
    cmp al, 1
    je end_game
    
    ; Draw game
    call draw_game
    
    ; Small delay
    call delay
    
    ; Get input
    call get_input
    
    ; Update direction
    mov al, [next_direction]
    mov [direction], al
    
    ; Move snake
    call move_snake
    
    ; Check collisions
    call check_collision
    
    ; Check food
    call check_food
    
    jmp game_loop

end_game:
    ; Clear screen 
    call clear_screen
    
    ; Display GAME OVER - yellow color, cx=10
    mov ah, 0x13
    mov al, 0x01
    mov bh, 0
    mov bl, COLOR_BORDER    ; Yellow
    mov dh, 10
    mov dl, 35
    mov cx, 10
    push cs
    pop es
    mov bp, msg_game_over
    int 0x10
    
    ; Display Final Score - yellow color, cx=13
    mov ah, 0x13
    mov al, 0x01
    mov bh, 0
    mov bl, COLOR_BORDER    ; Yellow
    mov dh, 12
    mov dl, 32
    mov cx, 13
    mov bp, msg_final_score
    int 0x10
    
    ; Display score number
    mov ah, 0x02
    mov bh, 0
    mov dh, 12
    mov dl, 45
    int 0x10
    
    mov ax, [score]
    call print_number
    
    ; Display press any key message - yellow color, cx=24
    mov ah, 0x13
    mov al, 0x01
    mov bh, 0
    mov bl, COLOR_BORDER    ; Yellow
    mov dh, 14
    mov dl, 28
    mov cx, 24
    mov bp, msg_press_key
    int 0x10
    
    ; Wait for key
    mov ah, 0x00
    int 0x16
	
	; Wait for key
    mov ah, 0x00
    int 0x16
    
    ; Clear screen
    call clear_screen
    
    ; Show cursor
    mov ah, 0x01
    mov ch, 0x06
    mov cl, 0x07
    int 0x10
    
    ; Termintion
    mov ax, 0x4C00
    int 0x21

; Clear screen
clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

; Initialize game
init_game:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    ; Hide cursor
    mov ah, 0x01
    mov ch, 0x20
    mov cl, 0x20
    int 0x10
    
    ; Initialize snake in center
    mov word [snake_length], 3
    
    mov byte [snake_x], 40
    mov byte [snake_y], 12
    
    mov byte [snake_x+1], 39
    mov byte [snake_y+1], 12
    
    mov byte [snake_x+2], 38
    mov byte [snake_y+2], 12
    
    ; Set initial direction
    mov byte [direction], DIR_RIGHT
    mov byte [next_direction], DIR_RIGHT
    
    ; Initialize random seed with timer
    mov ah, 0x00
    int 0x1A
    mov [seed], dx
    
    ; Spawn first food
    call spawn_food
    
    ret

; Get keyboard input
get_input:
    ; Check if key is pressed
    mov ah, 0x01
    int 0x16
    jz .no_key
    
    ; Get key
    mov ah, 0x00
    int 0x16
    
    ; Check for ESC
    cmp ah, 0x01
    je .exit_game
    
    ; Get current direction
    mov cl, [direction]
    
    ; Check arrow keys
    cmp ah, 0x48  ; Up arrow
    je .up
    cmp ah, 0x50  ; Down arrow
    je .down
    cmp ah, 0x4B  ; Left arrow
    je .left
    cmp ah, 0x4D  ; Right arrow
    je .right
    
    ; Check WASD
    cmp al, 'w'
    je .up
    cmp al, 'W'
    je .up
    cmp al, 's'
    je .down
    cmp al, 'S'
    je .down
    cmp al, 'a'
    je .left
    cmp al, 'A'
    je .left
    cmp al, 'd'
    je .right
    cmp al, 'D'
    je .right
    
    jmp .no_key

.up:
    cmp cl, DIR_DOWN
    je .no_key
    mov byte [next_direction], DIR_UP
    jmp .no_key

.down:
    cmp cl, DIR_UP
    je .no_key
    mov byte [next_direction], DIR_DOWN
    jmp .no_key

.left:
    cmp cl, DIR_RIGHT
    je .no_key
    mov byte [next_direction], DIR_LEFT
    jmp .no_key

.right:
    cmp cl, DIR_LEFT
    je .no_key
    mov byte [next_direction], DIR_RIGHT
    jmp .no_key

.exit_game:
    mov byte [game_over], 1

.no_key:
    ret

; Move snake
move_snake:
    ; Get head position
    mov al, [snake_x]
    mov [new_head_x], al
    mov al, [snake_y]
    mov [new_head_y], al
    
    ; Calculating new head position based on direction
    mov al, [direction]
    
    cmp al, DIR_UP
    je .move_up
    cmp al, DIR_DOWN
    je .move_down
    cmp al, DIR_LEFT
    je .move_left
    cmp al, DIR_RIGHT
    je .move_right
    
.move_up:
    dec byte [new_head_y]
    jmp .update_position
    
.move_down:
    inc byte [new_head_y]
    jmp .update_position
    
.move_left:
    dec byte [new_head_x]
    jmp .update_position
    
.move_right:
    inc byte [new_head_x]

.update_position:
    ; Shift all body segments back
    mov cx, [snake_length]
    dec cx
    
.shift_loop:
    cmp cx, 0
    jle .shift_done
    
    push cx
    
    mov si, cx
    mov di, cx
    dec si
    
    ; Copy X coordinate
    mov bx, snake_x
    add bx, si
    mov al, [bx]
    mov bx, snake_x
    add bx, di
    mov [bx], al
    
    ; Copy Y coordinate
    mov si, cx
    mov di, cx
    dec si
    mov bx, snake_y
    add bx, si
    mov al, [bx]
    mov bx, snake_y
    add bx, di
    mov [bx], al
    
    pop cx
    
    dec cx
    jmp .shift_loop

.shift_done:
    ; Set new head position
    mov al, [new_head_x]
    mov [snake_x], al
    mov al, [new_head_y]
    mov [snake_y], al
    
    ret

; Check collision with walls and self
check_collision:
    ; Get head position
    xor ax, ax
    xor bx, bx
    mov al, [snake_x]
    mov bl, [snake_y]
    
    ; Check walls
    cmp al, 1
    jle .collision
    cmp al, 78
    jge .collision
    
    cmp bl, 2
    jle .collision
    cmp bl, 23
    jge .collision
    
    ; Check self collision (start from segment 1)
    mov cx, 1
    
.check_self:
    cmp cx, [snake_length]
    jge .no_collision
    
    push ax
    push bx
    push cx
    
    mov si, cx
    mov bx, snake_x
    add bx, si
    xor dx, dx
    mov dl, [bx]
    
    mov si, cx
    mov bx, snake_y
    add bx, si
    xor di, di
    mov al, [bx]
    mov di, ax
    
    pop cx
    pop bx
    pop ax
    
    cmp al, dl
    jne .next_segment
    ; Compare Y coordinates
    push ax
    mov ax, di
    cmp bl, al
    pop ax
    je .collision
    
.next_segment:
    inc cx
    jmp .check_self

.collision:
    mov byte [game_over], 1
    
.no_collision:
    ret

; Check if food is eaten
check_food:
    mov al, [snake_x]
    mov bl, [snake_y]
    
    cmp al, [food_x]
    jne .no_food
    cmp bl, [food_y]
    jne .no_food
    
    ; Food eaten - increase length and score
    inc word [snake_length]
    inc word [score]
    
    ; Spawn new food
    call spawn_food

.no_food:
    ret

; Spawn food at random location
spawn_food:
.gen_position:
    ; Generate random X (2-77)
    call random
    mov ax, dx
    xor dx, dx
    mov cx, 76
    div cx
    add dl, 2
    mov [food_x], dl
    
    ; Generate random Y (3-22)
    call random
    mov ax, dx
    xor dx, dx
    mov cx, 20
    div cx
    add dl, 3
    mov [food_y], dl
    
    ; Check if food spawned on snake
    xor cx, cx
    
.check_loop:
    cmp cx, [snake_length]
    jge .spawn_done
    
    push cx
    mov si, cx
    mov bx, snake_x
    add bx, si
    mov al, [bx]
    
    mov bx, snake_y
    add bx, si
    mov bl, [bx]
    pop cx
    
    cmp al, [food_x]
    jne .next_check
    cmp bl, [food_y]
    je .gen_position
    
.next_check:
    inc cx
    jmp .check_loop

.spawn_done:
    ret

; Generate random number (result in DX)
random:
    push ax
    push cx
    
    mov ax, [seed]
    mov cx, 25173
    mul cx
    add ax, 13849
    mov [seed], ax
    mov dx, ax
    
    pop cx
    pop ax
    ret

; Draw the game
draw_game:
    ; Clear screen
    call clear_screen
    
    ; Draw title bar - cx=19 
    mov ah, 0x13
    mov al, 0x01
    mov bh, 0
    mov bl, COLOR_TITLE
    mov dh, 0
    mov dl, 30
    mov cx, 19
    push cs
    pop es
    mov bp, msg_title
    int 0x10
    
    ; Draw controls - cx=38 
    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TEXT
    mov dh, 24
    mov dl, 21
    mov cx, 38
    mov bp, msg_controls
    int 0x10
    
    ; Draw border
    call draw_border
    
    ; Draw snake
    call draw_snake
    
    ; Draw food
    call draw_food_sprite
    
    ; Draw score
    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TEXT
    mov dh, 1
    mov dl, 2
    mov cx, 7
    mov bp, msg_score_label
    int 0x10
    
    mov ah, 0x02
    mov bh, 0
    mov dh, 1
    mov dl, 9
    int 0x10
    
    mov ax, [score]
    call print_number
    
    ret

; Draw border using double-line box char
draw_border:
    mov ah, 0x09
    mov bh, 0
    mov cx, 1
    
    ; Top-left corner
    mov dx, 0x0201
    call set_cursor
    mov al, 0xC9  ; +
    mov bl, COLOR_BORDER
    int 0x10
    
    ; Top border
    mov dl, 2
.top_loop:
    cmp dl, 78
    jge .top_right
    call set_cursor
    mov al, 0xCD  ; -
    mov bl, COLOR_BORDER
    int 0x10
    inc dl
    jmp .top_loop
    
.top_right:
    ; Top-right corner
    mov dl, 78
    call set_cursor
    mov al, 0xBB  ; +
    mov bl, COLOR_BORDER
    int 0x10
    
    ; Side borders
    mov dh, 3
.side_loop:
    cmp dh, 23
    jge .bottom_border
    
    ; Left border
    mov dl, 1
    call set_cursor
    mov al, 0xBA  ; ¦
    mov bl, COLOR_BORDER
    int 0x10
    
    ; Right border
    mov dl, 78
    call set_cursor
    mov al, 0xBA  ; ¦
    mov bl, COLOR_BORDER
    int 0x10
    
    inc dh
    jmp .side_loop

.bottom_border:
    ; Bottom-left corner
    mov dx, 0x1701
    call set_cursor
    mov al, 0xC8  ; +
    mov bl, COLOR_BORDER
    int 0x10
    
    ; Bottom border
    mov dl, 2
.bottom_loop:
    cmp dl, 78
    jge .bottom_right
    call set_cursor
    mov al, 0xCD  ; -
    mov bl, COLOR_BORDER
    int 0x10
    inc dl
    jmp .bottom_loop
    
.bottom_right:
    ; Bottom-right corner
    mov dl, 78
    call set_cursor
    mov al, 0xBC  ; +
    mov bl, COLOR_BORDER
    int 0x10
    
    ret

; Set cursor helper
set_cursor:
    push ax
    mov ah, 0x02
    mov bh, 0
    int 0x10
    pop ax
    ret

; Draw snake
draw_snake:
    xor cx, cx
    
.draw_loop:
    cmp cx, [snake_length]
    jge .draw_done
    
    push cx
    
    ; Get segment position
    mov si, cx
    mov bx, snake_x
    add bx, si
    xor dx, dx
    mov dl, [bx]
    
    mov bx, snake_y
    add bx, si
    mov dh, [bx]
    
    ; Set cursor
    mov ah, 0x02
    mov bh, 0
    int 0x10
    
    ; Draw segment
    mov ah, 0x09
    mov bh, 0
    cmp cx, 0
    je .draw_head
    
    ; Body segment
    mov al, 0xFE  ; ¦ (solid block)
    mov bl, COLOR_SNAKE
    mov cx, 1
    int 0x10
    jmp .next_segment
    
.draw_head:
    ; Head segment (different character)
    mov al, 0xDB  ; ¦ (full block)
    mov bl, COLOR_SNAKE
    mov cx, 1
    int 0x10

.next_segment:
    pop cx
    inc cx
    jmp .draw_loop

.draw_done:
    ret

; Draw food
draw_food_sprite:
    xor dx, dx
    mov dl, [food_x]
    mov dh, [food_y]
    
    mov ah, 0x02
    mov bh, 0
    int 0x10
    
    mov ah, 0x09
    mov al, 0x04  ; diamond
    mov bl, COLOR_FOOD
    mov cx, 1
    int 0x10
    
    ret

; Print number in AX
print_number:
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 0
    mov bx, 10
    
    ; Handle zero case
    test ax, ax
    jnz .divide
    mov dl, '0'
    mov ah, 0x0E
    mov al, dl
    int 0x10
    jmp .done
    
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .divide
    
.print:
    pop dx
    add dl, '0'
    mov ah, 0x0E
    mov al, dl
    int 0x10
    loop .print
    
.done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Delay function
delay:
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 0x0000
    mov dx, 0xF000   ; Increase delay to slow down snake
    mov ah, 0x86
    int 0x15
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    
draw_welcome:
    push cs
    pop es

	call clear_screen

    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TITLE
    mov dh, 4             ; row on video memory
    mov dl, 10            ; column on video memory
    mov cx, 58            ; length of the string
    mov bp, wel1
    int 0x10

    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TITLE
    mov dh, 5
    mov dl, 10
    mov cx, 52
    mov bp, wel2
    int 0x10

    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TITLE
    mov dh, 6
    mov dl, 10
    mov cx, 53
    mov bp, wel3
    int 0x10

    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TITLE
    mov dh, 7
    mov dl, 10
    mov cx, 54
    mov bp, wel4
    int 0x10

    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TITLE
    mov dh, 8
    mov dl, 10
    mov cx, 53
    mov bp, wel5
    int 0x10

    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TITLE
    mov dh, 9
    mov dl, 10
    mov cx, 57
    mov bp, wel6
    int 0x10

    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TITLE
    mov dh, 10
    mov dl, 10
    mov cx, 58
    mov bp, wel7
    int 0x10

    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TITLE
    mov dh, 11
    mov dl, 10
    mov cx, 58
    mov bp, wel8
    int 0x10

    mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_TITLE
    mov dh, 12
    mov dl, 10
    mov cx, 58
    mov bp, wel9
    int 0x10
	
	mov ah, 0x13
    mov al, 0x01
    mov bl, COLOR_BORDER
    mov dh, 16
    mov dl, 10
    mov cx, 34
    mov bp, wel10
    int 0x10

    ret