include stdio.inc

	.code

fprintf PROC USES rbx file:LPFILE, format:LPSTR, argptr:VARARG
	_stbuf( rcx )
	mov	rbx,rax
	_output( file, format, addr argptr )
	xchg	rax,rbx
	_ftbuf( eax, file )
	mov	rax,rbx
	ret
fprintf ENDP

	END
