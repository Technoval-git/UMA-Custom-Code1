*----------------------------------------------------------------------*
***INCLUDE /DBE/LVM06F03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BADI_INITIALIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM badi_initialize .

  IF badi_search_ui IS NOT BOUND.
    TRY.
        GET BADI badi_search_ui.
      CATCH cx_root.
    ENDTRY.
  ENDIF.

ENDFORM.                    "badi_initialize


*&---------------------------------------------------------------------*
*&      Form  check_mass_actions_authority
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_ACTION  text
*----------------------------------------------------------------------*
FORM check_mass_actions_authority USING pv_action TYPE vlc_action.

  IF NOT ( pv_action IS INITIAL ).

    AUTHORITY-CHECK OBJECT vlc_authority_object_gc
         ID 'ACTVT'      DUMMY
         ID 'VLC_ACTION' FIELD pv_action
         ID 'WERKS'      DUMMY.

*   IF sy-subrc = 4.
    IF sy-subrc <> 0.
      MESSAGE e403(/DBE/vehicle_master).
    ENDIF.

  ENDIF.

ENDFORM.                    "check_mass_actions_authority
