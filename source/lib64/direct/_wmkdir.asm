; _WMKDIR.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include io.inc
include errno.inc
include direct.inc
include winbase.inc

    .code

    option win64:nosave

_wmkdir proc frame directory:LPWSTR

    .if CreateDirectoryW(rcx, 0)
        xor eax,eax
    .else
        _dosmaperr(GetLastError())
    .endif
    ret

_wmkdir endp

    END
