*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHI_ACTIONSF04.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SHOW_F4_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_DYNP_VALUES  text
*----------------------------------------------------------------------*
FORM show_f4_field USING pv_fieldname
                         pv_fieldvalue
                         ps_row_id       TYPE lvc_s_roid
                         pr_event_data   TYPE REF TO cl_alv_event_data
                         pt_bad_cells    TYPE lvc_t_modi
                         pv_display      TYPE char01
                         pv_settype_name TYPE /dbe/exts_set_id
                         pv_vguid        TYPE vlc_guid
                         pt_checktable   TYPE checktable_type_t
                         mo_alv_grid     TYPE REF TO cl_gui_alv_grid.

  DATA: lt_values         TYPE STANDARD TABLE OF ddshretval.
  DATA: ls_values         TYPE ddshretval.
  DATA: ls_modi           TYPE lvc_s_modi.
  DATA: ls_checktable     TYPE checktable_type_s.
  DATA: lv_veh_mode       TYPE c.
  DATA: lo_badi_vehicle_ui TYPE REF TO /dbe/badi_vehicle_ui.

  FIELD-SYMBOLS: <itab>      TYPE lvc_t_modi,
                 <fs_outtab> TYPE ANY TABLE.

*Get reference for relevant data
  ASSIGN COMPONENT pv_settype_name                          "N.1649844
    OF STRUCTURE gs_iobj_multi TO <fs_outtab>.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

*Get the Badi instance
  CALL FUNCTION '/DBE/VM08_BADI_UI_INSTANCE_GET'
    IMPORTING
      eo_instance = lo_badi_vehicle_ui.

*Call the Badi method in order to change the F4 process
  IF lo_badi_vehicle_ui IS BOUND.
    CALL BADI lo_badi_vehicle_ui->iobj_multi_alv_on_f4
      EXPORTING
        iv_vguid        = pv_vguid
        iv_settype_name = pv_settype_name
        iv_fieldname    = pv_fieldname
        iv_fieldvalue   = pv_fieldvalue
        is_row_no       = ps_row_id
        ir_event_data   = pr_event_data
        it_bad_cells    = pt_bad_cells
        iv_display      = pv_display
        ir_alv_grid     = mo_alv_grid
        it_outtab       = <fs_outtab>.                    "N.1649844
  ENDIF.

  CHECK pr_event_data->m_event_handled NE 'X'.

  READ TABLE pt_checktable INTO ls_checktable
    WITH KEY fieldname = pv_fieldname.
  IF sy-subrc EQ 0.
    IF NOT ( ls_checktable-checktable IS INITIAL OR
              ls_checktable-checktab_key IS INITIAL ).
* Read the values from the checktable.
      IF NOT ls_checktable-checktable IS INITIAL.
        CALL FUNCTION 'F4TOOL_CHECKTABLE_HELP'
          EXPORTING
            checktable       = ls_checktable-checktable
            retfield         = ls_checktable-checktab_key
            display          = pv_display
          TABLES
            return_tab       = lt_values
          EXCEPTIONS
            tabl_not_exists  = 1
            field_not_exists = 2
            illegal_call     = 3
            OTHERS           = 4.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
      ELSE.
*- Attribute id is rollname in settype where attribute is used.
        CALL FUNCTION 'DD_F4_FOR_ROLLNAME'
          EXPORTING
            rollname      = pv_fieldname
          TABLES
            return_values = lt_values.
      ENDIF.
      READ TABLE lt_values INTO ls_values INDEX 1.
      IF sy-subrc EQ 0.
        pr_event_data->m_event_handled = 'X'.
        ASSIGN pr_event_data->m_data->* TO <itab>.
        IF sy-subrc EQ 0.
          ls_modi-row_id = ps_row_id-row_id.
          ls_modi-fieldname = pv_fieldname.

          ls_modi-value = ls_values-fieldval.
          APPEND ls_modi TO <itab>.
        ENDIF.
      ENDIF.
      pr_event_data->m_event_handled = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " SHOW_F4_FIELD
