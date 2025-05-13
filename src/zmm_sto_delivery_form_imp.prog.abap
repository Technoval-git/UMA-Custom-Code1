*&---------------------------------------------------------------------*
*& Include          ZMM_STO_DELIVERY_FORM_IMP
*&---------------------------------------------------------------------*
CLASS lcl_print_form IMPLEMENTATION.

  METHOD call_form.

    DATA : lwa_formout       TYPE fpformoutput,
           lv_function       TYPE rs38l_fnam,
           lv_formname       TYPE fpname,
           lwa_interfacetype TYPE fpinterfacetype.

    fill_control_strcture(
      EXPORTING
        im_nast         = nast
        im_preview      = ch_preview
      IMPORTING
        ex_outputparams = DATA(lwa_outputparams)
        ex_docparams    = DATA(lwa_docparams)    ).

    lwa_outputparams-preview = ch_preview.

    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = lwa_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.

      update_nast_protocol(
        EXPORTING
          im_msgid = sy-msgid
          im_msgno = sy-msgno
          im_msgty = sy-msgty  ).

      ch_retcode = 1.
      RETURN.

    ENDIF.

    IF tnapr-sform IS NOT INITIAL.
      lv_formname = tnapr-sform.

      TRY.

          CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
            EXPORTING
              i_name           = lv_formname
            IMPORTING
              e_funcname       = lv_function
              e_interface_type = lwa_interfacetype.

        CATCH cx_root INTO DATA(lo_root).

          update_nast_protocol(
            EXPORTING
              im_msgid = sy-msgid
              im_msgno = sy-msgno
              im_msgty = sy-msgty  ).

          ch_retcode = 1.
          RETURN.

      ENDTRY.
    ELSE.
      update_nast_protocol(
        EXPORTING
          im_msgid = sy-msgid
          im_msgno = sy-msgno
          im_msgty = sy-msgty  ).

      ch_retcode = 1.
      RETURN.
    ENDIF.

    map_data(
      IMPORTING
        es_header       = DATA(ls_header)
        et_items        = DATA(lt_item) ).

    CALL FUNCTION lv_function
      EXPORTING
*       /1bcdwb/docparams  =
        wa_materila        = ls_header
        it_items           = lt_item
      IMPORTING
        /1bcdwb/formoutput = lwa_formout
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF sy-subrc <> 0.
      update_nast_protocol(
        EXPORTING
          im_msgid = sy-msgid
          im_msgno = sy-msgno
          im_msgty = sy-msgty  ).

      ch_retcode = 1.
      RETURN.
    ENDIF.

    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      update_nast_protocol(
       EXPORTING
         im_msgid = sy-msgid
         im_msgno = sy-msgno
         im_msgty = sy-msgty  ).

      ch_retcode = 1.
      RETURN.
    ENDIF.
*      Return Success Code
    ch_retcode = 0.

  ENDMETHOD.

  METHOD fill_control_strcture.
    CLEAR: ex_outputparams,ex_docparams.
    CONSTANTS: lc_mail TYPE fpmedium VALUE 'MAIL'.
    IF im_preview EQ abap_true.
      ex_outputparams-preview   = abap_true.
    ENDIF.
    ex_outputparams-nodialog = abap_true.                 " No Dialog
    ex_outputparams-dest     = im_nast-ldest.             " Printer Name
    ex_outputparams-reqimm   = im_nast-dimme.
    ex_outputparams-reqdel   = im_nast-delet.
    ex_outputparams-copies   = im_nast-anzal.             " No of copies
    ex_outputparams-dataset  = im_nast-dsnam.             " Data Set
    ex_outputparams-suffix1  = im_nast-dsuf1.             " Spool request: Suffix 1
    ex_outputparams-suffix2  = im_nast-dsuf2.             " Spool request: Suffix 2
    ex_outputparams-covtitle = im_nast-tdcovtitle.        " Document Title for email
    ex_outputparams-cover    = im_nast-tdocover.          " Document Cover
    ex_outputparams-receiver = im_nast-tdreceiver.        " Receiver
    ex_outputparams-division = im_nast-tddivision.        " Division
    ex_outputparams-reqfinal = abap_true.                 " Final
    ex_outputparams-arcmode  = im_nast-tdarmod.           " Archiv?
    ex_outputparams-schedule = im_nast-tdschedule.        " Scheduling
    ex_outputparams-senddate = im_nast-vsdat.             " Send Date
    ex_outputparams-sendtime = im_nast-vsura.             " Send Time
