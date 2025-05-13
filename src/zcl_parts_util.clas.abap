CLASS zcl_parts_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tt_materials TYPE TABLE OF matnr .
    TYPES:
      tt_werks TYPE TABLE OF werks_d .
    TYPES:
      tt_werks_range TYPE RANGE OF werks_d .
    TYPES:
      BEGIN OF ty_sales_hist,
        vbeln TYPE vbeln,
        posnr TYPE posnr,
        fkimg TYPE fkimg,
        matnr TYPE matnr,
        werks TYPE werks_d,
        fkdat TYPE fkdat,
      END OF ty_sales_hist .
    TYPES:
      BEGIN OF ty_mat_plant_qty,
        matnr TYPE matnr,
        werks TYPE werks_d,
        qty   TYPE menge_d,
      END OF ty_mat_plant_qty .
    TYPES:
      tt_mat_plant_qty TYPE TABLE OF  ty_mat_plant_qty .
    TYPES:
      BEGIN OF ty_open_sto,
        matnr           TYPE matnr,
        receiving_plant TYPE werks_d,
        supplying_plant TYPE werks_d,
        qty             TYPE menge_d,
      END OF ty_open_sto .
    TYPES:
      tt_open_sto TYPE TABLE OF ty_open_sto .
    TYPES:
      tt_sales_hist TYPE TABLE OF ty_sales_hist .
    TYPES:
      BEGIN OF ty_sales_hist_mseg,
        fkimg TYPE fkimg,
        matnr TYPE matnr,
        werks TYPE werks_d,
        fkdat TYPE fkdat,
        bwart TYPE bwart,
      END OF ty_sales_hist_mseg .
    TYPES:
      BEGIN OF ty_sales_hist_mseg1,
        mblnr TYPE mblnr,
        mjahr TYPE mjahr,
        zeile TYPE mblpo,
        fkimg TYPE fkimg,
        matnr TYPE matnr,
        werks TYPE werks_d,
        fkdat TYPE fkdat,
        bwart TYPE bwart,
      END OF ty_sales_hist_mseg1 .
    TYPES:
      tt_sales_hist_mseg TYPE TABLE OF ty_sales_hist_mseg .

    CLASS-METHODS get_sales_history
      IMPORTING
        !it_material   TYPE tt_materials
      EXPORTING
        !et_sales_curr TYPE tt_sales_hist
        !et_sales_3    TYPE tt_sales_hist
        !et_sales_12   TYPE tt_sales_hist .
    CLASS-METHODS get_sales_hist_mseg
      IMPORTING
        !it_material   TYPE tt_materials
      EXPORTING
        !et_sales_curr TYPE tt_sales_hist_mseg
        !et_sales_3    TYPE tt_sales_hist_mseg
        !et_sales_6    TYPE tt_sales_hist_mseg
        !et_sales_12   TYPE tt_sales_hist_mseg .
    CLASS-METHODS get_open_po_qty
      IMPORTING
        !it_material TYPE tt_materials
        !it_werks    TYPE tt_werks
      EXPORTING
        !et_open_po  TYPE tt_mat_plant_qty .
    CLASS-METHODS get_available_qty
      IMPORTING
        !it_material      TYPE tt_materials
        !it_plant         TYPE tt_werks
      EXPORTING
        !et_available_qty TYPE tt_mat_plant_qty .
    CLASS-METHODS get_open_ord_qty
      IMPORTING
        !it_material TYPE tt_materials
        !it_plant    TYPE tt_werks
      EXPORTING
        !et_open_so  TYPE tt_mat_plant_qty
        !et_open_ro  TYPE tt_mat_plant_qty .
    CLASS-METHODS get_open_sto_qty
      IMPORTING
        !it_material        TYPE tt_materials
        !it_plant           TYPE tt_werks_range
        !it_supplying_plant TYPE tt_werks_range
      EXPORTING
        !et_open_sto_qty    TYPE tt_open_sto .
protected section.
private section.
ENDCLASS.



CLASS ZCL_PARTS_UTIL IMPLEMENTATION.


  METHOD get_available_qty.
    TYPES : BEGIN OF ty_resb_f,
              matnr TYPE resb-matnr,
              werks TYPE resb-werks,
