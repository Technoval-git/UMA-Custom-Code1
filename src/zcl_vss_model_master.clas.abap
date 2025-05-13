CLASS zcl_vss_model_master DEFINITION
  PUBLIC
  CREATE PUBLIC .


  PUBLIC SECTION.

    DATA mv_model_sales_code TYPE /dbe/modcode_sale READ-ONLY .
    DATA mv_model_guid TYPE /dbe/model_guid READ-ONLY .
    DATA mv_mcatalog TYPE /dbe/mcatalog READ-ONLY .

    METHODS constructor
      IMPORTING
        !ir_log              TYPE REF TO zvss_ifm_cl_x_log
        !iv_model_sales_code TYPE /dbe/modcode_sale
      RAISING
        zcx_error.
    CLASS-METHODS exist_check
      IMPORTING
        !iv_model_sales_code TYPE /dbe/modcode_sale
      RETURNING
        VALUE(rv_exists)     TYPE abap_bool
      RAISING
        zcx_error.
    CLASS-METHODS generate_option_guid
      RETURNING
        VALUE(rv_option_guid) TYPE /dbe/option_guid .
    METHODS get_details
      IMPORTING
        !iv_refresh_buffer    TYPE abap_bool
      EXPORTING
        !es_material          TYPE /dbe/v_mara
        !es_model             TYPE /dbe/v_model
        !es_model_long_text   TYPE /dbe/lt_ltext_com
        !et_model_texts       TYPE /dbe/v_modelt_t
        !et_options           TYPE /dbe/tv_options
        !et_option_long_texts TYPE /dbe/lt_ltext_com_tt
        !et_option_texts      TYPE /dbe/tv_options_t
      RAISING
        zcx_error.
    CLASS-METHODS get_go_model_master_mapping
      IMPORTING
        !iv_model_guid    TYPE /dbe/model_guid
      RETURNING
        VALUE(rt_mapping) TYPE zvss_mm_opt_map_tt
      RAISING
        zcx_not_found .
    CLASS-METHODS get_go_model_master_map_text
      IMPORTING
        !iv_model_guid         TYPE /dbe/model_guid
      RETURNING
        VALUE(rt_mapping_text) TYPE zvss_mt_opt_map_tt
      RAISING
        zcx_not_found .
    CLASS-METHODS get_vm_options
      IMPORTING
        !iv_mcatalog      TYPE /dbe/mcatalog
      RETURNING
        VALUE(rt_options) TYPE zvss_vm_options_tt
      RAISING
        zcx_not_found .
    CLASS-METHODS get_vm_options_txt
      IMPORTING
        !iv_mcatalog      TYPE /dbe/mcatalog
      RETURNING
        VALUE(rt_options) TYPE zvss_vm_optionst_tt
      RAISING
        zcx_not_found .
    CLASS-METHODS lock
      IMPORTING
        !iv_model_guid TYPE /dbe/model_guid
      RAISING
        zcx_error
        zcx_model_master_locked .
    CLASS-METHODS unlock
      IMPORTING
        !iv_model_guid TYPE /dbe/model_guid .
    METHODS update
      IMPORTING
        !it_model_texts       TYPE /dbe/v_modelt_t OPTIONAL
        !it_option_texts      TYPE /dbe/tv_options_t OPTIONAL
        !iv_mode              TYPE char1 OPTIONAL
        !is_material          TYPE /dbe/v_mara OPTIONAL
        !iv_save_material     TYPE char1 OPTIONAL
        !iv_save_model        TYPE char1 OPTIONAL
        !is_model_long_text   TYPE /dbe/lt_ltext_com OPTIONAL
        !it_option_long_texts TYPE /dbe/lt_ltext_com_tt OPTIONAL
      EXPORTING
        !ev_model_guid        TYPE /dbe/guid
      CHANGING
        !cs_model             TYPE /dbe/v_model OPTIONAL
        !ct_options           TYPE /dbe/tv_options
      RAISING
        zcx_error.
    CLASS-METHODS update_go_model_master_mapping
      IMPORTING
        !iv_in_update_task TYPE abap_bool
        !it_data           TYPE zvss_mm_opt_map_tt
      RAISING
        zcx_error.
    CLASS-METHODS update_go_model_master_map_txt
      IMPORTING
        !iv_in_update_task TYPE abap_bool
        !it_data           TYPE zvss_mt_opt_map_tt
      RAISING
        zcx_error.
    CLASS-METHODS update_vm_options
      IMPORTING
        !iv_in_update_task TYPE abap_bool
        !it_data           TYPE zvss_vm_options_tt
      RAISING
        zcx_error.
    CLASS-METHODS update_vm_options_txt
      IMPORTING
        !iv_in_update_task TYPE abap_bool
        !it_data           TYPE zvss_vm_optionst_tt
      RAISING
        zcx_error.
    METHODS refresh_data
      IMPORTING
        !iv_model_sales_code TYPE /dbe/modcode_sale
      RAISING
        zcx_error.
    CLASS-METHODS get_feat_categories
      RETURNING
        VALUE(rt_feat_cat) TYPE zvss_v_optype_tt .
    CLASS-METHODS filter_vm_options
      CHANGING
        !ct_map TYPE zvss_mm_opt_map_tt .
  PROTECTED SECTION.

    DATA mr_log TYPE REF TO zvss_ifm_cl_x_log .
    DATA mo_model TYPE REF TO /dbe/cl_veh_model .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VSS_MODEL_MASTER IMPLEMENTATION.


  METHOD constructor.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 21.06.2017 15:08:31                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : GO Data processing class
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    DATA: ls_model TYPE /dbe/v_model.

    mr_log = ir_log.

    refresh_data( iv_model_sales_code = iv_model_sales_code ).

  ENDMETHOD.


  METHOD exist_check.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 07.06.2017 15:08:31                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Check existence of model master
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    DATA: lv_model_guid       TYPE /dbe/model_guid.

    TRY.
