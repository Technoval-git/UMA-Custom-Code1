*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHICLEF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INB_DELIVERY_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_INB_DELIVERY_DETAIL[]
*&      --> RETURN[]
*&      --> IS_INB_DELIVERY_HEADER
*&      --> EF_DELIVERY
*&---------------------------------------------------------------------*

FORM read_inbd_create_po_getitems
            TABLES   et_inb_d_create_po_items TYPE inbdelivdetail_type
                     return  TYPE return_type
            USING    if_vendor    LIKE bapiekko-vendor
                     if_po_number   LIKE bapiekko-po_number
                     if_deliv_date  LIKE likp-lfdat
                     if_deliv_time  LIKE likp-lfuhr.
*///////////////////////////////////////////////////////
* Local Variables

  DATA lf_wild TYPE c VALUE '%'.
  DATA lf_dellen TYPE i.
  DATA lf_sel-ebelnsear LIKE bapiekko-po_number.
  DATA  lf_confirmed_quantity LIKE lips-lfimg.
  DATA: lt_po_items LIKE bbp_inbd_po_view OCCURS 0 WITH HEADER LINE.
  DATA: lf_asnitemno LIKE lips-posnr.
  DATA: lf_reject.

  TABLES: bbp_inbd_po_view .                 "View
  TABLES: t160s.


***************Main program*********************
*DATA SASELECTIONCOUNT TYPE I.

  CLEAR et_inb_d_create_po_items.

  lf_dellen = strlen( if_po_number ).
  IF lf_dellen < 8.
    CONCATENATE lf_wild if_po_number lf_wild INTO lf_sel-ebelnsear.
  ELSE.
    lf_sel-ebelnsear = if_po_number.
  ENDIF.

*DESCRIBE TABLE XSASELECTION LINES SASELECTIONCOUNT.
*
*IF SASELECTIONCOUNT > 0.
*  SELECT * FROM ECASNVW  INTO TABLE ITAB_SALIST
*    FOR ALL ENTRIES IN XSASELECTION
*    WHERE LIFNR = LFA1-LIFNR
*    AND EBELN = XSASELECTION-VGBEL
*    AND IBTYP = '2'.
*ELSE.
  SELECT * FROM bbp_inbd_po_view INTO TABLE lt_po_items
    WHERE lifnr = if_vendor
    AND ebeln LIKE lf_sel-ebelnsear
    AND ibtyp = '2'
    AND mandt = sy-mandt.
*endif.

*perform check_itab_salist.

** CASE I Based on ME_CONFIRMATION_READ_AVIS

** Changed on 24111998 Based on C CALL WITH ANGELA F, JOCHEN S
** For Locking and Un-Locking Reasons
* perform asn_create_sa_selection_bydate.

** CASE II Based on ME_CONFIRMATION_MAINTAIN

  LOOP AT lt_po_items.

    PERFORM  filter_inbd_create_po_getitems
                   TABLES lt_po_items
                   CHANGING lf_confirmed_quantity
                            lf_reject.
    .
    IF lf_reject NE space.
      DELETE lt_po_items.
    ELSE.
      IF NOT lf_confirmed_quantity IS INITIAL.
        MOVE lf_confirmed_quantity TO lt_po_items-menge.
        MODIFY lt_po_items.
        CLEAR lf_confirmed_quantity.
      ENDIF.
    ENDIF.

  ENDLOOP.

*perform check_itab_salist.

**** Check Confirmation Control Flag****
**/////// IS Auto Specific**///////////////////////////////////////
* perform check_tracking_confirmation_sa tables lt_po_items.

*perform check_itab_salist.

*****  For IDOC ISO CODE is required

  PERFORM get_isocode TABLES lt_po_items.

  lf_asnitemno = 10.

  LOOP AT lt_po_items.
    IF NOT lt_po_items-menge IS INITIAL.
      MOVE lf_asnitemno TO et_inb_d_create_po_items-deliv_item.
      MOVE lt_po_items-matnr TO et_inb_d_create_po_items-material.
      MOVE lt_po_items-menge TO et_inb_d_create_po_items-deliv_qty.
      MOVE lt_po_items-meins TO et_inb_d_create_po_items-unit.
      MOVE lt_po_items-ebeln TO et_inb_d_create_po_items-po_number.
      MOVE lt_po_items-ebelp TO et_inb_d_create_po_items-po_item.
      APPEND et_inb_d_create_po_items.
      lf_asnitemno = lf_asnitemno + 10.
    ENDIF.
  ENDLOOP.

