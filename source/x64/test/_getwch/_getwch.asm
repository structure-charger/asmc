include conio.inc
include ctype.inc

	.code

main	proc

	_cputws( "Type 'Y' when finished typing keys: " )

	.repeat

		_getwch()
		toupper( eax  )

	.until	al == 'Y'

	_putwch( eax )	;
	_putwch( 13 )	; Carriage return
	_putwch( 10 )	; Line feed

	xor	eax,eax
	ret

main	endp

	END	main
