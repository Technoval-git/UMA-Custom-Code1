*----------------------------------------------------------------------*
***INCLUDE LZFGRP_TMGF01.
*----------------------------------------------------------------------*
FORM BEFORE_DEL.
DATA: lt_table   TYPE TABLE OF zfi_vend_user, " Replace with your table name
      ls_table   TYPE zfi_vend_user,
      lv_counter TYPE zfi_vend_user-zfi_recipients. " Replace with your key field type
BREAK-POINT.
* Select all records ordered by the key field
SELECT * FROM zfi_vend_user
  INTO TABLE lt_table
  ORDER BY zfi_recipients.

" Initialize the counter for re-sequencing
lv_counter = 1.

" Loop through the table and update the key field
LOOP AT lt_table INTO ls_table.
  ls_table-zfi_recipients = lv_counter. " Replace with your key field
  MODIFY zfi_vend_user FROM ls_table.
  lv_counter = lv_counter + 1.
ENDLOOP.

" Commit the changes to the database
COMMIT WORK.
ENDFORM.