*          lgort TYPE resb-lgort,
              bdmng TYPE resb-bdmng,
            END OF ty_resb_f.

    DATA: lt_werks     TYPE RANGE OF werks_d,
          ls_werks     LIKE LINE OF lt_werks,
          ls_resb_f    TYPE ty_resb_f,
          lt_resb_f    TYPE HASHED TABLE OF ty_resb_f WITH UNIQUE KEY matnr werks,
          ls_avail_qty TYPE ty_mat_plant_qty.

    FIELD-SYMBOLS: <fs_avail_qty> LIKE LINE OF et_available_qty.

    LOOP AT it_plant INTO DATA(lv_werks).
      ls_werks-sign = 'I'.
      ls_werks-option = 'EQ'.
      ls_werks-low = lv_werks.
      APPEND ls_werks TO lt_werks.
    ENDLOOP.

    SELECT matnr, werks, labst FROM mard
     INTO  TABLE @DATA(lt_mard)
     FOR ALL ENTRIES IN @it_material
     WHERE matnr = @it_material-table_line
       AND werks IN @lt_werks
       AND lgort = 'P001'.
    IF sy-subrc = 0 AND lt_mard IS NOT INITIAL.
      SELECT rsnum,
             rspos,
             matnr,
             werks,
             lgort,
             bdmng,
             shkzg
        FROM resb INTO TABLE @DATA(lt_resb)
                   FOR ALL ENTRIES IN @lt_mard
                   WHERE matnr EQ @lt_mard-matnr AND
                         werks EQ @lt_mard-werks AND
                         lgort EQ 'P001' AND
                         kzear NE 'X'.
      IF lt_resb IS NOT INITIAL.
        LOOP AT lt_resb  INTO DATA(ls_resb) .
          MOVE-CORRESPONDING ls_resb TO ls_resb_f.
          COLLECT ls_resb_f INTO lt_resb_f.
        ENDLOOP.
      ENDIF.
    ENDIF.

    LOOP AT lt_mard INTO DATA(ls_mard).
      ls_avail_qty-matnr = ls_mard-matnr.
      ls_avail_qty-werks = ls_mard-werks.

      READ TABLE lt_resb_f INTO ls_resb_f
        WITH KEY matnr = ls_mard-matnr
                 werks = ls_mard-werks.
      IF sy-subrc = 0.
        ls_avail_qty-qty = ls_mard-labst - ls_resb_f-bdmng.
      ELSE.
        ls_avail_qty-qty = ls_mard-labst.
      ENDIF.

      IF ls_avail_qty-qty LT 0.
        ls_avail_qty-qty = 0.
      ENDIF.
      APPEND ls_avail_qty TO et_available_qty.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_open_ord_qty.
    DATA: lt_werks TYPE RANGE OF werks_d,
          ls_werks LIKE LINE OF lt_werks.

    LOOP AT it_plant INTO DATA(lv_werks).
      ls_werks-sign = 'I'.
      ls_werks-option = 'EQ'.
      ls_werks-low = lv_werks.
      APPEND ls_werks TO lt_werks.
    ENDLOOP.

*BDTER  need to check date range to be include in this query
    SELECT rsnum,
         rspos,
         matnr,
         werks,
         lgort,
         bdmng,
         shkzg
         FROM resb INTO TABLE @DATA(lt_resb)
                         FOR ALL ENTRIES IN @it_material
                         WHERE matnr EQ @it_material-table_line AND
                               werks IN @lt_werks AND
