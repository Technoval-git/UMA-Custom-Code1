class ZCL_REXC_SA_EDOC_FACTORY_FI definition
  public
  inheriting from CL_EDOC_FACTORY
  final
  create public .

public section.
protected section.

  methods GET_AWTYP_FOR_FI
    importing
      !IO_SOURCE type ref to CL_EDOC_SOURCE
    returning
      value(RV_AWTYP) type AWTYP .

  methods MAKE_SOURCE_RELEVANT
    redefinition .
  methods CREATE_EDOC_INSTANCES
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_REXC_SA_EDOC_FACTORY_FI IMPLEMENTATION.


  METHOD create_edoc_instances.

    DATA: lo_edocument TYPE REF TO cl_edocument, is_relevant TYPE abap_bool, lv_relevant TYPE abap_bool.
*    * Initialization
    clear et_edocument_obj[].
* Prerequisite

    TRY.
        CALL METHOD make_source_relevant
          EXPORTING
            io_source             = io_source
            iv_hook               = iv_hook
          CHANGING
            cv_is_source_relevant = lv_relevant.
      CATCH cx_edocument.
        RETURN.
    ENDTRY.
    CHECK lv_relevant = abap_true.
* Create additional instance
    CREATE OBJECT lo_edocument TYPE zcl_edocument_sa
      EXPORTING
        io_source_data = io_source
        iv_update_task = iv_update_task.
    CLEAR et_edocument_obj.
    APPEND lo_edocument TO et_edocument_obj.
  ENDMETHOD.


  METHOD get_awtyp_for_fi.

    DATA: ld_source_data   TYPE REF TO data,
          ls_source_header TYPE edoc_src_header.

    FIELD-SYMBOLS: <ls_src_data_fi_invoice> TYPE edoc_src_data_fi_invoice.

    ls_source_header = io_source->get_header( ).


    IF ls_source_header-source_type = cl_edoc_source_fi_invoice=>gc_src_fi_invoice.
      ld_source_data = io_source->get_data_reference( ).
      ASSIGN ld_source_data->* TO <ls_src_data_fi_invoice>.
      IF sy-subrc <> 0.
        CLEAR rv_awtyp.
      ELSE.
        rv_awtyp = <ls_src_data_fi_invoice>-document_header-awtyp.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD make_source_relevant.
**TRY.
*CALL METHOD SUPER->MAKE_SOURCE_RELEVANT
*  EXPORTING
*    IO_SOURCE             =
*    IV_HOOK               =
**    iv_update_task        = ABAP_FALSE
*  CHANGING
*    CV_IS_SOURCE_RELEVANT =
*    .
**  CATCH cx_edocument.
**ENDTRY.

    DATA: ld_source_data   TYPE REF TO data, ls_source_header TYPE edoc_src_header.
    FIELD-SYMBOLS: <ls_src_data_fi_invoice> TYPE edoc_src_data_fi_invoice.


* Initialization
    clear cv_is_source_relevant.
    ls_source_header = io_source->get_header( ).


* Prerequisite
* - Country - Saudi Arabia
    CHECK ls_source_header-land = 'SA'.

* - Source type - FI Invoice
    CHECK io_source->mv_source_type = cl_edoc_source_fi_invoice=>gc_src_fi_invoice.

* - Reference transaction - REACI
    CHECK get_awtyp_for_fi( io_source = io_source ) = 'REACI'.

    cv_is_source_relevant = abap_true.
  ENDMETHOD.
ENDCLASS.
