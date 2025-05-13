CLASS zvss_ifm_cl_x_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-DATA mv_dummy TYPE string .

    METHODS add_msg
      IMPORTING
        !iv_problemclass TYPE bal_s_msg-probclass DEFAULT '4'
        !iv_handle       TYPE balloghndl OPTIONAL
      RAISING
        ZVSS_CX_IFM_LOG .
    METHODS add_msg_from_bapiret
      IMPORTING
        !iv_problemclass TYPE bal_s_msg-probclass DEFAULT '4'
        !iv_handle       TYPE balloghndl OPTIONAL
        !it_bapiret      TYPE bapiret2_t
      RAISING
        ZVSS_CX_IFM_LOG .
    METHODS constructor
      IMPORTING
        !iv_object    TYPE balobj_d
        !iv_subobject TYPE balsubobj
        !iv_ext_no    TYPE balnrext
      RAISING
        ZVSS_CX_IFM_LOG .
    METHODS get_log_handle
      RETURNING
        VALUE(rv_handle) TYPE balloghndl .
    METHODS get_messages
      RETURNING
        VALUE(rt_messages) TYPE bapiret2_t .
    METHODS is_log_full
      RETURNING
        VALUE(rv_log_is_full) TYPE sap_bool .
    METHODS open_log
      IMPORTING
        !iv_logno TYPE balognr OPTIONAL
      RAISING
        ZVSS_CX_IFM_LOG .
    METHODS save_log
      IMPORTING
        !iv_problemclass TYPE bal_s_msg-probclass OPTIONAL
        !iv_handle       TYPE balloghndl OPTIONAL
      CHANGING
        !cv_logno        TYPE balognr OPTIONAL
      RAISING
        ZVSS_CX_IFM_LOG .
    METHODS show_log
      IMPORTING
        !iv_handle     TYPE balloghndl OPTIONAL
        !iv_save_to_db TYPE xfeld .
    METHODS export_log_to_memory
      IMPORTING
        !iv_memory_id TYPE char20 OPTIONAL
      RAISING
        ZVSS_CX_IFM_LOG .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_log_is_full TYPE sap_bool .
    DATA mt_messages TYPE bapiret2_t .
    DATA mv_log TYPE balloghndl .

    METHODS import_log_from_memory
      IMPORTING
        !iv_memory_id TYPE char20
      RAISING
        ZVSS_CX_IFM_LOG .
ENDCLASS.



CLASS ZVSS_IFM_CL_X_LOG IMPLEMENTATION.


  METHOD add_msg.
************************************************************************

    DATA: lv_log_hndl TYPE balloghndl,
          ls_bapiret  TYPE bapiret2.

    IF iv_handle IS SUPPLIED.
      lv_log_hndl = iv_handle.
    ELSE.
      lv_log_hndl = mv_log.
    ENDIF.

*   Map SYST to BAPIRET
    ls_bapiret-id = sy-msgid.
    ls_bapiret-number = sy-msgno.
    ls_bapiret-message_v1 = sy-msgv1.
    ls_bapiret-message_v2 = sy-msgv2.
    ls_bapiret-message_v3 = sy-msgv3.
    ls_bapiret-message_v4 = sy-msgv4.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    INTO ls_bapiret-message.

*   Store message
    APPEND ls_bapiret TO mt_messages.

    mv_log_is_full = cl_log_ppf=>add_message( ip_handle = lv_log_hndl
                                              ip_problemclass = iv_problemclass ).

    IF mv_log_is_full IS NOT INITIAL.
      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG
        EXPORTING
          textid = ZVSS_CX_IFM_LOG=>log_is_full.
    ENDIF.
  ENDMETHOD.


  METHOD add_msg_from_bapiret.
************************************************************************

    DATA: ls_bapiret  TYPE bapiret2,
          lv_log_hndl TYPE balloghndl.

    IF iv_handle IS SUPPLIED.
      lv_log_hndl = iv_handle.
    ELSE.
      lv_log_hndl = mv_log.
    ENDIF.

    LOOP AT it_bapiret INTO ls_bapiret.
      MESSAGE ID ls_bapiret-id TYPE ls_bapiret-type NUMBER ls_bapiret-number
       WITH ls_bapiret-message_v1 ls_bapiret-message_v2 ls_bapiret-message_v3 ls_bapiret-message_v4
       INTO ls_bapiret-message.

      APPEND ls_bapiret TO mt_messages.
      mv_log_is_full = cl_log_ppf=>add_message( ip_handle = lv_log_hndl
                                                ip_problemclass = iv_problemclass ).
    ENDLOOP.

    IF mv_log_is_full IS NOT INITIAL.
      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG
        EXPORTING
          textid = ZVSS_CX_IFM_LOG=>log_is_full.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
