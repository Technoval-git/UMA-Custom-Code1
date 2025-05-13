class ZCL_VSS_VEH_UTIL definition
  public
  final
  create public .

public section.

  class-data MV_DUMMY type STRING .

  class-methods DATE_TO_DD_MM_YYYY
    importing
      !IV_DATE type DATUM default SY-DATUM
      !IV_DELIMITER type STRING default '-'
    returning
      value(RV_DATE) type STRING .
  class-methods DATE_TO_YYYY_MM_DD
    importing
      !IV_DATE type DATUM default SY-DATUM
      !IV_DELIMITER type STRING default '-'
    returning
      value(RV_DATE) type STRING .
  class-methods CLIKE_TO_LTEXT
    importing
      !IV_TEXT type CLIKE
      !IV_SEPARATOR type CLIKE default CL_ABAP_CHAR_UTILITIES=>CR_LF
    exporting
      !ET_TLINE type TLINE_T
      !ET_TEXT type STRINGTAB .
  class-methods CONVERT_BUSDOC_ITOBJID
    changing
      !CV_ITOBJID type /DBE/ITOBJID
    returning
      value(RV_MATNR) type MATNR .
  class-methods MAT_CONV_18TO40
    importing
      !IV_MATNR18 type MATNR
      value(IV_RAISE_IF_NOT_FOUND) type ABAP_BOOL default ABAP_FALSE
    returning
      value(RV_MATNR40) type /DBE/MATNR
    raising
      ZCX_ERROR .
  class-methods IS_VALID_MATNR
    importing
      !IV_ID type CLIKE
      !IV_CHECK_MVKE type ABAP_BOOL default ABAP_TRUE
      !IV_VTWEG type VTWEG optional
      !IV_VKORG type VKORG optional
    returning
      value(RV_RESULT) type ABAP_BOOL .
  class-methods SET_ORDER_TEXT
    importing
      !IV_TDOBJECT type TDOBJECT
      !IV_TDOBNAME type TDOBNAME
      !IV_TDID type TDID
      !IV_LANGU type SPRAS default SY-LANGU
      !IO_ORDER type ref to /DBE/CL_ORDER
      !IV_STRING type STRING
    raising
      ZCX_ERROR .
  class-methods GET_ORDER_TEXT
    importing
      !IV_TDOBJECT type TDOBJECT
      !IV_TDOBNAME type TDOBNAME
      !IV_TDID type TDID
      !IV_LANGU type SPRAS default SY-LANGU
      !IO_ORDER type ref to /DBE/CL_ORDER
    exporting
      !EV_STRING type STRING
    raising
      ZCX_ERROR .
  class-methods CONV_SAP_TO_ISO_UNIT
    importing
      value(IV_SAP_UNIT) type MSEHI
    returning
      value(RV_ISO_UNIT) type ISOCD_UNIT
    raising
      ZCX_ERROR .
  class-methods BAPI_COMMIT
    importing
      !IV_WAIT type BAPIWAIT
    raising
      ZCX_ERROR .
  class-methods BAPI_ROLLBACK
    raising
      ZCX_ERROR .
  class-methods DBM_VEHICLE_LOCK
    importing
      !IV_VGUID type VLC_GUID
    raising
      ZCX_ERROR
      ZCX_VEHICLE_LOCKED .
  class-methods DBM_VEHICLE_UNLOCK
    importing
      !IV_VGUID type VLC_GUID
    raising
      ZCX_ERROR .
  class-methods BAPIRET_HAS_ERROR
    importing
      !IT_BAPIRET type BAPIRET2_T
    returning
      value(RV_HAS_ERROR) type XFELD .
  class-methods GET_CONF_VALUES
    importing
      !IV_CHARACTNAME type ATNAM
    returning
      value(RT_CHARACTVALUESCHAR) type TT_BAPICHARACTVALUESCHAR
    raising
      ZCX_ERROR .
  class-methods BAPIRET_TO_BAPIRET2
    importing
      !IT_BAPIRET type ZISI_BAPIRETURN_TT
    returning
      value(RT_BAPIRET2) type BAPIRET2_TT .
  PROTECTED SECTION.

    CLASS-METHODS get_vehicle_instance
      IMPORTING
        !iv_vguid         TYPE vlc_guid
      RETURNING
        VALUE(ro_vehicle) TYPE REF TO /dbe/cl_veh_dbmvehicle
      RAISING
        zcx_error .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VSS_VEH_UTIL IMPLEMENTATION.


  METHOD bapiret_has_error.
    LOOP AT it_bapiret INTO DATA(ls_bapiret) WHERE type CA 'EAX'.
      rv_has_error = abap_true.
      RETURN.
    ENDLOOP.

  ENDMETHOD.


  METHOD bapiret_to_bapiret2.

    LOOP AT it_bapiret ASSIGNING FIELD-SYMBOL(<ls_bapiret>).
      APPEND INITIAL LINE TO rt_bapiret2 ASSIGNING FIELD-SYMBOL(<ls_bapiret2>).
      CALL FUNCTION 'BALW_RETURN_TO_RET2'
        EXPORTING
          return_in = <ls_bapiret>
        IMPORTING
          return_ou = <ls_bapiret2>.
    ENDLOOP.

  ENDMETHOD.


  METHOD bapi_commit.

    DATA:
      ls_return TYPE bapiret2,
      lo_ex     TYPE REF TO zcx_error.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = iv_wait
      IMPORTING
        return = ls_return.

    IF ls_return-type CA 'EAX'.
      CREATE OBJECT lo_ex.
      lo_ex->append_bapi_msg( ls_return ).
      RAISE EXCEPTION lo_ex.
    ENDIF.

  ENDMETHOD.


  METHOD bapi_rollback.

    DATA:
      ls_return TYPE bapiret2,
      lo_ex     TYPE REF TO zcx_error.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
      IMPORTING
        return = ls_return.

    IF ls_return-type CA 'EAX'.
      CREATE OBJECT lo_ex.
      lo_ex->append_bapi_msg( ls_return ).
      RAISE EXCEPTION lo_ex.
    ENDIF.

  ENDMETHOD.


  METHOD clike_to_ltext.

    CONSTANTS:
      lc_first_line_tdformat TYPE tline-tdformat VALUE '*',
      lc_next_line_tdformat  TYPE tline-tdformat VALUE '='.

    DATA:
      lv_text   LIKE LINE OF et_text[],
      lt_tdline TYPE STANDARD TABLE OF tline-tdline WITH NON-UNIQUE DEFAULT KEY,
      ls_tline  LIKE LINE OF et_tline[],
      lv_index  TYPE i.

    CLEAR et_tline[].
    CLEAR et_text[].

