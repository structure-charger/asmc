include io.inc
include string.inc
include stdio.inc
include stdlib.inc
include winbase.inc
include tchar.inc

    .code

BuildImportLib proc uses rsi rdi rbx r12 r13 dll:LPSTR
local buffer[256]:sbyte
local fn_dll[128]:sbyte

    lea rdi,fn_dll
    mov rdx,rcx
    .if strrchr(strcpy(rdi, rdx), '.')
        mov byte ptr [rax],0
    .endif
    .if LoadLibrary(strcat(rdi, ".dll"))

        mov rbx,rax
        strcpy(strrchr(rdi, '.'), ".def")
        .if fopen(rdi, "wt")

            mov r12,rax
            strrchr(rdi, '.')
            mov byte ptr [rax],0
            mov eax,[rbx].IMAGE_DOS_HEADER.e_lfanew
            mov eax,[rbx+rax].IMAGE_NT_HEADERS.OptionalHeader.DataDirectory.VirtualAddress
            mov r13d,[rbx+rax].IMAGE_EXPORT_DIRECTORY.NumberOfNames
            mov esi,[rbx+rax].IMAGE_EXPORT_DIRECTORY.AddressOfNames
            add rsi,rbx

            .while r13d
                lodsd
                fprintf(r12, "++%s.\'%s.dll\'\n", addr [rax+rbx], rdi)
                dec r13d
            .endw
            fclose(r12)
            lea rbx,buffer
            sprintf(rbx, "libw /n /c /q /b /fac /i6 %s.lib @%s.def", rdi, rdi)
            system(rbx)
            strcat(rdi, ".def")
            remove(rdi)
        .else
            perror(rdi)
        .endif
        FreeLibrary(rbx)
        xor eax,eax
    .else
        perror(rdi)
        mov eax,1
    .endif
    ret

BuildImportLib endp


ValidateString proc string:LPSTR
    mov al,[rcx]
    .if al == ' ' || al == 9 || al == ';'
        xor eax,eax
    .elseif strlen(rcx)
        mov rcx,rax
        add rcx,string
        .repeat
            dec rcx
            .break .if byte ptr [rcx] > ' '
            mov byte ptr [rcx],0
            dec rax
        .untilz
    .endif
    ret
ValidateString endp

main proc
local lbuf[256]:sbyte

    .if fopen("implist.ini", "rt")

        mov rsi,rax
        lea rdi,lbuf

        .while fgets(rdi, 256, rsi)

            .ifd ValidateString(rdi)

                printf("  %s.lib\n", rdi)
                BuildImportLib(rdi)
            .endif
        .endw
    .endif
    xor eax,eax
    ret

main endp

    end _tstart
