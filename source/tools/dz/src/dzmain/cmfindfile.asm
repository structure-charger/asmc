; CMSEARCH.ASM--
; Copyright (C) 2016 Doszip Developers -- see LICENSE.TXT

include doszip.inc
include tview.inc
include malloc.inc
include io.inc
include string.inc
include stdio.inc

GetPathFromHistory proto :ptr

MAXHIT      equ 9999
ID_FILE     equ 13
ID_GOTO     equ 22
OF_MASK     equ 14*16
OF_PATH     equ 15*16
OF_SSTR     equ 16*16
OF_SUBD     equ 17*16
OF_CASE     equ 18*16
OF_HEXA     equ 19*16
OF_FIND     equ 20*16
OF_FILT     equ 21*16
OF_SAVE     equ 22*16
OF_GOTO     equ 23*16
OF_QUIT     equ 24*16
OF_MSUP     equ 25*16
OF_MSDN     equ 26*16
OF_GCMD     equ OF_MSUP
OUTPUT_BINARY equ 0       ; Binary dump (default)
OUTPUT_TEXT equ 1       ; Convert tabs, CR/LF
OUTPUT_LINE equ 2       ; Convert tabs, break on LF

    .data

ff_basedir      dd 0
DLG_FindFile    dd 0
PUBLIC          ff_basedir
PUBLIC          DLG_FindFile
PUBLIC          cp_formatID

GCMD_search     dd KEY_F2,  event_mklist
                dd KEY_F3,  ff_event_view
                dd KEY_F4,  ff_event_edit
                dd KEY_F5,  ff_event_filter
                dd KEY_F6,  event_toggle_hex
                dd KEY_F7,  event_find
                dd KEY_F8,  ff_event_delete
                dd KEY_F9,  cmfilter_load
                dd KEY_F10, event_toggle_format
                dd KEY_F11, event_getpath
                dd KEY_DEL, ff_event_delete
                dd KEY_ALTX,    ff_event_exit
                dd 0

cp_formatID     db '[%04d:%04d]',0
cp_format_l     db '(%u)',0

MAXHLEN equ 128

    .code

atohex proc string:LPSTR
    .if strlen(string)
        .if eax < MAXHLEN/2
            btohex(string, eax)
        .endif
    .endif
    mov eax,string
    ret
atohex endp

ff_getcurobj proc
    xor eax,eax
    mov edx,tdllist
    .if [edx].S_LOBJ.ll_count != eax

        mov eax,[edx].S_LOBJ.ll_index
        add eax,[edx].S_LOBJ.ll_celoff
        shl eax,2
        mov edx,[edx].S_LOBJ.ll_list
        add edx,eax
        mov eax,[edx]
    .endif
    ret
ff_getcurobj endp

ff_getcurfile proc
    ff_getcurobj()
    .ifnz

        add eax,S_SBLK.sb_file
    .endif
    ret
ff_getcurfile endp

ff_putcelid proc uses ebx format

    mov  ebx,DLG_FindFile
    movzx eax,[ebx].S_DOBJ.dl_index
    .if al >= ID_FILE

        xor eax,eax
    .endif
    inc eax
    mov edx,tdllist
    add eax,[edx].S_LOBJ.ll_index
    mov ecx,[edx].S_LOBJ.ll_count
    mov bx,[ebx+4]
    add bx,0F03h
    mov dl,bh
    scputf(ebx, edx, 0, 0, format, eax, ecx)
    ret

ff_putcelid endp