*describe table itab_salist lines salistcount.

********  get material descirption
  PERFORM update_material_desc_sa TABLES et_inb_d_create_po_items.

*            cr_deldate = rv50a-lfdat_la.
*            cr_deltime = rv50a-lfuhr_la.


ENDFORM.                               " READ_INBD_CREATE_PO_GETITEMS
*&---------------------------------------------------------------------*
*&      Form  FILTER_INBD_CREATE_PO_GETITEMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_PO_ITEMS  text                                          *
*      <--P_LF_REJECT  text                                            *
*----------------------------------------------------------------------*
FORM filter_inbd_create_po_getitems
                     TABLES   lt_po_items TYPE inbd_po_items_type
                     CHANGING lf_confirmed_quantity LIKE lips-lfimg
                              lf_reject.

***********Local Variables******************
  DATA: reject.
** Purchasing Flags
*------- Tabelle der Selektionsparameter ------------------------------*
  DATA: BEGIN OF xt160s OCCURS 1.
          INCLUDE STRUCTURE t160s.
  DATA: END OF xt160s.

*------- Hilfsfelder Selektion ----------------------------------------*
  DATA: vfeld1(11) TYPE p,             "Vergleichsfeld
        vfeld2(11) TYPE p.             "Vergleichsfeld

*------- Hilfelder für Umrechnungen -----------------------------------*
  DATA: BEGIN OF h,
          netpr LIKE ekpo-netpr,
          menge LIKE ekpo-menge,
          avimg LIKE ekes-menge,
          avirl,
          gwerl,
          setmg LIKE rm06a-setmg,
          lagmg LIKE rm06a-lagmg,
          ofzmg LIKE rm06a-ofzmg,
          swemg LIKE rm06a-swemg,
          wemng LIKE ekbes-wemng,
          wamng LIKE ekbes-wamng,
          wert  LIKE ekko-ktwrt,
        END OF h.

*------- Tabelle der Einteilungen -------------------------------------*
  DATA: BEGIN OF ett OCCURS 10.
          INCLUDE STRUCTURE beket.
  DATA: END OF ett.

  DATA: BEGIN OF yeket                           OCCURS 20.
          INCLUDE STRUCTURE ueket                         .
  DATA: END OF yeket                          .
*------- BETS (Tabelle der Bestellentwicklungssummen ) ----------------*
  DATA:   BEGIN OF bets OCCURS 50.
            INCLUDE STRUCTURE ekbes.
  DATA:   END OF bets.

******** Main Program *******************************************
  SELECT * FROM t160s INTO TABLE xt160s
          WHERE selpa = 'AVIS'.

  reject = 'X'.

  READ TABLE xt160s INDEX 1.
  IF sy-subrc EQ 0.
    reject = 'X'.
  ENDIF.

  PERFORM fc_me_read_history TABLES lt_po_items.

  LOOP AT xt160s.

    IF xt160s-av000 NE space OR
       xt160s-avbe0 NE space OR
       xt160s-avwe0 NE space.
      IF lt_po_items-bstae EQ space.
        reject = 'X'.
      ELSE.
        reject = space.
        CALL FUNCTION 'ME_CONFIRMATION_MAINTAIN'
          EXPORTING
            i_bstae  = lt_po_items-bstae
            i_ebeln  = lt_po_items-ebeln
            i_ebelp  = lt_po_items-ebelp
            i_funkt  = 'A'
            i_werks  = lt_po_items-werks
          IMPORTING
            e_ekesok = h-avirl
            e_lamng  = h-avimg
          TABLES
            xeket    = ett
            yeket    = yeket.

        IF h-avirl EQ space.
          reject = 'X'.
        ELSE.
*- avisiert <-> 0 -----------------------------------------------------*
          IF xt160s-av000 NE space.
            vfeld1 = h-avimg.
            vfeld2 = 0.
            PERFORM selpa_vergleich USING xt160s-av000
                                                  vfeld1
                                                  vfeld2
                                    CHANGING      reject.
          ENDIF.

