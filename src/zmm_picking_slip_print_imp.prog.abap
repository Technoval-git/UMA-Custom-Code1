*&---------------------------------------------------------------------*
*& Include          ZMM_PICKING_SLIP_PRINT_IMP
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

    IF ls_header IS INITIAL  .

      update_nast_protocol(
        EXPORTING
          im_msgid = 'ZMM001'
          im_msgno = '000'
          im_msgty = 'E'  ).

      ch_retcode = 1.
      RETURN.

    ENDIF.

    CALL FUNCTION lv_function
      EXPORTING
        /1bcdwb/docparams  = lwa_docparams
        is_header          = ls_header
        it_items           = lt_item
      IMPORTING
        /1bcdwb/formoutput = lwa_formout
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.

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

    DATA ls_item TYPE zmm_s_picking_item.

    REFRESH et_items.

    SELECT SINGLE
           vbeln,
           erdat,
           erzet,
           lfart,
           lprio,
           vsbed,
           aenam
      FROM likp
      INTO @DATA(ls_likp)
     WHERE vbeln = @nast-objky(10) .
*       AND lfart IN ( 'YSTB' , 'YSTO', 'YP01' ).
    IF sy-subrc NE 0.
**Manage Error
      CLEAR es_header.
      RETURN.
    ENDIF.


*    IF lt_likp IS NOT INITIAL.
    SELECT lips~vbeln      AS vbeln,
           lips~posnr      AS posnr,
           lips~werks      AS werks,
           lips~lgort      AS lgort,
           lips~charg      AS charg,
           lips~lfimg      AS lfimg,
           lips~meins      AS meins,
           lips~lfbnr      AS lfbnr,
           lips~kdauf      AS kdauf,
           lips~lgpbe      AS lgpbe,
           lips~matnr      AS matnr,
           lips~arktx      AS arktx,
           lips~vgbel      AS vgbel,
           lips~vgpos      AS vgpos,
           lips~/dbe/vbeln AS vssvbeln,
           lips~/dbe/posnr AS vssposnr,
*           makt~MATNR,
           makt~maktx      AS maktx,
           makt_a~maktx    AS maktx_a,
           mard~labst      AS labst,
           t001w~name1     AS name1
*           mard~lgpbe AS lgpbe
       FROM lips AS lips
         INNER JOIN makt AS makt
                 ON lips~matnr = makt~matnr
                AND makt~spras = @nast-spras
    LEFT OUTER JOIN makt AS makt_a
                 ON lips~matnr = makt_a~matnr
                AND makt_a~spras = 'A'
    LEFT OUTER JOIN mard AS mard
                 ON lips~matnr = mard~matnr
                AND lips~werks = mard~werks
                AND lips~lgort = mard~lgort
      LEFT OUTER JOIN t001w  AS t001w
                       ON t001w~werks =  lips~werks
     INTO TABLE @DATA(lt_lips)

*      FOR ALL ENTRIES IN @LT_LIKP
      WHERE lips~vbeln EQ @ls_likp-vbeln
      ORDER BY vbeln,
               posnr.
*          AND lips~lgpbe NE ' '.

    es_header-vbeln = ls_likp-vbeln.

    es_header-erdat = ls_likp-erdat.
    es_header-erzet = ls_likp-erzet.
    es_header-vsbed = ls_likp-vsbed.
    es_header-lprio = ls_likp-lprio.
    es_header-aenam = ls_likp-aenam.


    LOOP AT lt_lips ASSIGNING FIELD-SYMBOL(<fs_lips>).
      if sy-tabix = 1.
        es_header-suplant = <fs_lips>-werks.
        es_header-SUPPLANTDESC = <fs_lips>-name1.
      endif.
      ls_item-posnr = <fs_lips>-posnr.
      ls_item-werks = <fs_lips>-werks. "supplying Plant
      ls_item-lgort = <fs_lips>-lgort.
      ls_item-lgpbe = <fs_lips>-lgpbe.
      ls_item-lfimg = <fs_lips>-lfimg.
      ls_item-meins = <fs_lips>-meins.
      ls_item-matnr = <fs_lips>-matnr.