*                                     lgort EQ it_mard-lgort AND
                               kzear NE 'X'.
    IF sy-subrc = 0 AND lt_resb IS NOT INITIAL.
      LOOP AT lt_resb INTO DATA(ls_resb).
        IF ls_resb-shkzg = 'S'.
          READ TABLE et_open_ro ASSIGNING FIELD-SYMBOL(<fs_open_ro>)
            WITH KEY matnr = ls_resb-matnr werks = ls_resb-werks.
          IF sy-subrc <> 0.
            APPEND INITIAL LINE TO et_open_ro ASSIGNING <fs_open_ro>.
            MOVE-CORRESPONDING ls_resb TO <fs_open_ro>.
          ENDIF.
          <fs_open_ro>-qty = <fs_open_ro>-qty + ls_resb-bdmng.
        ELSE.
          READ TABLE et_open_so ASSIGNING FIELD-SYMBOL(<fs_open_so>)
            WITH KEY matnr = ls_resb-matnr werks = ls_resb-werks.
          IF sy-subrc <> 0.
            APPEND INITIAL LINE TO et_open_so ASSIGNING <fs_open_so>.
            MOVE-CORRESPONDING ls_resb TO <fs_open_so>.
          ENDIF.
          <fs_open_so>-qty = <fs_open_so>-qty + ls_resb-bdmng.
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.


  METHOD get_open_po_qty.
    DATA: lt_werks TYPE RANGE OF werks_d,
          ls_werks LIKE LINE OF lt_werks.

    TYPES: BEGIN OF ty_ekpo,
             ebeln TYPE ekpo-ebeln,
             ebelp TYPE ekpo-ebelp,
             matnr TYPE ekpo-matnr,
             menge TYPE ekpo-menge,
             werks TYPE ekpo-werks,
             lgort TYPE ekpo-lgort,
             vgbel TYPE lips-vgbel,
             vgpos TYPE lips-vgpos,
             lfimg TYPE lips-lfimg,
           END OF ty_ekpo.

    DATA: lt_ekpo_lips TYPE STANDARD TABLE OF ty_ekpo,
          lw_ekpo_lips TYPE ty_ekpo.

    CLEAR: lt_ekpo_lips,lw_ekpo_lips.
    FIELD-SYMBOLS: <fs_open_po> LIKE LINE OF et_open_po.

    LOOP AT it_werks INTO DATA(lv_werks).
      ls_werks-sign = 'I'.
      ls_werks-option = 'EQ'.
      ls_werks-low = lv_werks.
      APPEND ls_werks TO lt_werks.
    ENDLOOP.

    IF it_material IS NOT INITIAL.
      SELECT ekpo~ebeln,
         ekpo~ebelp,
         ekpo~loekz,
         ekpo~matnr,
         ekpo~menge,
         ekpo~werks,
         ekpo~lgort FROM ekpo INNER JOIN ekko
               ON ekpo~ebeln = ekko~ebeln
               INTO TABLE @DATA(lt_ekpo)
                FOR ALL ENTRIES IN @it_material
                WHERE ekko~bsakz EQ '' AND    "added by ismail
                      ekpo~loekz EQ '' AND
                      ekpo~matnr EQ @it_material-table_line AND
                      ekpo~werks IN @lt_werks AND
                      ekpo~elikz NE 'X' ."and

      IF sy-subrc = 0 AND lt_ekpo IS NOT INITIAL.
        DELETE lt_ekpo WHERE loekz NE ''.

*--to fetch
        SELECT ebeln,
         ebelp,
         bwart,
         menge,
         shkzg FROM ekbe
              INTO TABLE @DATA(lt_ekbe)
              FOR ALL ENTRIES IN @lt_ekpo
              WHERE ebeln EQ @lt_ekpo-ebeln AND
                    ebelp EQ @lt_ekpo-ebelp AND
                    bewtp EQ 'E'.
      ENDIF.
    ENDIF.

    LOOP AT lt_ekpo INTO DATA(ls_ekpo).
      UNASSIGN: <fs_open_po>.
      READ TABLE et_open_po ASSIGNING <fs_open_po>
        WITH KEY matnr = ls_ekpo-matnr werks = ls_ekpo-werks.
      IF sy-subrc <> 0 OR <fs_open_po> IS NOT ASSIGNED.
        APPEND INITIAL LINE TO et_open_po ASSIGNING <fs_open_po>.
        <fs_open_po>-matnr = ls_ekpo-matnr.
        <fs_open_po>-werks = ls_ekpo-werks.
      ENDIF.


      <fs_open_po>-qty = <fs_open_po>-qty + ls_ekpo-menge.


      LOOP AT lt_ekbe INTO DATA(ls_ekbe) WHERE ebeln EQ ls_ekpo-ebeln AND
                                         ebelp EQ ls_ekpo-ebelp.
        IF ls_ekbe-shkzg EQ 'S'.
          <fs_open_po>-qty = <fs_open_po>-qty - ls_ekbe-menge.
        ELSE.
          <fs_open_po>-qty = <fs_open_po>-qty + ls_ekbe-menge.
        ENDIF.

      ENDLOOP.


    ENDLOOP.
  ENDMETHOD.


  METHOD get_open_sto_qty.
    FIELD-SYMBOLS: <fs_open_sto> LIKE LINE OF et_open_sto_qty.

    CHECK it_material IS NOT INITIAL.

    TYPES: BEGIN OF ty_ekpo,
             ebeln TYPE ekpo-ebeln,
             ebelp TYPE ekpo-ebelp,
             matnr TYPE ekpo-matnr,
             menge TYPE ekpo-menge,
             werks TYPE ekpo-werks,
             lgort TYPE ekpo-lgort,
             vgbel TYPE lips-vgbel,
             vgpos TYPE lips-vgpos,
             lfimg TYPE lips-lfimg,
           END OF ty_ekpo.


    DATA: lv_bewtp TYPE bewtp.

    DESCRIBE TABLE it_plant LINES DATA(lv_lines).
    CLEAR: lv_bewtp.
    IF lv_lines = 1.  " This means STO TO giving plant
      lv_bewtp = 'U'.
    ELSEIF lv_lines GT 1. "" This means STO from giving plant
      lv_bewtp = 'E'.
    ENDIF.