*- If medium is mail
    IF nast-nacha EQ 5 AND im_preview IS INITIAL.
      ex_outputparams-getpdf   = abap_true.               " Get PDF
      ex_outputparams-device   = lc_mail.                 " Mail
    ENDIF.
*- lo_document Parameters
    ex_docparams-langu       = nast-spras.                " Language
    ex_docparams-country     = nast-tland.                " Countery Code

  ENDMETHOD.

  METHOD update_nast_protocol.
    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
      EXPORTING
        msg_arbgb = im_msgid                              " Message  ID
        msg_nr    = im_msgno                              " Message Number
        msg_ty    = im_msgty                              " Messasge  Type
        msg_v1    = sy-msgv1                              " Variable 1
        msg_v2    = sy-msgv2                              " Varibale 2
        msg_v3    = sy-msgv3                              " Varibale 3
        msg_v4    = sy-msgv4                              " Variable 4
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1.
    ENDIF.
  ENDMETHOD.

  METHOD map_data.

    DATA: ls_item  TYPE zmm_s_inf_sto_item,
          lv_towe  TYPE brgew_15,
          lv_tovol TYPE volum_15.
    DATA : lt_lfart TYPE STANDARD TABLE OF bapidlv_range_lfart,
           ls_lfart TYPE bapidlv_range_lfart.

    SELECT * FROM tvarvc INTO TABLE @DATA(lt_tvarvc) WHERE name EQ 'DELVNOTE_TYPE'. " AND sign EQ 'S'.

    LOOP AT lt_tvarvc INTO DATA(ls_tvarvc).
      ls_lfart-dlv_type_low = ls_tvarvc-low.
      ls_lfart-dlv_type_high = ls_tvarvc-high.
      ls_lfart-option = ls_tvarvc-opti.
      ls_lfart-sign = ls_tvarvc-sign.
      APPEND ls_lfart TO lt_lfart.
      CLEAR ls_lfart.
    ENDLOOP.

    SELECT SINGLE
            a~vbeln, " Delivery no
            a~erzet, " Creation time
            a~erdat, " Creation date
            a~lfart, " Delivery Type
            a~wadat, " Delivery date
*            a~ablad, " Unloading point
            a~inco1, " Incoterms
            a~vsbed, " Shipping Conditions
            a~bolnr, " Way Bill No
            a~wauhr, " Delivery time
            b~bezei, " Incoterm Description
            c~vtext  " Shipping Conditions Description
    FROM likp AS a
        LEFT OUTER JOIN tinct AS b
              ON b~inco1 = a~inco1 AND b~spras = @nast-spras
        LEFT OUTER JOIN tvsbt AS c
              ON c~vsbed = a~vsbed AND c~spras = @nast-spras
*        WHERE vbeln = @nast-objky(10) AND (  lfart = 'YSTB' OR a~lfart = 'YSTO' ) INTO @DATA(ls_likp).
      WHERE vbeln = @nast-objky(10) AND lfart IN @lt_lfart INTO @DATA(ls_likp).

*    REFRESH et_items.
    IF sy-subrc = 0.
**Manage Error
*      CLEAR es_header.
*      RETURN.
*
      es_header-vbeln = ls_likp-vbeln.
      es_header-erzet = ls_likp-erzet.
      es_header-erdat = ls_likp-erdat.
      es_header-wadat = ls_likp-wadat.
      es_header-wauhr = ls_likp-wauhr.
      es_header-bolnr = ls_likp-bolnr.
      es_header-vsbed = ls_likp-vsbed.
      es_header-inco1 = ls_likp-inco1.
      es_header-bezei = ls_likp-bezei.
      es_header-sctext = ls_likp-vtext.
      es_header-pritdate = sy-datum.

      SELECT lips~vbeln AS vbeln, " Delivery no
             lips~posnr AS posnr, "Item
             lips~matnr AS matnr, "Material
             lips~lfimg AS lfimg, "Delivery Qty
             lips~vrkme AS vrkme, "Unit Of Delivery qty
             lips~volum AS volum, "Volum
             lips~voleh AS voleh, "Unit Of Volume
             lips~brgew AS brgew, "Weight
             lips~gewei AS gewei, "Unit of Weight
             lips~arktx AS arktx, "Short text for sales order item
             lips~vgbel AS vgbel, " PO Number
             lips~vgpos as vgpos, "
             makt~maktx AS maktx, " Description material
             t001w~name1 AS name1, "Name Supply Plant
             ekko~reswk AS reswk   "Supply Plant
     FROM lips AS lips
          LEFT OUTER JOIN makt AS makt
                 ON lips~matnr = makt~matnr
              AND makt~spras = 'A'
         LEFT OUTER JOIN  ekko AS ekko
                  ON  ekko~ebeln =  lips~vgbel
          LEFT OUTER JOIN t001w  AS t001w
                       ON t001w~werks =  ekko~reswk
         INTO TABLE @DATA(lt_lips)
         WHERE lips~vbeln EQ @ls_likp-vbeln
         ORDER BY vbeln,
                  posnr.
      IF sy-subrc = 0.
        DATA(ls_lips) = lt_lips[ 1 ].
        es_header-vgbel = ls_lips-vgbel.
        es_header-suplant = ls_lips-reswk.
        es_header-supname = ls_lips-name1.
        es_header-gewei = ls_lips-gewei.
        es_header-voleh = ls_lips-voleh.

