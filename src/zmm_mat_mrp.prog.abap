*&---------------------------------------------------------------------*
*& Report ZMM_MAT_MRP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_mat_mrp.
TABLES: zmm_mat_mrp,mara,marc,mard,zmm_golive.
TYPE-POOLS: slis.


DATA : lt_mrp TYPE STANDARD TABLE OF zmm_mat_mrp,
       ls_mrp TYPE zmm_mat_mrp.
DATA : lt_golive TYPE STANDARD TABLE OF zmm_golive.
FIELD-SYMBOLS <lf_mrp> TYPE zmm_mat_mrp.
* ALV Declaration
DATA : it_fieldcat TYPE slis_t_fieldcat_alv,
       wa_fieldcat TYPE slis_fieldcat_alv.

TYPES: BEGIN OF ty_werks,
         sign   TYPE c LENGTH 1,
         option TYPE c LENGTH 2,
         low    TYPE werks_d,
         high   TYPE werks_d,
       END OF ty_werks.
DATA lw_werks TYPE ty_werks.


DATA lt_ekpo TYPE STANDARD TABLE OF z_openpo.
DATA lt_ekpo_sto TYPE STANDARD TABLE OF z_openpo_sto.

FIELD-SYMBOLS <lf_ekpo> TYPE z_openpo. "ty_ekpo.
FIELD-SYMBOLS <lf_ekpo_sto> TYPE z_openpo_sto. "ty_ekpo_sto.
TYPES : BEGIN OF ty_eban1,
          matnr TYPE eban-matnr,
          reswk TYPE eban-reswk,
          menge TYPE eban-menge,
          bsmng TYPE eban-bsmng,
        END OF ty_eban1.
DATA :lw_eban1 TYPE ty_eban1,
      lt_eban1 TYPE STANDARD TABLE OF ty_eban1.
DATA lvindex TYPE sy-index.

TYPES : BEGIN OF ty_t161t,
          bsart TYPE esart,
          batxt TYPE batxt,
        END OF ty_t161t.
DATA :lw_t161t TYPE ty_t161t,
      lt_t161t TYPE STANDARD TABLE OF ty_t161t.
DATA lt_cpd_plants TYPE STANDARD TABLE OF zmm_cpd_plants.
DATA lw_cpd_plants TYPE zmm_cpd_plants.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS: s_matnr FOR mara-matnr ,
                  s_werks FOR mard-werks," OBLIGATORY,
                  s_mtart FOR mara-mtart DEFAULT 'YPOM' OBLIGATORY ,
                  s_matkl FOR mara-matkl OBLIGATORY,
                  s_maabc FOR marc-maabc,
                  s_dismm FOR marc-dismm  . " MRP Type
  PARAMETERS :p_region TYPE zmm_region.

  SELECTION-SCREEN BEGIN OF LINE.

  SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
  PARAMETERS p_upd TYPE c AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.

AT SELECTION-SCREEN OUTPUT.
  SELECT region_sa cpd branch branch_cp cpd_pr FROM zmm_cpd_plants INTO TABLE lt_cpd_plants.

