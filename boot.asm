ORG 0
BITS 16

_start:
    jmp short start     ; short jump (BIOS Parameter Block)
    nop                 ; nop (NO OPERATION)

times 33 db 0           ; Fills 33 bytes by 0 after short jump (BIOS Parameter Block)

start:
    jmp 0x7c0:step2     ; code segment set to 0x7c0

step2:
    cli                 ; clear interrupts

    mov ax, 0x7c0
    mov ds, ax          ; data segment set to 0x7c0
    mov es, ax          ; extra segment set to 0x7c0

    mov ax, 0x00
    mov ss, ax          ; stack segment set to 0x00
    mov sp, 0x7c00      ; stack pointer set to 0x7c00

    sti                 ; enable interrupts

    mov ah, 2           ; Read Sector Command
    mov al, 1           ; One Sector to read
    mov ch, 0           ; Cylinder low eight bits
    mov cl, 2           ; Read Sector two
    mov dh, 0           ; Head number
    mov bx, buffer
    int 0x13            ; Hard Drive interrupt (Invoke read command)
    jc error            ; If the carry flag is set, jump to error label

    mov si, buffer
    call print
    
    jmp $

error:
    mov si, error_message
    call print
    jmp $

print:
    mov bx, 0
    .loop:
        lodsb
        cmp al, 0
        je .done
        call print_char
        jmp .loop
    .done:
        ret


print_char:
    mov ah, 0eh
    int 0x10
    ret

error_message: db "Failed to load sector", 0

times 510 - ($-$$) db 0
dw 0xAA55

buffer:
