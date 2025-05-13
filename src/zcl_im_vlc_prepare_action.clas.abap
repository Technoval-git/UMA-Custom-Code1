class ZCL_IM_VLC_PREPARE_ACTION definition
  public
  final
  create public .

public section.

  interfaces IF_EX_VLC_PREPARE_ACTION .

  class-methods IS_VSS_ACTION
    importing
      !IV_ACTION type VLC_ACTION
    returning
      value(RV_RESULT) type ABAP_BOOL .
  methods PREPARE_ZSTO
    importing
      !ACTION_TO_BE_PERFORMED_IV type VLC_ACTION optional
      !INCOMING_ACTION_IS type VLCC_CVLC03_PS
      !ELEMENTARY_ACTION_IS type VLCC_CVLC03_PS
      !LIST_OF_VEHICLES_IT type VLCDIAVEHI_T
    changing
      !VLCGUIDCUOBJ_ET type VLCGUIDCUOBJ_T
      !VLCACTDATA_CS type VLCACTDATA
    exceptions
      ACTION_PREPARE_NOT_PERFORMED .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_VLC_PREPARE_ACTION IMPLEMENTATION.


  method IF_EX_VLC_PREPARE_ACTION~DATA_CHANGES_AFTER_PREPARE.
  endmethod.


  METHOD if_ex_vlc_prepare_action~data_changes_before_prepare.
    DATA:
      lo_action         TYPE REF TO /dbe/cl_veh_action,
      ls_action_flavour TYPE cvlc03.

    TRY.
        lo_action ?= /dbe/cl_veh_action=>get_action( incoming_action_is-aktion ).
        lo_action->get_action_flavour( IMPORTING es_action_flavour = ls_action_flavour ).

        IF ls_action_flavour-/dbe/veh_act_ty = lo_action->gc_dbm_action OR
           ls_action_flavour-/dbe/veh_act_ty = lo_action->gc_universal_action.
*       In case actions, prepare fills out the qualifiers table with all
*       necessary data
          CLEAR vlcactdata_cs-adddata_item[].
        ENDIF.

      CATCH /dbe/cx_veh_action_not_defined.
        RAISE action_prepare_not_performed.
    ENDTRY.
  ENDMETHOD.


  METHOD if_ex_vlc_prepare_action~prepare_further_actions.
*prefix for METHODS name
    CONSTANTS: lc_meth_pref(8)   TYPE c VALUE 'PREPARE_'.
*method name
    DATA: lv_meth_name TYPE string.
*dummy character for hiding error message
    DATA: lv_dummy TYPE c.
* Variables for getting exception type
    DATA: lo_root TYPE REF TO cx_root.
    DATA: lv_exceptiontype TYPE string.

* process VSS logic only for VSS-relevant actions
    CHECK is_vss_action( action_to_be_performed_iv ).

*construct the relevant methods name
    CONCATENATE lc_meth_pref action_to_be_performed_iv INTO lv_meth_name.

*try to call the method
    TRY.
        CALL METHOD me->(lv_meth_name)
          EXPORTING
            action_to_be_performed_iv    = action_to_be_performed_iv
            incoming_action_is           = incoming_action_is
            elementary_action_is         = elementary_action_is
            list_of_vehicles_it          = list_of_vehicles_it
          CHANGING
            vlcguidcuobj_et              = vlcguidcuobj_et
            vlcactdata_cs                = vlcactdata_cs
          EXCEPTIONS
            action_prepare_not_performed = 1
            OTHERS                       = 2.
        IF sy-subrc <> 0.
          RAISE action_prepare_not_performed.
        ENDIF.
      CATCH cx_sy_dyn_call_illegal_method.
*   This is not an error. Implementation might be in other BAdI or no preparation needed
      CATCH cx_root INTO lo_root.
*   Error occurred, no parameter for the error message
        lv_exceptiontype = lo_root->get_text( ).
        MESSAGE e016(velo) WITH lv_exceptiontype space space space INTO lv_dummy.
*     An error has occurred
        RAISE action_prepare_not_performed.
    ENDTRY.
  ENDMETHOD.


  method IF_EX_VLC_PREPARE_ACTION~REFRESH_VEHICLES.
  endmethod.


  METHOD is_vss_action.
    DATA:
  lo_action TYPE REF TO /dbe/cl_veh_action.

    TRY.
        lo_action ?= /dbe/cl_veh_action=>get_action( iv_action ).

        lo_action->get_action_flavour(
          EXPORTING
            iv_action         = iv_action
          IMPORTING
            es_action_flavour = DATA(ls_action_flavour) ).

        IF ls_action_flavour-/dbe/veh_act_ty = /dbe/cl_veh_action=>gc_dbm_action OR
           ls_action_flavour-/dbe/veh_act_ty = /dbe/cl_veh_action=>gc_universal_action.
          rv_result = abap_true.
        ENDIF.

      CATCH /dbe/cx_veh_action_not_defined.
        " ignore

    ENDTRY.
  ENDMETHOD.


  METHOD prepare_zsto.
*    DATA: ls_incoming_action   TYPE cvlc03,
*          ls_elemantary_action TYPE cvlc03.
*
*    MOVE-CORRESPONDING incoming_action_is TO ls_incoming_action.
*    MOVE-CORRESPONDING elementary_action_is TO ls_elemantary_action.
*
*    CALL FUNCTION 'ZDBE_VM13_QCIO_PREPARE'
*      EXPORTING
*        iv_xinterlinked      = incoming_action_is-intrlk
*        is_incoming_action   = ls_incoming_action
*        is_elementary_action = ls_elemantary_action
*      TABLES
*        it_vlcdiavehi        = list_of_vehicles_it
*      CHANGING
*        cs_vlcactdata        = vlcactdata_cs
*      EXCEPTIONS
*        OTHERS               = 1.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*              RAISING action_prepare_not_performed.
*    ENDIF.
  ENDMETHOD.
ENDCLASS.
