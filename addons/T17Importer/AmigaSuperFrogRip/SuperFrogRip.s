xplode:	MACRO
	lea	\1,a0
	bsr.w	explode
	ENDM

tpic:	MACRO
	lea	\1,a0
	bsr.w	explode
	lea	\1,a0
	bsr.w	tiles_to_pic
	ENDM

	INCDIR 	"Sources:Source7/superfrog/"

Start:
;	xplode 	HERO	;Superfrog sprites 320x384x4
;	xplode 	HPIC	;Hi Score 320x288x5
;	xplode 	MPIC	;Superfrog title image 320x256x6 (ehb no palette) 
;	xplode 	MUSC	;Music
;	xplode	END1	;End Anim 1 320x256x5
;	xplode	END2	;End Anim 2 320x256x5
;	xplode	AWA1	;Help screen 1 320x256x5
;	xplode	AWA2	;Help screen 2 320x256x5

;	xplode 	L1MA1	;Tilemap 1
;	xplode 	L1MA2	;Tilemap 2
;	xplode 	L1MA3	;Tilemap 3
;	xplode 	L1MA4	;Tilemap 4
;	tpic 	L1BM	;Tiles for tilemap 320x672x5
;	xplode 	L1BO	;Bobs for game 320x320x5
;	xplode 	L1MU	;Music PT4.1A
;	xplode 	L1LP	;Loading 320x352x5, palette 32 colors, unknown data
;	xplode 	L1ET	;End title 320x256x5, palette 32 colors
;	xplode 	L1FX	;SoundFx unknown format, all worlds
	xplode 	L1MS	;Tile masks 320x672x1

;	xplode 	L2MA1
;	xplode 	L2MA2
;	xplode 	L2MA3
;	xplode 	L2MA4
;	tpic	L2BM
;	xplode 	L2BO
;	xplode 	L2MU
;	xplode 	L2LP
;	xplode 	L2ET

;	xplode 	L3MA1
;	xplode 	L3MA2
;	xplode 	L3MA3
;	xplode 	L3MA4
;	tpic	L3BM
;	xplode 	L3BO
;	xplode 	L3MU
;	xplode 	L3LP
;	xplode 	L3ET

;	xplode 	L4MA1
;	xplode 	L4MA2
;	xplode 	L4MA3
;	xplode 	L4MA4
;	tpic	L4BM
;	xplode 	L4BO
;	xplode 	L4MU
;	xplode 	L4LP
;	xplode 	L4ET

;	xplode 	L5MA1
;	xplode 	L5MA2
;	xplode 	L5MA3
;	xplode 	L5MA4
;	tpic	L5BM
;	xplode 	L5BO
;	xplode 	L5MU
;	xplode 	L5LP
;	xplode 	L5ET

;	xplode 	L6MA1
;	xplode 	L6MA2
;	xplode 	L6MA3
;	xplode 	L6MA4
;	tpic	L6BM
;	xplode 	L6BO
;	xplode 	L6MU
;	xplode 	L6LP
;	xplode 	L6ET

;	xplode 	LBMA
;	tpic	LBBM
;	xplode 	LBBO
;	xplode 	LBMU
;	xplode 	LBLP
;	xplode 	LBFX	;SoundFx special

;	xplode 	LWMA1
;	tpic	LWBM
;	xplode 	LWBO

	rts

	INCLUDE	"Explode.s"

;a0 - original tiles address e.g
;tiles should be
;	320x672 on image (20x42 tiles)
;	5 bitplanes (32 colors)
;----------------------------------------------
tiles_to_pic:
	lea	TImg,a1			;Tiles image
	move.w	#840-1,d0		;840 tiles
	moveq	#20,d1			;20 per line
	move.l	d1,d5
	move.w	#40*5,d6		;line size 320/8*5 bitmaps
tile_copy:
	moveq	#0,d7			;bitmap offset
	moveq	#5-1,d2			;5 biplanes
tile_nextbm:
	move.l	d7,d4			;line offset
	moveq	#16-1,d3		;16px height
