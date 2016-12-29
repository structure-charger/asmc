ifndef __LIBC_INC
 include libc.inc
endif

_MAX_PATH	equ 260
_MAX_DRIVE	equ 3
_MAX_DIR	equ 256
_MAX_FNAME	equ 256
_MAX_EXT	equ 256

.xlist

_getdrive	PROTO
_chdrive	PROTO :SINT
_chdir		PROTO :LPSTR
_mkdir		PROTO :LPSTR
_rmdir		PROTO :LPSTR
_getcwd		PROTO :LPSTR, :SINT
_getdcwd	PROTO :SINT, :LPSTR, :SINT
_wchdir		PROTO :LPWSTR
_wmkdir		PROTO :LPWSTR
_wrmdir		PROTO :LPWSTR
_wgetcwd	PROTO :LPWSTR, :SINT
_wgetdcwd	PROTO :SINT, :LPWSTR, :SINT

externdef	_diskflag:DWORD

;;;;;;;;;;;;;;; crtl

__allocwpath	PROTO :LPSTR

;;;;;;;;;;;;;;; kernel32.dll

SECURITY_ATTRIBUTES	STRUC SIZE_T
nLength			DWORD ?
lpSecurityDescriptor	SIZE_T ?
bInheritHandle		DWORD ?
SECURITY_ATTRIBUTES	ENDS
LPSECURITY_ATTRIBUTES	TYPEDEF PTR SECURITY_ATTRIBUTES

CP_ACP			equ 0
SEM_FAILCRITICALERRORS	equ 1

;UINT
SetErrorMode proto \
	uMode:		UINT
;DWORD
GetLogicalDrives proto
;int
MultiByteToWideChar proto \
	CodePage:	UINT,
	dwFlags:	DWORD,
	lpMultiByteStr: LPSTR,	; Pointer to the character string to convert
	cbMultiByte:	SINT,	; byte count of the lpMultiByteStr parameter
	lpWideCharStr:	LPWSTR, ; Pointer to a buffer that receives the converted string
	cchWideChar:	SINT	; character count of lpWideCharStr
;DWORD
GetShortPathNameA proto \
	lpszLongPath:	LPSTR,	; pointer to a null-terminated path string
	lpszShortPath:	LPSTR,	; pointer to a buffer to receive the
				; null-terminated short form of the path
	cchBuffer:	DWORD	; specifies the size of the buffer pointed
				; to by lpszShortPath
GetShortPathNameW proto \
	lpszLongPath:	LPWSTR,
	lpszShortPath:	LPWSTR,
	cchBuffer:	DWORD
;DWORD
GetFullPathNameA proto \
	lpFileName:	LPSTR,	; pointer to name of file to find path for
	nBufferLength:	DWORD,	; size, in characters, of path buffer
	lpBuffer:	LPSTR,	; pointer to path buffer
	lpFilePart:	LPSTR	; pointer to filename in path
GetFullPathNameW proto \
	lpFileName:	LPWSTR,
	nBufferLength:	DWORD,
	lpBuffer:	LPWSTR,
	lpFilePart:	LPWSTR
;BOOL
RemoveDirectoryA proto \
	lpPathName:	LPSTR	; pointer to directory to remove
RemoveDirectoryW proto \
	lpPathName:	LPWSTR
;BOOL
CreateDirectoryA proto \
	lpPathName:	LPSTR,	; pointer to directory path string
	lpSecurityAttributes:LPSECURITY_ATTRIBUTES
CreateDirectoryW proto \
	lpPathName:	LPWSTR,
	lpSecurityAttributes:LPSECURITY_ATTRIBUTES
;BOOL
SetCurrentDirectoryA proto \
	lpPathName:	LPSTR	; pointer to name of new current directory
SetCurrentDirectoryW proto \
	lpPathName:	LPWSTR
;DWORD
GetCurrentDirectoryA proto \
	nBufferLength:	DWORD,	; size, in characters, of directory buffer
	lpBuffer:	LPSTR	; pointer to buffer for current directory
GetCurrentDirectoryW proto \
	nBufferLength:	DWORD,
	lpBuffer:	LPWSTR
;UINT
GetDriveTypeA proto \
	lpRootPathName: LPSTR	; pointer to root path
GetDriveTypeW proto \
	lpRootPathName: LPWSTR
