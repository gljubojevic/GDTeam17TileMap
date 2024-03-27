;
; sourcecode to decrunch data crunched using BeerMon's 'imp' command.
;
; explode:
;
; The decompressed data will be located in the memory region beginning
; with the supplied start address.
;
; in:	a0.l	address of imploded data
;
; out:	d0.l	0:error
;		-1:no error

;ImploderID	= 'IMP!'
ImploderID	= 'ATN!'

explode:movem.l	d2-d5/a2-a4,-(sp)
	move.l	a0,a3
	move.l	a0,a4
	cmp.l	#ImploderID,(a0)+
	bne.b	ex05
	add.l	(a0)+,a4
	add.l	(a0)+,a3
	move.l	a3,a2
	move.l	(a2)+,-(a0)
	move.l	(a2)+,-(a0)
	move.l	(a2)+,-(a0)
	move.l	(a2)+,d2
	move.w	(a2)+,d3
	bmi.b	ex00
	subq.l	#1,a3
ex00:	lea	-28(sp),sp
	move.l	sp,a1
	moveq	#6,d0
ex01:	move.l	(a2)+,(a1)+
	dbf	d0,ex01
	move.l	sp,a1
	moveq	#0,d4
ex02:	tst.l	d2
	beq.b	ex04
ex03:	move.b	-(a3),-(a4)
	subq.l	#1,d2
	bne.b	ex03
ex04:	cmp.l	a4,a0
	blo.b	ex07
	lea	28(sp),sp
	moveq	#-1,d0
	cmp.l	a3,a0
	beq.b	ex06
ex05:	moveq	#0,d0
ex06:	movem.l	(sp)+,d2-d5/a2-a4
	tst.l	d0
	rts
ex07:	add.b	d3,d3
	bne.b	ex08
	move.b	-(a3),d3
	addx.b	d3,d3
ex08:	bcc.b	ex20
	add.b	d3,d3
	bne.b	ex09
	move.b	-(a3),d3
	addx.b	d3,d3
ex09:	bcc.b	ex19
	add.b	d3,d3
	bne.b	ex10
	move.b	-(a3),d3
	addx.b	d3,d3
ex10:	bcc.b	ex18
	add.b	d3,d3
	bne.b	ex11
	move.b	-(a3),d3
	addx.b	d3,d3
ex11:	bcc.b	ex17
	add.b	d3,d3
	bne.b	ex12
	move.b	-(a3),d3
	addx.b	d3,d3
ex12:	bcc.b	ex13
	move.b	-(a3),d4
	moveq	#3,d0
	bra.b	ex21
ex13:	add.b	d3,d3
	bne.b	ex14
	move.b	-(a3),d3
	addx.b	d3,d3
ex14:	addx.b	d4,d4
	add.b	d3,d3
	bne.b	ex15
	move.b	-(a3),d3
	addx.b	d3,d3
ex15:	addx.b	d4,d4
	add.b	d3,d3
	bne.b	ex16
	move.b	-(a3),d3
	addx.b	d3,d3
ex16:	addx.b	d4,d4
	addq.b	#6,d4
	moveq	#3,d0
	bra.b	ex21
ex17:	moveq	#5,d4
	moveq	#3,d0
	bra.b	ex21
ex18:	moveq	#4,d4
	moveq	#2,d0
	bra.b	ex21
ex19:	moveq	#3,d4
	moveq	#1,d0
	bra.b	ex21
ex20:	moveq	#2,d4
	moveq	#0,d0
ex21:	moveq	#0,d5
	move.w	d0,d1
	add.b	d3,d3
	bne.b	ex22
	move.b	-(a3),d3
	addx.b	d3,d3
ex22:	bcc.b	ex25
	add.b	d3,d3
	bne.b	ex23
	move.b	-(a3),d3
	addx.b	d3,d3
ex23:	bcc.b	ex24
	move.b	extab0(pc,d0.w),d5
	addq.b	#8,d0
	bra.b	ex25
ex24:	moveq	#2,d5
	addq.b	#4,d0
ex25:	move.b	extab1(pc,d0.w),d0
ex26:	add.b	d3,d3
	bne.b	ex27
	move.b	-(a3),d3
	addx.b	d3,d3
ex27:	addx.w	d2,d2
	subq.b	#1,d0
	bne.b	ex26
	add.w	d5,d2
	moveq	#0,d5
	move.l	d5,a2
	move.w	d1,d0
	add.b	d3,d3
	bne.b	ex28
	move.b	-(a3),d3
	addx.b	d3,d3
ex28:	bcc.b	ex31
	add.w	d1,d1
	add.b	d3,d3
	bne.b	ex29
	move.b	-(a3),d3
	addx.b	d3,d3
ex29:	bcc.b	ex30
	move.w	8(a1,d1.w),a2
	addq.b	#8,d0
	bra.b	ex31
ex30:	move.w	0(a1,d1.w),a2
	addq.b	#4,d0
ex31:	move.b	$10(a1,d0.w),d0
ex32:	add.b	d3,d3
	bne.b	ex33
	move.b	-(a3),d3
	addx.b	d3,d3
ex33:	addx.l	d5,d5
	subq.b	#1,d0
	bne.b	ex32
	addq.w	#1,a2
	add.l	d5,a2
	add.l	a4,a2
ex34:	move.b	-(a2),-(a4)
	subq.b	#1,d4
	bne.b	ex34
	bra	ex02
extab0:	dc.l	$60A0A12
extab1:	dc.l	$1010101,$2030304,$405070E
