; _TOUPPER.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include ctype.inc

    .code

    OPTION PROLOGUE:NONE, EPILOGUE:NONE

_toupper proc char:SINT

    movzx eax,cl
    sub al,'a'-'A'
    ret

_toupper endp

    end

