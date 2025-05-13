FUNCTION ZDBE_MASS_PACKF4_PDIORD_EXIT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) TYPE  DDSHF4CTRL
*"--------------------------------------------------------------------


  DATA: ls_record    TYPE seahlpres,
        ls_dynp_read TYPE dynpread,
        lt_shlpfield TYPE RANGE OF ddshfprop-fieldname,
        ls_interface TYPE ddshiface,
        ls_shlpfield LIKE LINE OF lt_shlpfield.

  FIELD-SYMBOLS: <ls_interface>  TYPE ddshiface,
                 <ls_fielddescr> TYPE dfies,
                 <ls_fieldprop>  TYPE ddshfprop.

  CLEAR : gv_pdi_packiddesc, gv_pdi_packid.

  IF callcontrol-step EQ 'SELONE' OR callcontrol-step EQ 'PRESEL1'.

* Enable importing parameters for the search help
    LOOP AT shlp-fieldprop ASSIGNING <ls_fieldprop>.

      IF <ls_fieldprop>-fieldname EQ 'WERKS' OR
              <ls_fieldprop>-fieldname EQ 'PACKAGE_ID' OR
           <ls_fieldprop>-fieldname EQ 'STATUS' OR
         <ls_fieldprop>-fieldname EQ 'VTWEG' OR
              <ls_fieldprop>-fieldname EQ 'VKORG'.

        ls_shlpfield-low = <ls_fieldprop>-fieldname.
        <ls_fieldprop>-shlpinput = abap_true.

      ELSEIF
        <ls_fieldprop>-fieldname EQ 'CHANGEABLE' OR
        <ls_fieldprop>-fieldname EQ 'STATUS' OR
         <ls_fieldprop>-fieldname EQ 'AWTYP' OR
              <ls_fieldprop>-fieldname EQ 'SPART' OR
        <ls_fieldprop>-fieldname EQ 'COUNTRY' OR
           <ls_fieldprop>-fieldname EQ 'PACKAGE_PRICE' OR
           <ls_fieldprop>-fieldname EQ 'PACKAGE_CURRENCY'  OR
      <ls_fieldprop>-fieldname EQ 'VALID_FROM' OR <ls_fieldprop>-fieldname EQ 'VALID_TO'.

        ls_shlpfield-low = <ls_fieldprop>-fieldname.
        <ls_fieldprop>-shlpoutput = abap_true.

      ENDIF.

      READ TABLE shlp-interface TRANSPORTING NO FIELDS WITH KEY
       shlpfield = <ls_fieldprop>-fieldname.

      IF sy-subrc NE 0.
        MOVE <ls_fieldprop>-fieldname TO  ls_interface-shlpfield.
        APPEND ls_interface TO shlp-interface.
      ENDIF.

    ENDLOOP.

    LOOP AT shlp-fielddescr ASSIGNING <ls_fielddescr> WHERE fieldname = 'VALID_FROM' OR fieldname = 'VALID_TO'.
      CASE <ls_fielddescr>-fieldname.
        WHEN 'VALID_FROM'.

          <ls_fielddescr>-datatype = 'DEC'.
          <ls_fielddescr>-convexit = 'TSTLC'.
          <ls_fielddescr>-fieldtext = 'Valid From Date/Time'(039).
          <ls_fielddescr>-reptext = 'Valid From Date/Time'(040).
          <ls_fielddescr>-scrtext_l = 'Package Valid From Date/Time'(041).
          <ls_fielddescr>-scrtext_m = 'Valid From'(042).
          <ls_fielddescr>-scrtext_s = 'Valid From'(043).
        WHEN 'VALID_TO'.
          <ls_fielddescr>-datatype = 'DEC'.
          <ls_fielddescr>-convexit = 'TSTLC'.
          <ls_fielddescr>-fieldtext = 'Valid To Date/Time'(044).
          <ls_fielddescr>-reptext = 'Valid To Date/Time'(045).
          <ls_fielddescr>-scrtext_l = 'Package Valid To Date/Time'(046).
          <ls_fielddescr>-scrtext_m = 'Valid To'(047).
          <ls_fielddescr>-scrtext_s = 'Valid To'(049).
      ENDCASE.
    ENDLOOP.

    LOOP AT shlp-interface ASSIGNING <ls_interface>.
      CASE <ls_interface>-shlpfield.
