*&---------------------------------------------------------------------*
*& Include          ZVSS_INB_YARD_REP_SUB
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  DATA: lt_temp_inb TYPE TABLE OF ty_inb,
        ls_vbuk     TYPE ty_inb.

  FIELD-SYMBOLS: <fs_inb> TYPE ty_inb.

  SELECT
    likp~vbeln
    likp~lifnr
    likp~vstel
    likp~vlstk
    likp~lifex
    likp~lfdat
    likp~traid
    likp~bolnr
    lips~posnr
    lips~matnr
    lips~lfimg
    lips~meins
    lips~vgbel
    lips~vgpos
    lips~werks
    lips~lgort
    lips~charg
    lips~mtart
    lips~wbsta
    lips~pksta
    INTO TABLE it_inb
    FROM likp
    INNER JOIN lips
    ON likp~vbeln = lips~vbeln
    INNER JOIN but000
    ON likp~lifnr = but000~partner
    WHERE likp~vbeln IN s_vbeln
      AND likp~ernam IN s_ernam
      AND likp~erdat IN s_erdat
      AND likp~lfdat IN s_lfdat
      AND likp~vstel IN s_vstel
      AND likp~lifex IN s_lifex
      AND lips~matnr IN s_matnr
      AND likp~lifnr IN s_lifnr
      AND lips~vgbel IN s_ebeln
      AND lips~vgpos IN s_ebelp
      AND lips~mtart IN s_mtart
      AND likp~vbtyp EQ '7'
      AND but000~bu_group NE 'ZPLT'.
  IF sy-subrc = 0.
    lt_temp_inb = it_inb.
    SORT lt_temp_inb BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_temp_inb COMPARING vbeln.
    DELETE lt_temp_inb WHERE vbeln IS INITIAL.

    lt_temp_inb = it_inb.
    SORT lt_temp_inb BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_temp_inb COMPARING matnr.
    DELETE lt_temp_inb WHERE matnr IS INITIAL.
    IF lt_temp_inb IS NOT INITIAL.
      SELECT
         matnr
         maktx
         FROM makt
         INTO TABLE it_makt
         FOR ALL ENTRIES IN it_inb
         WHERE matnr = it_inb-matnr
         AND spras = 'E'."yif_dbm_jet_constants=>gc_lang_en  .
    ENDIF.

    lt_temp_inb = it_inb.
    SORT lt_temp_inb BY vgbel.
    DELETE ADJACENT DUPLICATES FROM lt_temp_inb COMPARING vgbel.
    DELETE lt_temp_inb WHERE vgbel IS INITIAL.
    IF lt_temp_inb IS NOT INITIAL.
      SELECT
        ebeln
        ebelp
        menge
        effwr
        netwr
        FROM ekpo
        INTO TABLE it_po
        FOR ALL ENTRIES IN it_inb
        WHERE ebeln = it_inb-vgbel.
    ENDIF.

    lt_temp_inb = it_inb.
    SORT lt_temp_inb BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_temp_inb COMPARING vbeln.
    DELETE lt_temp_inb WHERE vbeln IS INITIAL.

    IF rb_all <> 'X'.
      LOOP AT it_inb ASSIGNING <fs_inb>.
        IF ( <fs_inb>-wbsta = 'C' AND rb_open = 'X' )
          OR ( <fs_inb>-wbsta <> 'C'  AND rb_close = 'X' ).
          CLEAR: <fs_inb>.
        ENDIF.
      ENDLOOP.
      DELETE it_inb WHERE vbeln IS INITIAL.
    ENDIF.

    lt_temp_inb = it_inb.
    SORT lt_temp_inb BY vbeln.

    DELETE lt_temp_inb WHERE vbeln IS INITIAL.
    IF lt_temp_inb IS NOT INITIAL.
      SELECT
        vhcle
        vhcex
        mmsta
        vhvin
        /dbe/iobjguid
        vguid
        zint_color
        zext_color
        /dbe/spart