*--------------note ..need to add date range till on year..

    SELECT
      ekko~reswk,
      ekpo~ebeln,
      ekpo~ebelp ,
      ekpo~loekz,
      ekpo~matnr,
      ekpo~menge,
      ekpo~werks,
      ekpo~lgort FROM ekko INNER JOIN ekpo
      ON ekko~ebeln = ekpo~ebeln
      INTO TABLE @DATA(lt_po)
      FOR ALL ENTRIES IN @it_material
      WHERE
            ekko~bsakz EQ 'T' AND
            ekko~reswk IN @it_supplying_plant
        AND ekko~bstyp EQ 'F'
        AND ekko~frgke EQ 'R'
        AND ekpo~loekz EQ ''
        AND ekpo~matnr EQ @it_material-table_line
        AND ekpo~werks IN @it_plant
        AND ekpo~elikz NE 'X'.
    IF sy-subrc = 0 AND lt_po IS NOT INITIAL.

      DELETE lt_po WHERE loekz NE ''.

*--to fetch
      SELECT ebeln,
       ebelp,
       bwart,
       menge,
       shkzg FROM ekbe
            INTO TABLE @DATA(lt_ekbe)
            FOR ALL ENTRIES IN @lt_po
            WHERE ebeln EQ @lt_po-ebeln AND
                  ebelp EQ @lt_po-ebelp AND
*                bewtp EQ 'E'.
                  bewtp EQ @lv_bewtp.
    ENDIF.

    LOOP AT lt_po INTO DATA(ls_po).
      UNASSIGN: <fs_open_sto>.
      READ TABLE et_open_sto_qty ASSIGNING <fs_open_sto>
        WITH KEY matnr = ls_po-matnr receiving_plant = ls_po-werks supplying_plant = ls_po-reswk.
      IF sy-subrc <> 0 OR <fs_open_sto> IS NOT ASSIGNED.
        APPEND INITIAL LINE TO et_open_sto_qty ASSIGNING <fs_open_sto>.
        <fs_open_sto>-matnr = ls_po-matnr.
        <fs_open_sto>-receiving_plant = ls_po-werks.
        <fs_open_sto>-supplying_plant = ls_po-reswk.
      ENDIF.


      <fs_open_sto>-qty = <fs_open_sto>-qty + ls_po-menge.


      LOOP AT lt_ekbe INTO DATA(ls_ekbe) WHERE ebeln EQ ls_po-ebeln AND
                                         ebelp EQ ls_po-ebelp.

        IF lv_bewtp = 'E' .
          IF ls_ekbe-shkzg EQ 'S'.
            <fs_open_sto>-qty = <fs_open_sto>-qty - ls_ekbe-menge.
          ELSE.
            <fs_open_sto>-qty = <fs_open_sto>-qty + ls_ekbe-menge.
          ENDIF.
        ELSE.
          IF ls_ekbe-shkzg EQ 'H'.
            <fs_open_sto>-qty = <fs_open_sto>-qty - ls_ekbe-menge.
          ELSE.
            <fs_open_sto>-qty = <fs_open_sto>-qty + ls_ekbe-menge.
          ENDIF.
        ENDIF.
      ENDLOOP.


    ENDLOOP.
  ENDMETHOD.


  METHOD get_sales_history.
    DATA: lv_today_date  TYPE dats,
          lv_3mons_back  TYPE dats,
          lv_month_start TYPE dats,
          lv_12mons_back TYPE dats,
          lt_hist_data   TYPE tt_sales_hist,
          ls_hist_data   TYPE ty_sales_hist,
          lt_material    TYPE tt_materials.

    FIELD-SYMBOLS: <fs_hist>   TYPE ty_sales_hist.

