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
    dw gdt_end - gdt_start - 1;
    dd gdt_start

[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call ata_lba_read

    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax                        ; Backup the LBA
    ; SEND the highest 8 bits of the lba to hard disk controller
    shr eax, 24
    or eax, 0xE0                        ; Select the master drive
    mov dx, 0x1F6
    out dx, al
    ; FINISHED sending the highest 8 bits of the lba

    ; SEND the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; FINISHED sending the total sectors to read

    ; SEND more bits of the LBA
    mov eax, ebx                        ; Restore the backup LBA
    mov dx, 0x1F3
    out dx, al
    ; FINISHED sending more bits of the LBA

    ; SEND more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx                        ; Restore the backup LBA
    shr eax, 8
    out dx, al
    ; FINISHED sending more bits of the LBA

    ; SEND Upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx                        ; Restore the backup LBA
    shr eax, 16
    out dx, al
    ; FINISHED sending upper 16 bits of the LBA


    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

    ; READ all sectors into memory
.next_sector:
    push ecx

; Checking if we need to read
.try_again:
    mov dx, 0x1F7
    in al, dx
    test al, 8
    jz .try_again

    ; We need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector

    ; END reading sectors into memory
    ret

times 510 - ($-$$) db 0
dw 0xAA55