AT SELECTION-SCREEN.

  IF p_region IS NOT INITIAL AND s_werks IS INITIAL.
    CLEAR s_werks.
    SELECT cpd , branch FROM zmm_cpd_plants INTO TABLE @DATA(lt_plants) WHERE region_sa = @p_region.
    IF lt_plants IS INITIAL.
      MESSAGE 'Region does not exit' TYPE 'E'.
    ENDIF.
    LOOP AT lt_plants INTO DATA(lw_plants).
      IF sy-tabix = 1.
        lw_werks-sign = 'I'.
        lw_werks-option = 'EQ'.
        lw_werks-low = lw_plants-cpd.
        APPEND lw_werks TO s_werks.
      ENDIF.
      lw_werks-sign = 'I'.
      lw_werks-option = 'EQ'.
      lw_werks-low = lw_plants-branch.
      APPEND lw_werks TO s_werks.
    ENDLOOP.

  ENDIF.
  IF p_region IS INITIAL AND s_werks IS INITIAL.
    MESSAGE 'Please Enter Region or Plant' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.
  IF p_upd = 'X'.
    SELECT * FROM zmm_golive INTO TABLE lt_golive.
    SELECT t~werks, t~land1, t~regio, tt~bezei INTO TABLE @DATA(lt_regio)
      FROM t001w AS t  INNER JOIN t005u AS tt
       ON t~land1 = tt~land1 AND t~regio = tt~bland
        WHERE tt~spras = 'E'.

    SELECT c~matnr c~werks m~mtart m~matkl m~ersda x~maktx m~meins c~maabc c~bstmi AS min_order
           c~bstma AS max_order c~minbe AS reorder_point  c~eisbe AS safty_stock
      INTO CORRESPONDING FIELDS OF TABLE lt_mrp FROM marc AS c
       INNER JOIN mara AS m ON c~matnr = m~matnr
       INNER JOIN makt AS x ON c~matnr = x~matnr

       WHERE c~matnr IN s_matnr AND c~werks IN s_werks AND x~spras = 'EN' AND m~mtart IN s_mtart.

*    DATA lt_ekpo TYPE STANDARD TABLE OF ty_ekpo.
*    FIELD-SYMBOLS <lf_ekpo> TYPE ty_ekpo.



*    SELECT  bsart batxt FROM t161t INTO TABLE lt_t161t WHERE spras = 'E'.
**OPEN PO----------------------------------
***Need to write CDS view for the below code to get openpo
******    SELECT e~ebeln e~ebelp e~loekz e~matnr e~werks e~menge e~wemng e~retpo k~bsart
******      FROM ekko AS k INNER JOIN mdbs AS e ON k~ebeln = e~ebeln
******      INTO TABLE lt_ekpo
******      WHERE e~matnr IN s_matnr
******        AND e~werks IN s_werks
******        AND e~loekz = ' '
******        AND e~bstyp = 'F'
******        AND e~elikz = ' '.
*******        AND k~bsakz = ' '.
******    LOOP AT lt_ekpo ASSIGNING <lf_ekpo>.
******      <lf_ekpo>-openpo = <lf_ekpo>-menge - <lf_ekpo>-wemng.
******    ENDLOOP.
******    LOOP AT lt_ekpo ASSIGNING <lf_ekpo> WHERE retpo = 'X'.
******      <lf_ekpo>-openpo = ( <lf_ekpo>-menge * -1 ) - ( <lf_ekpo>-wemng * -1 ).
******    ENDLOOP.

    SELECT * FROM z_openpo INTO TABLE lt_ekpo  WHERE matnr IN s_matnr
      AND werks IN s_werks
      AND loekz = ' '
      AND bstyp = 'F'
      AND elikz = ' '.
*Open STO PO Quantity------------------------------------------
******    SELECT e~ebeln  e~ebelp e~loekz e~matnr k~reswk e~menge e~wemng e~retpo
******     FROM ekko AS k INNER JOIN mdbs AS e ON k~ebeln = e~ebeln
******     INTO TABLE lt_ekpo_sto
******     WHERE e~matnr IN s_matnr
******       AND k~reswk IN s_werks
******       AND e~loekz = ' '
******       AND e~bstyp = 'F'
******       AND e~elikz = ' '.
******    LOOP AT lt_ekpo_sto ASSIGNING <lf_ekpo_sto>.
******      <lf_ekpo_sto>-openpo_sto = <lf_ekpo_sto>-menge - <lf_ekpo_sto>-wemng.
******    ENDLOOP.