*        zprio_trans
        FROM vlcvehicle
        INTO TABLE it_vehicle
        FOR ALL ENTRIES IN lt_temp_inb
       WHERE vhcle = lt_temp_inb-charg.
      IF sy-subrc = 0 AND it_vehicle IS NOT INITIAL.
        SELECT
          /dbe/v_imodel~product_guid
          /dbe/v_imodel~mcodesd
          /dbe/v_imodel~modyear
          /dbe/v_imodelt~text1
          INTO TABLE it_model
          FROM /dbe/v_imodel
          INNER JOIN /dbe/v_imodelt
          ON /dbe/v_imodel~product_guid = /dbe/v_imodelt~product_guid
          FOR ALL ENTRIES IN it_vehicle
          WHERE /dbe/v_imodel~product_guid = it_vehicle-/dbe/iobjguid
          AND /dbe/v_imodelt~langu = 'E'.

        SELECT qmnum /dbe/demo_veh FROM  qmsm INTO TABLE lt_qmsm
              FOR ALL ENTRIES IN it_vehicle
              WHERE /dbe/demo_veh EQ it_vehicle-vguid.

      ENDIF.
    ENDIF.
    SELECT werks name1 FROM t001w
      INTO TABLE it_werks.

*    SELECT * FROM ydbmc_plant_comm
*      INTO TABLE it_plant_map.

    SELECT * FROM cvlc02t
              INTO TABLE lt_status WHERE spras EQ 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data .
  DATA : ts_inb     TYPE ty_inb,
         ts_po      TYPE ty_po,
         ts_vbup    TYPE ty_vbup,
         ts_vehicle TYPE ty_vehicle,
         ts_model   TYPE ty_model,
         ts_output  TYPE ty_output,
         it_dd07va  TYPE TABLE OF dd07v,
         ts_dd07va  TYPE  dd07v,
         ts_makt    TYPE  ty_makt,
         it_dd07vb  TYPE TABLE OF dd07v.


  LOOP AT it_inb INTO ts_inb.
    MOVE-CORRESPONDING ts_inb TO ts_output.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = ts_output-meins
      IMPORTING
        output         = ts_output-meins
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE it_makt INTO ts_makt
    WITH KEY matnr = ts_inb-matnr.
    IF sy-subrc = 0.
      ts_output-maktx = ts_makt-maktx.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ts_output-charg
      IMPORTING
        output = ts_output-charg.

    CALL FUNCTION 'DD_DOMA_GET'
      EXPORTING
        domain_name   = 'VLSTK'
        langu         = sy-langu
        withtext      = 'X'
      TABLES
        dd07v_tab_a   = it_dd07va
        dd07v_tab_n   = it_dd07vb
      EXCEPTIONS
        illegal_value = 1
        op_failure    = 2
        OTHERS        = 3.
    IF sy-subrc = 0.
      READ TABLE it_dd07va INTO ts_dd07va
      WITH KEY domvalue_l = ts_inb-vlstk.
      IF sy-subrc = 0.
        ts_output-vlstk_st = ts_dd07va-ddtext.
      ENDIF.
    ENDIF.

    READ TABLE it_po INTO ts_po
    WITH KEY ebeln = ts_inb-vgbel
    ebelp = ts_inb-vgpos+1(5).
    IF sy-subrc = 0.
      ts_output-netwr = ts_po-netwr.
      ts_output-effwr = ts_po-effwr.
      ts_output-menge = ts_po-menge.
      ts_output-balance = ts_output-menge - ts_output-lfimg.
    ENDIF.

    READ TABLE it_vbup INTO ts_vbup
    WITH KEY vbeln = ts_inb-vbeln
    posnr = ts_inb-posnr.
    IF sy-subrc = 0.
      ts_output-wbsta = ts_vbup-wbsta.
      CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name   = 'STATV'
          langu         = sy-langu
          withtext      = 'X'
        TABLES
          dd07v_tab_a   = it_dd07va
          dd07v_tab_n   = it_dd07vb
        EXCEPTIONS
          illegal_value = 1
          op_failure    = 2
          OTHERS        = 3.
      IF sy-subrc = 0.
        READ TABLE it_dd07va INTO ts_dd07va
        WITH KEY domvalue_l = ts_vbup-wbsta.
        IF sy-subrc = 0.
          ts_output-wbsta_st = ts_dd07va-ddtext.
        ENDIF.
      ENDIF.

      ts_output-pksta = ts_vbup-pksta.
      CLEAR :it_dd07va,ts_dd07va.
      CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name   = 'STATV_PKST'
          langu         = sy-langu
          withtext      = 'X'
        TABLES
          dd07v_tab_a   = it_dd07va
          dd07v_tab_n   = it_dd07vb
        EXCEPTIONS
          illegal_value = 1
          op_failure    = 2
          OTHERS        = 3.
      IF sy-subrc = 0.
        READ TABLE it_dd07va INTO ts_dd07va
        WITH KEY domvalue_l = ts_vbup-pksta.
        IF sy-subrc = 0.
          ts_output-pksta_st = ts_dd07va-ddtext.
        ENDIF.
      ENDIF.
    ENDIF.

    READ TABLE it_vehicle INTO ts_vehicle
    WITH KEY vhcle = ts_inb-charg.
    IF sy-subrc = 0.
      ts_output-vhcex = ts_vehicle-vhcex.
      ts_output-vhvin = ts_vehicle-vhvin.
      ts_output-vhcle = ts_vehicle-vhcle.
      ts_output-mmsta = ts_vehicle-mmsta.
