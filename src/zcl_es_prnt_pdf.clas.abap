class ZCL_ES_PRNT_PDF definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /SCWM/IF_EX_PRNT_PDF_HU .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ES_PRNT_PDF IMPLEMENTATION.


  METHOD /scwm/if_ex_prnt_pdf_hu~get_add_hu_data.

    DATA : lv_funcname      TYPE funcname,
           lv_output_params TYPE sfpoutputparams,
           lv_FPFORMOUTPUT  TYPE fpformoutput.
    CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
      EXPORTING
        i_name     = iv_form_name
      IMPORTING
        e_funcname = lv_funcname
*       e_interface_type    =
*        ev_funcname_inbound =.
      .

    lv_output_params = is_output_params.
    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = lv_output_params
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    DATA : lv_hu_details TYPE /scwm/tt_wo_info,
           lv_shp_label  TYPE  /scwm/tt_shplabel,
           lv_hu_header  TYPE /scwm/tt_huhdr_int.
    CALL FUNCTION lv_funcname
      EXPORTING
        /1bcdwb/docparams  = is_doc_params
        hu_details         = et_hu_wt_info
        shp_label          = et_hu_shplabel
        hu_header          = it_huhdr_int
        print_param        = is_print
        hu_hierarchy       = et_hu_print_tree
        it_hu_hazard_mat   = et_hu_hazard_mat
        material_items     = et_hu_content
        it_ser_labels      = et_hu_ser_label
      IMPORTING
        /1bcdwb/formoutput = lv_fpformoutput
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'FP_JOB_CLOSE'
* IMPORTING
*   E_RESULT             =
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    ev_printed = abap_true.






  ENDMETHOD.
ENDCLASS.