*open STO PR Quantity
    SELECT * FROM z_openpo_sto INTO TABLE lt_ekpo_sto  WHERE matnr IN s_matnr
       AND reswk IN s_werks
       AND loekz = ' '
       AND bstyp = 'F'
       AND elikz = ' '.

    SELECT matnr reswk    SUM( menge ) SUM( bsmng ) FROM eban INTO TABLE lt_eban1
            WHERE matnr IN s_matnr AND reswk IN s_werks AND loekz = ' '
          GROUP BY matnr  reswk.




    LOOP AT lt_mrp ASSIGNING <lf_mrp> .
      READ TABLE lt_cpd_plants INTO lw_cpd_plants WITH KEY branch = <lf_mrp>-werks.
      IF sy-subrc = 0.
        <lf_mrp>-region_sa = lw_cpd_plants-region_sa.
      ELSE.
        READ TABLE lt_cpd_plants INTO lw_cpd_plants WITH KEY cpd = <lf_mrp>-werks.
        IF sy-subrc = 0.
          <lf_mrp>-region_sa = lw_cpd_plants-region_sa.
        ENDIF.
      ENDIF.
      SELECT SINGLE no_sale_days  FROM zmm_work_days INTO  <lf_mrp>-no_sale_days WHERE werks = <lf_mrp>-werks.
      SELECT SINGLE pdt FROM ymm_mrp_plt INTO   <lf_mrp>-lead_time WHERE werks = <lf_mrp>-werks.
      SELECT SINGLE slev  FROM ymm_mrp_ssf INTO <lf_mrp>-service_level     WHERE  werks = <lf_mrp>-werks AND maabc = <lf_mrp>-maabc.
