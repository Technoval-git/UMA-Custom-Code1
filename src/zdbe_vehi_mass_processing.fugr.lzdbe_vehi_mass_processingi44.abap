*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI44 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_TRANSFER_NEW_VEHICLES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_transfer_new_vehicles INPUT.

  PERFORM f_transfer_new_vehicles.

ENDMODULE.                 " M_TRANSFER_NEW_VEHICLES  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_TRANSFER_OPTION_IOBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LR_IOBJ_MULTI_COM  text
*----------------------------------------------------------------------*
FORM f_transfer_option_iobject CHANGING pr_iobj_multi_com TYPE REF TO /dbe/iobj_data_multi_com_s.

  DATA:
    lv_lang_iso  TYPE laiso,
    ls_optionalv TYPE /dbe/v_options,
    ls_ioption   TYPE /dbe/v_ioption_dynp,
    lt_ioption   TYPE TABLE OF /dbe/v_ioption_dynp,
    ls_ioptiont  TYPE /dbe/v_ioptiont_dynp,
    lt_ioptiont  TYPE TABLE OF /dbe/v_ioptiont_dynp.

  LOOP AT gt_optionalv_all INTO ls_optionalv WHERE sel_option = abap_true.
    MOVE-CORRESPONDING ls_optionalv TO ls_ioption.
    ls_ioption-opmatnr = ls_optionalv-matnr.
    ls_ioption-puprc_c = ls_optionalv-pkonwa.
    ls_ioption-saprc_c = ls_optionalv-skonwa.
    ls_ioption-opguid  = ls_optionalv-option_guid.
    APPEND ls_ioption TO lt_ioption.

    MOVE-CORRESPONDING ls_optionalv TO ls_ioptiont.
    lv_lang_iso = sy-langu.
    "Get ISO language code
    CALL FUNCTION 'CONVERSION_EXIT_ISOLA_OUTPUT'
      EXPORTING
        input  = lv_lang_iso
      IMPORTING
        output = lv_lang_iso.

    ls_ioptiont-oplangu = lv_lang_iso.
    APPEND ls_ioptiont TO lt_ioptiont.

  ENDLOOP.

  pr_iobj_multi_com->/dbe/v_ioption[] = lt_ioption[].
  pr_iobj_multi_com->/dbe/v_ioptiont[] = lt_ioptiont[].

ENDFORM.                    " F_TRANSFER_OPTION_IOBJECT
