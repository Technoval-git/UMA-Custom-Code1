*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHI_ENHF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form f_init_1501
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_init_1501 .
  CONSTANTS: lc_otype TYPE plog-otype VALUE 'O',
             lc_ec_nm TYPE char03 VALUE 'EC_'.

  DATA:
    lv_char(40)      TYPE c,
    lv_date          TYPE /dbe/v_ireghist-regdate,
    ls_registration  TYPE LINE OF /dbe/iobj_data_multi_com_s-/dbe/v_ireghist,
    ls_kna1          TYPE kna1,
    ls_adrc          TYPE adrc,
    lt_adrc          TYPE STANDARD TABLE OF adrc,
    lv_street        TYPE string,
    ls_partner       TYPE LINE OF /dbe/iobj_data_multi_com_s-/dbe/v_ipartner,
    ls_modelt        LIKE LINE OF gs_iobj_multi-/dbe/v_imodelt, "/DBE/V_IMODELT_TXT_TAB.
    lv_str           TYPE string,
    lv_str_u         TYPE string,
    lv_descr         TYPE /dbe/descr,
    lv_stext         TYPE p1000-stext,
    lv_objid         TYPE plog-objid,
    lv_plvar         TYPE plvar,
    lo_factory       TYPE REF TO /dbe/cl_veh_md_reader_factory,
    lo_reader        TYPE REF TO /dbe/if_veh_md_reader,
    lo_result        TYPE REF TO /dbe/if_veh_md_result,
    lo_division      TYPE REF TO /dbe/cl_veh_md_key_division,
    lr_exroot        TYPE REF TO cx_root,
    lv_text(240)     TYPE c,
    lt_text          LIKE TABLE OF lv_text,
    lv_accdesp       TYPE string,
*  lt_stream         TYPE cocf_t_stream,
    lv_error_message TYPE string,
    ls_addr          TYPE szadr_addr1_complete,
    ls_addr1         TYPE szadr_addr1_line.

  FIELD-SYMBOLS : <ls_igenopt> TYPE LINE OF /dbe/iobj_data_multi_com_s-/dbe/v_igenopt.

  MOVE-CORRESPONDING gs_vlcdiavehi TO /dbe/vehordcom.

* Fill the last service date
  PERFORM f_get_last_service_date USING gs_vlcdiavehi-vguid CHANGING /dbe/scr_data_overview-last_service_date.

* --- Fill Registration data to structur /DBE/VEHORDCOM
* --- Move customer registration date --------------------------------
  CLEAR: lv_date.
  LOOP AT gs_iobj_multi-/dbe/v_ireghist INTO ls_registration
    WHERE regtype = '03'.
    IF ls_registration-regdate > lv_date.
      MOVE ls_registration-regdate TO lv_date.
    ENDIF.
  ENDLOOP.
  IF NOT lv_date IS INITIAL.
    MOVE lv_date TO /dbe/vehordcom-regdate_cu.
  ENDIF.

  lv_text = TEXT-ba1.
  lv_accdesp = TEXT-ba1.
  APPEND lv_text TO lt_text.

* --- Create vehicle textcontainer -----------------------------------
  IF gcl_vehicle_con IS INITIAL.
    CREATE OBJECT gcl_vehicle_con
      EXPORTING
        container_name = 'VEHICLE_CONTAINER'
      EXCEPTIONS
        OTHERS         = 1.
    CREATE OBJECT gcl_vehicle_edit
      EXPORTING
        parent = gcl_vehicle_con
      EXCEPTIONS
        OTHERS = 1.

    CALL METHOD gcl_vehicle_edit->set_accdescription
      EXPORTING
        accdescription    = lv_accdesp
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3.
    CALL METHOD gcl_vehicle_edit->set_readonly_mode
      EXPORTING
        readonly_mode = '1'.
    CALL METHOD gcl_vehicle_edit->set_statusbar_mode
      EXPORTING
        statusbar_mode = '0'.
    CALL METHOD gcl_vehicle_edit->set_toolbar_mode
      EXPORTING
        toolbar_mode = '0'.
  ENDIF.

