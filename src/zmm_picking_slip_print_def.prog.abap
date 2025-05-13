*&---------------------------------------------------------------------*
*& Include          ZMM_PICKING_SLIP_PRINT_DEF
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
      map_data EXPORTING es_header TYPE zmm_inf_picking_header
                         et_items  TYPE zmm_tt_inf_picking_items.






ENDCLASS.
