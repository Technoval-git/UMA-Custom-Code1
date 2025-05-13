FUNCTION ZDBE_VMASS_ADC_READ_DB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_PO_STATUS) TYPE  C OPTIONAL
*"     REFERENCE(IV_GR_STATUS) TYPE  C OPTIONAL
*"     REFERENCE(IV_INV_STATUS) TYPE  C OPTIONAL
*"     REFERENCE(IT_ADC_STATUS) TYPE  /DBE/VLC_ADC_STATUS_T OPTIONAL
*"     REFERENCE(IV_INCLUDE_ALL) TYPE  C OPTIONAL
*"     REFERENCE(IV_PO_NUMBER) TYPE  /DBE/EBELN OPTIONAL
*"     REFERENCE(IV_ADDDTIONAL_COST_OVERVIEW) TYPE  BOOLEAN OPTIONAL
*"  TABLES
*"      VLCGUID_IT STRUCTURE  VLCGUID
*"      VLCAPO_ET TYPE  /DBE/VLC_AC_PO_T
*"  EXCEPTIONS
*"      NO_RECORD_FOUND
*"--------------------------------------------------------------------
  DATA: lt_po_numbers	TYPE STANDARD TABLE OF /DBE/ebeln,
        lt_vlcpo TYPE /DBE/vlc_ac_po_t,
        ls_adc_status TYPE /DBE/vlc_adc_status_s.

  FIELD-SYMBOLS: <fs_vlc_ac_po> TYPE /DBE/vlc_ac_po.

  CLEAR :  lt_vlcpo,vlcapo_et,lt_po_numbers.

  CONSTANTS:
          lc_po_succes             TYPE c VALUE 'S',
          lc_gr_succes             TYPE c VALUE 'S'.


  IF iv_adddtional_cost_overview NE abap_true.

    IF iv_po_number IS NOT SUPPLIED.
*You cannot read by combination for po and  vguid.
*to read the po you have to pass the status.

      IF it_adc_status IS NOT SUPPLIED.
* Read the addtional cost posted with Vehicle GUID.
        SELECT *
        FROM /DBE/vlc_ac_po
        INTO CORRESPONDING FIELDS OF TABLE lt_vlcpo
        FOR ALL ENTRIES IN vlcguid_it
        WHERE vguid = vlcguid_it-vguid AND
        po_status = iv_po_status AND
        gr_status = iv_gr_status AND
        inv_status = iv_inv_status. "#EC CI_NOFIELD.

        IF sy-subrc <> 0.
          RAISE no_record_found.
        ELSE.
          IF iv_include_all EQ abap_true.
            CLEAR lt_po_numbers.

            LOOP AT lt_vlcpo ASSIGNING <fs_vlc_ac_po>.
              APPEND <fs_vlc_ac_po>-po_number TO lt_po_numbers.
            ENDLOOP.

            " We need retrun the all records of the Vehicle which are there in purchase order.
            SELECT *
            FROM /DBE/vlc_ac_po
            INTO CORRESPONDING FIELDS OF TABLE vlcapo_et
            FOR ALL ENTRIES IN lt_po_numbers
            WHERE po_number = lt_po_numbers-po_number. "#EC CI_NOFIELD.
            IF sy-subrc <> 0.
              RAISE no_record_found.
            ENDIF.

          ELSE.
            APPEND LINES OF lt_vlcpo TO vlcapo_et.
          ENDIF.
        ENDIF.

      ELSE.

        LOOP AT it_adc_status INTO ls_adc_status.
          " Here the select statment is loop nessary we are tyring to only unique combination of status
          " We should not send any inconsistent data
          SELECT *
          FROM /DBE/vlc_ac_po
          INTO CORRESPONDING FIELDS OF TABLE lt_vlcpo
          FOR ALL ENTRIES IN vlcguid_it
          WHERE vguid = vlcguid_it-vguid AND
          po_status = ls_adc_status-po_status AND
          gr_status = ls_adc_status-gr_status AND
          inv_status = ls_adc_status-inv_status.  "#EC CI_NOFIELD.
          IF sy-subrc <> 0.
          ELSE.
            APPEND LINES OF lt_vlcpo TO vlcapo_et.
          ENDIF.
        ENDLOOP.

        IF vlcapo_et[] IS INITIAL.
          RAISE no_record_found.
        ENDIF.

        IF iv_include_all EQ abap_true.
          " We need retrun the all records of the Vehicle which are there in purchase order.
          CLEAR lt_po_numbers.
          LOOP AT vlcapo_et ASSIGNING <fs_vlc_ac_po>.
            APPEND <fs_vlc_ac_po>-po_number TO lt_po_numbers.
          ENDLOOP.
          CLEAR vlcapo_et.
          " We need retrun the all records of the Vehicle which are there in purchase order.
          SELECT *
          FROM /DBE/vlc_ac_po
          INTO CORRESPONDING FIELDS OF TABLE vlcapo_et
          FOR ALL ENTRIES IN lt_po_numbers
          WHERE po_number = lt_po_numbers-po_number."#EC CI_NOFIELD.
          IF sy-subrc <> 0.
            RAISE no_record_found.
          ENDIF.

        ELSE.
          APPEND LINES OF lt_vlcpo TO vlcapo_et.
        ENDIF.
      ENDIF.

    ELSE.
      SELECT *
          FROM /DBE/vlc_ac_po
          INTO CORRESPONDING FIELDS OF TABLE vlcapo_et
          WHERE po_number = iv_po_number. "#EC CI_NOFIELD.
      IF sy-subrc <> 0.
        RAISE no_record_found.
      ENDIF.
    ENDIF.
  ELSE.
    SELECT *
    FROM /DBE/vlc_ac_po
    INTO CORRESPONDING FIELDS OF TABLE vlcapo_et
    FOR ALL ENTRIES IN vlcguid_it
    WHERE vguid = vlcguid_it-vguid AND
    po_status = lc_po_succes AND
    gr_status = lc_gr_succes. "#EC CI_NOFIELD.
    IF sy-subrc <> 0.
      RAISE no_record_found.
    ENDIF.
  ENDIF.

ENDFUNCTION.