************************************************************************
* Split the input text at CR LF as agreed with Bus Doc Team
************************************************************************
    SPLIT iv_text AT iv_separator INTO TABLE et_text[].

************************************************************************
* Generate the long text. Teoretically it can be the case, that the parts
* of the input text are longer than 72 characters. That is why we have to
* break every line as well.
************************************************************************
    LOOP AT et_text[] INTO lv_text.
      CLEAR lt_tdline[].
      CALL FUNCTION 'CONVERT_STRING_TO_TABLE'
        EXPORTING
          i_string         = lv_text
          i_tabline_length = 72
        TABLES
          et_table         = lt_tdline[].
      lv_index = 0.
      LOOP AT lt_tdline INTO ls_tline-tdline.
        ADD 1 TO lv_index.
        IF lv_index = 1.
          ls_tline-tdformat = lc_first_line_tdformat.
        ELSE.
          ls_tline-tdformat = lc_next_line_tdformat.
        ENDIF.
        APPEND ls_tline TO et_tline[].
      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.


  METHOD convert_busdoc_itobjid.

    DATA: lv_matnr_temp TYPE mara-matnr.

************************************************************************
*   Translate to upper case
************************************************************************
    TRANSLATE cv_itobjid TO UPPER CASE.

************************************************************************
*   1. attempt
*   Consider MARA-MATNR
************************************************************************
    SELECT SINGLE matnr
      FROM mara
      INTO rv_matnr
      WHERE matnr = cv_itobjid.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