*...<< Reading Sales history data >>
    lv_today_date = sy-datum.
    CONCATENATE sy-datum(6) '01' INTO lv_month_start.

    CALL FUNCTION 'CCM_GO_BACK_MONTHS'
      EXPORTING
        currdate   = lv_month_start
        backmonths = '3'
      IMPORTING
        newdate    = lv_3mons_back.

    CALL FUNCTION 'CCM_GO_BACK_MONTHS'
      EXPORTING
        currdate   = lv_month_start
        backmonths = '12'
      IMPORTING
        newdate    = lv_12mons_back.

    lt_material = it_material.
    SORT lt_material.
    DELETE ADJACENT DUPLICATES FROM lt_material COMPARING ALL FIELDS.
    DELETE lt_material WHERE table_line IS INITIAL.

    IF lt_material IS NOT INITIAL.
*    CR 8100001745: Add key fields to ensure all relevant records are fetched
      SELECT i~vbeln i~posnr i~fkimg i~matnr i~werks h~fkdat FROM vbrp AS i
        INNER JOIN vbrk AS h ON i~vbeln = h~vbeln
        INTO TABLE lt_hist_data
        FOR ALL ENTRIES IN lt_material
        WHERE i~matnr = lt_material-table_line
          AND h~vbtyp = 'M'
          AND h~fksto = ''
          AND h~fkdat GE lv_12mons_back
          AND h~fkdat LE lv_today_date
          AND i~/dbe/splnr = 1. "CR 8100001791
      IF sy-subrc = 0.
        LOOP AT lt_hist_data INTO ls_hist_data.
          IF ls_hist_data-fkdat LT lv_month_start.
            READ TABLE et_sales_12 ASSIGNING <fs_hist>
              WITH KEY matnr = ls_hist_data-matnr
                       werks = ls_hist_data-werks.
            IF sy-subrc = 0.
              <fs_hist>-fkimg = <fs_hist>-fkimg + ls_hist_data-fkimg.
            ELSE.
              APPEND ls_hist_data TO et_sales_12.
            ENDIF.
          ENDIF.

          IF ls_hist_data-fkdat GE lv_3mons_back
            AND ls_hist_data-fkdat LT lv_month_start.
            READ TABLE et_sales_3 ASSIGNING <fs_hist>
              WITH KEY matnr = ls_hist_data-matnr
                       werks = ls_hist_data-werks.
            IF sy-subrc = 0.
              <fs_hist>-fkimg = <fs_hist>-fkimg + ls_hist_data-fkimg.
            ELSE.
              APPEND ls_hist_data TO et_sales_3.
            ENDIF.
          ENDIF.

          IF ls_hist_data-fkdat GE lv_month_start.
            READ TABLE et_sales_curr ASSIGNING <fs_hist>
              WITH KEY matnr = ls_hist_data-matnr
                       werks = ls_hist_data-werks.
            IF sy-subrc = 0.
              <fs_hist>-fkimg = <fs_hist>-fkimg + ls_hist_data-fkimg.
            ELSE.
              APPEND ls_hist_data TO et_sales_curr.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD get_sales_hist_mseg.
    DATA: lv_today_date  TYPE dats,
          lv_3mons_back  TYPE dats,
          lv_6mons_back  TYPE dats,
          lv_month_start TYPE dats,
          lv_12mons_back TYPE dats,
          lt_hist_data   TYPE TABLE OF ty_sales_hist_mseg1,
          ls_hist_data   TYPE ty_sales_hist_mseg,
          ls_hist_data1  TYPE ty_sales_hist_mseg1,
          lt_material    TYPE tt_materials.

    FIELD-SYMBOLS: <fs_hist>   TYPE ty_sales_hist_mseg.