*       becasue of performance issues we have to get model guid first
*       (get instance is very slow if only model sales code is given)
        lv_model_guid = zcl_vss_db_access=>get_model_guid_for_mod_sal_cod( iv_model_sales_code = iv_model_sales_code ).
        /dbe/cl_veh_model=>get_instance( iv_model_guid = lv_model_guid ).
      CATCH /dbe/cx_veh_model_not_found
            zcx_error.
        rv_exists = abap_false.
        RETURN.
    ENDTRY.

    rv_exists = abap_true.

  ENDMETHOD.


  METHOD filter_vm_options.
    LOOP AT ct_map ASSIGNING FIELD-SYMBOL(<fs_map>).
      IF strlen( <fs_map>-opkey ) EQ 4
        AND <fs_map>-opkey+3(1) = 'U'.
        CLEAR: <fs_map>.
      ENDIF.
    ENDLOOP.
    DELETE ct_map WHERE model_guid IS INITIAL.
  ENDMETHOD.


  METHOD generate_option_guid.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 21.06.2017 10:40:06                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Generate option guid
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    DATA: lv_guid TYPE /dbe/guid.

    CALL FUNCTION 'GUID_CREATE'                         "#EC FB_OLDED
      IMPORTING
        ev_guid_16 = lv_guid.

    rv_option_guid = lv_guid.

  ENDMETHOD.


  METHOD get_details.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 21.06.2017 15:08:31                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Get model master data
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    TRY.

        IF iv_refresh_buffer = abap_true.
          refresh_data( iv_model_sales_code = mv_model_sales_code ).
        ENDIF.

        mo_model->get_model_data(
          IMPORTING
            es_material          = es_material
            es_model             = es_model
            es_model_long_text   = es_model_long_text
            et_model_texts       = et_model_texts
            et_options           = et_options
            et_option_long_texts = et_option_long_texts
            et_option_texts      = et_option_texts ).

      CATCH /dbe/cx_veh_model_not_found.
        MESSAGE e045(ydbm_id1) WITH mv_model_sales_code INTO zcx_error=>mv_dummy.
        zcx_error=>raise_sy_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_feat_categories.

    SELECT * FROM /dbe/v_optype INTO CORRESPONDING FIELDS OF TABLE rt_feat_cat.
    IF sy-subrc <> 0.