ff_fileblock proc private uses esi edi ebx directory, wfblk
  local path[_MAX_PATH*2]:byte
  local fblk, offs, line, fbsize, ioflag, result

    xor eax,eax
    xor esi,esi
    mov offs,eax
    mov edi,wfblk
    mov STDI.ios_line,eax
    mov line,eax
    mov edx,MAXHIT
    mov result,edx
    mov ebx,tdllist

    .if [ebx].S_LOBJ.ll_count < edx

        mov result,eax
        .if filter_wblk(edi)

            add edi,WIN32_FIND_DATA.cFileName
            strfcat(addr path, directory, edi)
            mov result,test_userabort()
            .ifz
                .if directory
                    .if cmpwarg(edi, fp_maskp)
                        inc esi
                    .endif
                .else
                    mov result,-1
                .endif
            .endif
        .endif
    .endif

    .if esi
        xor esi,esi
        cmp searchstring,0
        je  found

        mov ebx,wfblk
        osopen(addr path, [ebx].WIN32_FIND_DATA.dwFileAttributes, M_RDONLY, A_OPEN)
        mov STDI.ios_file,eax
        mov esi,eax
        inc eax
        .ifnz ; @v2.33 -- continue seacrh if open fails..

            mov eax,[ebx].WIN32_FIND_DATA.nFileSizeLow
            mov edx,[ebx].WIN32_FIND_DATA.nFileSizeHigh
            mov dword ptr STDI.ios_fsize,eax
            mov dword ptr STDI.ios_fsize[4],edx
            xor eax,eax
            .if edx == eax  ; No search above 4G...

                mov dword ptr STDI.ios_offset,eax
                mov dword ptr STDI.ios_offset[4],eax
                mov STDI.ios_flag,IO_RETURNLF
                mov STDI.ios_i,eax
                mov STDI.ios_c,eax
                ioread(addr STDI)
                mov ebx,wfblk
                mov eax,STDI.ios_c
                .if dword ptr STDI.ios_fsize <= eax

                    or STDI.ios_flag,IO_MEMBUF
                .endif

                xor eax,eax
                mov ebx,DLG_FindFile
                .if byte ptr [ebx+OF_CASE] & _O_FLAGB

                    or STDI.ios_flag,IO_SEARCHCASE
                .endif
                .if byte ptr [ebx+OF_HEXA] & _O_FLAGB

                    or STDI.ios_flag,IO_SEARCHHEX
                .endif
                .repeat
                    oseek(eax, SEEK_SET)
                    .break .if ZERO?
                    mov dword ptr STDI.ios_offset,eax
                    mov dword ptr STDI.ios_offset[4],edx
                    or  STDI.ios_flag,IO_SEARCHCUR
                    .break .if !searchstring
                    osearch()
                    .break .if ZERO?
                    mov offs,eax
                    mov line,ecx
                  found:
                    strlen(addr path)
                    add eax,BLOCKSIZE
                    mov edi,eax
                    .if !malloc(eax)
                        dec eax
                        mov result,eax
                        .break
                    .endif
                    mov fblk,eax
                    memset(eax, 0, edi)
                    add eax,S_SBLK.sb_file
                    lea ecx,path
                    strcpy(eax, ecx)
                    mov ebx,tdllist
                    xor edx,edx
                    mov eax,[ebx].S_LOBJ.ll_count
                    progress_update(edx::eax)
                    push eax
                    mov eax,[ebx].S_LOBJ.ll_count
                    inc [ebx].S_LOBJ.ll_count
                    mov edx,[ebx].S_LOBJ.ll_count
                    .if edx > ID_FILE

                        mov edx,ID_FILE
                    .endif
                    mov [ebx].S_LOBJ.ll_numcel,edx
                    mov ebx,[ebx].S_LOBJ.ll_list
                    mov ecx,fblk
                    mov [ebx+eax*4],ecx
                    mov [ecx].S_SBLK.sb_size,edi
                    mov eax,line
                    mov [ecx].S_SBLK.sb_line,eax
                    mov eax,offs
                    mov [ecx].S_SBLK.sb_offs,eax
                    mov ebx,ecx
                    pop eax
                    .if eax ; user abort

                        mov result,eax
                        .break
                    .endif
                    strlen(ff_basedir)
                    inc eax
                    mov [ebx],ax
                    .break .if !esi
                    oseek(offs, SEEK_SET)
                    mov eax,fblk
                    add eax,edi
                    sub eax,INFOSIZE
                    oreadb(eax, INFOSIZE-1)
                    mov ebx,wfblk
                    mov eax,offs
                    inc eax
                    .if eax >= dword ptr STDI.ios_fsize

                        mov eax,dword ptr STDI.ios_fsize
                    .endif
                    oseek(eax, SEEK_SET)
                    .break .if result
                    mov ebx,tdllist
                .until  [ebx].S_LOBJ.ll_count >= MAXHIT
            .endif
            .if esi

                _close(esi)
            .endif
        .endif
    .endif
    mov eax,result
    ret
ff_fileblock endp

