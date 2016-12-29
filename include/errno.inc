ifndef __LIBC_INC
 include libc.inc
endif

.xlist

ENOERR		equ 0
EPERM		equ 1
ENOENT		equ 2
ESRCH		equ 3
EINTR		equ 4
EIO		equ 5
ENXIO		equ 6
E2BIG		equ 7
ENOEXEC		equ 8
EBADF		equ 9
ECHILD		equ 10
EAGAIN		equ 11
ENOMEM		equ 12
EACCES		equ 13
EFAULT		equ 14
ENOTBLK		equ 15
EBUSY		equ 16
EEXIST		equ 17
EXDEV		equ 18
ENODEV		equ 19
ENOTDIR		equ 20
EISDIR		equ 21
EINVAL		equ 22
ENFILE		equ 23
EMFILE		equ 24
ENOTTY		equ 25
ETXTBSY		equ 26
EFBIG		equ 27
ENOSPC		equ 28
ESPIPE		equ 29
EROFS		equ 30
EMLINK		equ 31
EPIPE		equ 32
EDOM		equ 33
ERANGE		equ 34
EUCLEAN		equ 35
EDEADLK		equ 36
EUNKNOWN	equ 37
ENAMETOOLONG	equ 38
ENOLCK		equ 39
ENOSYS		equ 40
ENOTEMPTY	equ 41
EILSEQ		equ 42

externdef	errno:dword
externdef	oserrno:dword
externdef	sys_errlist:size_t

osmaperr	proto

;;;;;;;;;;;;;;; kernel32.dll

GetLastError	proto

ERROR_INVALID_FUNCTION		equ 1
ERROR_FILE_NOT_FOUND		equ 2
ERROR_PATH_NOT_FOUND		equ 3
ERROR_TOO_MANY_OPEN_FILES	equ 4
ERROR_ACCESS_DENIED		equ 5
ERROR_INVALID_HANDLE		equ 6
ERROR_ARENA_TRASHED		equ 7
ERROR_NOT_ENOUGH_MEMORY		equ 8
ERROR_INVALID_BLOCK		equ 9
ERROR_BAD_ENVIRONMENT		equ 10
ERROR_BAD_FORMAT		equ 11
ERROR_INVALID_ACCESS		equ 12
ERROR_INVALID_DATA		equ 13
ERROR_INVALID_DRIVE		equ 15
ERROR_CURRENT_DIRECTORY		equ 16
ERROR_NOT_SAME_DEVICE		equ 17
ERROR_NO_MORE_FILES		equ 18
ERROR_WRITE_PROTECT		equ 19
ERROR_NOT_ENOUGH_QUOTA		equ 24
ERROR_LOCK_VIOLATION		equ 33
ERROR_SHARINGBUF_EXCEEDED	equ 36
ERROR_BAD_NETPATH		equ 53
ERROR_NETWORK_ACCESS_DENIED	equ 65
ERROR_BAD_NET_NAME		equ 67
ERROR_FILE_EXISTS		equ 80
ERROR_CANNOT_MAKE		equ 82
ERROR_FAIL_I24			equ 83
ERROR_INVALID_PARAMETER		equ 87
ERROR_NO_PROC_SLOTS		equ 89
ERROR_DRIVE_LOCKED		equ 108
ERROR_BROKEN_PIPE		equ 109
ERROR_DISK_FULL			equ 112
ERROR_INVALID_TARGET_HANDLE	equ 114
ERROR_INVALID_LEVEL		equ 124
ERROR_WAIT_NO_CHILDREN		equ 128
ERROR_CHILD_NOT_COMPLETE	equ 129
ERROR_DIRECT_ACCESS_HANDLE	equ 130
ERROR_NEGATIVE_SEEK		equ 131
ERROR_SEEK_ON_DEVICE		equ 132
ERROR_DIR_NOT_EMPTY		equ 145
ERROR_NOT_LOCKED		equ 158
ERROR_BAD_PATHNAME		equ 161
ERROR_MAX_THRDS_REACHED		equ 164
ERROR_LOCK_FAILED		equ 167
ERROR_ALREADY_EXISTS		equ 183
ERROR_INVALID_CODESEG		equ 188
ERROR_LOOP_IN_RELOC_CHAIN	equ 202
ERROR_FILENAME_EXCED_RANGE	equ 206
ERROR_NESTING_NOT_ALLOWED	equ 215

.list