*&---------------------------------------------------------------------*
*& Include          ZLANDCOST_UPDATE_CLA
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form validation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validation .

  CASE 'X'.
    WHEN r_ex.
      LOOP AT SCREEN.
        IF screen-group1 = 'SC2'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN  r_upd.
      LOOP AT SCREEN.
        IF screen-name CS 'REPORT'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_PO
*&      <-- LT_FINAL
*&---------------------------------------------------------------------*
FORM fetch_data  USING    p_p_po
                 CHANGING p_lt_final.

  SELECT a~ebeln,
         a~knumv,
         b~ebelp,
         b~matnr,
         b~menge,
         b~netpr,
         b~banfn,
         b~bnfpo,
         b~werks,
         b~lgort,
         b~bednr
    FROM ekko AS a
   INNER JOIN ekpo AS b ON a~ebeln = b~ebeln
    INTO TABLE @DATA(lt_ekko)
   WHERE a~ebeln = @p_po
     AND b~loekz = ''.

  IF sy-subrc = 0.
    SELECT spras,
           kvewe,
           kappl,
           kschl,
           vtext
      FROM t685t INTO TABLE @DATA(lt_descriton).

    CALL FUNCTION 'BAPI_PO_GETDETAIL1'
      EXPORTING
        purchaseorder = p_po  " Purchasing Document Number
      IMPORTING
        poheader      = wa_headerdata  " Purchase Order Header Data
      TABLES
        pocondheader  = lt_poheadercom    " Conditions (header)
        pocond        = lt_poiteamcom.   " Conditions (Items)

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = 'KRECH'                 " Domain name
        text           = 'X'         " Default ' ': without texts, 'X': with, 'T': only text
        langu          = sy-langu          " Language, default SY-LANGU, '*': all texts
*       bypass_buffer  = space
      TABLES
        dd07v_tab      = lt_desr
      EXCEPTIONS
        wrong_textflag = 1                " Incorrect value in TEXT: Parameter (<> X, T ,'')
        OTHERS         = 2.
    MOVE-CORRESPONDING wa_headerdata TO wa_poheaderchdata.
    IF r_ex = 'X'.
*      IF lt_poheadercom IS NOT INITIAL.
*        LOOP AT lt_poheadercom INTO DATA(wa_poheacom) WHERE cond_type CP 'Y*'.
*          wa_final-condition_no = wa_poheacom-condition_no.
*          wa_final-itm_number = wa_poheacom-itm_number.
*          wa_final-cond_st_no = wa_poheacom-cond_st_no.
*          wa_final-ebeln = p_po.
*          TRY.
*              DATA(wa_ekko) = lt_ekko[ knumv = wa_poheacom-condition_no ].
*              wa_final-ebelp = wa_ekko-ebelp.
*              wa_final-matnr = wa_ekko-matnr.
*              wa_final-menge = wa_ekko-menge.
*              wa_final-netpr = wa_ekko-netpr.
*              wa_final-banfn = wa_ekko-banfn.
*              wa_final-bnfpo = wa_ekko-bnfpo.
*              wa_final-werks = wa_ekko-werks.
*              wa_final-lgort = wa_ekko-lgort.
*              wa_final-bednr = wa_ekko-bednr.
*            CATCH cx_root.
*          ENDTRY.
*          wa_final-kmein = wa_poheacom-cond_unit.
*          wa_final-kpein = wa_poheacom-cond_p_unt.
*          wa_final-kschl = wa_poheacom-cond_type.
*          wa_final-vtext = lt_descriton[ kschl = wa_poheacom-cond_type ].
*          wa_final-cur = wa_poheacom-currency.
*          wa_final-cur_te = lt_desr[ domvalue_l = wa_poheacom-calctypcon ]-ddtext.
*          wa_final-kbetr = wa_poheacom-cond_value.
*          APPEND wa_final TO lt_final.
*          APPEND wa_poheaderch TO it_pohederchange.
*        ENDLOOP.
*      ENDIF.
      IF lt_poiteamcom IS NOT INITIAL.

        LOOP AT lt_ekko INTO DATA(wa_ekko).

          LOOP AT lt_poiteamcom INTO DATA(wa_conit)
                               WHERE cond_type CP 'Y*'
                                 AND condition_no EQ wa_ekko-knumv
                                 AND itm_number   EQ wa_ekko-ebelp.

            wa_final-condition_no = wa_conit-condition_no.
            wa_final-itm_number   = wa_conit-itm_number.
            wa_final-cond_st_no   = wa_conit-cond_st_no.
            wa_final-ebeln        = p_po.

            TRY.