************************************************************************
*   2. attempt
*   Consider MARA-ZSORT
************************************************************************
*    SELECT SINGLE matnr
*      FROM mara
*      INTO rv_matnr
*      WHERE zsort = cv_itobjid.
*    IF sy-subrc = 0.
*      cv_itobjid = rv_matnr.
*      RETURN.
*    ENDIF.

************************************************************************
*   3. attempt
*   Apply the conversion exit and check if this identifies the valid material
************************************************************************
    rv_matnr = cv_itobjid.
    CALL FUNCTION 'CONVERSION_EXIT_MATN2_INPUT'
      EXPORTING
        input            = rv_matnr
      IMPORTING
        output           = rv_matnr
      EXCEPTIONS
        number_not_found = 1
        length_error     = 2
        OTHERS           = 3.
    IF sy-subrc = 0.
      SELECT SINGLE matnr
        FROM mara
        INTO lv_matnr_temp
        WHERE matnr = rv_matnr.
      IF sy-subrc = 0.
        cv_itobjid = rv_matnr.
        RETURN.
      ENDIF.
    ENDIF.

***************************************************************************
****    4. attempt
****    Cut first character, add 0 to the end, apply conversion exit
***************************************************************************
***    SHIFT cv_itobjid LEFT.
***    CONCATENATE cv_itobjid '0' INTO cv_itobjid.
***    rv_matnr = cv_itobjid.
***    CALL FUNCTION 'CONVERSION_EXIT_MATN2_INPUT'
***      EXPORTING
***        input            = rv_matnr
***      IMPORTING
***        output           = rv_matnr
***      EXCEPTIONS
***        number_not_found = 1
***        length_error     = 2
***        OTHERS           = 3.
***    IF sy-subrc = 0.
***      cv_itobjid = rv_matnr.
***    ENDIF.

  ENDMETHOD.


  METHOD conv_sap_to_iso_unit.
************************************************************************
*
*  Project...........: ID1 Daimler Interfaces
*  Description.......: Process IPS - Convert SAP to ISO
*  Dev-ID............: TRP
*
*  Author............: Piotr Trojanowicz
*  Company...........: Proaxia
*  Creation Date.....: 24.05.2017 13:00:00
*
************************************************************************
*  Changed on:          Changed by:   Change ID:  Description:
* 24.05.2017 13:00:00     TRP                    Initial version
************************************************************************

    CALL FUNCTION 'UNIT_OF_MEASURE_SAP_TO_ISO'
      EXPORTING
        sap_code    = iv_sap_unit
      IMPORTING
        iso_code    = rv_iso_unit
      EXCEPTIONS
        not_found   = 1
        no_iso_code = 2
        OTHERS      = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_dummy).
      DATA(lo_ex) = NEW zcx_error( ).
      lo_ex->append_sy_msg( ).
      RAISE EXCEPTION TYPE zcx_error.
    ENDIF.

  ENDMETHOD.


  METHOD date_to_dd_mm_yyyy.

    rv_date = |{ iv_date+6(2) }{ iv_delimiter }{ iv_date+4(2) }{ iv_delimiter }{ iv_date(4) }|.

  ENDMETHOD.


  METHOD date_to_yyyy_mm_dd .

    rv_date = |{ iv_date(4) }{ iv_delimiter }{ iv_date+4(2) }{ iv_delimiter }{ iv_date+6(2) }|.

  ENDMETHOD.


  METHOD dbm_vehicle_lock.