*      open PO
      CLEAR <lf_mrp>-openpo.
      LOOP AT lt_ekpo ASSIGNING <lf_ekpo> WHERE matnr = <lf_mrp>-matnr   AND werks = <lf_mrp>-werks.

        <lf_mrp>-openpo = <lf_mrp>-openpo + <lf_ekpo>-openpo.

        IF <lf_ekpo>-bsart  = 'YIPO'.
          <lf_mrp>-yipo_qty = <lf_ekpo>-openpo.
        ELSEIF  <lf_ekpo>-bsart  = 'YLPO'.
          <lf_mrp>-ylpo_qty = <lf_ekpo>-openpo.
        ELSEIF  <lf_ekpo>-bsart  = 'YSPO'.
          <lf_mrp>-yspo_qty = <lf_ekpo>-openpo.
        ELSEIF  <lf_ekpo>-bsart  = 'YVIP'.
          <lf_mrp>-yvip_qty = <lf_ekpo>-openpo.
        ELSEIF  <lf_ekpo>-bsart  = 'YWPO'.
          <lf_mrp>-ywpo_qty = <lf_ekpo>-openpo.
        ELSEIF    <lf_ekpo>-bsart  = 'YRPO'.
          <lf_mrp>-yrpo_qty = <lf_ekpo>-openpo.
        ENDIF.

      ENDLOOP.
      LOOP AT lt_ekpo_sto ASSIGNING <lf_ekpo_sto> WHERE matnr = <lf_mrp>-matnr   AND reswk = <lf_mrp>-werks.

        <lf_mrp>-openposto   = <lf_mrp>-openposto + <lf_ekpo_sto>-openpo_sto.
      ENDLOOP.


      READ TABLE lt_eban1 INTO lw_eban1 WITH KEY matnr = <lf_mrp>-matnr   reswk = <lf_mrp>-werks .
      IF sy-subrc = 0.
        <lf_mrp>-openstoprqty = lw_eban1-menge - lw_eban1-bsmng.
      ENDIF.


      READ TABLE lt_regio INTO DATA(ls_regio) WITH KEY werks = <lf_mrp>-werks .
      IF sy-subrc = 0.
        <lf_mrp>-region = ls_regio-regio.
        <lf_mrp>-region_desc = ls_regio-bezei.
      ENDIF.
      READ TABLE lt_golive INTO DATA(ls_golive) WITH KEY werks = <lf_mrp>-werks matkl = <lf_mrp>-matkl.
      IF sy-subrc = 0.CALL FUNCTION 'ZMM_SALES_HISTORY'
          EXPORTING
            matnr      = <lf_mrp>-matnr
            werks      = <lf_mrp>-werks
            months     = 00
            golivedate = ls_golive-golive_date              "'20240201'
          IMPORTING
            fklmg      = <lf_mrp>-sold0.
      CALL FUNCTION 'ZMM_SALES_HISTORY'
        EXPORTING
          matnr      = <lf_mrp>-matnr
          werks      = <lf_mrp>-werks
          months     = 01
          golivedate = ls_golive-golive_date "'20240201'
        IMPORTING
          fklmg      = <lf_mrp>-sold1.
      CALL FUNCTION 'ZMM_SALES_HISTORY'
        EXPORTING
          matnr      = <lf_mrp>-matnr
          werks      = <lf_mrp>-werks
          months     = 02
          golivedate = ls_golive-golive_date "'20240201'
        IMPORTING
          fklmg      = <lf_mrp>-sold2.
      CALL FUNCTION 'ZMM_SALES_HISTORY'
        EXPORTING
          matnr      = <lf_mrp>-matnr
          werks      = <lf_mrp>-werks
          months     = 03
          golivedate = ls_golive-golive_date "'20240201'
        IMPORTING
          fklmg      = <lf_mrp>-sold3.


      CALL FUNCTION 'ZMM_SALES_HISTORY'
        EXPORTING
          matnr      = <lf_mrp>-matnr
          werks      = <lf_mrp>-werks
          months     = 06
          golivedate = ls_golive-golive_date "'20240201'
        IMPORTING
          fklmg      = <lf_mrp>-sold6.


      CALL FUNCTION 'ZMM_SALES_HISTORY'
        EXPORTING
          matnr      = <lf_mrp>-matnr
          werks      = <lf_mrp>-werks
          months     = 09
          golivedate = ls_golive-golive_date "'20240201'
        IMPORTING
          fklmg      = <lf_mrp>-sold9.


      CALL FUNCTION 'ZMM_SALES_HISTORY'
        EXPORTING
          matnr      = <lf_mrp>-matnr
          werks      = <lf_mrp>-werks
          months     = 12
          golivedate = ls_golive-golive_date "'20240201'
        IMPORTING
          fklmg      = <lf_mrp>-sold12.
    ENDIF.

    SELECT  SINGLE ( SUM( menge ) -  SUM( bsmng ) ) AS menge  FROM eban AS e

      WHERE matnr = @<lf_mrp>-matnr AND
            werks = @<lf_mrp>-werks AND
            loekz NE 'X'
     GROUP   BY  matnr, werks   INTO @<lf_mrp>-openpr.
    IF sy-subrc = 0.
      SELECT SINGLE  banfn, bnfpo FROM eban AS e
       INTO @DATA(lt_eban)
       WHERE matnr = @<lf_mrp>-matnr AND werks      = @<lf_mrp>-werks AND loekz NE 'X'.
      IF sy-subrc = 0.

        <lf_mrp>-banfn = lt_eban-banfn.
        <lf_mrp>-bnfpo = lt_eban-bnfpo.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'ZMM_GET_OPENSO'
      EXPORTING
        matnr = <lf_mrp>-matnr
        werks = <lf_mrp>-werks
      IMPORTING
        zmeng = <lf_mrp>-openso.



    SELECT SINGLE SUM( labst ) FROM mard INTO <lf_mrp>-current_stock WHERE matnr = <lf_mrp>-matnr AND werks = <lf_mrp>-werks.


*    CALL FUNCTION 'ZMM_GET_REORDER_POINT'
*      EXPORTING
*        matnr = <lf_mrp>-matnr
*        werks = <lf_mrp>-werks
*        matkl = <lf_mrp>-matkl
*      IMPORTING
*        minbe = <lf_mrp>-reorder_point.