* --- Fill the vehicle textcontainer ---------------------------------
  CLEAR: gt_textlines[].

  CLEAR: lv_char.

* Model Text
  READ TABLE gs_iobj_multi-/dbe/v_imodelt INTO ls_modelt
  WITH KEY langu = sy-langu.

  MOVE ls_modelt-text1
    TO lv_char.

  PERFORM textlines_append USING lv_char.

  SELECT SINGLE descr FROM /dbe/v_classt INTO (lv_char)
    WHERE vclass = gs_iobj_single-/dbe/v_imodel-vclass
    AND   spras   = sy-langu.
  IF sy-subrc <> 0.
    lv_char = gs_iobj_single-/dbe/v_imodel-vclass.
  ENDIF.
  PERFORM textlines_append USING lv_char.

  CLEAR: lv_char.
  SELECT SINGLE descr FROM /dbe/v_bodyt INTO (lv_char)
    WHERE bodtype = gs_iobj_single-/dbe/v_imodel-bodtype
    AND   spras   = sy-langu.
  IF sy-subrc <> 0.
    lv_char = gs_iobj_single-/dbe/v_imodel-bodtype.
  ENDIF.
  PERFORM textlines_append USING lv_char.

  CLEAR lv_char.
* Engine info
  IF NOT  gs_iobj_single-/dbe/v_imodel-cubic_cap IS INITIAL.
    MOVE gs_iobj_single-/dbe/v_imodel-cubic_cap
      TO lv_str.
    MOVE gs_iobj_single-/dbe/v_imodel-cubic_cap_u
      TO lv_str_u.
    CONCATENATE lv_str lv_str_u INTO lv_char.
    CONDENSE lv_char NO-GAPS.
  ENDIF.

  IF NOT gs_iobj_single-/dbe/v_imodel-eng_perfo IS INITIAL.
    MOVE gs_iobj_single-/dbe/v_imodel-eng_perfo
      TO lv_str.
    MOVE gs_iobj_single-/dbe/v_imodel-eng_perfo_u
      TO lv_str_u.
    CONCATENATE lv_str lv_str_u INTO lv_str.
    CONDENSE lv_str NO-GAPS.
    CONCATENATE lv_char lv_str INTO lv_char SEPARATED BY space.
  ENDIF.

  IF NOT gs_iobj_single-/dbe/v_imodel-eng_fuel IS INITIAL.
    SELECT SINGLE descr FROM /dbe/v_fltypet INTO (lv_str)
      WHERE engfuel = gs_iobj_single-/dbe/v_imodel-eng_fuel
      AND   spras   = sy-langu.
    IF sy-subrc <> 0.
      lv_str = gs_iobj_single-/dbe/v_imodel-eng_fuel.
    ENDIF.
    CONCATENATE lv_char lv_str INTO lv_char SEPARATED BY space.
  ENDIF.

  PERFORM textlines_append USING lv_char.

* --- Delete the text and load new file into textedit ----------------
  CALL METHOD gcl_vehicle_edit->delete_text.
  CALL METHOD gcl_vehicle_edit->set_text_as_r3table
    EXPORTING
      table = gt_textlines.

* --- Create customer textcontainer ----------------------------------
  IF gcl_cust_con IS INITIAL.
    CREATE OBJECT gcl_cust_con
      EXPORTING
        container_name = 'CUSTOMER_CONTAINER'
      EXCEPTIONS
        OTHERS         = 1.
    CREATE OBJECT gcl_cust_edit
      EXPORTING
        parent = gcl_cust_con
      EXCEPTIONS
        OTHERS = 1.

    CALL METHOD gcl_cust_edit->set_accdescription
      EXPORTING
        accdescription    = lv_accdesp
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3.
    CALL METHOD gcl_cust_edit->set_readonly_mode
      EXPORTING
        readonly_mode = '1'.
    CALL METHOD gcl_cust_edit->set_statusbar_mode
      EXPORTING
        statusbar_mode = '0'.
    CALL METHOD gcl_cust_edit->set_toolbar_mode
      EXPORTING
        toolbar_mode = '0'.
  ENDIF.

