
;;
;; Official Kernal routine, described in:
;;
;; - [RG64] C64 Programmer's Reference Guide   - page 285
;; - [CM64] Compute's Mapping the Commodore 64 - page 238
;;
;; CPU registers that has to be preserved (see [RG64]): none
;;

ioinit:

	; Set $00/$01 port mode and value
	; We want BASIC and KERNAL ROMs mapped, and datasette motor off
	; (https://www.c64-wiki.com/wiki/Zeropage)
	;; XXX - Work around VICE bug: Writing $00 before $01 results in rubbish in $01
	;; after. https://sourceforge.net/p/vice-emu/bugs/1057/
	lda #$27
	ldx #$2F
	sta CPU_R6510
	stx CPU_D6510

	;; Silence the SID chips

	ldy #$00
*
	lda SID_SIGVOL, Y
	and #$F0
	sta SID_SIGVOL, Y
	tya
	clc
	adc #$20
	tay
	cpy #$80 ; $20 * amount of chips to silence, $80 to silence 4 chips
	bne -

	;; Enable CIA1 IRQ and ~50Hz timer
	;; (https://csdb.dk/forums/?roomid=11&topicid=69037)
	lda #$7f
	sta $DC0D 		; First disable all

	;; Set timer interval to ~1/60th of a second
	;; (This value was calculated by running a custom IRQ haandler on a C64
	;; with original KERNAL, and writing the values of $DC04/5 to the screen
	;; in the IRQ handler to see roughly what value the timers must be set to)
	lda #<16380
	sta $dc04
	lda #>16380
	sta $dc05

	;; Enable timer interrupt
	lda #$81
	sta $dc0d

	;; Enable timer A to run continuously
	;; (http://codebase64.org/doku.php?id=base:timerinterrupts)
	lda #$11
	sta $dc0e
	lda $dc0d

	;; Set DDR on CIA2 for IEC bus, VIC-II banking
	lda #$3b
	sta $dd02
	
	;; Set IEC bus oto its initial idle state
	jsr iec_set_idle
	
	rts