<lf_mrp>-reorder_point = <lf_mrp>-safty_stock.
*      IF   <lf_mrp>-reorder_point > <lf_mrp>-current_stock    .
    <lf_mrp>-expectedpr = ( <lf_mrp>-current_stock + <lf_mrp>-openpo + <lf_mrp>-openpr ) -
                          ( <lf_mrp>-reorder_point + <lf_mrp>-openso + <lf_mrp>-openposto + <lf_mrp>-openstoprqty ).

    IF <lf_mrp>-expectedpr >= 0.
      <lf_mrp>-expectedpr = 0.
    ELSE.
      <lf_mrp>-expectedpr  = <lf_mrp>-expectedpr * -1.
    ENDIF.
*      ENDIF.


  ENDLOOP.

TRY.

  MODIFY  zmm_mat_mrp FROM TABLE lt_mrp.

 CATCH CX_SY_OPEN_SQL_DB. "ERR_TX_ROLLBACK_DEADLOCK.

ENDTRY.
ELSE.
  SELECT * FROM zmm_mat_mrp INTO TABLE lt_mrp WHERE matnr IN s_matnr AND werks IN S_werks AND mtart IN s_mtart AND matkl IN s_matkl.
ENDIF.


CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
  EXPORTING
    i_structure_name       = 'ZMM_MAT_MRP'
  CHANGING
    ct_fieldcat            = it_fieldcat
  EXCEPTIONS
    inconsistent_interface = 1
    program_error          = 2
    OTHERS                 = 3.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
CLEAR wa_fieldcat.
READ TABLE it_fieldcat INTO wa_fieldcat WITH KEY fieldname = 'EXPECTEDPR'.
IF sy-subrc = 0.
  wa_fieldcat-edit = 'X'.
  MODIFY it_fieldcat FROM wa_fieldcat INDEX sy-tabix.
ENDIF.


CLEAR wa_fieldcat.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program       = sy-repid
    it_fieldcat              = it_fieldcat
    i_callback_pf_status_set = 'ZSTANDARD'
    i_callback_user_command  = 'USER_COMMAND'
    i_save                   = 'X'
    i_grid_title             = 'Parts Planning'
  TABLES
    t_outtab                 = lt_mrp
  EXCEPTIONS
    program_error            = 1
    OTHERS                   = 2.
IF sy-subrc <> 0.
ENDIF.



FORM zstandard USING rt_extab TYPE slis_t_extab..
  SET PF-STATUS 'ZSTANDARD'.
ENDFORM.                    "su_pf_status

FORM user_command USING r_ucomm  LIKE sy-ucomm
                          rs_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN '&PR1'.

      PERFORM callpr.
    WHEN '&UT'.
      MODIFY  zmm_mat_mrp FROM TABLE lt_mrp.
    WHEN '&RF'.
  ENDCASE.

ENDFORM.                    "user_command