;BOOL
GetDiskFreeSpaceA proto \
	lpRootPathName:		LPSTR,	; pointer to root path
	lpSectorsPerCluster:	LPDWORD,; pointer to sectors per cluster
	lpBytesPerSector:	LPDWORD,; pointer to bytes per sector
	lpNumberOfFreeClusters: LPDWORD,; pointer to number of free clusters
	lpTotalNumberOfClusters:LPDWORD ; pointer to total number of clusters
GetDiskFreeSpaceW proto \
	lpRootPathName:		LPWSTR,
	lpSectorsPerCluster:	LPDWORD,
	lpBytesPerSector:	LPDWORD,
	lpNumberOfFreeClusters: LPDWORD,
	lpTotalNumberOfClusters:LPDWORD
;BOOL
GetDiskFreeSpaceExA proto \
	lpDirectoryName:	      LPSTR,	; pointer to the directory name
	lpFreeBytesAvailableToCaller: PTR QWORD,; receives the number of bytes on
						; disk available to the caller
	lpTotalNumberOfBytes:	      PTR QWORD,; receives the number of bytes on disk
	lpTotalNumberOfFreeBytes:     PTR QWORD ; receives the free bytes on disk
GetDiskFreeSpaceExW proto \
	lpDirectoryName:	      LPWSTR,
	lpFreeBytesAvailableToCaller: PTR QWORD,
	lpTotalNumberOfBytes:	      PTR QWORD,
	lpTotalNumberOfFreeBytes:     PTR QWORD
;BOOL
GetVolumeInformationA proto \
	lpRootPathName:		LPSTR,	; address of root directory of the file system
	lpVolumeNameBuffer:	LPSTR,	; address of name of the volume
	nVolumeNameSize:	DWORD,	; length of lpVolumeNameBuffer
	lpVolumeSerialNumber:	LPDWORD,; address of volume serial number
	lpMaximumComponentLength:LPDWORD,; address of system's maximum filename length
	lpFileSystemFlags:	LPDWORD,; address of file system flags
	lpFileSystemNameBuffer: LPSTR,	; address of name of file system
	nFileSystemNameSize:	DWORD	; length of lpFileSystemNameBuffer
GetVolumeInformationW proto \
	lpRootPathName:		LPWSTR, ; address of root directory of the file system
	lpVolumeNameBuffer:	LPWSTR, ; address of name of the volume
	nVolumeNameSize:	DWORD,	; length of lpVolumeNameBuffer
	lpVolumeSerialNumber:	LPDWORD,; address of volume serial number
	lpMaximumComponentLength:LPDWORD,; address of system's maximum filename length
	lpFileSystemFlags:	LPDWORD,; address of file system flags
	lpFileSystemNameBuffer: LPWSTR, ; address of name of file system
	nFileSystemNameSize:	DWORD	; length of lpFileSystemNameBuffer

ifdef __UNICODE__
 GetShortPathName	equ <GetShortPathNameW>
 GetCurrentDirectory	equ <GetCurrentDirectoryW>
 SetCurrentDirectory	equ <SetCurrentDirectoryW>
 GetFullPathName	equ <GetFullPathNameW>
 CreateDirectory	equ <CreateDirectoryW>
 RemoveDirectory	equ <RemoveDirectoryW>
 GetDriveType		equ <GetDriveTypeW>
 GetDiskFreeSpace	equ <GetDiskFreeSpaceW>
 GetDiskFreeSpaceEx	equ <GetDiskFreeSpaceExW>
 GetVolumeInformation	equ <GetVolumeInformationW>
else
 GetShortPathName	equ <GetShortPathNameA>
 GetCurrentDirectory	equ <GetCurrentDirectoryA>
 SetCurrentDirectory	equ <SetCurrentDirectoryA>
 GetFullPathName	equ <GetFullPathNameA>
 CreateDirectory	equ <CreateDirectoryA>
 RemoveDirectory	equ <RemoveDirectoryA>
 GetDriveType		equ <GetDriveTypeA>
 GetDiskFreeSpace	equ <GetDiskFreeSpaceA>
 GetDiskFreeSpaceEx	equ <GetDiskFreeSpaceExA>
 GetVolumeInformation	equ <GetVolumeInformationA>
endif

.list