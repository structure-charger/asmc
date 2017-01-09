include errno.inc

	.data

errnotable	db EINVAL
		db ENOENT
		db ENOENT
		db EMFILE
		db EACCES
		db EBADF
		db ENOMEM
		db ENOMEM
		db ENOMEM
		db E2BIG
		db ENOEXEC
		db EINVAL
		db EINVAL
		db ENOENT
		db EACCES
		db EXDEV
		db ENOENT
		db EACCES
		db ENOENT
		db EACCES
		db ENOENT
		db EEXIST
		db EACCES
		db EACCES
		db EINVAL
		db EAGAIN
		db EACCES
		db EPIPE
		db ENOSPC
		db EBADF
		db EINVAL
		db ECHILD
		db ECHILD
		db EBADF
		db EINVAL
		db EACCES
		db ENOTEMPTY
		db EACCES
		db ENOENT
		db EAGAIN
		db EACCES
		db EEXIST
		db ENOENT
		db EAGAIN
		db ENOMEM

syserrtable	db ERROR_INVALID_FUNCTION
		db ERROR_FILE_NOT_FOUND
		db ERROR_PATH_NOT_FOUND
		db ERROR_TOO_MANY_OPEN_FILES
		db ERROR_ACCESS_DENIED
		db ERROR_INVALID_HANDLE
		db ERROR_ARENA_TRASHED
		db ERROR_NOT_ENOUGH_MEMORY
		db ERROR_INVALID_BLOCK
		db ERROR_BAD_ENVIRONMENT
		db ERROR_BAD_FORMAT
		db ERROR_INVALID_ACCESS
		db ERROR_INVALID_DATA
		db ERROR_INVALID_DRIVE
		db ERROR_CURRENT_DIRECTORY
		db ERROR_NOT_SAME_DEVICE
		db ERROR_NO_MORE_FILES
		db ERROR_LOCK_VIOLATION
		db ERROR_BAD_NETPATH
		db ERROR_NETWORK_ACCESS_DENIED
		db ERROR_BAD_NET_NAME
		db ERROR_FILE_EXISTS
		db ERROR_CANNOT_MAKE
		db ERROR_FAIL_I24
		db ERROR_INVALID_PARAMETER
		db ERROR_NO_PROC_SLOTS
		db ERROR_DRIVE_LOCKED
		db ERROR_BROKEN_PIPE
		db ERROR_DISK_FULL
		db ERROR_INVALID_TARGET_HANDLE
		db ERROR_INVALID_HANDLE
		db ERROR_WAIT_NO_CHILDREN
		db ERROR_CHILD_NOT_COMPLETE
		db ERROR_DIRECT_ACCESS_HANDLE
		db ERROR_NEGATIVE_SEEK
		db ERROR_SEEK_ON_DEVICE
		db ERROR_DIR_NOT_EMPTY
		db ERROR_NOT_LOCKED
		db ERROR_BAD_PATHNAME
		db ERROR_MAX_THRDS_REACHED
		db ERROR_LOCK_FAILED
		db ERROR_ALREADY_EXISTS
		db ERROR_FILENAME_EXCED_RANGE
		db ERROR_NESTING_NOT_ALLOWED
		db ERROR_NOT_ENOUGH_QUOTA

	.code

	OPTION	PROLOGUE:NONE, EPILOGUE:NONE

osmaperr PROC

	call	GetLastError

	mov	rdx,rax
	mov	oserrno,eax
	xor	rcx,rcx
	mov	rax,-1
	lea	r8,syserrtable
	lea	r9,errnotable

	.while	SDWORD PTR ecx < 45
		.if	dl == [r8+rcx]
			movzx	ecx,BYTE PTR [r9+rcx]
			mov	errno,ecx
			ret
		.endif
		inc	ecx
	.endw

	.if	edx >= ERROR_WRITE_PROTECT && edx <= ERROR_SHARINGBUF_EXCEEDED
		mov	errno,EACCES
	.elseif edx >= ERROR_INVALID_CODESEG && edx <= ERROR_LOOP_IN_RELOC_CHAIN
		mov	errno,ENOEXEC
	.else
		mov	errno,EINVAL
	.endif
	ret
osmaperr ENDP

	END