; vim: set et ts=8 sw=8 sts=8 syntax=64tass :
;
; Simple, 'cheated', sideborder D.Y.S.P., using $d017 stretching to allow for
; different Y-positions of each sprite. Since we're using $d017 to stretch the
; first and last line of the sprite over the whole area, we can only use 19
; lines high sprites, the first and last line must be clear so we won't see
; the $d017 stretcher effect.
;
; With some extra $d011 manipulation, this routine can be used for a
; line cruncher. My line cruncher part in 'Doolittle/Focus' uses this technique
; to display a swinging logo during the line crunching.
;
; 2016-04-22
 
 
; Music, comment out, or adjust to taste
music_sid ="/home/compyx/c64/HVSC/MUSICIANS/J/JCH/Training.sid"
music_init = $1000
music_play = $1003
 
 
        ; BASIC SYS line
        * = $0801
        .word (+), 2016
        .null $9e, ^start
+       .word 0
 
; Entry point: generate sprite and set up IRQ
start
        jsr $fda3
        jsr $fd15
        sei
        jsr create_sprite
        ldx #7
-       lda #$0340/64
        sta $07f8,x
        lda spr_colors,x
        sta $d027,x
        dex
        bpl -
        lda #0
        jsr music_init
        lda #$35
        sta $01
        lda #$7f
        sta $dc0d
        sta $dd0d
        lda #0
        sta $3fff
        sta $dc0e
        lda #$01
        sta $d01a
        lda #$1b
        sta $d011
        lda #$2d
        ldx #<irq1
        ldy #>irq1
        sta $d012
        stx $fffe
        sty $ffff
        ldx #<break
        ldy #>break
        stx $fffa
        sty $fffb
        stx $fffc
        sty $fffd
        bit $dc0d
        bit $dd0d
        inc $d019
        cli
        jmp *
 
        ; make sure timing loops don't cross page boundaries
        .align 256
 
; 'double IRQ' technique to stabilize raster
irq1
        pha
        txa
        pha
        tya
        pha
        lda #$2e
        ldx #<irq2
        ldy #>irq2
        sta $d012
        stx $fffe
        sty $ffff
        lda #1
        inc $d019
        tsx
        cli
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
irq2
        txs
        ldx #8
-       dex
        bne -
        bit $ea
        lda $d012
        cmp $d012
        beq +
+       ; stable raster here
 
        ; set sprite positions
        lda #$32        ; constant, the Y-movement is done with $d017 magic
        sta $d001
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f
x0      lda #$00
        sta $d000
x1      lda #$18
        sta $d002
x2      lda #$30
        sta $d004
x3      lda #$48
        sta $d006
x4      lda #$60
        sta $d008
x5      lda #$78
        sta $d00a
x6      lda #$90
        sta $d00c
x7      lda #$a8
        sta $d00e
xmsb    lda #$00
        sta $d010
        lda #$00
        sta $d01c
        sta $d01d
        lda #$ff
        sta $d015
 
 
        ldx #09
-       dex
        bne -
        nop
        nop
        nop
        jsr stretcher
 
        lda #$1b
        sta $d011
        lda #0
        sta $d015
        sta $d021
        dec $d020
        jsr clear_d017_table
        dec $d020
        jsr sinus_x
        jsr sinus_y
        dec $d020
        jsr update_d017_table
        lda #0
        sta $d020
        lda #$f9
        ldx #<irq3
        ldy #>irq3
        sta $d012
        stx $fffe
        sty $ffff
        lda #1
        sta $d019
        pla
        tay
        pla
        tax
        pla
break   rti
 
irq3
        pha
        txa
        pha
        tya
        pha
        ldx #3          ; open top/bottom borders to allow us to open the
-       dex             ; side borders earlier in the $d017 stretcher
        bne -
        stx $d011
        ldx #40
-       dex
        bne -
        lda #$1b
        sta $d011
        dec $d020
        jsr music_play
 
        lda #0
        sta $d020
        lda #$2d
        ldx #<irq1
        ldy #>irq1
        sta $d012
        stx $fffe
        sty $ffff
        lda #1
        sta $d019
        pla
        tay
        pla
        tax
        pla
        rti
 
 
; Create a single sprite at $0340
create_sprite
        ldx #0