tile_line:
	move.w	(a0)+,(a1,d4.w)		;copy tile line
	add.w	d6,d4			;next line offset
	dbf	d3,tile_line
	add.w	#40,d7			;next bitmap 320/8
	dbf	d2,tile_nextbm
	addq.l	#2,a1			;next tile in row address
	subq.l	#1,d1			;count tile in row
	bne.s	tile_samerow
	move.l	d5,d1			;Next line of tiles
	lea	40*16*5-40(a1),a1	;Address of next tiles line
tile_samerow:
	dbf	d0,tile_copy
	rts

TImg:	dcb.b	$20d00,0
TImg_E:	dc.b	"END!"


;SuperFrog files only one at time
;HERO:	dcb.b	$F000,0		;320x384x4
;HERO_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/HERO\HERO\HERO_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/HERO\HERO\HERO_E\

;HPIC:	dcb.b	$e140,0		;320x288x5
;HPIC_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/HPIC\HPIC\HPIC_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/HPIC\HPIC\HPIC_E-64\
;	AUTO WB Sources:Sources7/superfrog/data/HPIC.pal\HPIC_E-64\HPIC_E\

;MPIC:	dcb.b	$F000,0		;320x288x6 (ehb no palette)
;MPIC_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/MPIC\MPIC\MPIC_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/MPIC\MPIC\MPIC_E\

;MUSC:	dcb.b	$ec1e,0		;music
;MUSC_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/MUSC\MUSC\MUSC_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/MUSC.mod\MUSC\MUSC_E\

;END1:	dcb.b	$3c56a,0	;End anim 1 320x256x5
;END1_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/END1\END1\END1_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/END1.anim\END1\END1_E\

;END2:	dcb.b	$1e868,0	;End anim 2 320x256x5
;END2_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/END2\END2\END2_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/END2.anim\END2\END2_E\

;AWA1:	dcb.b	$C840,0		;320x256x5 help pic 1
;AWA1_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/AWA1\AWA1\AWA1_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/AWA1\AWA1\AWA1_E-64\
;	AUTO WB Sources:Sources7/superfrog/data/AWA1.pal\AWA1_E-64\AWA1_E\

;AWA2:	dcb.b	$C840,0		;320x256x5 help pic 2
;AWA2_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/AWA2\AWA2\AWA2_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/AWA2\AWA2\AWA2_E-64\
;	AUTO WB Sources:Sources7/superfrog/data/AWA2.pal\AWA2_E-64\AWA2_E\


;Level 1 ----------------------------------------
;L1MA1:	dcb.b	$d154,0
;L1MA1_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L1MA1\L1MA1\L1MA1_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L1MA1\L1MA1\L1MA1_E\
;	AUTO WB Sources:Sources7/superfrog/data/L1MA1.pal\L1MA1+312\L1MA1+376\
;Hero palete
;	AUTO WB Sources:Sources7/superfrog/data/HERO.pal\L1MA1+344\L1MA1+376\

;L1MA2:	dcb.b	$d154,0
;L1MA2_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L1MA2\L1MA2\L1MA2_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L1MA2\L1MA2\L1MA2_E\

;L1MA3:	dcb.b	$d154,0
;L1MA3_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L1MA3\L1MA3\L1MA3_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L1MA3\L1MA3\L1MA3_E\

;L1MA4:	dcb.b	$d154,0
;L1MA4_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L1MA4\L1MA4\L1MA4_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L1MA4\L1MA4\L1MA4_E\

;L1BM:	dcb.b	$20d00,0	;320x672x5
;L1BM_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L1BM\L1BM\L1BM_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L1BM\TImg\TImg_E\

;L1BO:	dcb.b	$fa00,0		;320x320x5
;L1BO_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L1BO\L1BO\L1BO_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L1BO\L1BO\L1BO_E\

;L1MU:	dcb.b	$9e42,0		;music
;L1MU_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L1MU\L1MU\L1MU_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L1MU.mod\L1MU\L1MU_E\

;L1LP:	dcb.b	$115e0,0	;320x352x5, palette 32 colors, unknown data
;L1LP_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L1LP\L1LP\L1LP_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L1LP\L1LP\L1LP+70400\
;	AUTO WB Sources:Sources7/superfrog/data/L1LP.pal\L1LP+70400\L1LP+70400+64\