* --- Fill the customer textcontainer --------------------------------
  CLEAR: gt_textlines[].

  READ TABLE gs_iobj_multi-/dbe/v_ipartner
    WITH KEY kunnr = gs_vlcdiavehi-kunnr
             parvw = 'AG'
    INTO ls_partner.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'ADDR_GET_COMPLETE'
      EXPORTING
        addrnumber              = ls_partner-adrnr
        blk_excpt               = abap_true
      IMPORTING
        addr1_complete          = ls_addr
      EXCEPTIONS
        parameter_error         = 1
        address_not_exist       = 2
        internal_error          = 3
        wrong_access_to_archive = 4
        address_blocked         = 5
        OTHERS                  = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      LOOP AT ls_addr-addr1_tab INTO ls_addr1.
        PERFORM textlines_append USING ls_addr1-data-name1.
        PERFORM textlines_append USING ls_addr1-data-name2.
        CONCATENATE ls_addr1-data-street ls_addr1-data-house_num1
          INTO lv_street SEPARATED BY space.
        PERFORM textlines_append USING lv_street.
        PERFORM textlines_append USING space.
        CLEAR: lv_char.
        CONCATENATE ls_addr1-data-post_code1 ls_addr1-data-city1 INTO lv_char
          SEPARATED BY space.
        PERFORM textlines_append USING lv_char.
      ENDLOOP.
    ENDIF.
  ELSE.
    CALL FUNCTION 'KNA1_READ_SINGLE'
      EXPORTING
        id_kunnr            = gs_vlcdiavehi-kunnr
        id_cvp_behavior     = /dbe/cl_bcvp_block_and_mask=>c_cvp_beh_default
      IMPORTING
        es_kna1             = ls_kna1
      EXCEPTIONS
        not_found           = 1
        input_not_specified = 2
        kunnr_blocked       = 3
        OTHERS              = 4.
    IF sy-subrc = 0.
      PERFORM textlines_append USING ls_kna1-name1.
      PERFORM textlines_append USING ls_kna1-name2.
      PERFORM textlines_append USING ls_kna1-stras.
      PERFORM textlines_append USING space.
      CLEAR: lv_char.
      CONCATENATE ls_kna1-pstlz ls_kna1-ort01 INTO lv_char
        SEPARATED BY space.
      PERFORM textlines_append USING lv_char.
    ENDIF.
  ENDIF.
* --- Delete the text and load new file into textedit ----------------
  CALL METHOD gcl_cust_edit->delete_text.
  CALL METHOD gcl_cust_edit->set_text_as_r3table
    EXPORTING
      table = gt_textlines.