ff_directory proc private directory
    .if !progress_set(0, directory, 0)

        scan_files(directory)
    .endif
    ret
ff_directory endp

ffsearchinitpath proc private path

    mov esi,path
    mov ah,0
    mov dl,' '
    .if [esi] == dl

        inc esi
    .endif
    .if byte ptr [esi] == '"'

        inc esi
        mov dl,'"'
    .endif
    push esi
    .repeat
        mov  al,[esi]
        test al,al
        jz   @F
        inc  esi
    .until  al == dl
    mov [esi-1],ah
@@:
    pop eax
    ret
ffsearchinitpath endp

ff_searchpath proc uses esi edi ebx directory

  local path[_MAX_PATH]:byte

    strcpy(addr path, directory)
    xor ecx,ecx
    xor ebx,ebx
    mov ff_basedir,eax
    .if path == cl

        mov path,'"'
        inc eax
        mov edx,com_wsub
        strcpy(eax, [edx].S_WSUB.ws_path)
    .endif

    .repeat
        ;
        ; Multi search using quotes:
        ; Find Files: ["Long Name.type" *.c *.asm.......]
        ; Location:   ["D:\My Documents" c: f:\doc......]
        ;
        ffsearchinitpath(ff_basedir)
        mov ff_basedir,eax
        push esi
        .if strlen(eax)
            push eax
            add eax,ff_basedir
            .if byte ptr [eax-1] == '\'

                mov byte ptr [eax-1],0
            .endif
            mov eax,DLG_FindFile
            mov edi,[eax+OF_SUBD]
            mov eax,[eax].S_TOBJ.to_data[OF_MASK]
            mov fp_maskp,eax
            .repeat
                ffsearchinitpath(fp_maskp)
                mov  fp_maskp,eax
                push edx
                .if edi & _O_FLAGB

                    scan_directory(1, ff_basedir)
                .else
                    push ff_basedir
                    call fp_directory
                .endif
                mov ebx,eax
                pop edx
                mov fp_maskp,esi
                .if dl == '"'

                    mov [esi-1],dl
                .endif
                .break .if byte ptr [esi] == 0
                mov [esi-1],dl
            .until eax
            pop eax
        .endif
        pop esi
        mov ff_basedir,esi
        .break .if ebx
        .break .if byte ptr [esi] == 0
    .until !eax
    mov eax,ebx
    ret
ff_searchpath endp

event_find proc private uses esi edi ebx
  local cursor:S_CURSOR

    mov fp_directory,ff_directory
    mov fp_fileblock,ff_fileblock
    mov STDI.ios_size,4096      ; default to _bufin
    mov STDI.ios_bp,offset _bufin
    .if malloc(800000h)

        mov STDI.ios_bp,eax
        mov STDI.ios_size,800000h
    .endif

    mov ebx,DLG_FindFile
    .if !([ebx].S_TOBJ.to_flag[OF_GOTO] & _O_STATE)

        CursorGet(&cursor)
        CursorOff()

        mov edi,tdllist
        mov esi,[edi].S_LOBJ.ll_count
        mov edi,[edi].S_LOBJ.ll_list
        .while esi

            free([edi])
            add edi,4
            dec esi
        .endw
        xor eax,eax
        mov edi,tdllist
        mov [edi].S_LOBJ.ll_celoff,eax
        mov [edi].S_LOBJ.ll_index,eax
        mov [edi].S_LOBJ.ll_numcel,eax
        mov [edi].S_LOBJ.ll_count,eax
        dlinit(ebx)
        mov ax,[ebx+4]
        add ax,0F03h
        mov dl,ah
        scputw(eax, edx, 11, 00C4h)
        progress_open(&cp_search, 0)
        mov eax,[ebx].S_TOBJ.to_data[OF_PATH]
        push eax
        progress_set(eax, 0, MAXHIT+2)
        ff_searchpath()
        progress_close()
        CursorSet(&cursor)
        mov eax,[edi].S_LOBJ.ll_count
        .if eax >= ID_FILE

            mov eax,ID_FILE
        .endif
        mov [edi].S_LOBJ.ll_numcel,eax
        update_cellid()
    .endif
    .if STDI.ios_size != 4096

        free(STDI.ios_bp)
    .endif
    memset(&STDI, 0, sizeof(S_IOST))
    ret
