
//
// Common part of CHKIN and CKOUT
//


chkinout_device_not_present:

	ply_trash_a
	pla
	jsr kernalstatus_DEVICE_NOT_FOUND
	jmp kernalerror_DEVICE_NOT_FOUND

chkinout_file_not_open:

	ply_trash_a
	pla
	jmp kernalerror_FILE_NOT_OPEN