*      ts_output-zprio_trans = ts_vehicle-zprio_trans.
      READ TABLE lt_status INTO ls_status WITH KEY statu = ts_vehicle-mmsta.
      IF sy-subrc EQ 0.
        ts_output-statut = ls_status-statut.
      ENDIF.
      ts_output-vguid = ts_vehicle-vguid.
      ts_output-zint_color = ts_vehicle-zint_color.
      ts_output-zext_color = ts_vehicle-zext_color.
      READ TABLE it_model INTO ts_model
        WITH KEY product_guid = ts_vehicle-/dbe/iobjguid.
      IF sy-subrc = 0.
        ts_output-mcodesd = ts_model-mcodesd.
        ts_output-modyear = ts_model-modyear.
        ts_output-motext1 = ts_model-motext1.
      ENDIF.

      READ TABLE lt_qmsm INTO ls_qmsm WITH KEY /dbm/demo_veh = ts_vehicle-vguid.
      IF sy-subrc EQ 0.
        ts_output-qmnum = ls_qmsm-qmnum.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ts_output-charg
        IMPORTING
          output = ts_output-charg.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ts_output-vhcle
        IMPORTING
          output = ts_output-vhcle.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ts_output-matnr
        IMPORTING
          output = ts_output-matnr.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ts_output-vbeln
        IMPORTING
          output = ts_output-vbeln.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ts_output-vgbel
        IMPORTING
          output = ts_output-vgbel.

    ENDIF.
    APPEND ts_output TO it_output.
    CLEAR : ts_output,
            ts_model,
            ts_vehicle,
            ts_inb,
            ts_vbup,
            ts_po.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_data .

  DATA : it_events2 TYPE slis_t_event.
  DATA : ts_events2 TYPE slis_alv_event,
         it_sort    TYPE  slis_t_sortinfo_alv,
         ts_sort    LIKE LINE OF it_sort.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    IMPORTING
      et_events = it_events2.
  IF sy-subrc <> 0.
  ENDIF.

  MODIFY it_events2 FROM ts_events2 INDEX sy-tabix .

*  for hotspot
  ts_events2-name =  TEXT-u01.
  ts_events2-form = TEXT-u01.
  APPEND ts_events2 TO it_events2 .
*  wa_layout-no_header = 'X'.
* Set field catalog
  PERFORM f_create_catalog.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
*     i_grid_title             = TEXT-t01
      i_callback_pf_status_set = 'SUB_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = wa_layout
      it_sort                  = it_sort
      it_fieldcat              = it_fcat "PASS FIELD CATALOG TO ALV
      i_screen_start_column    = 0
      i_screen_start_line      = 0
      i_screen_end_column      = 0
      i_screen_end_line        = 0
      it_events                = it_events2
      i_save                   = 'A'
    TABLES
      t_outtab                 = it_output
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  sub_pf_status
*&---------------------------------------------------------------------*
*  Sub-Routine to Set the PF status
*----------------------------------------------------------------------*
FORM sub_pf_status USING rt_extab TYPE slis_t_extab..
  SET PF-STATUS 'YSTANDARD'.
ENDFORM.                    "sub_pf_status
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_catalog .
  DATA lv_col TYPE i VALUE 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b37.
  wa_fcat-seltext_m = TEXT-v37 .
  wa_fcat-outputlen = 10.
  wa_fcat-checkbox  = 'X'.
  wa_fcat-input     = 'X'.
  wa_fcat-key       = abap_true.
  wa_fcat-edit       = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

