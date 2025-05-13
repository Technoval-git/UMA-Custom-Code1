*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF19 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_BUSTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_bustype .

  CONSTANTS: lc_difftax(22)  TYPE c VALUE '/DBE/V_IVEHICLE-DIFFTAX'.

*  DATA lv_value          TYPE string.
  DATA lv_crea_screen    TYPE c.
  DATA lv_pricingtype    TYPE /dbe/veh_pricingtype.
  DATA ls_msg            TYPE bapiret2.
*  DATA lt_msg            TYPE bapiret2_t.
  DATA lv_dummy          TYPE string.

*Get creation screen status
  CALL FUNCTION '/DBE/VM08_IS_CREA_SCREEN_GET'
    IMPORTING
      ev_is_crea_screen = lv_crea_screen.

  IF vlcactdata_head_s-/dbe/bustype IS INITIAL.
    GET PARAMETER ID '/DBE/PI_BUSTYPE'
      FIELD vlcactdata_head_s-/dbe/bustype.
  ENDIF.

* Determine if used vehicle pricing or new vehicle
* pricing applies. Only for used vehicle pricing
* the margin taxation flag is used. This replaces
* direct reading of the business transaction type
* from the INI file.
  CALL FUNCTION '/DBE/VM08_FIND_PRICING_TYPE'
    EXPORTING
      is_vlcdiavehi        = vlcdiavehi
      is_vlcactdata_item   = vlcactdata_item_s
      is_vlcactdata_head   = vlcactdata_head_s
    IMPORTING
      ev_pricingtype       = lv_pricingtype
    EXCEPTIONS
      determination_failed = 0
      OTHERS               = 0.

  IF lv_pricingtype = 1 AND /dbe/v_ivehicle-difftax IS NOT INITIAL.
    MESSAGE w089(/dbe/vehicle_master) INTO lv_dummy.
    ls_msg-type = sy-msgty.
    ls_msg-id = sy-msgid.
    ls_msg-number = sy-msgno.
    APPEND ls_msg TO gt_bapireturn.
  ENDIF.

* Change fields on UI depending on pricing type
  LOOP AT SCREEN.
    IF screen-name EQ lc_difftax.
      IF ( lv_pricingtype EQ gc_vehipricing_new ).
*       new vehicle pricing -> hide margin taxation
        screen-input = gc_0.
        CLEAR: /dbe/v_ivehicle-difftax.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHECK_BUSTYPE