*      gs_intf-header-kdauf = ls_lips-kdauf.

      APPEND <fs_lips>-maktx TO ls_item-tt_maktx.
      IF <fs_lips>-maktx_a IS NOT INITIAL.
        APPEND <fs_lips>-maktx_a TO ls_item-tt_maktx.
      ENDIF.




      ls_item-labst = <fs_lips>-labst.
      ls_item-charg = <fs_lips>-charg.

*      Get superssion material
      SELECT SINGLE
             pickey
        FROM picps
        INTO @DATA(lv_pickey)
       WHERE matnr = @<fs_lips>-matnr.
      IF sy-subrc EQ 0.

*****        SELECT matnr
*****          FROM picps
*****          INTO TABLE @DATA(lt_submatnr)
*****         WHERE pickey = @lv_pickey
*****           AND matnr NE @<fs_lips>-matnr.
        SELECT matnr UP TO 1 ROWS
                 FROM picps
                 INTO TABLE @DATA(lt_submatnr)
                WHERE pickey = @lv_pickey
                  AND matnr NE @<fs_lips>-matnr.
        IF sy-subrc EQ 0.

          APPEND LINES OF lt_submatnr TO ls_item-supmaterials.
        ELSE.
          APPEND space TO ls_item-supmaterials.
        ENDIF.

        REFRESH: lt_submatnr.

      ELSE.
        APPEND space  TO ls_item-supmaterials.
      ENDIF.


      APPEND ls_item TO et_items.

      REFRESH: lt_submatnr.
      CLEAR: ls_item.

    ENDLOOP.

    IF lt_lips IS NOT INITIAL.

*Reference Order Number and Receiving Plant
      es_header-vgbel = lt_lips[ 1 ]-vgbel.
      DATA(lv_item) = lt_lips[ 1 ]-vgpos.
      IF es_header-vgbel IS  INITIAL OR lv_item IS INITIAL.
        es_header-vgbel = lt_lips[ 1 ]-vssvbeln.
        lv_item         = lt_lips[ 1 ]-vssposnr.

        SELECT SINGLE
               a~partner    AS partner,
               b~name_last  AS name_last,
               b~name_first AS name_first
          FROM /dbe/vbpa    AS a
         INNER JOIN but000  AS b
            ON b~partner EQ a~partner
          INTO @DATA(ls_soldtoparty)
          WHERE vbeln EQ @es_header-vgbel
            AND parvw EQ 'AG' ."Sold To party
          IF sy-subrc  EQ 0.
              es_header-cust_name = ls_soldtoparty-name_first && ` / ` &&  ls_soldtoparty-name_last.
          ENDIF.

      ENDIF.

      SELECT SINGLE
             ekpo~werks  AS werks
             t001w~name1 AS name1
        FROM ekpo AS  ekpo
        LEFT OUTER JOIN t001w  AS t001w
          ON t001w~werks =  ekpo~werks
        INTO ( es_header-werks, es_header-res_plant_desc )
       WHERE ebeln EQ es_header-vgbel
         AND ebelp EQ lv_item.


    ENDIF.

***Header Texts
****Header Custom Name
   IF es_header-cust_name is  INITIAL.

    DATA(lv_patner) = 'BP' && es_header-werks .
    IF es_header-werks IS NOT INITIAL.
      SELECT SINGLE
             name_org1
        FROM but000
        INTO es_header-cust_name
       WHERE partner EQ lv_patner.

    ENDIF.

   ENDIF.
***** Shipping Conditions Description
    SELECT SINGLE
           vtext
      FROM tvsbt
      INTO es_header-vtext
     WHERE spras EQ nast-spras
       AND vsbed EQ es_header-vsbed.

    SELECT SINGLE
           bezei
      FROM tprit
      INTO es_header-bezei
     WHERE spras EQ nast-spras
       AND lprio EQ es_header-lprio.




  ENDMETHOD.

ENDCLASS.
