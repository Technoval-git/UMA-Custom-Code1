*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI71.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SERVICE_VENDOR_SEARCH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE service_vendor_search INPUT.

  PERFORM f_service_vendor_search.                           "N:2304203

ENDMODULE.                 " SERVICE_VENDOR_SEARCH  INPUT


*&---------------------------------------------------------------------*
*&      Form  F_SERVICE_VENDOR_SEARCH                         N:2304203
*&---------------------------------------------------------------------*
FORM f_service_vendor_search.

  DATA: ls_return TYPE bapiret2,
        lt_result TYPE TABLE OF ddshretval,
        ls_result TYPE ddshretval,
        ls_shlp   TYPE shlp_descr.
  DATA: ls_display_profile  TYPE  bal_s_prof,
        lo_vehicle          TYPE REF TO /DBE/cl_veh_dbmvehicle,  "N:2304203
        lo_buf              TYPE REF TO /DBE/cl_veh_buf,
        lt_bob              TYPE /DBE/t_veh_bob,
        ls_bob              TYPE /DBE/s_veh_bob.

  CLEAR: lt_result[], ls_shlp.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      shlpname = 'KRED'
    IMPORTING
      shlp     = ls_shlp.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      shlp          = ls_shlp
    TABLES
      return_values = lt_result.

  IF lt_result[] IS INITIAL.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = 'E'
        cl     = '/DBE/VEHICLE_MASTER'
        number = '467'
        field  = '/DBE/SRVC_VENDOR'
      IMPORTING
        return = ls_return.
    APPEND ls_return TO gt_return.

* get instance of the buffer...
    lo_buf = /DBE/cl_veh_buf=>get_instance( ).
* Read the buffer data
    CALL METHOD lo_buf->get_all
      RECEIVING
        rt_bob = lt_bob.
    READ TABLE lt_bob INTO ls_bob INDEX 1.

    IF sy-subrc = 0.
      lo_vehicle ?= ls_bob-bobref .
      lo_vehicle->add_bapiret2_bal( EXPORTING it_bapiret2 = gt_return ).
    ENDIF.

    IF lo_vehicle->mo_bal IS BOUND.
      INSERT lo_vehicle->mo_bal->mv_log_handle_tmp  INTO TABLE lt_log_handle.
    ENDIF.

    ls_display_profile-use_grid = 'X'.
    ls_display_profile-show_all = abap_true.

    CALL FUNCTION 'BAL_DSP_OUTPUT_INIT'
      EXPORTING
        i_s_display_profile = ls_display_profile
      EXCEPTIONS
        OTHERS              = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* get a prepared profile
    CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
      IMPORTING
        e_s_display_profile = ls_display_profile
      EXCEPTIONS
        OTHERS              = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    ls_display_profile-use_grid = abap_true.
    ls_display_profile-disvariant-report = sy-repid.

    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_s_display_profile  = ls_display_profile
        i_t_log_handle       = lt_log_handle
      EXCEPTIONS
        profile_inconsistent = 1
        internal_error       = 2
        no_data_available    = 3
        no_authority         = 4
        OTHERS               = 5.

    CALL FUNCTION 'BAL_LOG_MSG_DELETE_ALL'
      EXPORTING
        i_log_handle  = lo_vehicle->mo_bal->mv_log_handle_tmp
      EXCEPTIONS
        log_not_found = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*      RAISING log_error.
    ENDIF.

  ENDIF.

ENDFORM.
