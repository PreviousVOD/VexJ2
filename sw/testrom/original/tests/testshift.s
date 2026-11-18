/**************
 Initialization
 **************/
.global _testshift
_testshift:
 sts.l  pr, @-r15
 mov.l  _pfail, r13 !fail address
 bra    _testgo
 nop
_pfail: .long _fail
_testgo:

/************************
 SHLL Rn
 ************************/
 mov.l  _ptestvalue, r1
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 shll   r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 shal   r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 shlr   r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 shar   r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 rotl   r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 rotcl  r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 rotr   r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 rotcr  r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 shll2  r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 shll8  r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 shll16 r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 shlr2  r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 shlr8  r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop
!----
 mov.l  @r1+, r2 ! initial SR
 ldc    r2, sr
 mov.l  @r1+, r3 ! initial value
 shlr16 r3
 mov.l  @r1+, r4 ! result SR
 mov.l  @r1+, r5 ! result value
 stc    sr, r6
 cmp/eq r3, r5
 bt     .+6
 jmp    @r13
 nop
 cmp/eq r4, r6
 bt     .+6
 jmp    @r13
 nop

 mov.l _ppass_value, r3
 mov.l _ppass_addr, r4
 mov.l r3, @r4


        
!----
 bra    _pass
 nop
!----
 .align 4
_ptestvalue: .long _testvalue
_testvalue :
!----SHLL
 .long 0x00000000
 .long 0xaaaaaaab ! 1010....1011
 .long 0x00000001
 .long 0x55555556 ! 0101....0110
!----SHAL
 .long 0x00000001
 .long 0x55555557 ! 0101....0111
 .long 0x00000000
 .long 0xaaaaaaae ! 1010....1110
!----SHLR
 .long 0x00000001
 .long 0xeaaaaaaa ! 1110....1010
 .long 0x00000000
 .long 0x75555555 ! 0111....0101
!----SHAR
 .long 0x00000001
 .long 0xaaaaaaaa ! 1010....1010
 .long 0x00000000
 .long 0xd5555555 ! 1101....0101
!----ROTL
 .long 0x00000000
 .long 0xaaaaaaab ! 1010....1011
 .long 0x00000001
 .long 0x55555557 ! 0101....0111
!----ROTCL
 .long 0x00000000
 .long 0xaaaaaaab ! 1010....1011
 .long 0x00000001
 .long 0x55555556 ! 0101....0110
!----ROTR
 .long 0x00000000
 .long 0xd5555555 ! 1101....0101
 .long 0x00000001
 .long 0xeaaaaaaa ! 1110....1010
!----ROTCR
 .long 0x00000000
 .long 0xd5555555 ! 1101....0101
 .long 0x00000001
 .long 0x6aaaaaaa ! 0110....1010
!----SHLL2
 .long 0x00000001
 .long 0x12345678
 .long 0x00000001
 .long 0x48d159e0
!----SHLL8
 .long 0x00000001
 .long 0x12345678
 .long 0x00000001
 .long 0x34567800
!----SHLL16
 .long 0x00000001
 .long 0x12345678
 .long 0x00000001
 .long 0x56780000
!----SHLR2
 .long 0x00000000
 .long 0x12345678
 .long 0x00000000
 .long 0x048d159e
!----SHLR8
 .long 0x00000000
 .long 0x12345678
 .long 0x00000000
 .long 0x00123456
!----SHLR16
 .long 0x00000000
 .long 0x12345678
 .long 0x00000000
 .long 0x00001234
/**************
 Congratulations
 **************/
_pass:
 lds.l  @r15+, pr
 mov.l _ppass2_value, r0
 mov.l _ppass_addr, r1
 mov.l r0, @r1
 rts
 nop
.align 4
_ppass_addr: .long 0xFF000004
_ppass_value: .long 0x00000032
_ppass2_value: .long 0x00000033

/**********
 You Failed
 **********/
_fail:
 mov.l _pfail_value, r0
 mov.l _pfail_value, r1
 bra   _fail
 nop
.align 4
_pfail_value: .long 0x88888888

.end
