*&---------------------------------------------------------------------*
*& Include          ZMM_SSESSION_UPLD_UPLD
*&---------------------------------------------------------------------*



DATA : wa_v_pics TYPE v_picps.

DATA : i_picps TYPE STANDARD TABLE OF picps,
       wa_pics TYPE picps.


DATA : lv_tab        TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
       lv_split1(40) TYPE c,
       lv_split2(40) TYPE c,
       lv_split3(40) TYPE c,
       lv_split4(40) TYPE c,
       lv_split5(40) TYPE c,
       lv_pic_num    TYPE pic_picnum.

CONSTANTS : ca_check TYPE c       VALUE '0',
            ca_ftype TYPE char10  VALUE 'ASC'.

DATA : lv_pic_list TYPE pic01_ts_pic_interface,
       i_old_pic   TYPE STANDARD TABLE OF v_picpsrl,
       wa_old_pic  TYPE v_picpsrl,
       i_new_pic   TYPE STANDARD TABLE OF v_picpsrl,
       wa_new_pic  TYPE v_picpsrl.

DATA : i_old_vpicmrl TYPE STANDARD TABLE OF v_picmrl,
       i_new_vpicmrl TYPE STANDARD TABLE OF v_picmrl,
       i_errors      TYPE STANDARD TABLE OF smesg,
       ts_errors     TYPE  smesg.

TYPES : BEGIN OF ty_file_value,
          matnr_m(40) TYPE c,
          matnr_s(40) TYPE c,
          valid(10)   TYPE c,
          cause(4)    TYPE c,
          replace     TYPE c,
        END OF ty_file_value.

DATA : i_file_value     TYPE STANDARD TABLE OF ty_file_value,
       wa_file_value    TYPE ty_file_value,
       wa_file_value_at TYPE ty_file_value,
       it_matnr         TYPE    table_matnr,
       ts_matnr         TYPE matnr.

DATA : lv_inc       TYPE i,
       lv_matnr(40) TYPE c,
       lv_matnr_o   TYPE matnr.

DATA : i_picpsrl  TYPE STANDARD TABLE OF v_picpsrl,
       wa_picpsrl TYPE v_picpsrl.





TYPES: BEGIN OF ty_log,
         type       TYPE char10,
         pic_picnum TYPE pic_picnum,
         message    TYPE bapi_msg,
       END OF ty_log.


DATA : lt_log TYPE STANDARD TABLE OF ty_log,
       ls_log TYPE ty_log.

DATA : it_fieldcat TYPE slis_t_fieldcat_alv,
       wa_layout   TYPE slis_layout_alv,
       ls_print    TYPE slis_print_alv.


DATA va_top           TYPE slis_formname VALUE 'F_ALV_HEADER'.

DATA:
  lv_validity TYPE sy-datum,
  lv_tabix    TYPE sy-tabix,
  lv_msg      TYPE string.







TYPES: BEGIN OF ty_ssupld,
         Matnr(40)  TYPE c,
         Matnr1(40) TYPE c,
         Datfr(10)  TYPE c,
         Piccode(4) TYPE c,
         Inttype(1) TYPE c,
       END OF ty_ssupld.
DATA wa_ssupld TYPE ty_ssupld.
DATA lt_ssupld TYPE STANDARD TABLE OF ty_ssupld.
DATA wa_ssupld1 TYPE ty_ssupld.
DATA lt_ssupld1 TYPE STANDARD TABLE OF ty_ssupld.
FIELD-SYMBOLS:
       <fs_ssupld> TYPE ty_ssupld.

DATA lt_raw TYPE truxs_t_text_data.

CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
  EXPORTING
*   I_FIELD_SEPERATOR    =
    i_line_header        = abap_true
    i_tab_raw_data       = lt_raw
    i_filename           = pv_file
*   I_STEP               = 1
  TABLES
    i_tab_converted_data = lt_ssupld
  EXCEPTIONS
    conversion_failed    = 1
    OTHERS               = 2.
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.


LOOP AT lt_ssupld ASSIGNING <fs_ssupld>.


  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input        = <fs_ssupld>-matnr
    IMPORTING
      output       = <fs_ssupld>-matnr
    EXCEPTIONS
      length_error = 1
      OTHERS       = 2.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input        = <fs_ssupld>-matnr1
    IMPORTING
      output       = <fs_ssupld>-matnr1
    EXCEPTIONS
      length_error = 1
      OTHERS       = 2.
*  wa_ssupld1-matnr = <fs_ssupld>-matnr.
*  wa_ssupld1-matnr1 = <fs_ssupld>-matnr1.
*  APPEND wa_ssupld1 TO lt_ssupld1.
ENDLOOP.


