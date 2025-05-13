class ZCL_PICK_PRNT_PDF definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /SCWM/IF_EX_PRNT_PDF_WO .
protected section.
private section.
ENDCLASS.



CLASS ZCL_PICK_PRNT_PDF IMPLEMENTATION.


  METHOD /scwm/if_ex_prnt_pdf_wo~get_add_wo_data.
*    BREAK-POINT.
    DATA : lv_funcname      TYPE funcname,
           lv_output_params TYPE sfpoutputparams,
           lv_FPFORMOUTPUT  TYPE fpformoutput.
    CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
      EXPORTING
        i_name     = iv_form
      IMPORTING
        e_funcname = lv_funcname.

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
*       IT_PI_ITEM         = O
*        wo_misc            = et_wo_info
        who                = is_who
*       WHUHU              = O
        ordim_o            = it_ordim_o "et_oridm_o
        ordim_c            = it_ordim_c
*       ORDIM_L            = O
        ordim_os           = it_ordim_os
        ordim_cs           = it_ordim_cs
        print_param        = is_print
*       WHO_CREATED_DATE   = O
        huhdr_int          = et_huhdr
        tsp_carrier        = ev_tsp
*       ALPHA_CODE         = O
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