*  wa_fcat-col_pos = lv_col .
*  wa_fcat-fieldname = TEXT-b25.
*  wa_fcat-seltext_m = TEXT-v25 .
*  wa_fcat-outputlen = 10.
*  wa_fcat-lowercase = 'X'.
*  wa_fcat-key = abap_true.
*
*  APPEND wa_fcat TO it_fcat .
*  CLEAR wa_fcat .
*  lv_col = lv_col + 1.



  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b01.
  wa_fcat-seltext_m = TEXT-v01 .
  wa_fcat-outputlen = 20.
  wa_fcat-lowercase = 'X'.
  wa_fcat-key = abap_true.
  wa_fcat-hotspot = abap_true.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b02 .
  wa_fcat-seltext_m = TEXT-v02 .
  wa_fcat-outputlen = 16.
  wa_fcat-lowercase = 'X'.
  wa_fcat-key = abap_true.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b28 .
  wa_fcat-seltext_m = TEXT-v28 .
  wa_fcat-outputlen = 20.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b03 .
  wa_fcat-seltext_m = TEXT-v03 .
  wa_fcat-outputlen = 45.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.


  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b04 .
  wa_fcat-hotspot = abap_true.
  wa_fcat-seltext_m = TEXT-v04 .
  wa_fcat-outputlen = 28.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b05 .
  wa_fcat-seltext_m = TEXT-v05 .
  wa_fcat-outputlen = 40.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b06 .
  wa_fcat-seltext_m = TEXT-v06 .
  wa_fcat-decimals_out = 0.
  wa_fcat-outputlen = 23.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b07 .
  wa_fcat-seltext_m = TEXT-v07 .
  wa_fcat-outputlen = 10.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b08 .
  wa_fcat-seltext_m = TEXT-v08 .
  wa_fcat-hotspot = abap_true.
  wa_fcat-outputlen = 20.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.
  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b09 .
  wa_fcat-seltext_m = TEXT-v09 .
  wa_fcat-outputlen = 16.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b25 .
  wa_fcat-seltext_m = TEXT-v25 .
  wa_fcat-decimals_out = 0.
  wa_fcat-outputlen = 23.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b26 .
  wa_fcat-seltext_m = TEXT-v26 .
  wa_fcat-decimals_out = 0.
  wa_fcat-outputlen = 23.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b27 .
  wa_fcat-seltext_m = TEXT-v27 .
  wa_fcat-outputlen = 23.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b10 .
  wa_fcat-seltext_m = TEXT-v10 .
  wa_fcat-outputlen = 25.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b11 .
  wa_fcat-seltext_m = TEXT-v11 .
  wa_fcat-outputlen = 25.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b12 .
  wa_fcat-seltext_m = TEXT-v12 .
  wa_fcat-outputlen = 50.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b33 .
  wa_fcat-seltext_m = TEXT-v33 .
  wa_fcat-outputlen = 14.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b34 .
  wa_fcat-seltext_m = TEXT-v34 .
  wa_fcat-outputlen = 50.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b13 .
  wa_fcat-seltext_m = TEXT-v13 .
  wa_fcat-outputlen = 10.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b14 .
  wa_fcat-seltext_m = TEXT-v14 .
  wa_fcat-outputlen = 50.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b15 .
  wa_fcat-seltext_m = TEXT-v15 .
  wa_fcat-outputlen = 14.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b16 .
  wa_fcat-seltext_m = TEXT-v16 .
  wa_fcat-outputlen = 10.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b17 .
  wa_fcat-seltext_m = TEXT-v17 .
  wa_fcat-outputlen = 10.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b18 .
  wa_fcat-seltext_m = TEXT-v18 .
  wa_fcat-hotspot = abap_true.
  wa_fcat-outputlen = 20.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b19 .
  wa_fcat-seltext_m = TEXT-v19 .
  wa_fcat-outputlen = 30.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b20 .
  wa_fcat-seltext_m = TEXT-v20 .
  wa_fcat-outputlen = 50.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b21 .
  wa_fcat-seltext_m = TEXT-v21 .
  wa_fcat-outputlen = 20.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b22 .
  wa_fcat-seltext_m = TEXT-v22 .
  wa_fcat-outputlen = 50.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b23 .
  wa_fcat-seltext_m = TEXT-v23 .
  wa_fcat-outputlen = 50.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b30 .
  wa_fcat-seltext_m = TEXT-v30 .
  wa_fcat-hotspot = abap_true.
  wa_fcat-outputlen = 25.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b31 .
  wa_fcat-seltext_m = TEXT-v31 .
  wa_fcat-outputlen = 30.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b32 .
  wa_fcat-seltext_m = TEXT-v32 .
  wa_fcat-outputlen = 30.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b36.
  wa_fcat-seltext_m = TEXT-v36 .
  wa_fcat-outputlen = 30.
  wa_fcat-lowercase = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_fcat-col_pos = lv_col .
  wa_fcat-fieldname = TEXT-b35 .
  wa_fcat-seltext_m = TEXT-v35.
  wa_fcat-outputlen = 20.
  wa_fcat-checkbox = 'X'.
  APPEND wa_fcat TO it_fcat .
  CLEAR wa_fcat .
  lv_col = lv_col + 1.

  wa_layout-zebra = abap_true .
  wa_layout-colwidth_optimize = abap_true .

