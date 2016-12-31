	.486
	.model	flat, stdcall

public _U8LD
public _I8LD

	.code
	;
	; SQWORD [eax] to long double[edx]
	;
_I8LD:

_s8told PROC
	push	ecx
	xor	ecx,ecx
	jmp	L8TOLD
_s8told ENDP
	;
	; QWORD [eax] to long double[edx]
	;
_U8LD:

_u8told PROC
	push	ecx
	or	ecx,1
_u8told ENDP

L8TOLD:
	push	ebx
	mov	ebx,edx
	mov	edx,[eax+4]
	mov	eax,[eax]
	test	ecx,ecx
	mov	ecx,0000403Eh ; 16446
	jnz	@F
	or	edx,edx
	jns	@F
	neg	edx
	neg	eax
	sbb	edx,0
	or	ecx,0FFFF8000h
@@:
	test	edx,edx
	jnz	@F
	sub	ecx,32
	or	edx,eax
	mov	eax,0
	jnz	@F
	mov	ecx,eax
	jmp	toend
@@:
	js	toend
@@:
	dec	ecx
	shld	edx,eax,1
	shl	eax,1
	jns	@B
toend:
	mov	[ebx],eax
	mov	[ebx+4],edx
	mov	[ebx+8],cx
	pop	ebx
	pop	ecx
	ret

	END