FUNCTION ZDBE_VMASS_GET_ADC_ITEMS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_DOCUMENT_TYPE) TYPE  INT4 DEFAULT 1
*"  TABLES
*"      IT_VLCGUID STRUCTURE  VLCGUID
*"      ET_VLCAPO TYPE  /DBE/VLC_AC_PO_T
*"  EXCEPTIONS
*"      NO_RECORD_FOUND
*"--------------------------------------------------------------------
*  TYPES:  BEGIN OF ty_adc,
*          po_number TYPE /DBE/ebeln,
*          inv_number TYPE re_belnr,
*          END OF ty_adc.
  DATA:
*        lt_adc   TYPE TABLE OF ty_adc,
        lt_vlcpo TYPE /DBE/vlc_ac_po_t,
*        ls_adc   TYPE ty_adc,
        ls_vlcpo TYPE /DBE/vlc_ac_po,
        lt_unique_vlcpo TYPE /DBE/vlc_ac_po_t,
        lt_return           TYPE TABLE OF bapiret2,           "N:2753894
        ls_po_item          TYPE bapiekpo,
        lt_po_items         TYPE TABLE OF bapiekpo.

    FIELD-SYMBOLS: <fs_vlcpo>  TYPE /DBE/vlc_ac_po.

  "Read the ADC table for distinct PO
  SELECT DISTINCT po_number inv_number inv_year gr_number gr_year       "N:2348422
  FROM /DBE/vlc_ac_po
  INTO CORRESPONDING FIELDS OF TABLE lt_unique_vlcpo
  FOR ALL ENTRIES IN it_vlcguid
  WHERE vguid = it_vlcguid-vguid . "#EC CI_NOFIELD.

  " Fetch all po-related item one by one
  LOOP AT lt_unique_vlcpo INTO ls_vlcpo.

    CASE iv_document_type.

      WHEN 0.                                                           "N:2348422
        "Fetch all the vehicles belonging to the given PO, invoice and material document
        SELECT *
        FROM /DBE/vlc_ac_po
        INTO CORRESPONDING FIELDS OF TABLE lt_vlcpo
        WHERE ( po_number = ls_vlcpo-po_number ) OR
              ( gr_number = ls_vlcpo-gr_number AND gr_year = ls_vlcpo-gr_year ) OR
              ( inv_number = ls_vlcpo-inv_number AND inv_year = ls_vlcpo-inv_year ).    "#EC CI_NOFIELD
        IF sy-subrc <> 0.
          RAISE no_record_found.
        ENDIF.
        SORT lt_vlcpo BY inv_number gr_number po_number.
      WHEN 1.
        "Fetch all the vehicles belonging to the given PO
        SELECT *
        FROM /DBE/vlc_ac_po
        INTO CORRESPONDING FIELDS OF TABLE lt_vlcpo
        WHERE po_number = ls_vlcpo-po_number ."#EC CI_NOFIELD.

        IF sy-subrc <> 0.
          RAISE no_record_found.
        ENDIF.
        SORT lt_vlcpo BY po_number.

      WHEN 2.
        "Fetch all the vehicles with the given invoice
        SELECT *
        FROM /DBE/vlc_ac_po
        INTO CORRESPONDING FIELDS OF TABLE lt_vlcpo
        WHERE inv_number = ls_vlcpo-inv_number AND inv_year = ls_vlcpo-inv_year.    "#EC CI_NOFIELD

        IF sy-subrc <> 0.
          RAISE no_record_found.
        ENDIF.
        SORT lt_vlcpo BY inv_number inv_year.

      WHEN 3.                                                           "N:2348422
        "Fetch all the vehicles with the given material document
        SELECT *
        FROM /DBE/vlc_ac_po
        INTO CORRESPONDING FIELDS OF TABLE lt_vlcpo
        WHERE gr_number = ls_vlcpo-gr_number AND gr_year = ls_vlcpo-gr_year.    "#EC CI_NOFIELD

        IF sy-subrc <> 0.
          RAISE no_record_found.
        ENDIF.
        SORT lt_vlcpo BY gr_number gr_year.

      WHEN OTHERS.
        "do nothing
    ENDCASE.

    LOOP AT lt_vlcpo ASSIGNING <fs_vlcpo>.
 "The actual net price should be read from PO                          "N:2753894
      CALL FUNCTION 'BAPI_PO_GETDETAIL' "#EC CI_USAGE_OK[2438131]
                                        "#EC CI_USAGE_OK[1803189]
        EXPORTING
          purchaseorder               = <fs_vlcpo>-po_number
        TABLES
          po_items                    = lt_po_items
          return                      = lt_return.
      IF sy-subrc IS INITIAL.
        READ TABLE lt_po_items INTO ls_po_item
          WITH KEY po_number = <fs_vlcpo>-po_number
                   po_item   = <fs_vlcpo>-po_item.
        IF sy-subrc IS INITIAL.
          <fs_vlcpo>-cost = ls_po_item-net_price.
        ENDIF.
      ENDIF.
     ENDLOOP.

    APPEND LINES OF lt_vlcpo TO et_vlcapo.

  ENDLOOP.

  SORT et_vlcapo BY guid.
  DELETE ADJACENT DUPLICATES FROM et_vlcapo COMPARING guid.
ENDFUNCTION.
