*&---------------------------------------------------------------------*
*& Include          ZMM_STO_DELIVERY_FORM_DEF
*&---------------------------------------------------------------------*
CLASS lcl_print_form DEFINITION FINAL.

  PUBLIC SECTION.

    METHODS :

      " Method is triggering point of Adobe Form
      call_form CHANGING ch_retcode TYPE sy-subrc
                         ch_preview TYPE c,

      " Method to Update the NAST Data for error/success
      update_nast_protocol IMPORTING im_msgid TYPE sy-msgid
                                     im_msgno TYPE sy-msgno
                                     im_msgty TYPE sy-msgty,

      "Method to fill control data for print output
      fill_control_strcture IMPORTING im_nast         TYPE nast
                                      im_preview      TYPE c
                            EXPORTING ex_outputparams TYPE sfpoutputparams
                                      ex_docparams    TYPE sfpdocparams,

*      "Method to map Data to Interface form.
      map_data EXPORTING es_header TYPE ZMM_S_INF_STO_HEADER
                         et_items  TYPE ZMM_TT_INF_STO_ITEMS.






ENDCLASS.
