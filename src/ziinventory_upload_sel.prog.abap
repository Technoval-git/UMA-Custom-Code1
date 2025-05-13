*&---------------------------------------------------------------------*
*& Include          ZIINVENTORY_UPLOAD_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

PARAMETERS: rb_pc RADIOBUTTON GROUP rad2 DEFAULT 'X' MODIF ID b3
                                         USER-COMMAND select,
            rb_pi RADIOBUTTON GROUP rad2  MODIF ID b3.

PARAMETERS: p_fname TYPE rlgrap-filename.


SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-202.
PARAMETERS: rb_file  RADIOBUTTON GROUP rad1 DEFAULT 'X' MODIF ID b4 USER-COMMAND file,
            rb_logic RADIOBUTTON GROUP rad1 MODIF ID b4,
            p_succ   TYPE              localfile MODIF ID fil DEFAULT '/tmp',
            p_error  TYPE              localfile MODIF ID fil DEFAULT '/tmp',
            p_slogic TYPE              filename-fileintern MODIF ID lgc  ,
            p_elogic TYPE              filename-fileintern MODIF ID lgc .
SELECTION-SCREEN END OF BLOCK b2.



*&--------------------------------------------------------------------*
*&                AT SELECTION SCREEN VALUE-REQUEST
*&--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.
  IF rb_pi IS INITIAL.
    clear p_fname.
    PERFORM f_file_value.
  ELSE.
    clear p_fname.
    PERFORM f_at_sel_scr_on_val_req_pi USING p_fname.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_succ.
  PERFORM f_at_sel_scr_on_val_req_pi USING p_succ.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_error.
  PERFORM f_at_sel_scr_on_val_req_pi USING p_error.

AT SELECTION-SCREEN OUTPUT.
*  IF rb_pi IS INITIAL.
*      clear p_fname.
*  ELSE.
*    clear p_fname.
*  ENDIF.

  IF rb_file IS NOT INITIAL.
** Hide the Success & Error Logical File Name Fields
    PERFORM f_hide_field USING lc_lgc.
** Unhide the Success & Error File Path Fields
    PERFORM f_unhide_field USING lc_fil.
  ELSE.
** Hide the Success & Error File Path Fields
    PERFORM f_hide_field USING lc_fil.
** Unhide the Success & Error Logical File Name Fields
    PERFORM f_unhide_field USING lc_lgc.
  ENDIF.
