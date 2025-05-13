CLASS zcl_vss_wty_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS append_error
      IMPORTING
        !ix_error  TYPE REF TO zcx_error
        !iv_pnguid TYPE wty_pnguid
        !iv_msggrp TYPE wty_dflmsg .
    CLASS-METHODS trigger_ucomm_save .
    CLASS-METHODS trigger_version_pricing
      IMPORTING
        !is_pnwtyv_dia TYPE wty_pnwtyv_dia .
    CLASS-METHODS get_selected_version
      IMPORTING
        !is_pnwtyh_dia    TYPE wty_pnwtyh_dia
        !it_pnwtyv_dia    TYPE wty_pnwtyv_dia_tab
        !it_pvwty_dia     TYPE wty_pvwty_dia_tab OPTIONAL
      EXPORTING
        !es_pnwtyv_dia    TYPE wty_pnwtyv_dia
        !et_pvwty_dia_ver TYPE wty_pvwty_dia_tab
      RAISING
        zcx_error .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VSS_WTY_UTIL IMPLEMENTATION.


  METHOD append_error.

    LOOP AT ix_error->get_bapi_msgs( ) INTO DATA(ls_return).

      MESSAGE ID     ls_return-id
              TYPE   ls_return-type
              NUMBER ls_return-number
              WITH   ls_return-message_v1
                     ls_return-message_v2
                     ls_return-message_v3
              INTO   zcx_error=>mv_dummy.

      CALL FUNCTION 'WTY07_MESSAGE_PROCESSING_SYST'
        EXPORTING
          iv_dflmsg = iv_msggrp
          iv_pnguid = iv_pnguid.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_selected_version.

    DATA: lv_version_guid TYPE wty_guid,
          lt_pnwtyv_dia   LIKE it_pnwtyv_dia[].

    cl_ppeliwty_cntl=>selected_guids_get( IMPORTING ev_version_guid = lv_version_guid ).

    IF lv_version_guid IS NOT INITIAL.
      READ TABLE it_pnwtyv_dia INTO es_pnwtyv_dia WITH KEY pnguid = lv_version_guid.
      IF sy-subrc NE 0.
        MESSAGE e006(ydbm_id1_wty) INTO ZCX_ERROR=>mv_dummy.
        ZCX_ERROR=>raise_sy_msg( ).
      ENDIF.
    ELSE.
      "read last IV Version
      lt_pnwtyv_dia[] = it_pnwtyv_dia[].
      SORT lt_pnwtyv_dia[] BY versn DESCENDING.
      READ TABLE lt_pnwtyv_dia[] INTO es_pnwtyv_dia WITH KEY aktiv = abap_true kateg = pwty_kateg-iv.
      IF sy-subrc <> 0 .
        MESSAGE e006(ydbm_id1_wty) INTO ZCX_ERROR=>mv_dummy.
        ZCX_ERROR=>raise_sy_msg( ).
      ENDIF.

    ENDIF.


* get items of selected version -------------------------------------
    IF NOT it_pvwty_dia IS INITIAL AND et_pvwty_dia_ver IS REQUESTED.
      CALL FUNCTION 'WTY03_ITEM_FROM_VERSION_GET'
        EXPORTING
          iv_pnwtyv_guid = es_pnwtyv_dia-pnguid
          it_pnwtyv_dia  = it_pnwtyv_dia
          it_pvwty_dia   = it_pvwty_dia
        IMPORTING
          et_pvwty_dia   = et_pvwty_dia_ver
        EXCEPTIONS
          not_found      = 1
          OTHERS         = 2.
      IF sy-subrc NE 0.
*     no items, no worries
        sy-subrc = 0.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD trigger_ucomm_save.

    CALL FUNCTION 'PVSUIWTY_SET_OKCODE'
      EXPORTING
        iv_okcode = 'SAVENQ'. "yif_id1_const=>mc_wty_ucomm-save_wo_popup.

  ENDMETHOD.


  METHOD trigger_version_pricing.

    cl_wty_version=>get_object_by_guid( is_pnwtyv_dia-pnguid )->set_pricing_mode( 'C' ).

  ENDMETHOD.
ENDCLASS.