-       lda sprite,x
        sta $0340,x
        inx
        cpx #63
        bne -
        rts
 
; Clear the $d017 'stretcher' table by storing $ff in it
;
; We later mask out bits in this table with the $d017 update routine
clear_d017_table
        lda #$ff
        ldx #$3f
-       sta d017_table,x
        dex
        bpl -
        rts
 
 
; Update the $d017 'stretcher' table
;
; This is what creates the D.Y.S.P. effect
;
; For each sprite, we get its Y-position and mask out the proper bits in the
; $d017 table. We only mask out bits for 19 lines, line 0 and line 20 are
; always stretched to keep the timing in the loop constant
update_d017_table
        ; sprite 0
        ldx siny_table + 0
        ldy #18
-       lda d017_table,x
        and #%11111110
        sta d017_table,x
        inx
        dey
        bpl -
 
        ; sprite 1
        ldx siny_table + 1
        ldy #18
-       lda d017_table,x
        and #%11111101
        sta d017_table,x
        inx
        dey
        bpl -
 
        ldx siny_table + 2
        ldy #18
-       lda d017_table,x
        and #%11111011
        sta d017_table,x
        inx
        dey
        bpl -
 
        ldx siny_table + 3
        ldy #18
-       lda d017_table,x
        and #%11110111
        sta d017_table,x
        inx
        dey
        bpl -
 
        ldx siny_table + 4
        ldy #18
-       lda d017_table,x
        and #%11101111
        sta d017_table,x
        inx
        dey
        bpl -
 
        ldx siny_table + 5
        ldy #18
-       lda d017_table,x
        and #%11011111
        sta d017_table,x
        inx
        dey
        bpl -
 
        ldx siny_table + 6
        ldy #18
-       lda d017_table,x
        and #%10111111
        sta d017_table,x
        inx
        dey
        bpl -
 
        ; sprite 7
        ldx siny_table + 7
        ldy #18
-       lda d017_table,x
        and #%01111111
        sta d017_table,x
        inx
        dey
        bpl -
        rts
 
 
; X-movement parameters, two sinus tables added together
sinx_idx1       .byte 0
sinx_idx2       .byte 64
sinx_adc1       .byte 8
sinx_adc2       .byte 5
sinx_spd1       .byte $fe
sinx_spd2       .byte $03
xmsb_temp       .byte 0
 
; Calculate the X-movement of the sprites
sinus_x
        lda #0
        sta xmsb_temp   ; temporary storage for $d010
 
        ldx sinx_idx1
        ldy sinx_idx2
 
        lda sinus256,x
        clc
        adc sinus88,y
        sta x0 + 1
        bcc +
        lda xmsb_temp
        ora #1
        sta xmsb_temp
+       txa
        clc
        adc sinx_adc1
        tax
        tya
        clc
        adc sinx_adc2
        tay
 
        lda sinus256,x
        clc
        adc sinus88,y
        sta x1 + 1
        bcc +
        lda xmsb_temp
        ora #2
        sta xmsb_temp
+       txa
        clc
        adc sinx_adc1
        tax
        tya
        clc
        adc sinx_adc2
        tay
 
        lda sinus256,x
        clc
        adc sinus88,y
        sta x2 + 1
        bcc +
        lda xmsb_temp
        ora #4
        sta xmsb_temp
+       txa
        clc
        adc sinx_adc1
        tax
        tya
        clc
        adc sinx_adc2
        tay
 
        lda sinus256,x
        clc
        adc sinus88,y
        sta x3 + 1
        bcc +
        lda xmsb_temp
        ora #8
        sta xmsb_temp
+       txa
        clc
        adc sinx_adc1
        tax
        tya
        clc
        adc sinx_adc2
        tay
 
        lda sinus256,x
        clc
        adc sinus88,y
        sta x4 + 1
        bcc +
        lda xmsb_temp
        ora #16
        sta xmsb_temp
+       txa
        clc
        adc sinx_adc1
        tax
        tya
        clc
        adc sinx_adc2
        tay
 
        lda sinus256,x
        clc
        adc sinus88,y
        sta x5 + 1
        bcc +
        lda xmsb_temp
        ora #32
        sta xmsb_temp