*
        WHEN 'PACKAGE_ID_EXT'.
          <ls_interface>-dispfield = abap_true.
        WHEN 'VKORG'.

          <ls_interface>-dispfield = abap_true.
          READ TABLE gt_dynp_read INTO ls_dynp_read  WITH KEY
        fieldname = '/DBE/VBAK_COM-VKORG' TRANSPORTING fieldvalue.

          IF sy-subrc EQ 0.
            <ls_interface>-value  = ls_dynp_read-fieldvalue.
          ENDIF.
        WHEN 'SPART'.
          <ls_interface>-dispfield = abap_true.
          READ TABLE gt_dynp_read INTO ls_dynp_read  WITH KEY
          fieldname = '/DBE/VBAK_COM-SPART' TRANSPORTING fieldvalue.

          IF sy-subrc EQ 0.
            <ls_interface>-value  = ls_dynp_read-fieldvalue.
          ENDIF.
        WHEN 'WERKS'.
          <ls_interface>-dispfield = abap_true.
          READ TABLE gt_dynp_read INTO ls_dynp_read  WITH KEY
          fieldname = '/DBE/VBAK_COM-WERKS' TRANSPORTING fieldvalue.

          IF sy-subrc EQ 0.
            <ls_interface>-value  = ls_dynp_read-fieldvalue.
          ENDIF.

        WHEN 'VTWEG'.

          <ls_interface>-dispfield = abap_true.
          READ TABLE gt_dynp_read INTO ls_dynp_read  WITH KEY
        fieldname = '/DBE/VBAK_COM-VTWEG' TRANSPORTING fieldvalue.

          IF sy-subrc EQ 0.
            <ls_interface>-value  = ls_dynp_read-fieldvalue.
          ENDIF.

        WHEN 'STATUS'.

          <ls_interface>-dispfield = abap_true.
          <ls_interface>-value = '02'.

        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      <ls_interface>-valfield = abap_true.
    ENDLOOP.

  ENDIF.

* adjust selection parameters
  IF callcontrol-step = 'SELECT'.
    READ TABLE shlp-selopt INTO DATA(ls_selopt) WITH KEY shlpfield = 'WERKS'.
    IF sy-subrc = 0.
      ls_selopt-low    = space.
      ls_selopt-sign   = 'I'.
      ls_selopt-option = 'EQ'.
      INSERT ls_selopt INTO TABLE shlp-selopt.
    ENDIF.
    READ TABLE shlp-selopt INTO ls_selopt WITH KEY shlpfield = 'VKORG'.
    IF sy-subrc = 0.
      ls_selopt-low    = space.
      ls_selopt-sign   = 'I'.
      ls_selopt-option = 'EQ'.
      INSERT ls_selopt INTO TABLE shlp-selopt.
    ENDIF.
    READ TABLE shlp-selopt INTO ls_selopt WITH KEY shlpfield = 'VTWEG'.
    IF sy-subrc = 0.
      ls_selopt-low    = space.
      ls_selopt-sign   = 'I'.
      ls_selopt-option = 'EQ'.
      INSERT ls_selopt INTO TABLE shlp-selopt.
    ENDIF.
    READ TABLE shlp-selopt INTO ls_selopt WITH KEY shlpfield = 'SPART'.
    IF sy-subrc = 0.
      ls_selopt-low    = space.
      ls_selopt-sign   = 'I'.
      ls_selopt-option = 'EQ'.
      INSERT ls_selopt INTO TABLE shlp-selopt.
    ENDIF.
  ENDIF.

* calculate the output parameters.
  IF callcontrol-step = 'RETURN'.
    LOOP AT record_tab INTO ls_record.

      gv_pdi_packid = ls_record(20).
      gv_pdi_packiddesc = ls_record+20(40) .
    ENDLOOP.

  ENDIF.

ENDFUNCTION.