*        do nothing
    ENDIF.

  ENDMETHOD.


  METHOD get_go_model_master_mapping.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 22.06.2017 10:48:40                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Get model master mapping
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    TRY.
        rt_mapping = zcl_vss_db_access=>get_oem_model_master_mapping( iv_model_guid ).
      CATCH zcx_error.
        RAISE EXCEPTION TYPE zcx_not_found.
    ENDTRY.

  ENDMETHOD.


  METHOD get_go_model_master_map_text.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 10.08.2017 10:48:40                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Get model master mapping texts
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    TRY.
        rt_mapping_text = zcl_vss_db_access=>get_oem_model_master_map_text( iv_model_guid ).
      CATCH zcx_error.
        RAISE EXCEPTION TYPE zcx_not_found.
    ENDTRY.

  ENDMETHOD.


  METHOD get_vm_options.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 23.06.2017 15:41:55                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Get /DBE/VM_OPTIONS
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    TRY.
        rt_options = zcl_vss_db_access=>get_vm_options( iv_mcatalog ).
      CATCH zcx_error.
        RAISE EXCEPTION TYPE zcx_not_found.
    ENDTRY.

  ENDMETHOD.


  METHOD get_vm_options_txt.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 11.08.2017 15:41:55                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Get /DBE/VM_OPTIONS
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    TRY.
        rt_options = zcl_vss_db_access=>get_vm_options_txt( iv_mcatalog ).
      CATCH zcx_error.
        RAISE EXCEPTION TYPE zcx_not_found.
    ENDTRY.

  ENDMETHOD.


  METHOD lock.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 21.06.2017 15:11:17                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Lock model master
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    DATA: lv_model_locked    TYPE abap_bool,
          lt_return          TYPE bapiret2_t,
          lo_ex              TYPE REF TO zcx_error,
          lo_ex_model_locked TYPE REF TO zcx_model_master_locked.

    CALL FUNCTION '/DBE/VM16_MODEL_ENQUEUE'
      EXPORTING
        iv_model_guid   = iv_model_guid
      IMPORTING
        ev_model_locked = lv_model_locked
      CHANGING
        ct_bapireturn   = lt_return.

    IF lv_model_locked = abap_true.
      CREATE OBJECT lo_ex_model_locked.
      lo_ex_model_locked->append_bapi_msgs( lt_return ).
      RAISE EXCEPTION lo_ex_model_locked.
    ELSEIF zcx_error=>contain_error( lt_return ) = abap_true.
      CREATE OBJECT lo_ex.
      lo_ex->append_bapi_msgs( lt_return ).
      RAISE EXCEPTION lo_ex.
    ENDIF.

  ENDMETHOD.


  METHOD refresh_data.

    DATA: ls_model      TYPE /dbe/v_model,
          lv_model_guid TYPE /dbe/model_guid.

    TRY.

        CLEAR: mo_model.