*&**********************************************************************
*  &   Author           : Szymon Galandziej TECH4                        *
*  &   Date             : 09.06.2017 15:24:27                            *
*  &   Company          : Proaxia consulting ag                          *
*  &**********************************************************************
*  & Program Definition : Lock vehicle
*  &
*  &**********************************************************************
*  & PROGRAM CHANGES / Modification Logs :                               *
*  &**********************************************************************
*  &   Date    Request     Programmer        Changes                     *
*  &+-------------------------------------------------------------------+*
*  &                                                                     *
*  &+-------------------------------------------------------------------+*

    DATA:
      lo_vehicle           TYPE REF TO /dbe/cl_veh_dbmvehicle,
      lo_veh_buf           TYPE REF TO  /dbe/cl_veh_buf,
      lo_ex                TYPE REF TO zcx_error,
      lo_ex_veh            TYPE REF TO /dbe/cx_veh_static_check,
      lo_ex_veh_locked     TYPE REF TO zcx_vehicle_locked,
      lo_ex_dbm_veh_locked TYPE REF TO /dbe/cx_oe_object_locked.

    TRY.
        lo_vehicle = get_vehicle_instance( iv_vguid ).
        lo_vehicle->lock( ).

      CATCH /dbe/cx_veh_static_check INTO lo_ex_veh.
        lo_vehicle->unlock( ).
        CREATE OBJECT lo_ex.
        lo_ex->append_bapi_msgs( lo_ex_veh->mt_bapiret ).
        RAISE EXCEPTION lo_ex.
      CATCH /dbe/cx_oe_object_locked INTO lo_ex_dbm_veh_locked.
        lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
        LOOP AT lo_veh_buf->get_cx_root( ) ASSIGNING FIELD-SYMBOL(<cx_root>).
          TRY.
              lo_ex_veh ?= <cx_root>.
              IF lo_ex_veh IS BOUND.
                CREATE OBJECT lo_ex_veh_locked.
                lo_ex_veh_locked->append_bapi_msgs( lo_ex_veh->mt_bapiret ).
                RAISE EXCEPTION lo_ex_veh_locked.
              ENDIF.
            CATCH cx_sy_move_cast_error.
          ENDTRY.
        ENDLOOP.
        MESSAGE e007(ydbm_id1_go) WITH lo_ex->get_text( ) INTO zcx_error=>mv_dummy.
        zcx_vehicle_locked=>raise_sy_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD dbm_vehicle_unlock.
*&**********************************************************************
*  &   Author           : Szymon Galandziej TECH4                        *
*  &   Date             : 14.06.2017 15:24:27                            *
*  &   Company          : Proaxia consulting ag                          *
*  &**********************************************************************
*  & Program Definition : Unlock vehicle
*  &
*  &**********************************************************************
*  & PROGRAM CHANGES / Modification Logs :                               *
*  &**********************************************************************
*  &   Date    Request     Programmer        Changes                     *
*  &+-------------------------------------------------------------------+*
*  &                                                                     *
*  &+-------------------------------------------------------------------+*

    DATA lo_vehicle TYPE REF TO /dbe/cl_veh_dbmvehicle.

    lo_vehicle = get_vehicle_instance( iv_vguid ).
    lo_vehicle->unlock( ).

  ENDMETHOD.


  METHOD get_conf_values.

    DATA: lt_return TYPE bapiret2_t,
          lo_ex     TYPE REF TO zcx_error.

    REFRESH rt_charactvalueschar.

    CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
      EXPORTING
        charactname       = iv_charactname
      TABLES
        charactvalueschar = rt_charactvalueschar
        return            = lt_return.
    IF rt_charactvalueschar IS INITIAL.
      CREATE OBJECT lo_ex.
      lo_ex->append_bapi_msgs( lt_return ).
      RAISE EXCEPTION lo_ex.
    ELSE.
      SORT rt_charactvalueschar BY value_char.
    ENDIF.

  ENDMETHOD.


  METHOD get_order_text.


    DATA:
      lo_ord_text TYPE REF TO /dbe/cl_ord_text,
      lo_ltext    TYPE REF TO /dbe/cl_ltext,
      lt_tdline   TYPE STANDARD TABLE OF tdline.


    lo_ord_text ?= io_order->object_get(
                  iv_classname = /dbe/cl_ord_text=>cv_object_name
                  iv_key       = /dbe/cl_ord_text=>cv_object_key ).

    IF lo_ord_text IS BOUND.

      CALL METHOD lo_ord_text->get_instance_by_key
        EXPORTING
          iv_tdobject = iv_tdobject
          iv_tdname   = iv_tdobname
        IMPORTING
          eo_instance = lo_ltext.

      IF lo_ltext IS BOUND.

        READ TABLE lo_ltext->mt_ltext ASSIGNING FIELD-SYMBOL(<ls_ltext>)
         WITH KEY tdspras = iv_langu tdid = iv_tdid.
        IF sy-subrc = 0.

          CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
            TABLES
              itf_text    = <ls_ltext>-tlines
              text_stream = lt_tdline.


          CALL FUNCTION 'CONVERT_TABLE_TO_STRING'
            EXPORTING
              i_tabline_length = 132
            IMPORTING
              e_string         = ev_string
            TABLES
              it_table         = lt_tdline.

        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE e030(/dbe/oe) WITH /dbe/cl_ord_text=>cv_object_name
       INTO mv_dummy.
      zcx_error=>raise_sy_msg( ).
    ENDIF.


  ENDMETHOD.


  METHOD get_vehicle_instance.