*...<< Reading Sales history data >>
    lv_today_date = sy-datum.
    CONCATENATE sy-datum(6) '01' INTO lv_month_start.

    CALL FUNCTION 'CCM_GO_BACK_MONTHS'
      EXPORTING
        currdate   = lv_month_start
        backmonths = '3'
      IMPORTING
        newdate    = lv_3mons_back.

    CALL FUNCTION 'CCM_GO_BACK_MONTHS'
      EXPORTING
        currdate   = lv_month_start
        backmonths = '6'
      IMPORTING
        newdate    = lv_6mons_back.

    CALL FUNCTION 'CCM_GO_BACK_MONTHS'
      EXPORTING
        currdate   = lv_month_start
        backmonths = '12'
      IMPORTING
        newdate    = lv_12mons_back.

    lt_material = it_material.
    SORT lt_material.
    DELETE ADJACENT DUPLICATES FROM lt_material COMPARING ALL FIELDS.
    DELETE lt_material WHERE table_line IS INITIAL.

    IF lt_material IS NOT INITIAL.
*    CR 8100001745: Add key fields to ensure all relevant records are fetched
      SELECT mseg~mblnr mseg~mjahr mseg~zeile mseg~erfmg mseg~matnr mseg~werks mkpf~budat mseg~bwart
        FROM mkpf INNER JOIN mseg
          ON mkpf~mandt = mseg~mandt
         AND mkpf~mblnr = mseg~mblnr
         AND mkpf~mjahr = mseg~mjahr
        INTO TABLE lt_hist_data
        FOR ALL ENTRIES IN lt_material
        WHERE mkpf~budat GE lv_12mons_back
          AND mkpf~budat LE lv_today_date
          AND mseg~bwart IN ( '261' , '262' , 'Z61' , 'Z62' )
          AND mseg~matnr = lt_material-table_line.
*        AND mseg~lgort = 'P001'. "commented by ismail
      IF sy-subrc = 0.
        LOOP AT lt_hist_data INTO ls_hist_data1.
          MOVE-CORRESPONDING ls_hist_data1 TO ls_hist_data.
          IF ls_hist_data-bwart = '262' OR ls_hist_data-bwart = 'Z61'.
            ls_hist_data-fkimg = ls_hist_data-fkimg * -1.
          ENDIF.

          IF ls_hist_data-fkdat LT lv_month_start.
            READ TABLE et_sales_12 ASSIGNING <fs_hist>
              WITH KEY matnr = ls_hist_data-matnr
                       werks = ls_hist_data-werks.
            IF sy-subrc = 0.
              <fs_hist>-fkimg = <fs_hist>-fkimg + ls_hist_data-fkimg.
            ELSE.
              APPEND ls_hist_data TO et_sales_12.
            ENDIF.
          ENDIF.

          IF ls_hist_data-fkdat GE lv_6mons_back
            AND ls_hist_data-fkdat LT lv_month_start.
            READ TABLE et_sales_6 ASSIGNING <fs_hist>
              WITH KEY matnr = ls_hist_data-matnr
                       werks = ls_hist_data-werks.
            IF sy-subrc = 0.
              <fs_hist>-fkimg = <fs_hist>-fkimg + ls_hist_data-fkimg.
            ELSE.
              APPEND ls_hist_data TO et_sales_6.
            ENDIF.
          ENDIF.

          IF ls_hist_data-fkdat GE lv_3mons_back
            AND ls_hist_data-fkdat LT lv_month_start.
            READ TABLE et_sales_3 ASSIGNING <fs_hist>
              WITH KEY matnr = ls_hist_data-matnr
                       werks = ls_hist_data-werks.
            IF sy-subrc = 0.
              <fs_hist>-fkimg = <fs_hist>-fkimg + ls_hist_data-fkimg.
            ELSE.
              APPEND ls_hist_data TO et_sales_3.
            ENDIF.
          ENDIF.

          IF ls_hist_data-fkdat GE lv_month_start.
            READ TABLE et_sales_curr ASSIGNING <fs_hist>
              WITH KEY matnr = ls_hist_data-matnr
                       werks = ls_hist_data-werks.
            IF sy-subrc = 0.
              <fs_hist>-fkimg = <fs_hist>-fkimg + ls_hist_data-fkimg.
            ELSE.
              APPEND ls_hist_data TO et_sales_curr.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