*       becasue of performance issues we have to get model guid first
*       (get instance is very slow if only model sales code is given)
        lv_model_guid = zcl_vss_db_access=>get_model_guid_for_mod_sal_cod( iv_model_sales_code = iv_model_sales_code ).
        mo_model = /dbe/cl_veh_model=>get_instance( iv_model_guid = lv_model_guid ).
        mv_model_sales_code = iv_model_sales_code.

        mo_model->get_model_data( IMPORTING es_model = ls_model ).
        mv_model_guid = ls_model-model_guid.
        mv_mcatalog = ls_model-mcatalog.

      CATCH /dbe/cx_veh_model_not_found
            zcx_error.
        MESSAGE e005(ydbm_id1_go) WITH iv_model_sales_code INTO zcx_error=>mv_dummy. "Model master does not exist (Baumuster &1).
        zcx_error=>raise_sy_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD unlock.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 21.06.2017 15:36:59                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Unlock model master
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    CALL FUNCTION '/DBE/VM16_MODEL_DEQUEUE'
      EXPORTING
        iv_model_guid = iv_model_guid.

  ENDMETHOD.


  METHOD update.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 21.06.2017 09:11:41                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Model master update
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    DATA:
      lt_return TYPE  bapireturn_t,
      lo_ex     TYPE REF TO zcx_error,
      lv_dummy  TYPE c.

    IF cs_model-mcodesd <> mv_model_sales_code.
      MESSAGE e046(ydbm_id1) WITH cs_model-mcodesd mv_model_sales_code INTO lv_dummy. "Model instance attr. differs from the method param. (&1 <> &2).
      zcx_error=>raise_sy_msg( ).
    ENDIF.

    CLEAR lt_return.
    CALL FUNCTION '/DBE/VM16_MODEL_SAVE'
      EXPORTING
        it_modelt        = it_model_texts
        it_optionst      = it_option_texts "mandatory, otherwise some options may be deleted
        iv_mode          = iv_mode
        is_material      = is_material
        iv_save_material = iv_save_material "TRUE means that material WILL NOT BE saved!
        iv_save_model    = iv_save_model "FALSE means that model WILL BE saved!
        is_modellongt    = is_model_long_text
        it_optionslongt  = it_option_long_texts
      IMPORTING
        model_guid       = ev_model_guid
        et_bapireturn    = lt_return
      CHANGING
        cs_model         = cs_model
        ct_options       = ct_options.
    IF zcx_error=>contain_error( lt_return ) = abap_true.
      CREATE OBJECT lo_ex.
      lo_ex->append_bapi_msgs( lt_return ).
      RAISE EXCEPTION lo_ex.
    ENDIF.

    mr_log->add_msg_from_bapiret( it_bapiret = lt_return ).

  ENDMETHOD.


  METHOD update_go_model_master_mapping.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 22.06.2017 11:35:34                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Update model master mapping
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    IF iv_in_update_task = abap_true.
      CALL FUNCTION 'YDBM_ID1_GO_GOMM_UPDATE_M' IN UPDATE TASK
        EXPORTING
          it_data = it_data.
    ELSE.
      CALL FUNCTION 'YDBM_ID1_GO_GOMM_UPDATE_M'
        EXPORTING
          it_data    = it_data
        EXCEPTIONS
          db_failure = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
        zcx_error=>raise_sy_msg( ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD update_go_model_master_map_txt.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 10.08.2017 11:35:34                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Update model master mapping text
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    IF iv_in_update_task = abap_true.
      CALL FUNCTION 'YDBM_ID1_GO_GOMT_UPDATE_M' IN UPDATE TASK
        EXPORTING
          it_data = it_data.
    ELSE.
      CALL FUNCTION 'YDBM_ID1_GO_GOMT_UPDATE_M'
        EXPORTING
          it_data    = it_data
        EXCEPTIONS
          db_failure = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
        zcx_error=>raise_sy_msg( ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD update_vm_options.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 22.06.2017 11:35:34                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Update /DBE/VM_OPTIONS
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    IF iv_in_update_task = abap_true.
      CALL FUNCTION 'YDBM_ID1_VM_OPTIONS_UPDATE_M' IN UPDATE TASK
        EXPORTING
          it_data = it_data.
    ELSE.
      CALL FUNCTION 'YDBM_ID1_VM_OPTIONS_UPDATE_M'
        EXPORTING
          it_data    = it_data
        EXCEPTIONS
          db_failure = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
        zcx_error=>raise_sy_msg( ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD update_vm_options_txt.
*&**********************************************************************
*&   Author           : Szymon Galandziej TECH4                        *
*&   Date             : 11.08.2017 11:35:34                            *
*&   Company          : Proaxia consulting ag                          *
*&**********************************************************************
*& Program Definition : Update /DBE/VM_OPTIONS
*&
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date    Request     Programmer        Changes                     *
*&+-------------------------------------------------------------------+*
*&                                                                     *
*&+-------------------------------------------------------------------+*

    IF iv_in_update_task = abap_true.
      CALL FUNCTION 'YDBM_ID1_VM_OPTIONST_UPDATE_M' IN UPDATE TASK
        EXPORTING
          it_data = it_data.
    ELSE.
      CALL FUNCTION 'YDBM_ID1_VM_OPTIONST_UPDATE_M'
        EXPORTING
          it_data    = it_data
        EXCEPTIONS
          db_failure = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
        zcx_error=>raise_sy_msg( ).
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