****        SELECT SINGLE a~werks, "Unloading Point
****                      b~name1  "Unloading Point Description
****          FROM ekpo AS a
****          INNER JOIN ekko AS ekko ON ekko~ebeln = a~ebeln
****          LEFT OUTER JOIN t001w AS b
****                       ON b~werks = a~werks
****          INTO @DATA(lv_name)
****          WHERE ekko~ebeln = @ls_lips-vgbel
****            and ekpo~ebelp = @ls_lips-vgbel.
****        IF sy-subrc = 0.
****          es_header-werks = lv_name-werks.
****          es_header-unlod = lv_name-name1.
****        ENDIF.

*        ---------------------------------------

      SELECT SINGLE
             ekpo~werks  AS werks " Unloading Point
             t001w~name1 AS name1 " Unloading Point Description
        FROM ekpo AS  ekpo
        LEFT OUTER JOIN t001w  AS t001w
          ON t001w~werks =  ekpo~werks
        INTO ( es_header-werks, es_header-unlod )
       WHERE ebeln EQ ls_lips-vgbel
         AND ebelp EQ ls_lips-vgpos.




*        ---------------------------------------
        LOOP AT lt_lips INTO DATA(wa_lips).
          ls_item-matnr = wa_lips-matnr.
          ls_item-posnr = wa_lips-posnr.
          ls_item-iteamdes = wa_lips-arktx.
          ls_item-maktx = wa_lips-maktx.
          ls_item-lfimg = wa_lips-lfimg.
          ls_item-vrkme = wa_lips-vrkme.
          ls_item-brgew = wa_lips-brgew.
          ls_item-gewei = wa_lips-gewei.
          ls_item-volum = wa_lips-volum.
          ls_item-voleh = wa_lips-voleh.
          lv_towe = lv_towe + wa_lips-brgew.
          lv_tovol = lv_tovol + wa_lips-volum.
          APPEND ls_item TO et_items.
        ENDLOOP.
      ENDIF.
      es_header-brgew = lv_towe.
      es_header-volum = lv_tovol.
    ENDIF.
*-----------VHVIN
    DATA: lv_vguid TYPE vlcvehicle-vguid, " VGUID from VSS table
          lv_vhvin TYPE vlcvehicle-vhvin. " VIN number
    DATA: lv_license_plate TYPE vlcvehicle-/dbe/licext. " License plate number

    " Step 1: Fetch the VSS order number using Delivery number
    SELECT SINGLE /dbe/vbeln
    INTO @DATA(ls_lips1)
    FROM lips
    WHERE vbeln = @nast-objky(10).

    " Step 2: Fetch the VGUID using VSS order number
    IF ls_lips1 IS NOT INITIAL.
      SELECT SINGLE vguid
        INTO @lv_vguid
        FROM /dbe/vbak_db
        WHERE vbeln = @ls_lips1.

      " Step 3: Fetch the VIN number using VGUID
      SELECT SINGLE vhvin, /dbe/licext
        INTO @DATA(ls_vlcvehicle)
        FROM vlcvehicle
        WHERE vguid = @lv_vguid.

      es_header-vhvin = ls_vlcvehicle-vhvin. " Add VIN to the header data
      es_header-licenec_plate_no = ls_vlcvehicle-/dbe/licext. " Add License Plate to the header
    ENDIF.

*-----------VHVIN



  ENDMETHOD.
ENDCLASS.