*                DATA(wa_ekko)  = lt_ekko[ knumv = wa_conit-condition_no].
                wa_final-ebelp = wa_ekko-ebelp.
                wa_final-matnr = wa_ekko-matnr.
                wa_final-menge = wa_ekko-menge.
                wa_final-netpr = wa_ekko-netpr.
                wa_final-banfn = wa_ekko-banfn.
                wa_final-bnfpo = wa_ekko-bnfpo.
                wa_final-werks = wa_ekko-werks.
                wa_final-lgort = wa_ekko-lgort.
                wa_final-bednr = wa_ekko-bednr.
              CATCH cx_root.
            ENDTRY.
            wa_final-kmein = wa_conit-cond_unit.
            wa_final-kpein = wa_conit-cond_p_unt.
            wa_final-kschl = wa_conit-cond_type.
            wa_final-vtext = lt_descriton[ kschl = wa_conit-cond_type ].
            wa_final-cur = wa_conit-currency.
            wa_final-cur_te = lt_desr[ domvalue_l = wa_conit-calctypcon ]-ddtext.
            wa_final-kbetr = wa_conit-cond_value.
            APPEND wa_final TO lt_final.

          ENDLOOP.

        ENDLOOP.
*        sort lt_final.
*        delete ADJACENT DUPLICATES FROM lt_final COMPARING ALL FIELDS.
      ENDIF.
    ELSE.
      IF r_header = 'X'.
        IF lt_poheadercom IS NOT INITIAL.
          LOOP AT lt_poheadercom INTO DATA(wa_poheacom) WHERE cond_type CP 'Y*' .
            wa_final-condition_no = wa_poheacom-condition_no.
            wa_final-itm_number = wa_poheacom-itm_number.
            wa_final-cond_st_no = wa_poheacom-cond_st_no.
            wa_final-ebeln = p_po.
            TRY.
                wa_ekko = lt_ekko[ knumv = wa_poheacom-condition_no ].
*                wa_final-ebelp = wa_ekko-ebelp.
                wa_final-matnr = wa_ekko-matnr.
                wa_final-menge = wa_ekko-menge.
                wa_final-netpr = wa_ekko-netpr.
                wa_final-banfn = wa_ekko-banfn.
                wa_final-bnfpo = wa_ekko-bnfpo.
                wa_final-werks = wa_ekko-werks.
                wa_final-lgort = wa_ekko-lgort.
                wa_final-bednr = wa_ekko-bednr.
              CATCH cx_root.

            ENDTRY.
*            wa_final-curency  = wa_poheacom-calctypcon.
            wa_final-kmein = wa_poheacom-cond_unit.
            wa_final-kpein = wa_poheacom-cond_p_unt.
            wa_final-kschl = wa_poheacom-cond_type.
            wa_final-vtext = lt_descriton[ kschl = wa_poheacom-cond_type ].
            wa_final-cur = wa_poheacom-currency.
            wa_final-cur_te = lt_desr[ domvalue_l = wa_poheacom-calctypcon ]-ddtext.
            wa_final-kbetr = wa_poheacom-cond_value.
            APPEND wa_final TO lt_final.
            MOVE-CORRESPONDING wa_poheacom TO wa_poheaderch.
            APPEND wa_poheaderch TO it_pohederchange.
            CLEAR: wa_poheaderch,wa_poheaderch.
*       APPEND wa_poheacom to
          ENDLOOP.
        ENDIF.
      ELSE.
        IF lt_poiteamcom IS NOT INITIAL.

          LOOP AT lt_ekko INTO wa_ekko.

            LOOP AT lt_poiteamcom INTO wa_conit
                                 WHERE cond_type CP 'Y*'
                                   AND condition_no EQ wa_ekko-knumv
                                   AND itm_number   EQ wa_ekko-ebelp.

              wa_final-condition_no = wa_conit-condition_no.
              wa_final-itm_number = wa_conit-itm_number.
              wa_final-cond_st_no = wa_conit-cond_st_no.
              wa_final-ebeln = p_po.
              TRY.
*                  wa_ekko = lt_ekko[ knumv = wa_conit-condition_no ].
                  wa_final-ebelp = wa_ekko-ebelp.
                  wa_final-matnr = wa_ekko-matnr.
                  wa_final-menge = wa_ekko-menge.
                  wa_final-netpr = wa_ekko-netpr.
                  wa_final-banfn = wa_ekko-banfn.
                  wa_final-bnfpo = wa_ekko-bnfpo.
                  wa_final-werks = wa_ekko-werks.
                  wa_final-lgort = wa_ekko-lgort.
                  wa_final-bednr = wa_ekko-bednr.
                CATCH cx_root.
              ENDTRY.