*&**********************************************************************
*  &   Author           : Szymon Galandziej TECH4                        *
*  &   Date             : 09.06.2017 15:03:37                            *
*  &   Company          : Proaxia consulting ag                          *
*  &**********************************************************************
*  & Program Definition : Get vehicle instance
*  &                      Code copied from standard FM /DBE/VM20_RFC_CHANGE
*  &
*  &**********************************************************************
*  & PROGRAM CHANGES / Modification Logs :                               *
*  &**********************************************************************
*  &   Date    Request     Programmer        Changes                     *
*  &+-------------------------------------------------------------------+*
*  &                                                                     *
*  &+-------------------------------------------------------------------+*

    DATA:
      lo_veh_buf      TYPE REF TO  /dbe/cl_veh_buf,
      lt_new_vehicles TYPE         /dbe/t_veh_bobnew,
      ls_new_vehicle  TYPE         /dbe/s_veh_bobnew,
      lt_vehicles     TYPE         /dbe/t_veh_bob,
      ls_vehicle      TYPE         /dbe/s_veh_bob,
      lt_cx_root      TYPE         sibfexctab,
      ls_cx_root      TYPE LINE OF sibfexctab,
      ls_cx_veh       TYPE REF TO  /dbe/cx_veh_static_check,
      lx_root         TYPE REF TO  cx_root,
      lt_return       TYPE         bapiret2_t,
      lv_dummy_msg    TYPE         c,
      lo_ex           TYPE REF TO zcx_error.

    CLEAR: ro_vehicle.

    TRY.
        lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
        ls_new_vehicle-guid = iv_vguid.
        ls_new_vehicle-bobtype = /dbe/cl_veh_dbmvehicle=>gc_bobtype.
        APPEND ls_new_vehicle TO lt_new_vehicles.
        lo_veh_buf->new_bob( EXPORTING it_bobnew = lt_new_vehicles
                             IMPORTING et_bob = lt_vehicles ).
        READ TABLE lt_vehicles INTO ls_vehicle WITH KEY guid = iv_vguid.
        IF sy-subrc NE 0.
          MESSAGE e006(ydbm_id1_go) INTO lv_dummy_msg.
          zcx_error=>raise_sy_msg( ).
        ENDIF.
        ro_vehicle ?= ls_vehicle-bobref.
      CATCH /dbe/cx_veh_error_occured
            /dbe/cx_veh_static_check INTO lx_root.
        lo_veh_buf->get_messages( EXPORTING io_cx_root = lx_root
                                  IMPORTING et_bapireturn = lt_return ).
        CREATE OBJECT lo_ex.
        lo_ex->append_bapi_msgs( lt_return ).
        RAISE EXCEPTION lo_ex.
      CATCH /dbe/cx_oe_object_locked INTO lx_root.
        lt_cx_root = lo_veh_buf->get_cx_root( ).
        LOOP AT lt_cx_root INTO ls_cx_root.
          TRY.
              ls_cx_veh ?= ls_cx_root.
              IF ls_cx_veh IS BOUND.
                APPEND LINES OF ls_cx_veh->mt_bapiret TO lt_return.
              ENDIF.
            CATCH cx_sy_move_cast_error.
          ENDTRY.
        ENDLOOP.
        CREATE OBJECT lo_ex.
        lo_ex->append_bapi_msgs( lt_return ).
        RAISE EXCEPTION lo_ex.
    ENDTRY.

  ENDMETHOD.


  METHOD is_valid_matnr.

    DATA: lv_matnr      TYPE matnr,
          lv_matnr_temp TYPE matnr,
          lv_vtweg      TYPE vtweg.

    rv_result = abap_false.

    WHILE lv_matnr_temp IS INITIAL.
      lv_matnr = iv_id.
      CASE sy-index.
        WHEN 1. "step1: check mara-matnr
          SELECT SINGLE matnr
            FROM mara
            INTO lv_matnr_temp
            WHERE matnr = lv_matnr.
        WHEN 2. "step2: check mara-zsort
