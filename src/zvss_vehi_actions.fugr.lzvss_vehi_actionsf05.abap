*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHI_ACTIONSF05.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_determine_layout .

  DATA:
    lv_veh_mode,
    lv_crea_screen,
    lv_after_action,
    lv_activity_type,
    lv_subscreen_mode.

* Check if creation mode
  CALL FUNCTION '/DBE/VM08_IS_CREA_SCREEN_GET'
    IMPORTING
      ev_is_crea_screen = lv_crea_screen.

* If creation screen - disable all fields if obligatory fields
* have been passed
* 0 - initial state, 1 - not all fields have been filled out
* 2 - all obligatory fields for creation have been passed
* 3 - creation screen complete, disable all oblig. fields
  IF lv_crea_screen EQ gc_2 OR
     lv_crea_screen EQ gc_3.
    LOOP AT SCREEN.
      IF screen-group4 EQ gc_ftype_in0.
        screen-input = gc_0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Get vehicle mode - change or display
  CALL FUNCTION '/DBE/VM08_VEHICLE_MODE_GET'
    EXPORTING
      iv_subscreen      = sy-dynnr
    IMPORTING
      ev_veh_mode       = lv_veh_mode
      ev_subscreen_mode = lv_subscreen_mode.

  IF lv_subscreen_mode IS NOT INITIAL.
    lv_activity_type = lv_subscreen_mode.
  ELSE.
    lv_activity_type = lv_veh_mode.
  ENDIF.

* if display mode - gray out all fields if not group4 equal IN1
  IF lv_activity_type EQ gc_0.
    LOOP AT SCREEN.
      IF screen-group4 NE gc_ftype_in1.
        screen-input = gc_0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_DETERMINE_LAYOUT