event_find endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ff_event_xcell proc
    ff_putcelid(addr cp_formatID)
    dlxcellevent()
    ret
ff_event_xcell endp

event_hexa:
    dlcheckevent()
    cmp eax,KEY_SPACE
    je  toggle_hex
    ret

event_toggle_format:
    mov eax,ffflag
    .if eax == OUTPUT_LINE
        mov eax,OUTPUT_BINARY
    .elseif eax
        mov eax,OUTPUT_LINE
    .else
        mov eax,OUTPUT_TEXT
    .endif
    mov ffflag,eax
    jmp event_list@

event_toggle_hex:
    mov eax,DLG_FindFile
    cmp [eax].S_DOBJ.dl_index,ID_FILE+2
    jne event_normal
    xor byte ptr [eax+OF_HEXA],_O_FLAGB

toggle_hex:
    mov eax,DLG_FindFile
    push [eax+OF_SSTR].S_TOBJ.to_data
    .if byte ptr [eax+OF_HEXA] & _O_FLAGB
        atohex()
    .else
        hextob()
    .endif
event_list@:
    event_list()
    mov eax,_C_NORMAL
    ret

event_help:
    view_readme(HELPID_10)
    ret

ff_event_edit proc
    ff_getcurfile()
    jz event_normal
    push eax
    dlhide(DLG_FindFile)
    pop eax
    tedit(eax, [eax-8])
    dlshow(DLG_FindFile)
    jmp event_normal
ff_event_edit endp

ff_event_exit proc
    mov eax,_C_ESCAPE
    ret
ff_event_exit endp

ff_event_view proc
    mov eax,DLG_FindFile
    cmp [eax].S_DOBJ.dl_index,ID_FILE
    jnb event_normal
    ff_getcurfile()
    jz  event_normal
    tview(eax, [eax-4]) ; .S_SBLK.sb_offs
ff_event_view endp

event_normal:
    mov eax,_C_NORMAL
    ret

ff_event_filter proc
    cmfilter()
    mov edx,DLG_FindFile
    mov dx,[edx+4]
    add dx,1410h
    mov cl,dh
    mov eax,filter
    test eax,eax
    mov eax,7
    .if ZERO?
        mov al,' '
    .endif
    scputw(edx, ecx, 1, eax)
    jmp event_normal
ff_event_filter endp

event_mklist proc private uses esi edi

    mov esi,tdllist
    xor eax,eax
    .if [esi].S_LOBJ.ll_count != eax

        .if mklistidd()

            xor edi,edi
            .while  edi < [esi].S_LOBJ.ll_count
                mov edx,[esi].S_LOBJ.ll_list
                mov edx,[edx+edi*4]
                mov eax,[edx]
                mov mklist.mkl_offspath,eax
                mov eax,[edx].S_SBLK.sb_offs
                mov mklist.mkl_offset,eax
                lea eax,[edx].S_SBLK.sb_file
                mklistadd()
                inc edi
            .endw
            _close(mklist.mkl_handle)
            mov eax,_C_NORMAL
        .endif
    .endif
    ret
event_mklist endp

event_list proc private uses esi edi ebx
    dlinit(DLG_FindFile)

    mov eax,DLG_FindFile
    movzx esi,[eax].S_DOBJ.dl_rect.rc_x
    add esi,4
    movzx edi,[eax].S_DOBJ.dl_rect.rc_y
    add edi,2
    mov eax,tdllist
    mov edx,[eax].S_LOBJ.ll_index
    shl edx,2
    add edx,[eax].S_LOBJ.ll_list
    mov ecx,[eax].S_LOBJ.ll_numcel

    .while ecx
        mov eax,[edx]
        add eax,[eax]
        add eax,S_FBLK.fb_name
        scpath(esi, edi, 25, eax)
        add eax,esi
        mov ebx,[edx]
        mov ebx,[ebx].S_SBLK.sb_line
        .if ebx

            inc ebx ; append (<line>) to filename
            scputf(eax, edi, 0, 7, addr cp_format_l, ebx)
        .endif

        push esi
        push ecx
        lea ebx,[esi+33]
        mov ecx,36
        mov esi,[edx]
        add esi,[esi].S_SBLK.sb_size
        sub esi,INFOSIZE
        .repeat
            lodsb
            .if ffflag == OUTPUT_LINE
                .break .if al == 10
                .break .if al == 13
            .endif
            .if ffflag && (al == 9 || al == 10 || al == 13)

                mov ah,al
                mov al,'\'
                scputc(ebx, edi, 1, eax)
                inc ebx
                mov al,'t'
                .if ah == 13

                    mov al,'n'
                .endif
                .if ah == 10

                    mov al,'r'
                .endif
                dec ecx
                .break .if ZERO?
            .endif
            .if al
                scputc(ebx, edi, 1, eax)
            .endif
            inc ebx
        .untilcxz
        pop ecx
        pop esi
        inc edi
        add edx,4
        dec ecx
    .endw
    mov eax,1
    ret