;L1ET:	dcb.b	$C840,0	;320x352x5, palette 32 colors
;L1ET_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L1ET\L1ET\L1ET_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L1ET\L1ET\L1ET+51200\
;	AUTO WB Sources:Sources7/superfrog/data/L1ET.pal\L1ET+51200\L1ET_E\

;L1FX:	dcb.b	$7aba,0	;
;L1FX_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L1FX\L1FX\L1FX_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L1FX\L1FX\L1FX_E\

L1MS:	dcb.b	$6900,0	;
L1MS_E:dc.b	"END!"
	AUTO RB Transfer:SuperFrogCD32/data/L1MS\L1MS\L1MS_E\
	AUTO J\
	AUTO WB Sources:Sources7/superfrog/data/L1MS\L1MS\L1MS_E\


;Level 2 ----------------------------------------
;L2MA1:	dcb.b	$d154,0
;L2MA1_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L2MA1\L2MA1\L2MA1_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L2MA1\L2MA1\L2MA1_E\
;	AUTO WB Sources:Sources7/superfrog/data/L2MA1.pal\L2MA1+312\L2MA1+376\

;L2MA2:	dcb.b	$d154,0
;L2MA2_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L2MA2\L2MA2\L2MA2_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L2MA2\L2MA2\L2MA2_E\

;L2MA3:	dcb.b	$d154,0
;L2MA3_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L2MA3\L2MA3\L2MA3_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L2MA3\L2MA3\L2MA3_E\

;L2MA4:	dcb.b	$d154,0
;L2MA4_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L2MA4\L2MA4\L2MA4_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L2MA4\L2MA4\L2MA4_E\

;L2BM:	dcb.b	$20d00,0
;L2BM_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L2BM\L2BM\L2BM_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L2BM\TImg\TImg_E\

;L2BO:	dcb.b	$fa00,0	;320x320x5
;L2BO_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L2BO\L2BO\L2BO_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L2BO\L2BO\L2BO_E\

;L2MU:	dcb.b	$9cba,0		;music
;L2MU_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L2MU\L2MU\L2MU_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L2MU.mod\L2MU\L2MU_E\

;L2LP:	dcb.b	$119d0,0	;320x352x5, palette 32 colors, unknown data
;L2LP_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L2LP\L2LP\L2LP_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L2LP\L2LP\L2LP+70400\
;	AUTO WB Sources:Sources7/superfrog/data/L2LP.pal\L2LP+70400\L2LP+70400+64\

;L2ET:	dcb.b	$C840,0	;320x352x5, palette 32 colors
;L2ET_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L2ET\L2ET\L2ET_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L2ET\L2ET\L2ET+51200\
;	AUTO WB Sources:Sources7/superfrog/data/L2ET.pal\L2ET+51200\L2ET_E\


;Level 3 ----------------------------------------
;L3MA1:	dcb.b	$d154,0
;L3MA1_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L3MA1\L3MA1\L3MA1_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L3MA1\L3MA1\L3MA1_E\
;	AUTO WB Sources:Sources7/superfrog/data/L3MA1.pal\L3MA1+312\L3MA1+376\

;L3MA2:	dcb.b	$d154,0
;L3MA2_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L3MA2\L3MA2\L3MA2_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L3MA2\L3MA2\L3MA2_E\

;L3MA3:	dcb.b	$d154,0
;L3MA3_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L3MA3\L3MA3\L3MA3_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L3MA3\L3MA3\L3MA3_E\

;L3MA4:	dcb.b	$d154,0
;L3MA4_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L3MA4\L3MA4\L3MA4_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L3MA4\L3MA4\L3MA4_E\

;L3BM:	dcb.b	$20d00,0
;L3BM_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L3BM\L3BM\L3BM_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L3BM\TImg\TImg_E\

;L3BO:	dcb.b	$fa00,0	;320x320x5
;L3BO_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L3BO\L3BO\L3BO_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L3BO\L3BO\L3BO_E\

;L3MU:	dcb.b	$8dba,0		;music
;L3MU_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L3MU\L3MU\L3MU_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L3MU.mod\L3MU\L3MU_E\

;L3LP:	dcb.b	$115e0,0	;320x352x5, palette 32 colors, unknown data
;L3LP_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L3LP\L3LP\L3LP_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L3LP\L3LP\L3LP+70400\
;	AUTO WB Sources:Sources7/superfrog/data/L3LP.pal\L3LP+70400\L3LP+70400+64\

