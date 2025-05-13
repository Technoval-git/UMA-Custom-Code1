*&---------------------------------------------------------------------*
*& Report ZR_TAB_UPLD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_tab_upld.

PARAMETERS: p_file TYPE string.
DATA :lw_ZRIMI TYPE zrimi.
DATA lww_zrimi TYPE zrimi.
DATA :lw_ZRIMh TYPE zrimh.
DATA :lt_zrimh TYPE STANDARD TABLE OF zrimh.
DATA :lt_zrimi TYPE STANDARD TABLE OF zrimi.
DATA :ltt_zrimi TYPE STANDARD TABLE OF zrimi.

TYPES: BEGIN OF ty_ClubPart,
         Club_Part(18) TYPE c,
       END OF ty_ClubPart.
data: ls_clubPart type ty_ClubPart,
      lt_clubParts type Table of ty_ClubPart.

DATA syindex TYPE syst-tabix.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  DATA: lt_filetable TYPE filetable,
        lv_rc        TYPE i.


  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    CHANGING
      file_table = lt_filetable
      rc         = lv_rc.

  IF lv_rc > 0.
    p_file = lt_filetable[ 1 ].
  ENDIF.

START-OF-SELECTION.
  DATA: lt_list       TYPE STANDARD TABLE OF abaplist.
  "DATA: txtlines TYPE zty_dwi WITH HEADER LINE. "(3000)
  TYPES: BEGIN OF zstring_table,
           string1(30000) TYPE c,
         END OF zstring_table.

  FIELD-SYMBOLS: <fs_field> TYPE any.

  DATA : llt_DWI       TYPE TABLE OF zstring_table,
         lt_fields     TYPE TABLE OF string,
         lt_final      TYPE TABLE OF zty_dwi, " Final structured table
         lr_struct     TYPE REF TO cl_abap_structdescr,
         lt_header     TYPE TABLE OF string, " Table to store header fields
         zmain_header  TYPE zrimh, " Table to store header fields
         zmain_Item    LIKE zrimi, " Table to store header fields
         ls_final      TYPE zty_dwi, " Work area for structured data
         lv_line       TYPE string,
         lv_index      TYPE i,
         lv_field_name TYPE string,
         lt_components TYPE abap_compdescr_tab,
         ls_component  TYPE LINE OF abap_compdescr_tab.


  DATA: lt_data TYPE TABLE OF string,
        lv_data TYPE string.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename = p_file
      filetype = 'ASC'
    CHANGING
      data_tab = llt_DWI.


******    READ TABLE llt_DWI INDEX 1 INTO lv_line. " Read the header row
******
******    CONDENSE lv_line.
******
******
******    CONCATENATE '110' lv_line  into lv_line SEPARATED BY ' '.
******
******    SPLIT lv_line AT ' ' INTO TABLE lt_header.
******
******" Get structure components dynamically
******lr_struct ?= cl_abap_typedescr=>describe_by_data( zmain_header ).
******lt_components = lr_struct->components.

  CLEAR syindex.
  LOOP AT llt_DWI INTO DATA(lw_data) .


    IF sy-tabix = 1.

      lw_ZRIMh-mandt = sy-mandt.
      lw_ZRIMh-zr_main = lw_data+0(54).
      lw_ZRIMh-zr_sapinv =  'X' .
      lw_ZRIMh-zr_oeminv = lw_data+12(9).
      lw_ZRIMh-zr_subtpa = lw_data+65(16).
      lw_ZRIMh-zr_insur = lw_data+81(15).
      lw_ZRIMh-zr_frght = lw_data+96(15).
      lw_ZRIMh-zr_subtdv = lw_data+111(15).
      lw_ZRIMh-zr_duty = lw_data+126(15).
*lw_data-ZR_VAT = LW_DATA+
      lw_ZRIMh-zr_invttl = lw_data+141(15).
      lw_ZRIMh-zr_currnc = lw_data+156(4).
      APPEND lw_zrimh TO lt_zrimh.

      MODIFY  zrimh FROM TABLE lt_zrimh.
*      INSERT lw_ZRIMh INTO TABLE zrimh.

    ELSE.

      IF lw_data-string1+0(2) = '99'.
        CONTINUE.
      ENDIF.
      syindex = syindex + 1.
      lw_zrimi-mandt = sy-mandt.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = lw_data-string1+82(18)
        IMPORTING
          output = lw_ZRIMI-zr_gm_dprt.
      IF lw_ZRIMI-zr_gm_dprt IS NOT INITIAL.
        lw_ZRIMI-zr_uma_dpr = 'GM' && lw_ZRIMI-zr_gm_dprt.
      ENDIF.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = lw_data-string1+100(18)
        IMPORTING
          output = lw_ZRIMI-zr_sup_gmp.

      IF lw_ZRIMI-zr_sup_gmp IS NOT INITIAL.
        lw_ZRIMI-zr_sup_uma = 'GM' && lw_ZRIMI-zr_sup_gmp.
      ENDIF.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = lw_data-string1+118(18)
        IMPORTING
          output = lw_ZRIMI-zr_gm_oprt.
      IF lw_ZRIMI-zr_gm_oprt IS NOT INITIAL.
        lw_ZRIMI-zr_uma_opr = 'GM' && lw_ZRIMI-zr_gm_oprt.
      ENDIF.
      lw_ZRIMI-zr_main = lw_ZRIMh-zr_main. "lw_data-string1+0(56).
      lw_ZRIMI-zr_main_i = lw_data-string1+0(56). " lw_data-string1+56(26).
      lw_ZRIMI-zr_main_n = syindex.
      lw_ZRIMI-zr_uma_ref = lw_data-string1+44(13).
      lw_ZRIMI-zr_gm_ordr = lw_data-string1+9(9).
