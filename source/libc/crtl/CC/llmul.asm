	.486
	.model	flat, stdcall

public	_allmul
public	__llmul ; PellesC
_mul64	proto

	.code

__llmul:
_allmul:
	push	ebx
	mov	eax,4[esp+4]
	mov	edx,4[esp+8]
	mov	ebx,4[esp+12]
	mov	ecx,4[esp+16]
	call	_mul64
	pop	ebx
	ret	16

	END