SORT lt_ssupld BY matnr matnr1.
*SORT lt_ssupld1 BY matnr matnr1.

LOOP AT lt_ssupld INTO wa_ssupld.
  ON CHANGE OF wa_ssupld-matnr.



    wa_new_pic-piccat = '01'.
    wa_new_pic-matnr    = wa_ssupld-matnr.
    wa_new_pic-seqnr    = '0001'.
    wa_new_pic-datfr    = wa_ssupld-datfr.
    wa_new_pic-piccode  = wa_ssupld-piccode.
    wa_new_pic-inttype  = wa_ssupld-inttype.

    APPEND wa_new_pic TO i_new_pic.
  ENDON.

  wa_new_pic-piccat = '01'.
  wa_new_pic-matnr    = wa_ssupld-matnr1.
  wa_new_pic-datfr    = wa_ssupld-datfr.
  wa_new_pic-piccode  = wa_ssupld-piccode.
  wa_new_pic-inttype  = wa_ssupld-inttype.


  APPEND wa_new_pic TO i_new_pic.




  AT END OF matnr.
  if sy-tabix = 1.
    CONTINUE.
  endif.
    CLEAR : i_PICPSRL[],wa_picpsrl,wa_old_pic,i_old_pic[],lv_pic_list-old_picpsrl[] ,lv_pic_list.

    lv_pic_list-new_picpsrl[] = i_new_pic[].
    CLEAR: i_new_pic[].

    CALL FUNCTION 'PIC01_MAINTAIN_VPICPSRL'
      EXPORTING
        is_pic_list       = lv_pic_list
      IMPORTING
        e_picnum          = lv_pic_num
      TABLES
        it_old_vpicmrl    = i_old_vpicmrl
        it_new_vpicmrl    = i_new_vpicmrl
        it_error          = i_errors
      EXCEPTIONS
        missing_parameter = 1
        error_input       = 2
        OTHERS            = 3.


    READ TABLE i_errors INTO ts_errors WITH KEY msgty = 'E'.
    IF sy-subrc EQ 0.
      LOOP AT i_errors INTO ts_errors.
        CALL FUNCTION 'FORMAT_MESSAGE'
          EXPORTING
            id  = ts_errors-arbgb
            no  = ts_errors-txtnr
            v1  = ts_errors-msgv1
            v2  = ts_errors-msgv2
            v3  = ts_errors-msgv3
            v4  = ts_errors-msgv4
          IMPORTING
            msg = lv_msg.
        IF ls_log-message IS INITIAL.
          ls_log-message = lv_msg.
        ELSE.
          CONCATENATE ls_log-message ' '  lv_msg INTO  ls_log-message RESPECTING BLANKS.
        ENDIF.
        ls_log-type = 'E'.
        APPEND ls_log TO lt_log.
        CLEAR ls_log.
      ENDLOOP.

    ELSE.
      ls_log-type = 'S'.
      ls_log-message = 'Success'.
      ls_log-pic_picnum = lv_pic_num.

      APPEND ls_log TO lt_log.
      CLEAR ls_log.
    ENDIF.

    CLEAR  : lv_pic_list, lv_pic_num.

  ENDAT.
ENDLOOP.



IF lt_log[] IS NOT INITIAL.


  CLEAR lt_fieldcat[].

  lwa_fieldcat-row_pos = 1.
  lwa_fieldcat-col_pos = 1.
  lwa_fieldcat-fieldname = 'TYPE'.
  lwa_fieldcat-tabname = 'lt_log'.
  lwa_fieldcat-outputlen = 4.
  lwa_fieldcat-seltext_m = 'TYPE'.
  APPEND lwa_fieldcat TO lt_fieldcat.
  CLEAR: lwa_fieldcat.

  lwa_fieldcat-row_pos = 1.
  lwa_fieldcat-col_pos = 2.
  lwa_fieldcat-fieldname = 'PIC_PICNUM'.
  lwa_fieldcat-tabname = 'lt_log'.
  lwa_fieldcat-outputlen = 40.
  lwa_fieldcat-seltext_m = 'PIC_PICNUM'.
  APPEND lwa_fieldcat TO lt_fieldcat.
  CLEAR: lwa_fieldcat.

  lwa_fieldcat-row_pos = 1.
  lwa_fieldcat-col_pos = 3.
  lwa_fieldcat-fieldname = 'MESSAGE'.
  lwa_fieldcat-tabname = 'lt_log'.
  lwa_fieldcat-outputlen = 100.
  lwa_fieldcat-seltext_m = 'MESSAGE'.
  APPEND lwa_fieldcat TO lt_fieldcat.
  CLEAR: lwa_fieldcat.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat   = lt_fieldcat
    TABLES
      t_outtab      = lt_log
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.






ENDIF.