ENDFORM.
FORM user_command USING p_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  TYPES: BEGIN OF ty_msg,
           type    TYPE icon_d,
           message TYPE msgtxt,
         END OF ty_msg.
  DATA: lt_batch     TYPE TABLE OF bdcdata,
        ls_batch     LIKE LINE OF lt_batch,
        it_param     TYPE /dbe/v_para_t,
        ts_param     LIKE LINE OF it_param,
        lv_trans     TYPE char20,
        ts_output    TYPE ty_output,
        lt_rowid     TYPE lvc_t_roid,
        ls_rowid     TYPE lvc_s_roid,
        ls_output    TYPE ty_output,
        ls_veh_inb   TYPE zst_veh_inb_data,
        lt_veh_inb   TYPE ztt_veh_inb_data,
        lv_tabix     TYPE sy-tabix,
        lf_formname  TYPE tdsfname VALUE 'YEWM_VEH_DLV_NOTE',
        ts_ctrlparms TYPE ssfctrlop,
        lf_fm_name   TYPE rs38l_fnam,
        lv_len       TYPE int1,
        lv_comm_ref  TYPE numc2,
*        ls_plant_map TYPE ydbmc_plant_comm,
        ls_werks     TYPE ty_werks,
        ls_msg       TYPE ty_msg,
        lt_msg       TYPE TABLE OF ty_msg,
        lt_fcat      TYPE slis_t_fieldcat_alv,
        ls_fcat      TYPE slis_fieldcat_alv.

  IF rs_selfield-value IS NOT INITIAL.
    CASE rs_selfield-fieldname.
      WHEN 'VHCLE'.
        DATA lv_vhcle TYPE vlc_vhcle.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = rs_selfield-value
          IMPORTING
            output = lv_vhcle.

        READ TABLE it_output INTO ts_output
        WITH KEY vhcle = rs_selfield-value.
        lv_trans = '/DBE/VM'.
        ts_param-paramid = 'VGUID'.
        ts_param-paramval = ts_output-vguid.
        APPEND ts_param TO it_param.
        ts_param-paramid = 'VMODE'.
        ts_param-paramval = '0'.
        APPEND ts_param TO it_param.
        CALL FUNCTION '/DBE/VM08_TRANSACTION_CALL'
          EXPORTING
            iv_trans_name = lv_trans
            it_param      = it_param.
      WHEN 'VBELN'.
        DATA lv_vbeln TYPE vbeln.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = rs_selfield-value
          IMPORTING
            output = lv_vbeln.

        SET PARAMETER ID 'VLM' FIELD lv_vbeln.
        CALL TRANSACTION 'VL33N' AND SKIP FIRST SCREEN.
      WHEN 'VGBEL'.
        DATA lv_ebeln TYPE ebeln.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = rs_selfield-value
          IMPORTING
            output = lv_ebeln.
        SET PARAMETER ID 'BES' FIELD lv_ebeln .
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      WHEN 'MATNR'.
        DATA lv_matnr TYPE matnr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = rs_selfield-value
          IMPORTING
            output = lv_matnr.
        SET PARAMETER ID 'MAT' FIELD  lv_matnr.
        SET PARAMETER ID 'MXX' FIELD 'K'.
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      WHEN 'QMNUM'.
        DATA : lv_qmnum TYPE qmnum.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = rs_selfield-value
          IMPORTING
            output = lv_qmnum.
        SET PARAMETER ID 'IQM' FIELD lv_qmnum.
        CALL TRANSACTION 'IQS2' AND SKIP FIRST SCREEN.
    ENDCASE.
  ENDIF.

  CASE p_ucomm.
    WHEN '&REC'.