FORM callpr .

  DATA: lt_itemdata   TYPE TABLE OF bapiebanc,
        ls_itemdata   TYPE bapiebanc,
        lt_return     TYPE TABLE OF  bapireturn,
        ltt_return    TYPE TABLE OF  bapireturn,
        ls_return     TYPE  bapireturn,
        lv_document   TYPE bapiebanc-preq_no,
        lv_banfn      TYPE eban-banfn,
        lt_cpd_plants TYPE STANDARD TABLE OF zmm_cpd_plants,
        lw_cpd_plants TYPE zmm_cpd_plants.
  SELECT region_sa cpd branch branch_cp CPD_pr FROM zmm_cpd_plants INTO TABLE lt_cpd_plants .

  CLEAR ls_mrp.

  LOOP AT lt_mrp INTO ls_mrp WHERE expectedpr > 0.
    IF ls_mrp-werks = '1100' OR  ls_mrp-werks = '1300' OR  ls_mrp-werks = '1495' OR  ls_mrp-werks = '1700' OR  ls_mrp-werks = '1201' .

      READ TABLE lt_cpd_plants INTO lw_cpd_plants WITH KEY branch = ls_mrp-werks.
      IF sy-subrc = 0.
        ls_itemdata-doc_type = lw_cpd_plants-branch_cp.
        ls_itemdata-suppl_plnt = lw_cpd_plants-cpd.
        ls_itemdata-item_cat = '7'.
      ENDIF.
      READ TABLE lt_cpd_plants INTO lw_cpd_plants WITH KEY cpd = ls_mrp-werks.
      IF sy-subrc = 0.
        ls_itemdata-doc_type = lw_cpd_plants-cpd_pr.
      ENDIF.
      ls_itemdata-created_by = sy-uname.
      ls_itemdata-material_long = ls_mrp-matnr.

      IF ls_mrp-werks+0(1) = 1.
        ls_itemdata-pur_group = '103'.
      ELSE.
        ls_itemdata-pur_group = '203'.
      ENDIF.
      ls_itemdata-quantity = ls_mrp-expectedpr.
      ls_itemdata-deliv_date = sy-datum.
      ls_itemdata-plant = ls_mrp-werks.
      APPEND ls_itemdata TO lt_itemdata.
      CLEAR ls_mrp-expectedpr.
      MODIFY lt_mrp FROM ls_mrp.
    ENDIF.
  ENDLOOP.

  IF lt_itemdata IS NOT INITIAL.
    CALL FUNCTION 'BAPI_REQUISITION_CREATE'
      TABLES
        requisition_items = lt_itemdata
        return            = lt_return.
    MOVE lt_return TO ltt_return.
    MODIFY  zmm_mat_mrp FROM TABLE lt_mrp.
  ENDIF.
  CLEAR :lt_itemdata[],lvindex..

  LOOP AT lt_mrp INTO ls_mrp WHERE expectedpr > 0. " '0'.
    IF ls_mrp-werks = '1100' OR  ls_mrp-werks = '1300' OR  ls_mrp-werks = '1495' OR  ls_mrp-werks = '1700' OR  ls_mrp-werks = '1201' .
      CONTINUE.
    ELSE.
      lvindex = lvindex + 1.
      IF lvindex > 500.
        EXIT.
      ENDIF.
      READ TABLE lt_cpd_plants INTO lw_cpd_plants WITH KEY branch = ls_mrp-werks.
      IF sy-subrc = 0.
        ls_itemdata-doc_type = lw_cpd_plants-branch_cp.
        ls_itemdata-suppl_plnt = lw_cpd_plants-cpd.
        ls_itemdata-item_cat = '7'.
      ENDIF.
      READ TABLE lt_cpd_plants INTO lw_cpd_plants WITH KEY cpd = ls_mrp-werks.
      IF sy-subrc = 0.
        ls_itemdata-doc_type = lw_cpd_plants-cpd_pr.
      ENDIF.
      ls_itemdata-created_by = sy-uname.
      ls_itemdata-material_long = ls_mrp-matnr.

      IF ls_mrp-werks+0(1) = 1.
        ls_itemdata-pur_group = '103'.
      ELSE.
        ls_itemdata-pur_group = '203'.
      ENDIF.
      ls_itemdata-quantity = ls_mrp-expectedpr.
      ls_itemdata-deliv_date = sy-datum.
      ls_itemdata-plant = ls_mrp-werks.
      APPEND ls_itemdata TO lt_itemdata.
      CLEAR ls_mrp-expectedpr.
      MODIFY lt_mrp FROM ls_mrp.

    ENDIF.

  ENDLOOP.

  IF lt_itemdata IS NOT INITIAL.
    CALL FUNCTION 'BAPI_REQUISITION_CREATE'
      TABLES
        requisition_items = lt_itemdata
        return            = lt_return.

    APPEND LINES OF lt_return TO ltt_return.
    CLEAR lt_return.
    MODIFY  zmm_mat_mrp FROM TABLE lt_mrp.
  ENDIF.



  COMMIT WORK.
  CALL FUNCTION 'ZMM_ALV_POPUP'
    EXPORTING
      i_start_column = 5
      i_start_line   = 5
      i_end_column   = 200
      i_end_line     = 100
      i_title        = 'ALV'
      i_popup        = 'X'
    TABLES
      it_alv         = ltt_return.
ENDFORM.