*          SELECT SINGLE matnr
*            FROM mara
*            INTO lv_matnr_temp
*            WHERE zsort = lv_matnr.
        WHEN 3. "step3: check conversion from matnr40
          CALL FUNCTION 'CONVERSION_EXIT_MATN2_INPUT'
            EXPORTING
              input            = lv_matnr
            IMPORTING
              output           = lv_matnr
            EXCEPTIONS
              number_not_found = 1
              length_error     = 2
              OTHERS           = 3.
          IF sy-subrc EQ 0.
            SELECT SINGLE matnr
              FROM mara
              INTO lv_matnr_temp
              WHERE matnr = lv_matnr.
          ENDIF.
        WHEN OTHERS.
          EXIT.
      ENDCASE.
    ENDWHILE.

    IF lv_matnr_temp IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_check_mvke = abap_true.
      CALL FUNCTION 'MCV_REFERENCE_ORG_MATERIAL_GET'
        EXPORTING
          i_vkorg = iv_vkorg
          i_vtweg = iv_vtweg
        IMPORTING
          r_vtweg = lv_vtweg.
      IF lv_vtweg IS INITIAL.
        lv_vtweg = iv_vtweg.
      ENDIF.
      SELECT COUNT( * )
        FROM mvke
        WHERE matnr = lv_matnr_temp
          AND vkorg = iv_vkorg
          AND vtweg = lv_vtweg.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDIF.

    rv_result = abap_true.

  ENDMETHOD.


  METHOD mat_conv_18to40.

    IF iv_matnr18 IS INITIAL.
      RETURN.
    ENDIF.

************************************************************************
* Call SAP Standard
************************************************************************
    CALL FUNCTION '/DBE/P_MAT_CONV_18TO40'
      EXPORTING
        e_matnr18 = iv_matnr18
      IMPORTING
        e_matnr40 = rv_matnr40
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      IF iv_raise_if_not_found = abap_true.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_dummy).
        RAISE EXCEPTION TYPE zcx_error.
      ELSE.
        RETURN.
      ENDIF.
    ENDIF.