* --- Select descriptions --------------------------------------------
  SELECT SINGLE descr FROM /dbe/v_bustypet INTO (cnt_label_business)
    WHERE bustype = gs_vlcdiavehi-/dbe/bustype
    AND   spras   = sy-langu.
  IF sy-subrc <> 0.
    CLEAR: cnt_label_business.
  ENDIF.

  cnt_label_primar = gs_vlcdiavehi-mmstatxt.
  cnt_label_secu   = gs_vlcdiavehi-sdstatxt.

  SELECT SINGLE name1 FROM t001w INTO (cnt_label_werk)
    WHERE werks = gs_vlcdiavehi-werks.
  IF sy-subrc <> 0.
    CLEAR: cnt_label_werk.
  ENDIF.

  SELECT SINGLE lgobe FROM t001l INTO (cnt_label_lgort)
    WHERE werks = gs_vlcdiavehi-werks
    AND   lgort = gs_vlcdiavehi-lgort.
  IF sy-subrc <> 0.
    CLEAR: cnt_label_lgort.
  ENDIF.

  SELECT SINGLE vtext FROM tvkot INTO (cnt_label_vkorg)
    WHERE spras = sy-langu
    AND   vkorg = gs_vlcdiavehi-/dbe/vkorg.
  IF sy-subrc <> 0.
    CLEAR: cnt_label_vkorg.
  ENDIF.

  SELECT SINGLE vtext FROM tvtwt INTO (cnt_label_vtweg)
    WHERE spras = sy-langu
    AND   vtweg = gs_vlcdiavehi-/dbe/vtweg.
  IF sy-subrc <> 0.
    CLEAR: cnt_label_vtweg.
  ENDIF.

  TRY.
      lo_factory = /dbe/cl_veh_md_reader_factory=>get_instance( ).
      TRY.
          lo_reader = lo_factory->create_reader( 'DIVISION' ).
          lo_division ?= lo_reader->createkey( ).
          lo_division->set_division( vlcdiavehi-/dbe/spart ).
          lo_result = lo_reader->read( lo_division ).
          tspat-vtext = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          tspat-vtext = ''.
      ENDTRY.
    CATCH cx_root INTO lr_exroot .
      lv_error_message = lr_exroot->if_message~get_longtext( ).
*     if something went wrong during reading short text, the shost text will be empty and error silently
*     dropped becasue it not effecting.
  ENDTRY.

* Text for DBM resource group
  CALL FUNCTION '/DBE/SCH_DB_READ_RESRPTXT'
    EXPORTING
      iv_resgrp = vlcdiavehi-/dbe/resgrp
*     IV_LANGU  = SY-LANGU
    IMPORTING
      ev_descr  = lv_descr
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc EQ 0.
    MOVE lv_descr
      TO cnt_label_resgrp.
  ELSE.
    CLEAR cnt_label_resgrp.
  ENDIF.

* Get Text for the org. unit
* First read the plan version

  CALL FUNCTION 'RH_GET_PLVAR'
    IMPORTING
      plvar    = lv_plvar
    EXCEPTIONS
      no_plvar = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Read the object

  MOVE vlcdiavehi-/dbe/objid
    TO lv_objid.

  CALL FUNCTION 'RH_READ_OBJECT'
    EXPORTING
      plvar     = lv_plvar
      otype     = lc_otype
      objid     = lv_objid
    IMPORTING
      stext     = lv_stext
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc EQ 0.
    MOVE lv_stext
      TO cnt_label_org_unit.
  ELSE.
    CLEAR cnt_label_org_unit.
  ENDIF.

* --- Fill the Color Group code ---------------------------------
  CLEAR: /dbe/vlcselvehi-/dbe/col_ext.
  LOOP AT gs_iobj_multi-/dbe/v_igenopt[] ASSIGNING <ls_igenopt>
                                        WHERE genopt IS NOT INITIAL.
    IF <ls_igenopt>-genopt+0(3) = lc_ec_nm.
      MOVE <ls_igenopt>-genopt+3(2) TO /dbe/vlcselvehi-/dbe/col_ext.
      EXIT.
    ENDIF.
  ENDLOOP.

* --- Get Vehicle Make Description ------------------------------
  CLEAR: /dbe/c_veh_maket-descr.
  IF /dbe/v_imodel-vmake IS NOT INITIAL.
    SELECT SINGLE descr FROM  /dbe/c_veh_maket
                        INTO  /dbe/c_veh_maket-descr
                        WHERE v_make = /dbe/v_imodel-vmake
                        AND   spras = sy-langu.
    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_init_1501

*---------------------------------------------------------------------*
*       FORM textlines_append                                         *
*---------------------------------------------------------------------*

* --- Add line to download table
FORM textlines_append USING lv_text.
  CLEAR: gs_textlines.
  gs_textlines-text = lv_text.
  APPEND gs_textlines TO gt_textlines.
ENDFORM.                    "textlines_append