*            wa_final-CALCTYPCON  = wa_conit-calctypcon.
              wa_final-kmein = wa_conit-cond_unit.
              wa_final-kpein = wa_conit-cond_p_unt.
              wa_final-kschl = wa_conit-cond_type.
              wa_final-vtext = lt_descriton[ kschl = wa_conit-cond_type ].
              wa_final-cur = wa_conit-currency.
              wa_final-cur_te = lt_desr[ domvalue_l = wa_conit-calctypcon ]-ddtext.
              wa_final-kbetr = wa_conit-cond_value.
              APPEND wa_final TO lt_final.
              MOVE-CORRESPONDING wa_conit TO  wa_poiteamch.
              APPEND  wa_poiteamch  TO  it_poiteamchange.
              CLEAR : wa_poiteamch,wa_conit.
            ENDLOOP.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- IT_FIELDCAT
*&---------------------------------------------------------------------*
FORM field_catalog  CHANGING p_it_fieldcat.

  it_fieldcat = VALUE #(  ( col_pos = 1 fieldname = 'EBELN'
 outputlen = 10
 seltext_m = 'PO number'
*outputlen = '5'
  )


  ( col_pos = 2
 fieldname = 'EBELP'
 outputlen = 10
 seltext_m = 'PO Line '
*  OUTPUTLEN = 5
  )


  ( col_pos = 3
 fieldname = 'MATNR'
 outputlen = 10
 seltext_m = 'Material'
*  OUTPUTLEN = 5
  )

   ( col_pos = 4
 fieldname = 'MENGE'
 outputlen = 10
 seltext_m = 'Quantity'
*  OUTPUTLEN = 5
  )
     ( col_pos = 5
 fieldname = 'KMEIN'
 outputlen = 10
 seltext_m = 'UOM'
*  OUTPUTLEN = 5
  )
       ( col_pos = 6
 fieldname = 'KMEIN'
 outputlen = 10
 seltext_m = 'Unit Of Price'
*  OUTPUTLEN = 5
  )
   ( col_pos = 7
 fieldname = 'KPEIN'
 outputlen = 10
 seltext_m = 'Net Price'
*  OUTPUTLEN = 5
  )

   ( col_pos = 8
 fieldname = 'BANFN'
 outputlen = 10
 seltext_m = 'PR No'
*  OUTPUTLEN = 5
  )
    ( col_pos = 9
 fieldname = 'BNFPO'
 outputlen = 10
 seltext_m = 'PR Line item'
*  OUTPUTLEN = 5
  )
      ( col_pos = 10
 fieldname = 'WERKS'
 outputlen = 10
 seltext_m = 'Plant'
*  OUTPUTLEN = 5
  )
        ( col_pos = 11
 fieldname = 'LGORT'
* outputlen = 10
 seltext_m = 'Storage Location'
*  OUTPUTLEN = 5
  )
          ( col_pos = 12
 fieldname = 'BEDNR'
* outputlen = 10
 seltext_m = 'Tracking Number'
*  OUTPUTLEN = 5
  )



    ( col_pos = 13
 fieldname = 'KSCHl'
 outputlen = 10
 seltext_m = 'Condition Type'
*  OUTPUTLEN = 5
  )
      ( col_pos = 14
 fieldname = 'VTEXT'
 outputlen = 10
 seltext_m = 'Condition Type Description'
*  OUTPUTLEN = 5
  )

        ( col_pos = 15
 fieldname = 'CUR'
 outputlen = 10
 seltext_m = 'Condition UNIT'
*  OUTPUTLEN = 5
  )

          ( col_pos = 16
 fieldname = 'CUR_TE'
 outputlen = 10
 seltext_m = 'Condition UNIT Description'
*  OUTPUTLEN = 5
  )
            ( col_pos = 17
 fieldname = 'kbetr'
 outputlen = 10
 seltext_m = 'Condition Amount'
*  OUTPUTLEN = 5
  )

  ).
  IF r_ex NE 'X'.
    APPEND         VALUE #( col_pos = 18
fieldname = 'new_KPEIN'
outputlen = 10
seltext_m = 'New Condition Amount'
edit = 'X'
 ) TO it_fieldcat.
    ls_layout-colwidth_optimize = 'X'.
  ENDIF.
* ls_layout-
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_FIELDCAT
*&      --> LT_FINAL
*&---------------------------------------------------------------------*
FORM display  USING    p_it_fieldcat
                       p_lt_final.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SUBR_MENU'
      i_callback_user_command  = 'SAVE'
      it_fieldcat              = p_it_fieldcat
    TABLES
      t_outtab                 = lt_final
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.

FORM subr_menu USING x TYPE slis_t_extab.
  IF r_ex NE 'X'.
    SET PF-STATUS 'ZSTANDARD'.
  ENDIF.