event_list endp

event_getpath proc

    .if GetPathFromHistory(cpanel)

        mov ecx,DLG_FindFile
        mov ecx,[ecx].S_TOBJ.to_data[OF_PATH]
        strcpy(ecx, [eax].S_DIRECTORY.path)
        dlinit(DLG_FindFile)
        mov eax,_C_NORMAL
    .endif
    ret

event_getpath endp

update_cellid:
    ff_putcelid(addr cp_formatID)
    event_list()

ff_update_cellid proc uses edi ebx

    mov ebx,DLG_FindFile
    mov edi,tdllist
    mov ecx,ID_FILE
    mov eax,_O_STATE
    .repeat
        add ebx,16
        or  [ebx],ax
    .untilcxz
    mov ebx,DLG_FindFile
    mov eax,not _O_STATE
    mov ecx,[edi].S_LOBJ.ll_numcel
    .while ecx
        add ebx,16
        and [ebx],ax
        dec ecx
    .endw
    mov eax,_C_NORMAL
    ret

ff_update_cellid endp

ff_deleteobj proc uses ebx

    ff_getcurobj()
    .if !ZERO?
        .repeat
            mov ecx,[edx+4]
            mov [edx],ecx
            add edx,4
        .until !ecx

        free(eax)
        mov ebx,tdllist
        dec [ebx].S_LOBJ.ll_count
        mov eax,[ebx].S_LOBJ.ll_count
        mov edx,[ebx].S_LOBJ.ll_index
        mov ecx,[ebx].S_LOBJ.ll_celoff
        .if ZERO?

            mov edx,eax
            mov ecx,eax
        .else
            .if edx

                mov ebx,eax
                sub ebx,edx
                .if ebx < ID_FILE
                    dec edx
                    inc ecx
                .endif
            .endif
            sub eax,edx
            .if eax >= ID_FILE

                mov eax,ID_FILE
            .endif
            .if ecx >= eax

                dec ecx
            .endif
        .endif
        mov ebx,tdllist
        mov [ebx].S_LOBJ.ll_index,edx
        mov [ebx].S_LOBJ.ll_celoff,ecx
        mov [ebx].S_LOBJ.ll_numcel,eax
        mov ebx,DLG_FindFile
        test eax,eax
        mov al,cl
        .if ZERO?
            mov al,ID_FILE
        .endif
        mov [ebx].S_DOBJ.dl_index,al
        mov eax,1
    .endif
    ret

ff_deleteobj endp

ff_event_delete:
    ff_deleteobj()
    update_cellid()
    mov eax,_C_NORMAL
    ret

ff_close proc uses esi edi

    mov edi,tdllist
    mov esi,[edi].S_LOBJ.ll_list
    .if esi
        mov edi,[edi].S_LOBJ.ll_count
        .while  edi
            lodsd
            free(eax)
            dec edi
        .endw
        mov edi,tdllist
        free([edi].S_LOBJ.ll_list)
    .endif
    ret

ff_close endp

