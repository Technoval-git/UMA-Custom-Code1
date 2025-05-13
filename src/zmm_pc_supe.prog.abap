*----------------------------------------------------------------------*
***INCLUDE ZMM_PC_SUPE.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zmm_pc_supe
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zmm_pc_supe .

  TYPES: BEGIN OF ty_log,
           type       TYPE char10,
           pic_picnum TYPE pic_picnum,
           message    TYPE bapi_msg,
         END OF ty_log.
  DATA : lt_log        TYPE STANDARD TABLE OF ty_log,
         ls_log        TYPE ty_log,
         lv_pic_num    TYPE pic_picnum,
         i_picpsrl     TYPE STANDARD TABLE OF v_picpsrl,
         wa_picpsrl    TYPE v_picpsrl,
         lv_pic_list   TYPE pic01_ts_pic_interface,
         i_old_pic     TYPE STANDARD TABLE OF v_picpsrl,
         wa_old_pic    TYPE v_picpsrl,
         i_new_pic     TYPE STANDARD TABLE OF v_picpsrl,
         wa_new_pic    TYPE v_picpsrl,
         i_old_vpicmrl TYPE STANDARD TABLE OF v_picmrl,
         i_new_vpicmrl TYPE STANDARD TABLE OF v_picmrl,
         i_errors      TYPE STANDARD TABLE OF smesg,
         ts_errors     TYPE  smesg,
         i_picps       TYPE STANDARD TABLE OF picps,
         wa_pics       TYPE picps,
         lv_msg        TYPE string.





  IF  p_gm = 'X'.
    SELECT gm_matnr, gm_supersession FROM zmm_gm  WHERE gm_supersession IS NOT INITIAL AND gm_matnr IN @s_matnr
        INTO TABLE @DATA(lt_zmm_gm).
    LOOP AT lt_zmm_gm ASSIGNING FIELD-SYMBOL(<ls_zmm_gm>).


      CONCATENATE 'GM' <ls_zmm_gm>-gm_matnr INTO <ls_zmm_gm>-gm_matnr.


      CONCATENATE 'GM' <ls_zmm_gm>-gm_supersession INTO <ls_zmm_gm>-gm_supersession.
    ENDLOOP.
    SORT lt_zmm_gm BY gm_matnr gm_supersession.

    LOOP AT lt_zmm_gm INTO DATA(wa_ssupld).
      ON CHANGE OF wa_ssupld-gm_matnr.
        wa_new_pic-piccat = '01'.
        wa_new_pic-matnr    = wa_ssupld-gm_matnr.
        wa_new_pic-seqnr    = '0001'.
        wa_new_pic-datfr    = sy-datum . "wa_ssupld-datfr.
        wa_new_pic-piccode  = '01'. "wa_ssupld-piccode.
        wa_new_pic-inttype  = 'I'. "wa_ssupld-inttype.

        APPEND wa_new_pic TO i_new_pic.
      ENDON.

      wa_new_pic-piccat = '01'.
      wa_new_pic-matnr    = wa_ssupld-gm_supersession.
      wa_new_pic-datfr    = sy-datum. "wa_ssupld-datfr.
      wa_new_pic-piccode  = '01'. "wa_ssupld-piccode.
      wa_new_pic-inttype  = 'I'. "wa_ssupld-inttype.


      APPEND wa_new_pic TO i_new_pic.

      AT END OF gm_matnr.
        IF sy-tabix = 1.
          CONTINUE.
        ENDIF.
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

        CLEAR  : lv_pic_list, lv_pic_num.
      ENDAT.
    ENDLOOP.
    MESSAGE 'SuperSession Executed' TYPE 'I'.

  ELSEIF p_ac = 'X'. "-----------------------------------------------------------------------------------------

    SELECT ac_delco,  ac_supersession FROM zmm_ac  WHERE ac_supersession IS NOT INITIAL AND ac_delco IN @s_matnr
        INTO TABLE @DATA(lt_zmm_ac).
    LOOP AT lt_zmm_ac ASSIGNING FIELD-SYMBOL(<ls_zmm_ac>).


      CONCATENATE 'AC' <ls_zmm_ac>-ac_delco INTO <ls_zmm_ac>-ac_delco.

      CONCATENATE 'AC' <ls_zmm_ac>-ac_supersession INTO <ls_zmm_ac>-ac_supersession.

    ENDLOOP.
    SORT lt_zmm_ac BY ac_delco ac_supersession.

    LOOP AT lt_zmm_ac INTO DATA(wa_ssupld1).
      ON CHANGE OF wa_ssupld1-ac_delco.
        wa_new_pic-piccat = '01'.
        wa_new_pic-matnr    = wa_ssupld1-ac_delco.
        wa_new_pic-seqnr    = '0001'.
        wa_new_pic-datfr    = sy-datum . "wa_ssupld-datfr.
        wa_new_pic-piccode  = '01'. "wa_ssupld-piccode.
        wa_new_pic-inttype  = 'I'. "wa_ssupld-inttype.

        APPEND wa_new_pic TO i_new_pic.
      ENDON.

      wa_new_pic-piccat = '01'.
      wa_new_pic-matnr    = wa_ssupld1-ac_supersession.
      wa_new_pic-datfr    = sy-datum. "wa_ssupld-datfr.
      wa_new_pic-piccode  = '01'. "wa_ssupld-piccode.
      wa_new_pic-inttype  = 'I'. "wa_ssupld-inttype.


      APPEND wa_new_pic TO i_new_pic.

      AT END OF ac_delco.
        IF sy-tabix = 1.
          CONTINUE.
        ENDIF.
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


        CLEAR  : lv_pic_list, lv_pic_num.
      ENDAT.
    ENDLOOP.
    MESSAGE 'SuperSession Executed' TYPE 'I'.

  ELSE.

    MESSAGE 'SuperSession not required' TYPE 'I'.

  ENDIF.


ENDFORM.