* to reflect the data changed into internal table
      DATA : ref_grid TYPE REF TO cl_gui_alv_grid. "new
      IF ref_grid IS INITIAL.
        CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
          IMPORTING
            e_grid = ref_grid.
      ENDIF.
      IF NOT ref_grid IS INITIAL.
        CALL METHOD ref_grid->check_changed_data.

        CALL METHOD ref_grid->get_selected_rows
          IMPORTING
*           et_index_rows =     " Indexes of Selected Rows
            et_row_no = lt_rowid.
      ENDIF.

      DATA: lt_temp TYPE TABLE OF ty_output.
      DATA ls_vbkok TYPE vbkok.
      DATA : lt_vbpok TYPE STANDARD TABLE OF vbpok,
             ls_vbpok TYPE vbpok.
      DATA : lt_prott TYPE STANDARD TABLE OF prott,
             ls_prott TYPE prott.

      DATA : lv_error_any     TYPE c.

*      CLEAR: lt_temp.
*      LOOP AT lt_rowid INTO ls_rowid.
*        READ TABLE it_output INTO ls_output
*          INDEX ls_rowid-row_id.
*        IF sy-subrc = 0.
*
*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              input  = ls_output-vbeln
*            IMPORTING
*              output = ls_output-vbeln.
*
*          APPEND ls_output TO lt_temp.
*        ENDIF.
*      ENDLOOP.
*      SORT lt_temp ASCENDING BY vbeln.
*      LOOP AT lt_temp INTO DATA(ls_temp).
      LOOP AT it_output INTO DATA(ls_temp) WHERE sel = 'X'.
        DATA(ls_temp1) = ls_temp.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_temp-vbeln
          IMPORTING
            output = ls_temp-vbeln.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_temp1-vbeln
          IMPORTING
            output = ls_temp1-vbeln.

        ls_vbkok-vbeln_vl = ls_temp-vbeln.
        ls_vbkok-wabuc = 'X'.
        ls_vbkok-spe_auto_gr = 'X'.
        ls_vbkok-kzebu = 'X'.
        ls_vbkok-bolnr = ls_temp1-bolnr.

        ls_vbpok-vbeln_vl = ls_temp1-vbeln.
        ls_vbpok-posnr_vl = ls_temp1-posnr.
        ls_vbpok-ebumg_bme = 1.
        APPEND ls_vbpok TO lt_vbpok.

        AT END OF vbeln.

          CLEAR: lt_prott, lv_error_any.
          CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
            EXPORTING
              vbkok_wa      = ls_vbkok
              synchron      = 'X'
              commit        = 'X'
              delivery      = ls_temp-vbeln
            IMPORTING
              ef_error_any  = lv_error_any
            TABLES
              vbpok_tab     = lt_vbpok
              prot          = lt_prott
            EXCEPTIONS
              error_message = 1
              OTHERS        = 2.

          READ TABLE lt_prott INTO ls_prott WITH KEY msgty = 'E'.
          IF sy-subrc <> 0.
            COMMIT WORK.
            LOOP AT lt_vbpok INTO ls_vbpok.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                EXPORTING
                  input  = ls_vbpok-vbeln_vl
                IMPORTING
                  output = ls_vbpok-vbeln_vl.

              READ TABLE it_output INTO ls_temp WITH KEY vbeln = ls_vbpok-vbeln_vl posnr = ls_vbpok-posnr_vl sel = 'X'.
              IF sy-subrc EQ 0.

                DATA: ls_vlchistory TYPE vlchistory,
                      ls_vehicle    TYPE vlcvehicle,
                      ls_vlcreceipt TYPE vlcgreceipt.

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = ls_temp-vbeln
                  IMPORTING
                    output = ls_temp-vbeln.


                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = ls_temp-posnr
                  IMPORTING
                    output = ls_temp-posnr.


                SELECT SINGLE vbeln posnn FROM vbfa INTO ( ls_vlcreceipt-mblnr , ls_vlcreceipt-mblpo )
                       WHERE vbelv = ls_temp-vbeln AND posnv = ls_temp-posnr AND vbtyp_n = 'R'.
                IF sy-subrc EQ 0.
                  UPDATE vlcvehicle SET lgort = 'V001' mmsta = 'QP40' avail = 'Z3' "zveh_bin = lv_bin
                                    WHERE vguid EQ ls_temp-vguid AND
                                          sdsta = ' '.
                  IF sy-subrc <> 0.
                    UPDATE vlcvehicle SET lgort = 'V001' mmsta = 'QP40' avail = 'Z3' " zveh_bin = lv_bin
                                    WHERE vguid EQ ls_temp-vguid.
                  ENDIF.

                  CLEAR: ls_vlchistory.
                  GET TIME STAMP FIELD ls_vlchistory-tstmp.
                  ls_vlchistory-vguid = ls_temp-vguid.
                  ls_vlchistory-actdoctype = 'QGOR'.
                  ls_vlchistory-action = 'QGOR'.
                  SELECT SINGLE * FROM vlcvehicle
                    INTO ls_vehicle
                    WHERE vguid = ls_vlchistory-vguid.
                  IF sy-subrc = 0.
                    ls_vlchistory-cuobj = ls_vehicle-cuobj.
                    ls_vlchistory-mmctr = ls_vehicle-mmctr.
                    ls_vlchistory-mmsta_old = ls_vehicle-mmsta.
                    ls_vlchistory-mmsta_new = ls_vehicle-mmsta.
                    ls_vlchistory-sdctr = ls_vehicle-sdctr.
                    ls_vlchistory-sdsta_old = ls_vehicle-sdsta.
                    ls_vlchistory-sdsta_new = ls_vehicle-sdsta.
                    ls_vlchistory-kunnr = ls_vehicle-kunnr.
                    ls_vlchistory-ernam = sy-uname.
                    ls_vlchistory-/dbe/bustype = ls_vehicle-/dbe/bustype.
                    MODIFY vlchistory FROM ls_vlchistory.
                    IF sy-subrc = 0.
