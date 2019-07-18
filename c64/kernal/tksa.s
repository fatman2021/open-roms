
;;
;; Official Kernal routine, described in:
;;
;; - [RG64] C64 Programmer's Reference Guide   - page 302
;; - [CM64] Compute's Mapping the Commodore 64 - page 224
;;
;; CPU registers that has to be preserved (see [RG64]): .X, .Y
;;

;; XXX currently does not preserve registers, to be fixed!
;; XXX shouldn't this do a turnaround?

tksa:

	;; See also https://www.pagetable.com/?p=1031, , https://github.com/mist64/cbmbus_doc

	and #$1F ; make sure bits encoding the command are cleared out
	ora #$F0
	jmp iec_tx_command