;L3ET:	dcb.b	$C840,0	;320x352x5, palette 32 colors
;L3ET_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L3ET\L3ET\L3ET_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L3ET\L3ET\L3ET+51200\
;	AUTO WB Sources:Sources7/superfrog/data/L3ET.pal\L3ET+51200\L3ET_E\


;Level 4 ----------------------------------------
;L4MA1:	dcb.b	$d154,0
;L4MA1_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L4MA1\L4MA1\L4MA1_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L4MA1\L4MA1\L4MA1_E\
;	AUTO WB Sources:Sources7/superfrog/data/L4MA1.pal\L4MA1+312\L4MA1+376\

;L4MA2:	dcb.b	$d154,0
;L4MA2_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L4MA2\L4MA2\L4MA2_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L4MA2\L4MA2\L4MA2_E\

;L4MA3:	dcb.b	$d154,0
;L4MA3_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L4MA3\L4MA3\L4MA3_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L4MA3\L4MA3\L4MA3_E\

;L4MA4:	dcb.b	$d154,0
;L4MA4_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L4MA4\L4MA4\L4MA4_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L4MA4\L4MA4\L4MA4_E\

;L4BM:	dcb.b	$20d00,0
;L4BM_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L4BM\L4BM\L4BM_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L4BM\TImg\TImg_E\

;L4BO:	dcb.b	$fa00,0	;320x320x5
;L4BO_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L4BO\L4BO\L4BO_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L4BO\L4BO\L4BO_E\

;L4MU:	dcb.b	$9870,0		;music
;L4MU_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L4MU\L4MU\L4MU_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L4MU.mod\L4MU\L4MU_E\

;L4LP:	dcb.b	$119d0,0	;320x352x5, palette 32 colors, unknown data
;L4LP_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L4LP\L4LP\L4LP_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L4LP\L4LP\L4LP+70400\
;	AUTO WB Sources:Sources7/superfrog/data/L4LP.pal\L4LP+70400\L4LP+70400+64\

;L4ET:	dcb.b	$C840,0	;320x352x5, palette 32 colors
;L4ET_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L4ET\L4ET\L4ET_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L4ET\L4ET\L4ET+51200\
;	AUTO WB Sources:Sources7/superfrog/data/L4ET.pal\L4ET+51200\L4ET_E\


;Level 5 ----------------------------------------
;L5MA1:	dcb.b	$d154,0
;L5MA1_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L5MA1\L5MA1\L5MA1_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L5MA1\L5MA1\L5MA1_E\
;	AUTO WB Sources:Sources7/superfrog/data/L5MA1.pal\L5MA1+312\L5MA1+376\

;L5MA2:	dcb.b	$d154,0
;L5MA2_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L5MA2\L5MA2\L5MA2_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L5MA2\L5MA2\L5MA2_E\

;L5MA3:	dcb.b	$d154,0
;L5MA3_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L5MA3\L5MA3\L5MA3_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L5MA3\L5MA3\L5MA3_E\

;L5MA4:	dcb.b	$d154,0
;L5MA4_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L5MA4\L5MA4\L5MA4_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L5MA4\L5MA4\L5MA4_E\

;L5BM:	dcb.b	$20d00,0
;L5BM_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L5BM\L5BM\L5BM_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L5BM\TImg\TImg_E\

;L5BO:	dcb.b	$fa00,0	;320x320x5
;L5BO_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L5BO\L5BO\L5BO_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L5BO\L5BO\L5BO_E\

;L5MU:	dcb.b	$a2d0,0		;music
;L5MU_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L5MU\L5MU\L5MU_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L5MU.mod\L5MU\L5MU_E\

;L5LP:	dcb.b	$119d0,0	;320x352x5, palette 32 colors, unknown data
;L5LP_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L5LP\L5LP\L5LP_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L5LP\L5LP\L5LP+70400\
;	AUTO WB Sources:Sources7/superfrog/data/L5LP.pal\L5LP+70400\L5LP+70400+64\

;L5ET:	dcb.b	$C840,0	;320x352x5, palette 32 colors
;L5ET_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L5ET\L5ET\L5ET_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L5ET\L5ET\L5ET+51200\
;	AUTO WB Sources:Sources7/superfrog/data/L5ET.pal\L5ET+51200\L5ET_E\