*- avisiert <-> bestellte Menge ---------------------------------------*
          IF xt160s-avbe0 NE space.
            vfeld1 = h-avimg.
            vfeld2 = lt_po_items-menge.
            PERFORM selpa_vergleich USING         xt160s-avbe0
                                                  vfeld1
                                                  vfeld2
                                    CHANGING      reject.
            IF reject EQ space.
              lf_confirmed_quantity = lt_po_items-menge - h-avimg.
            ENDIF.
          ENDIF.

*- avisiert <-> gelieferte Menge --------------------------------------*
          IF xt160s-avwe0 NE space.
            vfeld1 = h-avimg.
            vfeld2 = bets-wemng.
            PERFORM selpa_vergleich USING xt160s-avwe0
                                                  vfeld1
                                                  vfeld2
                                    CHANGING      reject.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*- Grob-WE-Menge ------------------------------------------------------*
    IF xt160s-gw000 NE space OR
       xt160s-gwbe0 NE space OR
       xt160s-gwwe0 NE space.
      IF lt_po_items-bstae EQ space.
        reject = 'X'.
      ELSE.
        reject = space.
        CALL FUNCTION 'ME_CONFIRMATION_MAINTAIN'
          EXPORTING
            i_bstae  = lt_po_items-bstae
            i_ebeln  = lt_po_items-ebeln
            i_ebelp  = lt_po_items-ebelp
            i_funkt  = 'G'
            i_werks  = lt_po_items-werks
          IMPORTING
            e_ekesok = h-gwerl
            e_lamng  = h-avimg
          TABLES
            xeket    = ett
            yeket    = yeket.
        IF h-gwerl = space.
          reject = 'X'.
        ELSE.
*- Grob-WE-Menge <-> 0 ------------------------------------------------
          IF xt160s-gw000 NE space.
            vfeld1 = h-avimg.
            vfeld2 = 0.
            PERFORM selpa_vergleich USING xt160s-gw000
                                                  vfeld1
                                                  vfeld2
                                    CHANGING      reject.
          ENDIF.

*- Grob-WE-Menge <-> bestellte Menge ---------------------------------*
          IF xt160s-gwbe0 NE space.
            vfeld1 = h-avimg.
            vfeld2 = lt_po_items-menge.
            PERFORM selpa_vergleich USING xt160s-gwbe0
                                                  vfeld1
                                                  vfeld2
                                    CHANGING      reject.
          ENDIF.

*- Grob-WE-Menge <-> gelieferte Menge ---------------------------------
          IF xt160s-gwwe0 NE space.
            vfeld1 = h-avimg.
            vfeld2 = bets-wemng.
            PERFORM selpa_vergleich USING xt160s-gwwe0
                                                  vfeld1
                                                  vfeld2
                                    CHANGING      reject.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.
  lf_reject = reject.
ENDFORM.                               " FILTER_INBD_CREATE_PO_GETITEMS
*&---------------------------------------------------------------------*
*&      Form  SELPA_VERGLEICH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T160S_AV000  text                                          *
*----------------------------------------------------------------------*
FORM selpa_vergleich USING svg_oper
                           vfeld1
                           vfeld2
                     CHANGING      reject.

  CASE svg_oper.
    WHEN '< '.
      IF vfeld1 < vfeld2.
      ELSE.
        reject = 'X'.
      ENDIF.
    WHEN '<='.
      IF vfeld1 <= vfeld2.
      ELSE.
        reject = 'X'.
      ENDIF.
    WHEN '> '.
      IF vfeld1 > vfeld2.
      ELSE.
        reject = 'X'.
      ENDIF.
    WHEN '>='.
      IF vfeld1 >= vfeld2.
      ELSE.
        reject = 'X'.
      ENDIF.
    WHEN '<>'.
      IF vfeld1 <> vfeld2.
      ELSE.
        reject = 'X'.
      ENDIF.
    WHEN '= '.
      IF vfeld1 = vfeld2.
      ELSE.
        reject = 'X'.
      ENDIF.
  ENDCASE.