************************************************************************
* This operation seems to be missing in SAP Standard
************************************************************************
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = rv_matnr40
      IMPORTING
        output = rv_matnr40.

  ENDMETHOD.


  METHOD set_order_text.

    DATA:
      lo_ex            TYPE REF TO zcx_error,
      lo_ord_text      TYPE REF TO /dbe/cl_ord_text,
      lo_ltext         TYPE REF TO /dbe/cl_ltext,
      lt_tdline        TYPE STANDARD TABLE OF tdline,
      lt_tline_tab     TYPE tline_tab,
      ls_ltext         TYPE /dbe/lt_ltext,
      ls_ord_ltext_com TYPE /dbe/lt_ltext_com,
      lt_update_text   TYPE /dbe/lt_ltext_com_tt.

    lo_ex = NEW #( ).

    lo_ord_text ?= io_order->object_get(
    iv_classname = /dbe/cl_ord_text=>cv_object_name
    iv_key       = /dbe/cl_ord_text=>cv_object_key ).

    IF lo_ord_text IS BOUND.

      CALL METHOD lo_ord_text->get_instance_by_key
        EXPORTING
          iv_tdobject = iv_tdobject
          iv_tdname   = iv_tdobname
        IMPORTING
          eo_instance = lo_ltext.

      CALL FUNCTION 'CONVERT_STRING_TO_TABLE'
        EXPORTING
          i_string         = iv_string
          i_tabline_length = 132
        TABLES
          et_table         = lt_tdline.

      CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
        TABLES
          text_stream = lt_tdline
          itf_text    = lt_tline_tab.

      IF lo_ltext IS BOUND.

        READ TABLE lo_ltext->mt_ltext ASSIGNING FIELD-SYMBOL(<ls_ltext>)
          WITH KEY tdspras = iv_langu tdid = iv_tdid.
**********************************************************************
* Long text - overwritten
**********************************************************************
        IF sy-subrc = 0.
          ls_ltext = <ls_ltext>.
          ls_ltext-chngd = /dbe/cl_ltext=>c_change.
          ls_ltext-tlines = lt_tline_tab.
          APPEND ls_ltext TO ls_ord_ltext_com-ltext.
          ls_ord_ltext_com-tdname = iv_tdobname.
          ls_ord_ltext_com-tdobject = iv_tdobject.
          APPEND ls_ord_ltext_com TO lt_update_text.

        ELSE.
**********************************************************************
* Long text - create new
**********************************************************************
          ls_ltext-tdobject = iv_tdobject.
          ls_ltext-tdname = iv_tdobname.
          ls_ltext-tdid = iv_tdid.
          ls_ltext-tdspras = iv_langu.
          ls_ltext-tlines = lt_tline_tab.
          ls_ltext-chngd = /dbe/cl_ltext=>c_insert.
          APPEND ls_ltext TO ls_ord_ltext_com-ltext.

          ls_ord_ltext_com-tdname = iv_tdobname.
          ls_ord_ltext_com-tdobject = iv_tdobject.
          APPEND ls_ord_ltext_com TO lt_update_text.
        ENDIF.

      ELSE."There is no any text yet
        ls_ltext-tdobject = iv_tdobject.
        ls_ltext-tdname = iv_tdobname.
        ls_ltext-tdid = iv_tdid.
        ls_ltext-tdspras = iv_langu.
        ls_ltext-tlines = lt_tline_tab.
        ls_ltext-chngd = /dbe/cl_ltext=>c_insert.
        APPEND ls_ltext TO ls_ord_ltext_com-ltext.

        ls_ord_ltext_com-tdname = iv_tdobname.
        ls_ord_ltext_com-tdobject = iv_tdobject.
        APPEND ls_ord_ltext_com TO lt_update_text.
      ENDIF.
**********************************************************************
* Insert and update order text
**********************************************************************
      LOOP AT lt_update_text INTO ls_ord_ltext_com.

        CALL METHOD lo_ord_text->set_data
          EXPORTING
            is_ltext_com = ls_ord_ltext_com.

        IF lo_ord_text->ms_ltext_detail IS NOT INITIAL.
          CALL METHOD lo_ord_text->update_text
            EXCEPTIONS
              error_text_update = 1.
          IF sy-subrc NE 0.
            lo_ex->append_sy_msg( ).
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lo_ex->is_error( ).
        RAISE EXCEPTION lo_ex.
      ENDIF.

    ELSE.
      MESSAGE e030(/dbe/oe) WITH /dbe/cl_ord_text=>cv_object_name
      INTO mv_dummy.
      zcx_error=>raise_sy_msg( ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.
