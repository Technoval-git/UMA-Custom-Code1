*----------------------------------------------------------------------*
***INCLUDE ZI_EWM_PARTNO_PRINT_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form VALIDATIONS_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validations_all .
  IF s_matnr[] IS NOT INITIAL.
    SELECT SINGLE @abap_true FROM mara INTO @DATA(ls_matnr) WHERE matnr IN @s_matnr.
    IF ls_matnr IS INITIAL.
      MESSAGE 'Part number not found' TYPE 'E'.
    ENDIF.
  ENDIF.

  IF s_matkl[] IS NOT INITIAL.
    SELECT SINGLE @abap_true FROM mara INTO @DATA(ls_matkl) WHERE matkl IN @s_matkl.
    IF ls_matkl IS INITIAL.
      MESSAGE 'Material group not found' TYPE 'E'.
    ENDIF.
  ENDIF.
  IF ls_matnr IS INITIAL.
  ENDIF.
  IF s_mtart[] IS NOT INITIAL.
    SELECT SINGLE @abap_true FROM mara INTO @DATA(ls_mtart) WHERE mtart IN @s_mtart.
    IF ls_mtart IS INITIAL.
      MESSAGE 'Material type not found' TYPE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT matnr FROM mara INTO TABLE @gt_mara
   WHERE  matnr IN @s_matnr AND mtart IN @s_mtart AND matkl IN @s_matkl .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT_FORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print_form .
  DATA : lt_return   TYPE bapirettab,
         lt_return1  TYPE bapirettab,
         lv_funcname TYPE funcname.

  rep_eaps_cz_cl_utils=>fp_job_open(
    CHANGING
      ct_return =  lt_return                " Table with BAPI Return Information
    EXCEPTIONS
      job_error = 1                " Open spool job error
      OTHERS    = 2
  ).
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = 'Z_EWM_PARTNO_PRINT_FORM'
    IMPORTING
      e_funcname = lv_funcname.

  CALL FUNCTION lv_funcname
    EXPORTING
      im_mara = gt_mara.

  rep_eaps_cz_cl_utils=>fp_job_close(
    CHANGING
      ct_return = lt_return1                 " Table with BAPI Return Information
  ).

ENDFORM.