ENDFORM.                               " SELPA_VERGLEICH
*&---------------------------------------------------------------------*
*&      Form  FC_ME_READ_HISTORY
*&---------------------------------------------------------------------*
****** Based on FM06LFSL, To get History
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fc_me_read_history TABLES lt_po_items TYPE inbd_po_items_type.

** PO History
*------- BETS (Tabelle der Bestellentwicklungssummen ) ----------------*
  DATA:   BEGIN OF bets OCCURS 50.
            INCLUDE STRUCTURE ekbes.
  DATA:   END OF bets.

*------- BET ( Tabelle der Bestellentwicklungssaetze ) ----------------*
  DATA:   BEGIN OF bet OCCURS 50.
            INCLUDE STRUCTURE ekbe.
  DATA:   END OF bet.

*------- BZT ( Tabelle der Bezugsnebenkostenelemente ) ----------------*
  DATA:   BEGIN OF bzt OCCURS 50.
            INCLUDE STRUCTURE ekbz.
  DATA:   END OF bzt.

*------- BETZ (Tabelle der WE-RE-Zuordnungen) -------------------------*
  DATA:   BEGIN OF betz OCCURS 50.
            INCLUDE STRUCTURE ekbez.
  DATA:   END OF betz.

*------- XEKBNK ( Tabelle der Bezugsnebenkostensummen ) ---------------*
  DATA:   BEGIN OF xekbnk OCCURS 10.
            INCLUDE STRUCTURE ekbnk.
  DATA:   END OF xekbnk.


  CALL FUNCTION 'ME_READ_HISTORY'
    EXPORTING
      ebeln  = lt_po_items-ebeln
      ebelp  = lt_po_items-ebelp
      webre  = lt_po_items-webre
    TABLES
      xekbe  = bet
      xekbz  = bzt
      xekbes = bets
      xekbez = betz
      xekbnk = xekbnk.
  READ TABLE bets INDEX 1.
  SORT bzt BY ebelp vgabe bewtp gjahr belnr buzei.
  SORT bet BY ebelp vgabe bewtp gjahr belnr buzei.

ENDFORM.                               " FC_ME_READ_HISTORY
***********************************************************************
*&---------------------------------------------------------------------*
*&      Form  CHECK_TRACKING_CONFIRMATION_SA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_PO_ITEMS  text                                          *
*----------------------------------------------------------------------*
*FORM CHECK_TRACKING_CONFIRMATION_SA
*                           TABLES LT_PO_ITEMS TYPE INBD_PO_ITEMS_TYPE.
*
*****Local Variable
*  DATA: F_TRACK.
*  TABLES: T163L.
*
*  LOOP AT LT_PO_ITEMS.
*
*    SELECT SINGLE IDT_TRACK_IND
*      INTO F_TRACK
*      FROM T163L AS T INNER JOIN EKPO AS E ON  T~BSTAE = E~BSTAE
*    WHERE E~EBELN = LT_PO_ITEMS-EBELN
*      AND E~EBELP = LT_PO_ITEMS-EBELP.
*
*    IF F_TRACK = SPACE.
*       DELETE LT_PO_ITEMS.        "Delete from Itab_saList
*    ENDIF.
*
*  ENDLOOP.
*
*ENDFORM.                    " CHECK_TRACKING_CONFIRMATION_SA

*&---------------------------------------------------------------------*
*&      Form  GET_ISOCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_PO_ITEMS  text                                          *
*----------------------------------------------------------------------*
FORM get_isocode TABLES  lt_po_items  TYPE inbd_po_items_type.
***Local Variables
  DATA itab_salistcount TYPE p.
  TYPES:
    BEGIN OF unitwa,
      meins  LIKE ekpo-meins,
      meinsn LIKE ekpo-meins,
    END OF unitwa.

  DATA: unitlg TYPE unitwa OCCURS 0 WITH HEADER LINE.
  TABLES: t006.

*****Main Program*****
  DESCRIBE TABLE  lt_po_items  LINES itab_salistcount.

  IF itab_salistcount > 0.

    SELECT msehi isocode
       FROM t006
       INTO TABLE unitlg
       FOR ALL ENTRIES IN  lt_po_items
       WHERE msehi =  lt_po_items-meins.


    LOOP AT  lt_po_items .
      READ TABLE unitlg WITH KEY  lt_po_items-meins.
      IF sy-subrc = 0.
        MOVE  unitlg-meinsn TO  lt_po_items-meins.
        MODIFY  lt_po_items .
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.                               " GET_ISOCODE
*&---------------------------------------------------------------------*
*&      Form  UPDATE_MATERIAL_DESC_SA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_material_desc_sa
               TABLES et_inbd_create_po_items TYPE inbdelivdetail_type.


