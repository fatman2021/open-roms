
;; This is a common part of iec_tx_byte and iec_tx_command
;; Implemented based on https://www.pagetable.com/?p=1135, https://github.com/mist64/cbmbus_doc

iec_tx_common:

	;; Store the bye to send on a stack
	pha

	;; Wait till all receivers are ready, they should all release DATA
	jsr iec_wait_for_data_release
	
	;; Pull CLK back to indicate that DATA is not valid, keep it for 60us
	;; Don't wait too long, as 200us or more is considered EOI

	jsr iec_pull_clk_release_data
	jsr iec_wait60us

	;; Now, we can start transmission of 8 bits of data
	ldx #7
	pla

iec_tx_common_sendbit:
	;; Is next bit 0 or 1?
	lsr
	pha
	bcs +

	;; Bit is 0
	jsr iec_release_clk_pull_data
	jmp iec_tx_common_bit_is_sent
*
	;; Bit is 1
	jsr iec_release_clk_data
	
iec_tx_common_bit_is_sent:

	;; Wait 20us, so that device(s) can pick DATA
	jsr iec_wait20us

	;; More bits to send?
	pla
	dex
	bpl iec_tx_common_nextbit
	
	;; XXX the flow below is REALLY dangerous, as if there are multiple devices,
	;; one can signal that it's busy much earlier (more than 100ms) than the other.
	;; Can we do something about it?

	;; All done - give devices time to tell if they are busy by pulling DATA
	;; They should do it within 1ms
	ldx #$FF
*	lda CI2PRA
	;; BPL here is checking that bit 7 of $DD00 clears,
	;; i.e, that the DATA line is pulled by drive
	bpl +
	dex
	bne -
	bpl iec_tx_common_done
*
	;; Wait 100us to give busy devices some time
	jsr iec_wait100us
	
iec_tx_common_done:
	;; Byte sent, return
	rts
	
iec_tx_common_nextbit:

	;; Pull CLK for 20us again, before
	jsr iec_pull_clk_release_data
	jsr iec_wait20us
	
	jmp iec_tx_common_sendbit