*  lw_ZRIMI-ZR_GM_DPRT = LW_DATA-STRING1+82(18).
*  lw_ZRIMI-ZR_UMA_DPR = LW_DATA-STRING1+136(13)
*  lw_ZRIMI-ZR_SUP_GMP = LW_DATA-STRING1+149(12)
*  lw_ZRIMI-ZR_SUP_UMA = LW_DATA-STRING1+161(13)
*  lw_ZRIMI-ZR_GM_OPRT = LW_DATA-STRING1+174(4)
*  lw_ZRIMI-ZR_UMA_OPR = LW_DATA-STRING1+178(12)
      lw_ZRIMI-zr_qty0001 = lw_data-string1+136(13) .
      lw_ZRIMI-zr_unit_pr = lw_data-string1+149(12).
      lw_ZRIMI-zr_tot_pr = lw_data-string1+161(13).
      lw_ZRIMI-zr_curr000 = lw_data-string1+174(4).
      lw_ZRIMI-zr_box_id = lw_data-string1+178(12).
      lw_ZRIMI-zr_cour_sc = lw_data-string1+190(12).
      lw_ZRIMI-zr_t_cour = lw_data-string1+202(13).
      lw_ZRIMI-zr_ref0001 = lw_data-string1+215(11).
      lw_ZRIMI-zr_part_d = lw_data-string1+244(40).
      lw_ZRIMI-zr_harm_cd = lw_data-string1+284(8).
      lw_ZRIMI-zr_country = lw_data-string1+301(15).
      lw_ZRIMI-zr_sap_inv = 'X'.
      APPEND lw_zrimi TO lt_zrimi.
      CLEAR lw_zrimi.
    ENDIF.


  ENDLOOP.
****ltt_zrimi[] = lt_zrimi[].
****
****sort lt_zrimi by zr_main zr_main_i .
****syindex = 1.
****
****loop at lt_zrimi into lw_zrimi.
****
**** READ TABLE ltt_zrimi into lww_zrimi with key zr_main   = lw_zrimi-zr_main
****                                              zr_main_i = lw_zrimi-zr_main_i.
****  if lw_zrimi-zr_main = lww_zrimi-zr_main  and lw_zrimi-zr_main_i = lww_zrimi-zr_main_i.
****  syindex = syindex + 1.
****  else .
****  syindex = 1.
****  endif.
****
****   lw_zrimi-zr_main_n = syindex.
****  move lw_zrimi to lww_zrimi.
****
****
****endloop.
  MODIFY  ZRIMi FROM TABLE lt_zrimi.
****
****" Assign values dynamically to zmain_header
****lv_index = 1.
****LOOP AT lt_components INTO ls_component.
****  READ TABLE lt_header INDEX lv_index INTO lv_field_name.
****  IF sy-subrc = 0.
****    ASSIGN zmain_header-(ls_component-name) TO <fs_field>.
****    IF sy-subrc = 0.
****      <fs_field> = lv_field_name.  " Assign header values to structure fields
****    ENDIF.
****  ENDIF.
****  lv_index = lv_index + 1.
****ENDLOOP.
****
****
****
****DELETE llt_DWI INDEX 1. " Remove header row
**** LOOP AT llt_DWI INTO lv_line.
****
****  " Split the line into fields
****  SPLIT lv_line AT '    ' INTO TABLE lt_fields.
****
****  " Populate structure
****   CLEAR ls_final.
****  " Append to final table
****  APPEND ls_final TO lt_final.
****ENDLOOP.
  LOOP AT lt_zrimi INTO DATA(ls_zrimi).
    IF ls_zrimi-zr_uma_dpr is not INITIAL and ls_zrimi-zr_uma_dpr <> ls_zrimi-zr_sup_uma.
      ls_clubpart-club_part = ls_zrimi-zr_uma_dpr.
      append ls_clubpart to lt_clubparts.
      clear ls_clubpart-club_part.
    ENDIF.
    IF ls_zrimi-zr_sup_uma is not INITIAL and ls_zrimi-zr_sup_uma <> ls_zrimi-zr_uma_dpr.
      ls_clubpart-club_part = ls_zrimi-zr_sup_uma.
      append ls_clubpart to lt_clubparts.
      clear ls_clubpart-club_part.
    ENDIF.
  ENDLOOP.

  delete ADJACENT DUPLICATES FROM lt_clubparts COMPARING ALL FIELDS.
  clear ls_clubpart.
  LOOP AT lt_clubparts into ls_clubpart.

    select SINGLE matnr from mara into @data(existingPart) where matnr = @ls_clubpart-club_part.
    IF sy-subrc <> 0 .
      write  / |Parts to be Uploded { ls_clubpart-club_part } |.
      "Upload here
    else.
      write: / existingPart, 'already exists' .
    ENDIF.

  ENDLOOP.