***Local Variable***
** Material Text
  TYPES:
    BEGIN OF imakttextwa,
      matnr LIKE makt-matnr,
      maktx LIKE makt-maktx,
    END OF imakttextwa.

  DATA: imakttext TYPE imakttextwa OCCURS 0 WITH HEADER LINE.
  DATA xsalistcount TYPE p.

*** Main Program
  DESCRIBE TABLE et_inbd_create_po_items LINES xsalistcount.

  IF xsalistcount > 0.


    SELECT matnr maktx
       FROM makt CLIENT SPECIFIED
       INTO TABLE imakttext
       FOR ALL ENTRIES IN et_inbd_create_po_items
       WHERE matnr = et_inbd_create_po_items-material
       AND spras = sy-langu
       AND mandt = sy-mandt.

    LOOP AT et_inbd_create_po_items.
      READ TABLE imakttext WITH KEY et_inbd_create_po_items-material.
      IF sy-subrc = 0.
        MOVE  imakttext-maktx TO et_inbd_create_po_items-matl_desc.
        MODIFY et_inbd_create_po_items.
      ENDIF.
    ENDLOOP.
  ENDIF.
*
ENDFORM.                               " UPDATE_MATERIAL_DESC_SA
*&---------------------------------------------------------------------*
*&      Form  INB_DELIVERY_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_INB_DELIVERY_DETAIL[]  text                             *
*      -->P_RETURN[]  text                                             *
*      -->P_IS_INB_DELIVERY_HEADER  text                               *
*      -->P_EF_DELIVERY  text                                          *
*----------------------------------------------------------------------*
FORM inb_delivery_create
            TABLES   it_inb_delivery_detail TYPE inbdelivdetail_type
                     return  TYPE return_type
            USING    is_inb_delivery_header STRUCTURE bbp_inbd_l
                     ef_delivery LIKE likp-vbeln.

*** Local Variables
  DATA lt_vbsk LIKE vbsk OCCURS 0 WITH HEADER LINE.
  DATA lt_komdlgn LIKE komdlgn OCCURS 0 WITH HEADER LINE.
  DATA lt_vbfs LIKE vbfs OCCURS 0 WITH HEADER LINE.
  DATA lt_vbls LIKE vbls OCCURS 0 WITH HEADER LINE.
  DATA lf_h-ind LIKE sy-tabix.         "Hilfsfeld Index
  DATA lf_v_vbeln LIKE likp-vbeln.     "From delivery Number
  DATA lf_b_vbeln LIKE likp-vbeln.     "To delivery Number
  DATA lt_prop LIKE wuebs OCCURS 100 WITH HEADER LINE.


**** Loading the lt_komdlgn

  lt_komdlgn-lifex = is_inb_delivery_header-deliv_ext.
  lt_komdlgn-verur = is_inb_delivery_header-deliv_ext.
  lt_komdlgn-lfdat = is_inb_delivery_header-deliv_date.
  lt_komdlgn-lfuhr = is_inb_delivery_header-deliv_time.
  lt_komdlgn-traid = is_inb_delivery_header-transp_id.
  lt_komdlgn-traty = is_inb_delivery_header-trans_cat.
  lt_komdlgn-xabln = is_inb_delivery_header-shipno.
*  lt_komdlgn-lifnr = 'Lear_03'. "if_vendor

  LOOP AT it_inb_delivery_detail. "into et_po_detail.


    lt_komdlgn-matnr = it_inb_delivery_detail-material.
    lt_komdlgn-lfimg = it_inb_delivery_detail-deliv_qty.
    lt_komdlgn-vrkme = it_inb_delivery_detail-unit.
    lt_komdlgn-meins = it_inb_delivery_detail-unit.
