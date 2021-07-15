ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start                     ; short jump (BIOS Parameter Block)
    nop                                 ; nop (NO OPERATION)

times 33 db 0                           ; Fills 33 bytes by 0 after short jump (BIOS Parameter Block)

start:
    jmp 0:step2                         ; code segment set to 0x7c0

step2:
    cli                                 ; clear interrupts

    mov ax, 0x00
    mov ds, ax                          ; data segment set to 0x00
    mov es, ax                          ; extra segment set to 0x00
    mov ss, ax                          ; stack segment set to 0x00
    mov sp, 0x7c00                      ; stack pointer set to 0x7c00

    sti                                 ; enable interrupts

    

.load_protected:
    cli
    lgdt [gdt_descriptor]               ; load global descriptor table

    mov eax, cr0
    mov eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32


; GDT
gdt_start:

gtd_null:
    dd 0x0
    dd 0x0


; Offset 0x8
gdt_code:                               ; CS should point to this
    dw 0xffff                           ; Segment limit first 0-15 bits
    dw 0                                ; Base first 0-15 bits
    db 0                                ; Base 16-23 bits
    db 0x9a                             ; Access bytes
    db 11001111b                        ; High 4 bit flags and the low 4 bit flags
    db 0                                ; Base 24-31 bits


; Offset 0x10
gdt_data:                               ; DS, SS, ES, FS, GS
    dw 0xffff                           ; Segment limit first 0-15 bits
    dw 0                                ; Base first 0-15 bits
    db 0                                ; Base 16-23 bits
    db 0x92                             ; Access bytes
    db 11001111b                        ; High 4 bit flags and the low 4 bit flags
    db 0                                ; Base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start -1;
    dd gdt_start


[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; Enabling A20 line
    in al, 0x92
    or al, 2
    out 0x92, al
    jmp $

times 510 - ($-$$) db 0
dw 0xAA55
