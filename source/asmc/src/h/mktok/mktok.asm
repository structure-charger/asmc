	.486
	.model flat
	.code

	enumval = 1

res	macro tok, string, type, value, bytval, flags, cpu, sflags
%	echo @CatStr(@CatStr(@CatStr(<T_>,@SubStr(<tok>,2)),<	equ >),%enumval)
	enumval = enumval + 1
	endm

insa	macro tok, string, opcls, byte1_info, op_dir, rm_info, opcode, rm_byte, cpu, prefix
%	echo @CatStr(@CatStr(@CatStr(<T_>,@SubStr(<tok>,2)),<	equ >),%enumval)
	enumval = enumval + 1
	endm

insx	macro tok, string, opcls, byte1_info, op_dir, rm_info, opcode, rm_byte, cpu, prefix, flgs
%	echo @CatStr(@CatStr(@CatStr(<T_>,@SubStr(<tok>,2)),<	equ >),%enumval)
	enumval = enumval + 1
	endm

insn	macro tok, suffix, opcls, byte1_info, op_dir, rm_info, opcode, rm_byte, cpu, prefix
	endm

insm	macro tok, suffix, opcls, byte1_info, op_dir, rm_info, opcode, rm_byte, cpu, prefix
	endm

avxins	macro tok, string, cpu, flgs
%	echo @CatStr(@CatStr(@CatStr(<T_V>,@SubStr(<tok>,2)),<	equ >),%enumval)
	enumval = enumval + 1
	endm

OpCls	macro op1, op2, op3
	exitm<OPC_&op1&&op2&&op3&>
	endm

	echo TITLE TOKEN.INC -- Auto made from mktok.asm
	echo .xlist
	echo
	echo TOK_DEFAULT		equ 0
	echo TOK_RESCAN		equ 1
	echo TOK_NOCURLBRACES	equ 2
	echo TOK_LINE		equ 4
	echo ;
	echo T_NULL	equ 0
	echo ;
include ..\special.h
	echo ;
include ..\directve.h
%	echo SPECIAL_LAST	equ @CatStr(%enumval)
	echo ;
include instruct.inc
	echo ;
	echo VEX_START	equ T_VBROADCASTSS ; first VEX encoded item
	echo ;
include ..\instravx.h
	echo .list

	end
