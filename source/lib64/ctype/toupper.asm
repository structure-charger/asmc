; TOUPPER.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;
include ctype.inc
include winnls.inc

    .code

toupper proc char:int_t

    mov eax,ecx

    .repeat

        .break .if ( al <= 'Z' )

        .if ( al >= 'a' && al <= 'z' )

            sub al,'a'-'A'
            .break
        .endif

if WINVER GE 0x0600
        LCMapStringEx(LOCALE_NAME_USER_DEFAULT,
            LCMAP_UPPERCASE, &char, 1, &char, 1, 0, 0, 0)
        mov eax,char
endif
    .until 1
    ret

toupper endp

    end

