include process.inc
include string.inc
include cfini.inc

	.code

CFExecute PROC USES esi __ini:PCFINI

  local cmd[256]:byte

	xor	esi,esi

	.while	CFGetEntryID( __ini, esi )

		mov	edx,eax
		system( strcpy( addr cmd, edx ) )
		inc	esi
	.endw

	ret

CFExecute ENDP

	END