*                      COMMIT WORK.

                      SELECT SINGLE vbeln posnn FROM vbfa
                        INTO ( ls_vlcreceipt-mblnr , ls_vlcreceipt-mblpo )
                        WHERE vbelv = ls_temp-vbeln
                          AND posnv = ls_temp-posnr
                          AND vbtyp_n = 'R'.
                      IF sy-subrc = 0.
                        ls_vlcreceipt-vguid = ls_temp-vguid.
                        ls_vlcreceipt-tstmp = ls_vlchistory-tstmp.
                        ls_vlcreceipt-actdoctype = 'QGOR'.
                        ls_vlcreceipt-mjahr = sy-datum(4).
                        MODIFY vlcgreceipt FROM ls_vlcreceipt.
                      ENDIF.
                    ENDIF.
                  ENDIF.

                  COMMIT WORK.
                  WRITE icon_led_green TO ls_msg-type AS ICON.
                  MESSAGE s008(zmsg_vss01) WITH ls_temp-vbeln ls_temp-vhvin INTO ls_msg-message.
                  APPEND ls_msg TO lt_msg.
                  DELETE it_output WHERE vbeln = ls_vbpok-vbeln_vl  AND posnr = ls_vbpok-posnr_vl.
                ELSE.
                  WRITE icon_led_red TO ls_msg-type AS ICON.
                  MESSAGE s009(zmsg_vss01) WITH ls_temp-vbeln ls_temp-vhvin INTO ls_msg-message.
                  APPEND ls_msg TO lt_msg.
                ENDIF.
              ENDIF.

            ENDLOOP.

          ELSE.
            WRITE icon_led_red TO ls_msg-type AS ICON.
            LOOP AT lt_prott INTO ls_prott WHERE msgty = 'E'.
              MESSAGE ID ls_prott-msgid TYPE ls_prott-msgty NUMBER ls_prott-msgno
                WITH ls_prott-msgv1 ls_prott-msgv2 ls_prott-msgv3 ls_prott-msgv4
                INTO ls_msg-message.
              APPEND ls_msg TO lt_msg.
            ENDLOOP.
            MESSAGE s009(zmsg_vss01) WITH ls_temp-vbeln ls_temp-vhvin INTO ls_msg-message.
            APPEND ls_msg TO lt_msg.
          ENDIF.
          CLEAR : ls_vbkok,
        lt_vbpok,
        lt_prott.
        ENDAT.
      ENDLOOP.


      ls_fcat-fieldname = 'TYPE'.
      ls_fcat-tabname = 'LT_MSG'.
      ls_fcat-seltext_l = 'Type'.
      ls_fcat-icon = 'X'.
      APPEND ls_fcat TO lt_fcat.
      ls_fcat-fieldname = 'MESSAGE'.
      ls_fcat-tabname = 'LT_MSG'.
      ls_fcat-seltext_l = 'Message'.
      ls_fcat-outputlen = 80.
      APPEND ls_fcat TO lt_fcat.

      IF lt_msg IS NOT INITIAL.
        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
            it_fieldcat           = lt_fcat    " Field catalog with field descriptions
            i_screen_start_column = 15    " Coordinates for list in dialog box
            i_screen_start_line   = 5    " Coordinates for list in dialog box
            i_screen_end_column   = 100    " Coordinates for list in dialog box
            i_screen_end_line     = 15    " Coordinates for list in dialog box
          TABLES
            t_outtab              = lt_msg    " Table with data to be displayed
          EXCEPTIONS
            program_error         = 1
            OTHERS                = 2.
      ENDIF.
