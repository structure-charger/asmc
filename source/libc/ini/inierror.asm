include consx.inc

	.data
	cp_badentry	db "Bad or missing Entry in DZ.INI",0
	cp_badentrymsg	db "Section: [%s]",10,"Entry: [%s]",10,0

	.code

inierror PROC section, entry
	ermsg( addr cp_badentry, addr cp_badentrymsg, section, entry )
	ret
inierror ENDP

	END
