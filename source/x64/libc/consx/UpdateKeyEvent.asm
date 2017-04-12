include consx.inc

SCROLLLOCK_ON		equ 40h
CAPSLOCK_ON		equ 80h
NUMLOCK_ON		equ 20h
ENHANCED_KEY		equ 100h
RIGHT_ALT_PRESSED	equ 1h
RIGHT_CTRL_PRESSED	equ 4h
SHIFT_PRESSED		equ 10h

	.code

	ASSUME	rbx:ptr INPUT_RECORD

UpdateKeyEvent PROC USES rsi rbx pInput:ptr INPUT_RECORD

	xor	esi,esi
	mov	rbx,pInput

	movzx	eax,[rbx].KeyEvent.wVirtualKeyCode
	mov	keybcode,al
	mov	al,byte ptr [rbx].KeyEvent.wVirtualScanCode
	mov	keybscan,al
	movzx	ecx,al
	mov	al,byte ptr [rbx].KeyEvent.AsciiChar
	mov	keybchar,al
	mov	rax,keyshift
	mov	edx,[rax]
	mov	eax,[rbx].KeyEvent.dwControlKeyState
	and	edx,not (SHIFT_SCROLL or SHIFT_NUMLOCK or SHIFT_CAPSLOCK \
			or SHIFT_ENHANCED or SHIFT_KEYSPRESSED)
	.if	eax & SHIFT_PRESSED
		or edx,SHIFT_KEYSPRESSED
	.else
		and edx,not (SHIFT_LEFT or SHIFT_RIGHT)
	.endif
	.if	eax & SCROLLLOCK_ON
		or edx,SHIFT_SCROLL
	.endif
	.if	eax & NUMLOCK_ON
		or edx,SHIFT_NUMLOCK
	.endif
	.if	eax & CAPSLOCK_ON
		or edx,SHIFT_CAPSLOCK
	.endif
	.if	eax & ENHANCED_KEY
		or edx,SHIFT_ENHANCED
	.endif

	xchg	edx,eax
	.if	[rbx].KeyEvent.bKeyDown

		mov	keybstate,1
		or	eax,SHIFT_RELEASEKEY
		.switch ecx
		  .case 2Ah
			.if	eax & SHIFT_KEYSPRESSED
				or eax,SHIFT_LEFT
			.endif
			.endc
		  .case 36h
			.if	eax & SHIFT_KEYSPRESSED
				or eax,SHIFT_RIGHT
			.endif
			.endc
		  .case 38h
			.if	edx & RIGHT_ALT_PRESSED
				or eax,SHIFT_ALT
			.else
				or eax,SHIFT_ALTLEFT or SHIFT_ALT
			.endif
			.endc
		  .case 1Dh
			.if	edx & RIGHT_CTRL_PRESSED
				or eax,SHIFT_CTRL
			.else
				or eax,SHIFT_CTRLLEFT or SHIFT_CTRL
			.endif
			.endc
		  .case 46h
			or	eax,SHIFT_SCROLLKEY
			.endc
		  .case 3Ah
			or	eax,SHIFT_CAPSLOCKKEY
			.endc
		  .case 45h
			or	eax,SHIFT_NUMLOCKKEY
			.endc
		  .case 57h
			mov	esi,8500h	; F11
			.endc
		  .case 58h
			mov	esi,8600h	; F12
			.endc
		  .default
			.if	cl == 52h && keybcode == 2Dh
				or  eax,SHIFT_INSERTKEY
				xor eax,SHIFT_INSERTSTATE
				mov esi,5200h
			.else
				mov dl,keybchar
				mov dh,cl
				and edx,0000FFFFh
				mov esi,edx
			.endif
		.endsw

	.else

		mov	keybstate,0
		and	eax,not SHIFT_RELEASEKEY
		.switch ecx
		  .case 2Ah
			.if	eax & SHIFT_KEYSPRESSED
				and eax,not SHIFT_LEFT
			.endif
			.endc
		  .case 36h
			.if	eax & SHIFT_KEYSPRESSED
				and eax,not SHIFT_RIGHT
			.endif
			.endc
		  .case 38h
			and	eax,not (SHIFT_ALT or SHIFT_ALTLEFT)
			.endc
		  .case 1Dh
			and	eax,not (SHIFT_CTRL or SHIFT_CTRLLEFT)
			.endc
		  .case 46h
			and	eax,not SHIFT_SCROLLKEY
			.endc
		  .case 3Ah
			and	eax,not SHIFT_CAPSLOCKKEY
			.endc
		  .case 45h
			and	eax,not SHIFT_NUMLOCKKEY
			.endc
		  .case 52h
			and	eax,not SHIFT_INSERTKEY
		.endsw
	.endif
	mov	rcx,keyshift
	mov	[rcx],eax
	mov	eax,esi
	ret
UpdateKeyEvent ENDP

	END
