/*
 *  unistd.h
 *
 * =========================================================================
 *
 *			    Open Watcom Project
 *
 *    Copyright (c) 2002-2010 Open Watcom Contributors. All Rights Reserved.
 *    Portions Copyright (c) 1983-2002 Sybase, Inc. All Rights Reserved.
 *
 *    This file is automatically generated. Do not edit directly.
 *
 * =========================================================================
 */
#ifndef _UNISTD_H_INCLUDED
#define _UNISTD_H_INCLUDED

#ifndef _ENABLE_AUTODEPEND
 #if defined(__WATCOMC__)
  #pragma read_only_file;
 #endif
#endif

#ifndef __COMDEF_H_INCLUDED
 #include <_comdef.h>
#endif

#ifndef _IO_H_INCLUDED
 #include <io.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__OS2__) && defined(__386__) && defined(__TCPIP_HEADERS)
 #include <tcpustd.h>  /* unistd.h conflicts with OS/2 TCP/IP headers */
#endif

_WCRTLINK extern int	chdir( const char *__path );
/* the following are also in process.h, but they are expected to be here */
_WCRTLINK extern int	execl( const char *__path, const char *__arg0, ... );
_WCRTLINK extern int	execle( const char *__path, const char *__arg0, ... );
_WCRTLINK extern int	execlp( const char *__file, const char *__arg0, ... );
_WCRTLINK extern int	execv( const char *__path, const char *const __argv[] );
_WCRTLINK extern int	execve( const char *__path, const char *const __argv[], const char *const __envp[] );
_WCRTLINK extern int	execvp( const char *__file, const char *const __argv[] );

#ifndef _SIZE_T_DEFINED
typedef unsigned int size_t;
#define _SIZE_T_DEFINED
#endif

_WCRTLINK extern char	*getcwd( char *__buf, size_t __size );
_WCRTLINK extern char	*_getcwd( char *__buf, size_t __size );
_WCRTLINK extern int	getopt( int __argc, char * const __argv[], const char *__optstring );
_WCRTLINK extern int	getpid( void );
_WCRTLINK extern int	rmdir( const char *__path );
_WCRTLINK extern unsigned int sleep( unsigned int __seconds );
_WCRTLINK extern int	usleep( unsigned long __usec );

/* Globals used and set by getopt() */
_WCRTDATA extern char	*optarg;
_WCRTDATA extern int	optind;
_WCRTDATA extern int	opterr;
_WCRTDATA extern int	optopt;

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif
