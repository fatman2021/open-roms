
;;
;; Official Kernal routine, described in:
;;
;; - [RG64] C64 Programmer's Reference Guide   - page 301
;; - [CM64] Compute's Mapping the Commodore 64 - page 232
;;
;; CPU registers that has to be preserved (see [RG64]): .Y
;;

stop:
	;; Bit 7 of BUCKYSTATUS contains the state of the STOP key
	;; (Compute's Mapping the 64, p27)

	;; BASIC checks carry flag to indicate STOP or not
	lda BUCKYSTATUS
	and #$80
	beq stop_pressed

	;; By trial and error, we know that Z + C = BREAK
	;; and that neither should be set otherwise
	lda #$ff
	clc
	rts

stop_pressed:
	sec
	lda #$00
	rts