+       txa
        clc
        adc sinx_adc1
        tax
        tya
        clc
        adc sinx_adc2
        tay
 
        lda sinus256,x
        clc
        adc sinus88,y
        sta x6 + 1
        bcc +
        lda xmsb_temp
        ora #64
        sta xmsb_temp
+       txa
        clc
        adc sinx_adc1
        tax
        tya
        clc
        adc sinx_adc2
        tay
 
        lda sinus256,x
        clc
        adc sinus88,y
        sta x7 + 1
        bcc +
        lda xmsb_temp
        ora #128
        sta xmsb_temp
+
        lda xmsb_temp
        sta xmsb + 1
 
        lda sinx_idx1
        clc
        adc sinx_spd1
        sta sinx_idx1
        lda sinx_idx2
        clc
        adc sinx_spd2
        sta sinx_idx2
        rts
 
; Y-movement parameters, a single sinus, for now
siny_table      .fill 8, 0
siny_idx        .byte 0
siny_adc        .byte 16
siny_spd        .byte 2
 
sinus_y
        ldy #0
        ldx siny_idx
-       lda sinus40,x
        clc
        adc #1
        sta siny_table,y
        txa
        clc
        adc siny_adc
        tax
        iny
        cpy #8
        bne -
        lda siny_idx
        clc
        adc siny_spd
        sta siny_idx
        rts
 
; Colors for the sprites
spr_colors
        .byte 1, 7, 13, 15, 14, 4, 6, 9
 
 
; Example sprite
sprite
        .byte 0, 0, 0
        .byte %00000000, %00000000, %00000000
        .byte %00000000, %11111111, %00000000
        .byte %00000111, %11111111, %11100000
        .byte %00011111, %11000001, %11111000
        .byte %00111111, %10000000, %11100000
        .byte %01111111, %00000000, %00000000
        .byte %01111111, %00000000, %00000000
        .byte %11111111, %00000000, %00000000
        .byte %11111111, %00000000, %00000000
        .byte %11111111, %00000000, %00000000
        .byte %11111111, %00000000, %00000000
        .byte %11111111, %00000000, %00000000
        .byte %01111111, %00000000, %00000000
        .byte %01111111, %00000000, %11100000
        .byte %00111111, %10000000, %11111000
        .byte %00011111, %11000011, %11111000
        .byte %00000111, %11111111, %11100000
        .byte %00000000, %11111111, %00000000
        .byte %00000000, %00000000, %00000000
        .byte 0, 0, 0
 
 
        ; make sure we don't cross a page in the stretcher or its data
        .align 256
 
 
; The $d017 stretcher
;
; Basically an FLD with $d017 manipulation and open borders: we use the FLD
; effect to inhibit bad lines, giving us 63 cycles on each rasterline, of which
; a lot of cycles get eaten by the sprites
;
; At each line we set Y-stretch to false, immediately followed by true, which
; causes a line of a sprite to be stretched indefinately. When we set the
; Y-stretch to false at a line (after the initial false condition), we allow
; the VIC to update its position in the sprite matrix, thus displaying a line
; of a sprite
;
; This loop can be unrolled and optimized to allow for raster splits, if
; desired
stretcher
        ldy #0
        ldx #0
-       sty $d017               ; set Y-stretch to false
        lda d017_table,x        ; set Y-stretch to true for selected sprites
        sta $d017
        lda d011_table + 0,x
        bit $ea
        nop
        nop
        dec $d016               ; open side border and do FLD to inhibit
        sta $d011               ; bad lines
        inc $d016
        inx
        cpx #64
        bne -
        rts
 
; Table with values for $d017 in the stretcher
d017_table
        .fill 64, $ff
 
; Values for $d011 in the stretcher
d011_table
        - = range(0, 64, 1)
        .byte <(-) & 7 | $10
 
        ; Don't overwrite music with code/data
        .cerror * > $0fff, "code section too long"
 
 
; Link music
        * = $1000
.binary music_sid, $7e
 
 
 
        * = $2000
; Sinus for X-movement
sinus256        .byte 127.5 + 128 * sin(range(256) * rad(360.0/256))
sinus88         .byte 42.5 + 43 * sin(range(256) * rad(360.0/256))
 
; Sinus for Y-movement
sinus40         .byte 19.5 + 20 * sin(range(256) * rad(360.0/256))