************************************************************************
*
    mv_log = cl_log_ppf=>create_log( ip_object = iv_object
                                     ip_subobject = iv_subobject
                                     ip_ext_no = iv_ext_no ).
    IF mv_log IS INITIAL.
      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG
        EXPORTING
          textid = ZVSS_CX_IFM_LOG=>cannot_create_log.
    ENDIF.
  ENDMETHOD.


  METHOD export_log_to_memory.
************************************************************************
*

    DATA: lv_logno TYPE balognr.

    save_log( CHANGING cv_logno = lv_logno ).

    EXPORT logno = lv_logno TO MEMORY ID iv_memory_id.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG
        EXPORTING
          textid = ZVSS_CX_IFM_LOG=>log_fail_export.
    ENDIF.

  ENDMETHOD.


  METHOD get_log_handle.
    rv_handle = mv_log.
  ENDMETHOD.


  METHOD get_messages.
    rt_messages = mt_messages.
  ENDMETHOD.


  METHOD import_log_from_memory.
************************************************************************
*

    DATA: lv_logno   TYPE balognr,
          lv_loghndl TYPE balloghndl.

    IMPORT logno = lv_logno FROM MEMORY ID iv_memory_id.

    IF lv_logno IS NOT INITIAL.
      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG
        EXPORTING
          textid = ZVSS_CX_IFM_LOG=>log_fail_import.
    ENDIF.

    lv_loghndl = cl_log_ppf=>load_log( EXPORTING ip_logno = lv_logno ).
    IF lv_loghndl IS NOT INITIAL.
      mv_log = lv_loghndl.

    ELSE.
      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG
        EXPORTING
          textid = ZVSS_CX_IFM_LOG=>log_fail_open.
    ENDIF.

  ENDMETHOD.


  METHOD is_log_full.
    rv_log_is_full = mv_log_is_full.
  ENDMETHOD.


  METHOD open_log.
************************************************************************
*
*    Project...........: DBME Interface Framework
*    Description.......: Open existing log
*    Dev-ID............: RZM
*
*    Author............: Mateusz Rzepczyk
*    Company...........: Proaxia
*    Creation Date.....: 03.03.2017 12:11:28
*
*  ***********************************************************************
*    Changed on:          Changed by:   Change ID:  Description:
*   03.03.2017 12:11:28   RZM                       Initial version
*  ***********************************************************************
    DATA: lv_log TYPE balloghndl.

    lv_log = cl_log_ppf=>load_log( EXPORTING ip_logno = iv_logno ).

    IF lv_log IS NOT INITIAL.
      mv_log = lv_log.
    ELSE.
      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG
        EXPORTING
          textid = ZVSS_CX_IFM_LOG=>log_fail_open.
    ENDIF.
  ENDMETHOD.


  METHOD save_log.
************************************************************************
*

    DATA: lv_log_hndl TYPE balloghndl.

    IF iv_handle IS SUPPLIED.
      lv_log_hndl = iv_handle.
    ELSE.
      lv_log_hndl = mv_log.
    ENDIF.

    cv_logno = cl_log_ppf=>save_log( EXPORTING ip_loghandle = lv_log_hndl
                                               ip_update_task = 'X' ).

    IF cv_logno IS INITIAL.
      RAISE EXCEPTION TYPE ZVSS_CX_IFM_LOG
        EXPORTING
          textid = ZVSS_CX_IFM_LOG=>log_fail_save.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ENDIF.

  ENDMETHOD.


  METHOD show_log.
************************************************************************

    DATA: lv_log_hndl TYPE balloghndl,
          ls_profile  TYPE bal_s_prof,
          lt_handles  TYPE bal_t_logh.

    IF iv_handle IS SUPPLIED.
      lv_log_hndl = iv_handle.
    ELSE.
      lv_log_hndl = mv_log.
    ENDIF.

    INSERT lv_log_hndl INTO TABLE lt_handles.
    CALL FUNCTION 'BAL_DSP_PROFILE_SINGLE_LOG_GET'
      IMPORTING
        e_s_display_profile = ls_profile.

    ls_profile-use_grid   = sppf_true.
    ls_profile-start_col  = '20'.
    ls_profile-start_row  = '5'.
    ls_profile-end_col    = '120'.
    ls_profile-pop_adjst  = sppf_true.

    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_s_display_profile = ls_profile
        i_t_log_handle      = lt_handles
      EXCEPTIONS
        OTHERS              = 0.

  ENDMETHOD.
ENDCLASS.