ff_close_dlg proc

    mov byte ptr fsflag,ah
    movzx eax,[ebx].S_DOBJ.dl_index
    dlclose(ebx)

    .if edx == ID_GOTO

        mov ebx,tdllist
        .if [ebx].S_LOBJ.ll_count

            .if panel_state(cpanel)

                mov eax,[ebx].S_LOBJ.ll_index
                add eax,[ebx].S_LOBJ.ll_celoff
                mov ebx,[ebx].S_LOBJ.ll_list
                mov ebx,[ebx+eax*4]
                add ebx,S_SBLK.sb_file

                .if strrchr(ebx, '\')

                    mov byte ptr [eax],0
                    cpanel_setpath(ebx)
                .endif
            .endif
        .endif
    .endif
    ret
ff_close_dlg endp

ff_rsevent proc idd, find

    .repeat
        mov [edx],eax
        add edx,sizeof(S_TOBJ)
    .untilcxz
    dlshow(ebx)
    dlinit(ebx)

    mov filter,0
    .while rsevent(idd, ebx)

        mov esi,eax
        mov edi,ecx
        mov al,[ebx].S_DOBJ.dl_index
        .if al < ID_FILE

            .break .if ff_event_view() != _C_NORMAL
        .else
            .break .if al == ID_GOTO
            find()
        .endif
    .endw
    mov ah,byte ptr fsflag
    ret
ff_rsevent endp

FindFile proc uses esi edi ebx wspath

  local ll:S_LOBJ, cursor:S_CURSOR

    push    thelp
    mov     thelp,event_help
    xor     esi,esi     ; returned value

    lea     ebx,ll
    mov     tdllist,ebx
    mov     edi,ebx
    mov     ecx,sizeof(S_LOBJ)
    xor     eax,eax
    rep     stosb

    .repeat

        mov [ebx].S_LOBJ.ll_dcount,ID_FILE
        mov [ebx].S_LOBJ.ll_proc,event_list


        .if !malloc(MAXHIT*4+4)

            mov esi,-1
            ermsg(0, _sys_errlist[ENOMEM*4])
            .break
        .endif
        mov [ebx].S_LOBJ.ll_list,eax

        mov edi,eax
        mov ecx,MAXHIT * 4 + 4
        xor eax,eax
        rep stosb

        clrcmdl()
        CursorGet(addr cursor)
        .if !rsopen(IDD_DZFindFile)

            ff_close()
            mov esi,-1
            ermsg(0, _sys_errlist[ENOMEM*4])
            .break
        .endif

        mov DLG_FindFile,eax
        mov ebx,eax
        mov [ebx].S_TOBJ.to_data[OF_GCMD],offset GCMD_search
        lea eax,findfilemask
        mov [ebx].S_TOBJ.to_data[OF_MASK],eax
        .if byte ptr [eax] == 0

            strcpy(eax, addr cp_stdmask)
        .endif

        lea esi,searchstring
        mov [ebx].S_TOBJ.to_data[OF_SSTR],esi
        mov eax,wspath
        mov [ebx].S_TOBJ.to_data[OF_PATH],eax
        mov [ebx].S_TOBJ.to_proc[OF_HEXA],event_hexa
        mov [ebx].S_TOBJ.to_proc[OF_FIND],event_find
        mov [ebx].S_TOBJ.to_proc[OF_FILT],ff_event_filter
        mov [ebx].S_TOBJ.to_proc[OF_SAVE],event_mklist
        mov ah,byte ptr fsflag
        mov al,_O_FLAGB

        .if ah & IO_SEARCHCASE
            or [ebx+OF_CASE],al
        .endif
        .if ah & IO_SEARCHHEX
            or [ebx+OF_HEXA],al
        .endif
        .if ah & IO_SEARCHSUB
            or [ebx+OF_SUBD],al
        .endif

        lea edx,[ebx].S_TOBJ.to_proc[sizeof(S_TOBJ)]
        mov ecx,ID_FILE
        mov eax,ff_event_xcell

        ff_rsevent(IDD_DZFindFile, event_find)

        and ah,not (IO_SEARCHCASE or IO_SEARCHSUB or IO_SEARCHHEX)
        mov al,_O_FLAGB

        .if [ebx+OF_CASE] & al
            or ah,IO_SEARCHCASE
        .endif
        .if [ebx+OF_HEXA] & al
            or ah,IO_SEARCHHEX
        .endif
        .if [ebx+OF_SUBD] & al
            or ah,IO_SEARCHSUB
        .endif

        ff_close_dlg()
        ff_close()

    .until 1

    pop thelp
    CursorSet(&cursor)
    mov eax,esi     ; Exit code
    mov ecx,edi     ; Exit key
    ret

FindFile endp

cmsearch proc

    FindFile(&findfilepath)
    ret

cmsearch endp

    END