* refresh the ALV Grid output from internal table
      rs_selfield-refresh = 'X'.
    WHEN '&PRT'.
      IF ref_grid IS INITIAL.
        CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
          IMPORTING
            e_grid = ref_grid.
      ENDIF.
      IF NOT ref_grid IS INITIAL.
        CALL METHOD ref_grid->check_changed_data.

        CALL METHOD ref_grid->get_selected_rows
          IMPORTING
*           et_index_rows =     " Indexes of Selected Rows
            et_row_no = lt_rowid.   " Numeric IDs of Selected Rows
        LOOP AT lt_rowid INTO ls_rowid.
          CLEAR: ls_veh_inb.
          lv_tabix = sy-tabix.
          READ TABLE it_output INTO ls_output INDEX ls_rowid-row_id.
          IF sy-subrc = 0.
            ls_veh_inb-seqno = lv_tabix.
*            ls_veh_inb-plant = ls_output-werks.
            ls_veh_inb-cmsn_no = ls_output-vhcex.
            lv_len = strlen( ls_veh_inb-cmsn_no ) - 5.
            IF lv_len GE 0.
              lv_comm_ref = ls_veh_inb-cmsn_no+lv_len(2).
*              READ TABLE it_plant_map INTO ls_plant_map
*                WITH KEY cmsn_ref_no = lv_comm_ref .
              IF sy-subrc = 0.
*                READ TABLE it_werks INTO ls_werks
*                  WITH KEY werks = ls_plant_map-plant.
                IF sy-subrc = 0.
                  ls_veh_inb-plant = ls_werks-name1.
                ENDIF.
              ENDIF.
            ENDIF.
            ls_veh_inb-inbdate = ls_output-lfdat.
            ls_veh_inb-int_veh_no = ls_output-vhcle.
            ls_veh_inb-model = ls_output-mcodesd.
            ls_veh_inb-vessel_name = ls_output-traid.
            ls_veh_inb-vin = ls_output-vhvin.
            ls_veh_inb-division = ls_output-division.
            APPEND ls_veh_inb TO lt_veh_inb.
          ENDIF.
        ENDLOOP.
        IF lt_veh_inb IS NOT INITIAL.
          CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
            EXPORTING
              formname           = lf_formname
*             variant            = ' '
*             direct_call        = ' '
            IMPORTING
              fm_name            = lf_fm_name
            EXCEPTIONS
              no_form            = 1
              no_function_module = 2
              OTHERS             = 3.
          IF sy-subrc = 0.
            CALL FUNCTION lf_fm_name
              EXPORTING
                control_parameters = ts_ctrlparms
                it_data            = lt_veh_inb
*              IMPORTING
*               job_output_info    = ls_job_info
              EXCEPTIONS
                formatting_error   = 1
                internal_error     = 2
                send_error         = 3
                user_canceled      = 4
                OTHERS             = 5.
          ENDIF.

        ENDIF.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