ENDFORM.
FORM save USING rcomm TYPE sy-ucomm
                sel TYPE slis_selfield.
  CASE sy-ucomm.
    WHEN 'UPDATE'.

      IF r_header = 'X'.
        LOOP AT lt_final INTO DATA(wa_change) WHERE new_kpein IS NOT INITIAL.

          READ TABLE   it_pohederchange ASSIGNING FIELD-SYMBOL(<fs_chhea>)
                                        WITH KEY cond_type = wa_change-kschl
                                                 cond_value = wa_change-kbetr.
          IF sy-subrc = 0.
            new_k =    wa_change-new_kpein.
            ASSIGN COMPONENT 'COND_VALUE' OF STRUCTURE <fs_chhea> TO FIELD-SYMBOL(<fs_chhd2>).
            <fs_chhea>-cond_value =   new_k.
            ASSIGN COMPONENT 'CHANGE_ID' OF STRUCTURE <fs_chhea> TO FIELD-SYMBOL(<fs_chhd3>).
            <fs_chhea>-change_id = 'U'.
            IF <fs_chhea>-calctypcon = 'A'.
              ASSIGN COMPONENT 'CURRENCY' OF STRUCTURE <fs_chhea>  TO FIELD-SYMBOL(<fs_chhd4>).
              <fs_chhea>-currency = '%'.
*             wa_pohederconx-currency  = 'X'.
            ENDIF.
            wa_pohederconx-condition_no = wa_change-condition_no.
            wa_pohederconx-itm_number = wa_change-itm_number.
            wa_pohederconx-cond_st_no = wa_change-cond_st_no.
            wa_pohederconx-cond_value = 'X'.
            wa_pohederconx-change_id = 'X'.
*             wa_pohederconx-currency  = 'X'.
            APPEND wa_pohederconx TO lt_pohederconx.
*            CLEAR: wa_change.
          ELSE.
          ENDIF.
        ENDLOOP.
      ELSE.

        LOOP AT lt_final INTO wa_change WHERE new_kpein IS NOT INITIAL.

          READ TABLE   it_poiteamchange ASSIGNING FIELD-SYMBOL(<fs_chit>)
                                        WITH KEY condition_no = wa_change-condition_no
                                                 itm_number   = wa_change-itm_number
                                                 cond_type    = wa_change-kschl.
*                                                 cond_value   = wa_change-kbetr.


*          condition_no EQ wa_ekko-knumv
*                                   AND itm_number   EQ wa_ekko-ebelp

          IF sy-subrc = 0.
            new_k =    wa_change-new_kpein.
            IF wa_change-kbetr < 0.
              new_k = -1 *  new_k.
            ENDIF.

            ASSIGN COMPONENT 'COND_VALUE' OF STRUCTURE <fs_chit> TO FIELD-SYMBOL(<fs_chit2>).

            <fs_chit>-cond_value = new_k.

            ASSIGN COMPONENT 'CHANGE_ID' OF STRUCTURE <fs_chit> TO FIELD-SYMBOL(<fs_chit3>).
            <fs_chit>-change_id = 'U'.
            IF <fs_chit>-currency = '%'.
              ASSIGN COMPONENT 'CURRENCY' OF STRUCTURE <fs_chit>  TO FIELD-SYMBOL(<fs_chit4>).
              <fs_chit>-currency = ' '.
            ENDIF.
            wa_poiteamchx-condition_no = wa_change-condition_no.
            wa_poiteamchx-itm_number = wa_change-itm_number.
            wa_poiteamchx-cond_st_no = wa_change-cond_st_no.
            wa_poiteamchx-cond_value = 'X'.
            wa_poiteamchx-change_id = 'X'.
            APPEND wa_poiteamchx  TO it_pochaitcontypx.
          ENDIF.
*          DELETE FROM it_poiteamchange WHERE in
        ENDLOOP.
      ENDIF.
      CALL FUNCTION 'BAPI_PO_CHANGE'
        EXPORTING
          purchaseorder = wa_change-ebeln    " Purchasing Document Number
          poheader      = wa_poheaderchdata    " Header Data
        TABLES
          return        = it_return    " Return Parameter
          pocondheader  = it_pohederchange  " Conditions (Header)
          pocondheaderx = lt_pohederconx   " Conditions (Header, Change Parameter)
          pocond        = it_poiteamchange  " Conditions (Items)
          pocondx       = it_pochaitcontypx.
      " Conditions (Items, Change Parameter)
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.               " Use of Command `COMMIT AND WAIT`.
      IF line_exists( it_return[ type = 'S' ] ).
        IF r_header = 'X'.
          MESSAGE 'Data Update Sucessfully For Conditions Header Type' TYPE 'S'.
        ENDIF.
        IF r_item = 'X'.
          MESSAGE 'Data Update sucessfully For Conditions Item Type' TYPE 'S'.
        ENDIF.
      ENDIF.

    WHEN 'SHIFT-F3'.
      LEAVE TO SCREEN 0.
    WHEN '&F3'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.