;Level 6 ----------------------------------------
;L6MA1:	dcb.b	$d154,0
;L6MA1_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L6MA1\L6MA1\L6MA1_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L6MA1\L6MA1\L6MA1_E\
;	AUTO WB Sources:Sources7/superfrog/data/L6MA1.pal\L6MA1+312\L6MA1+376\

;L6MA2:	dcb.b	$d154,0
;L6MA2_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L6MA2\L6MA2\L6MA2_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L6MA2\L6MA2\L6MA2_E\

;L6MA3:	dcb.b	$d154,0
;L6MA3_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L6MA3\L6MA3\L6MA3_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L6MA3\L6MA3\L6MA3_E\

;L6MA4:	dcb.b	$d154,0
;L6MA4_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L6MA4\L6MA4\L6MA4_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L6MA4\L6MA4\L6MA4_E\

;L6BM:	dcb.b	$20d00,0
;L6BM_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L6BM\L6BM\L6BM_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L6BM\TImg\TImg_E\

;L6BO:	dcb.b	$fa00,0	;320x320x5
;L6BO_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L6BO\L6BO\L6BO_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L6BO\L6BO\L6BO_E\

;L6MU:	dcb.b	$982c,0		;music
;L6MU_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L6MU\L6MU\L6MU_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L6MU.mod\L6MU\L6MU_E\

;L6LP:	dcb.b	$115e0,0	;320x352x5, palette 32 colors, unknown data
;L6LP_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L6LP\L6LP\L6LP_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L6LP\L6LP\L6LP+70400\
;	AUTO WB Sources:Sources7/superfrog/data/L6LP.pal\L6LP+70400\L6LP+70400+64\

;L6ET:	dcb.b	$C840,0	;320x352x5, palette 32 colors
;L6ET_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/L6ET\L6ET\L6ET_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/L6ET\L6ET\L6ET+51200\
;	AUTO WB Sources:Sources7/superfrog/data/L6ET.pal\L6ET+51200\L6ET_E\

;Level B ----------------------------------------
;LBMA:	dcb.b	$d154,0
;LBMA_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/LBMA\LBMA\LBMA_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/LBMA\LBMA\LBMA_E\
;	AUTO WB Sources:Sources7/superfrog/data/LBMA.pal\LBMA+312\LBMA+376\

;LBBM:	dcb.b	$20d00,0
;LBBM_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/LBBM\LBBM\LBBM_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/LBBM\TImg\TImg_E\

;LBBO:	dcb.b	$fa00,0	;320x320x5
;LBBO_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/LBBO\LBBO\LBBO_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/LBBO\LBBO\LBBO_E\

;LBMU:	dcb.b	$8454,0		;music
;LBMU_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/LBMU\LBMU\LBMU_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/LBMU.mod\LBMU\LBMU_E\

;LBLP:	dcb.b	$11340,0	;320x352x5, palette 32 colors, unknown data
;LBLP_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/LBLP\LBLP\LBLP_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/LBLP\LBLP\LBLP+70400\
;	AUTO WB Sources:Sources7/superfrog/data/LBLP.pal\LBLP+70400\LBLP+70400+64\

;LBFX:	dcb.b	$3fe0,0	;
;LBFX_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/LBFX\LBFX\LBFX_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/LBFX\LBFX\LBFX_E\


;Level W ----------------------------------------
;LWMA1:	dcb.b	$d154,0
;LWMA1_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/LWMA1\LWMA1\LWMA1_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/LWMA1\LWMA1\LWMA1_E\
;	AUTO WB Sources:Sources7/superfrog/data/LWMA1.pal\LWMA1+312\LWMA1+376\

;LWBM:	dcb.b	$20d00,0
;LWBM_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/LWBM\LWBM\LWBM_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/LWBM\TImg\TImg_E\

;LWBO:	dcb.b	$fa00,0	;320x320x5
;LWBO_E:dc.b	"END!"
;	AUTO RB Transfer:SuperFrogCD32/data/LWBO\LWBO\LWBO_E\
;	AUTO J\
;	AUTO WB Sources:Sources7/superfrog/data/LWBO\LWBO\LWBO_E\