*    lt_komdlgn-umvkz = 1.
*    lt_komdlgn-umvkn = 1.
*    lt_komdlgn-werks = '0001'.
    lt_komdlgn-vgbel = it_inb_delivery_detail-po_number.
    lt_komdlgn-vgpos = it_inb_delivery_detail-po_item.
    lt_komdlgn-brgew = is_inb_delivery_header-total_wght * lt_komdlgn-lfimg.
    lt_komdlgn-gewei = is_inb_delivery_header-unit_of_wt.
    lt_komdlgn-lgort = 'V001'.
    lt_vbsk-brgew = lt_vbsk-brgew + lt_komdlgn-brgew.
    lt_vbsk-gewei = is_inb_delivery_header-unit_of_wt.

    APPEND lt_komdlgn.
  ENDLOOP.


*** Code from IDOC_INPUT_DESADV1
*** Not Available in 3.1
  CALL FUNCTION 'ME_CONFIRMATION_VIA_EDI'
    TABLES
      t_kom  = lt_komdlgn
      errors = lt_prop
    EXCEPTIONS
      OTHERS = 1.

  IF sy-subrc NE 0.
    WRITE / 'Error Coccured in ME_CONFIRMATION_VIA_EDI'.
  ENDIF.


  LOOP AT lt_komdlgn.
* set default parameter
    lt_komdlgn-vgtyp = 'V'.
    lt_komdlgn-kzazu = 'X'.
    IF lt_komdlgn-lfart IS INITIAL.
      lt_komdlgn-lfart = 'EL'.
    ENDIF.
    MODIFY lt_komdlgn.
  ENDLOOP.

***** Create
  DATA: nrnr LIKE inri-nrrangenr.
  TABLES: tvsa.

* Sammelgangsnummer vergeben
  lt_vbsk-mandt = sy-mandt.
  lt_vbsk-ernam = sy-uname.
  lt_vbsk-erdat = sy-datum.
  lt_vbsk-uzeit = sy-uzeit.
  lt_vbsk-smart = 'L'.
*  lt_vbsk-brgew = is_inb_delivery_header-total_wght.
*  lt_vbsk-gewei = is_inb_delivery_header-unit_of_wt.

  SELECT SINGLE * FROM tvsa WHERE smart = lt_vbsk-smart.
  IF sy-subrc <> 0.
*** Error Handling To be Done
*   Meldung ins Protokoll
  ENDIF.


  nrnr = tvsa-numki.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = nrnr
      object      = 'RV_SAMMG'
    IMPORTING
      number      = lt_vbsk-sammg
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc <> 0.
*** Error Hadling TBD
*   Meldung ins Protokoll
  ENDIF.

**** Call Core Function GN_DELIVERY_CREATE.
  CALL FUNCTION 'GN_DELIVERY_CREATE'
    EXPORTING
      vbsk_i   = lt_vbsk
    IMPORTING
      vbsk_e   = lt_vbsk
    TABLES
      xkomdlgn = lt_komdlgn
      xvbfs    = lt_vbfs
      xvbls    = lt_vbls
    EXCEPTIONS
      OTHERS   = 1.

*** Error Handling
  IF sy-subrc NE 0.
    ROLLBACK WORK.
    PERFORM fill_bapireturn TABLES return
                            USING  sy-msgty sy-msgid sy-msgno
                                   sy-msgv1 sy-msgv2
                                   sy-msgv3 sy-msgv4.
  ELSE.

    IF lt_vbsk-ernum EQ 0 AND
       lt_vbsk-vbnum GT 0.
      DESCRIBE TABLE lt_vbls LINES lf_h-ind.
      READ TABLE lt_vbls INDEX 1.
      lf_v_vbeln = lt_vbls-vbeln_lif.
      READ TABLE lt_vbls INDEX lf_h-ind.
      lf_b_vbeln = lt_vbls-vbeln_lif.
      CLEAR lf_h-ind.

      ef_delivery = lf_v_vbeln.
      PERFORM fill_bapireturn TABLES return
                              USING  'S'   "msgType
                                     'ME'  "msgid
                                     '780' "msgno
                                     lt_vbsk-vbnum "sy-msgv1
                                     lf_v_vbeln    "sy-msgv1
                                     lf_b_vbeln    "sy-msgv2
                                     sy-msgv4.

    ENDIF.
  ENDIF.

ENDFORM.                               " INB_DELIVERY_CREATE
