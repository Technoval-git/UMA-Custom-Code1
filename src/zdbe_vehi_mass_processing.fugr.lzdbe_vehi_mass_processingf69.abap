*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF69 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_DETERMINE_OBLIGATORY_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_determine_obligatory_fields .

  DATA: lv_activ              TYPE activ_auth.
  DATA: lv_naventry           TYPE /dbe/naventry.
  DATA: lv_disable            TYPE c.
  DATA: lv_veh_mode           TYPE c.
  DATA: lv_subscreen_mode     TYPE c.
  DATA: lv_activity_type      TYPE c.
  DATA: lv_profile            TYPE /dbe/sprofile.
  DATA: ls_iobj_multi_control TYPE control_type.
  DATA: ls_adddata_cntrl      TYPE adddata_type.
  DATA: ls_authority          TYPE c.
  DATA lr_exroot              TYPE REF TO cx_root.
  DATA lv_error_message       TYPE string.
  DATA lo_factory             TYPE REF TO /dbe/cl_veh_md_reader_factory.
  DATA lo_reader              TYPE REF TO /dbe/if_veh_md_reader.
  DATA lo_buskey              TYPE REF TO /dbe/cl_veh_md_key_bustype.
  DATA lo_result              TYPE REF TO /dbe/if_veh_md_result.
  DATA lo_bpkey               TYPE REF TO /dbe/cl_veh_md_key_bp.
  DATA lo_txt                 TYPE string.

* Set all obligatory fields as type '2' should be filled
  LOOP AT SCREEN.
    IF screen-group1 EQ gc_ftype_in1.
      screen-required = gc_2.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

* Get vehicle mode - change, display
  CALL FUNCTION '/DBE/VM08_VEHICLE_MODE_GET'
    EXPORTING
      iv_subscreen      = sy-dynnr
    IMPORTING
      ev_veh_mode       = lv_veh_mode
      ev_subscreen_mode = lv_subscreen_mode
    EXCEPTIONS
      OTHERS            = 01.

  IF lv_subscreen_mode IS NOT INITIAL.
    lv_activity_type = lv_subscreen_mode.
  ELSE.
    lv_activity_type = lv_veh_mode.
  ENDIF.

* If change mode
  IF lv_activity_type EQ gc_0.
    lv_activ = gc_2.
*   if display mode
  ELSEIF lv_activity_type EQ gc_1.
    lv_activ = gc_3.
  ENDIF.

* Determine whether user has an authorization for the screen
* 0 - no authority, 1 - all, 2 - change mode allowed, 3 - only display
  CALL FUNCTION '/DBE/VM08_SELECTED_ACTION_GET'
    IMPORTING
      ev_authority = ls_authority.

  IF ls_authority EQ gc_3.
    lv_disable = gc_xflag.
  ELSE.
    CLEAR: lv_disable.
  ENDIF.

* Disable all fields on the screen
  IF lv_disable EQ gc_xflag.
    LOOP AT SCREEN.
      screen-input = gc_0.
      MODIFY SCREEN.
    ENDLOOP.

*   Disable all IObject multi and qualifiers grid controls
    LOOP AT gt_iobj_multi_control INTO ls_iobj_multi_control
      WHERE progname EQ sy-repid AND
            dynnr    EQ sy-dynnr.
      CALL METHOD ls_iobj_multi_control-alv_ref->set_ready_for_input
        EXPORTING
          i_ready_for_input = 0.
    ENDLOOP.
*   Set qulifiers control grid as disable
    READ TABLE gt_adddata_cntrl INTO ls_adddata_cntrl
      WITH KEY progname = sy-repid
               dynnr    = sy-dynnr.
    IF sy-subrc EQ 0.
      CALL METHOD ls_adddata_cntrl-alv_control->set_ready_for_input
        EXPORTING
          i_ready_for_input = 0.
    ENDIF.
  ENDIF.

  TRY.
      lo_factory = /dbe/cl_veh_md_reader_factory=>get_instance( ).

*     reading the bustype
      TRY.
          lo_reader = lo_factory->create_reader( 'BUSTYPE' ).
          lo_buskey ?= lo_reader->createkey( ).
          lo_buskey->set_bustype( vlcactdata_head_s-/dbe/bustype ).
          lo_buskey->set_lang( sy-langu ).
          lo_result = lo_reader->read( lo_buskey ).
          /dbe/v_bustypet-descr = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          /dbe/v_bustypet-descr = ''.
      ENDTRY.

*     read business partner
      TRY.
          lo_reader = lo_factory->create_reader( 'BP' ).
          lo_bpkey ?= lo_reader->createkey( ).
          lo_bpkey->set_bpkey( /dbe/v_ipartner_dynp-partner ).
          lo_result = lo_reader->read( lo_bpkey ).
          /dbe/v_ipartner_dynp-partner_desc = lo_result->getstring( ).
        CATCH /dbe/cx_veh_md_datanotfound.
          /dbe/v_ipartner_dynp-partner_desc = ''.
      ENDTRY.

    CATCH cx_root INTO lr_exroot .
      lv_error_message = lr_exroot->if_message~get_longtext( ).
*     if something went wrong during reading short text, the shost text will be empty and error silently
*     dropped becasue it not effecting.
  ENDTRY.

ENDFORM.                    " F_DETERMINE_OBLIGATORY_FIELDS
