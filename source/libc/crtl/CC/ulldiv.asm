	.486
	.model	flat, c

PUBLIC	_aulldiv
_U8D	proto

	.code

_aulldiv:
	push	ebx
	mov	eax,4[esp+4]
	mov	edx,4[esp+8]
	mov	ebx,4[esp+12]
	mov	ecx,4[esp+16]
	call	_U8D
	pop	ebx
	ret	16

	END
