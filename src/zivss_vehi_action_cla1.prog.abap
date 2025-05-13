*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_ACTION_CLA1
*&---------------------------------------------------------------------*
CLASS lcl_iobj_multi_alv_control DEFINITION.

  PUBLIC SECTION.
    DATA: mt_checktable    TYPE checktable_type_t.
    DATA: mo_alv_grid      TYPE REF TO cl_gui_alv_grid.
    DATA: mv_settype_name  TYPE /dbe/exts_set_id.
    DATA: mv_vguid         TYPE vlc_guid.
    DATA: mo_protocol      TYPE REF TO cl_alv_changed_data_protocol.

* perform the necessary checks of input values
    METHODS
      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING
          er_data_changed
          e_onf4
          e_onf4_before
          e_onf4_after
          e_ucomm.

    METHODS handle_f4 FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING
        e_fieldname
        e_fieldvalue
        es_row_no
        er_event_data
        et_bad_cells
        e_display.

ENDCLASS.                    "LCL_IOBJ_MULTI_ALV_CONTROL DEFINITION

*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_IOBJ_MULTI_ALV_CONTROL
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_iobj_multi_alv_control IMPLEMENTATION.
*Implementation of the main method for maintaining table data
  METHOD  handle_data_changed.
    DATA: lv_prc_pai TYPE c VALUE space.
    DATA: ls_inserted_row TYPE lvc_s_moce.
    DATA: ls_mod_cells TYPE lvc_s_modi.
    DATA: lo_badi_vehicle_ui TYPE REF TO /dbe/badi_vehicle_ui.

    FIELD-SYMBOLS: <fs_outtab> TYPE ANY TABLE.

*Get reference for relevant data
    ASSIGN COMPONENT mv_settype_name                        "N.1649844
      OF STRUCTURE gs_iobj_multi TO <fs_outtab>.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.

*Don't process the pai in case of search help
    IF e_onf4 NE gc_xflag.
      lv_prc_pai = gc_xflag.
    ENDIF.

*   In case of ALV data_changed event PBO is not executed so navigation
*   block flag is not cleared at the end of PBO in f_error_show->clear it here
    CALL FUNCTION '/DBE/VM08_ERROR_SET'
      EXPORTING
        iv_block_navigation = abap_false.

*Get the Badi instance
    CALL FUNCTION '/DBE/VM08_BADI_UI_INSTANCE_GET'
      IMPORTING
        eo_instance = lo_badi_vehicle_ui.

*Call the Badi in order to change the standard on data changed process
    IF lo_badi_vehicle_ui IS BOUND.
      CALL BADI lo_badi_vehicle_ui->iobj_multi_alv_data_changed
        EXPORTING
          ir_data_changed = er_data_changed
          iv_onf4         = e_onf4
          iv_onf4_before  = e_onf4_before
          iv_onf4_after   = e_onf4_after
          iv_ucomm        = e_ucomm
          iv_settype_name = mv_settype_name
          ir_alv_grid     = mo_alv_grid
          it_outtab       = <fs_outtab>                  "N.1649844
        CHANGING
          ev_prc_pai      = lv_prc_pai.

*  Check if no errors in the alv grid
      mo_protocol = er_data_changed.
      READ TABLE er_data_changed->mt_protocol[]
      TRANSPORTING NO FIELDS WITH KEY msgty = 'E'.
      IF sy-subrc EQ 0.
        CLEAR lv_prc_pai.
      ENDIF.
    ENDIF.

*Process the PAI after
    IF lv_prc_pai EQ gc_xflag.
      CALL METHOD cl_gui_cfw=>set_new_ok_code
        EXPORTING
          new_code = gc_xxxx_fc.
    ENDIF.

  ENDMETHOD.                    "handle_data_changed

  METHOD handle_f4.
*Show help for check table
    PERFORM show_f4_field USING e_fieldname
                                e_fieldvalue
                                es_row_no
                                er_event_data
                                et_bad_cells
                                e_display
                                mv_settype_name
                                mv_vguid
                                mt_checktable
                                mo_alv_grid.
  ENDMETHOD.                                                "HANDLE_F4

ENDCLASS.               "lcl_adddata_event_handler
