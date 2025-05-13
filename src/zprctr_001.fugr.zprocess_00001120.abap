FUNCTION zprocess_00001120.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_BKDF) TYPE  BKDF OPTIONAL
*"  TABLES
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEG STRUCTURE  BSEG
*"      T_BKPFSUB STRUCTURE  BKPF_SUBST
*"      T_BSEGSUB STRUCTURE  BSEG_SUBST
*"      T_BSEC STRUCTURE  BSEC OPTIONAL
*"  CHANGING
*"     REFERENCE(I_BKDFSUB) TYPE  BKDF_SUBST OPTIONAL
*"----------------------------------------------------------------------
  DATA : lv_vbeln TYPE vbeln_vf,
         lv_spart TYPE spart.
  DATA : lv_tabix TYPE sy-tabix.
  DATA : lv_segment TYPE fb_segment.

  DATA : lt_zser_parts_prct TYPE STANDARD TABLE OF zser_parts_prct,
         ls_zser_parts_prct TYPE zser_parts_prct.

  DATA: lt_yfi_der_mm TYPE STANDARD TABLE OF yfi_der_mm,
        ls_yfi_der_mm TYPE yfi_der_mm.
  FIELD-SYMBOLS : <fs_yfi_der_mm> TYPE yfi_der_mm.

  FIELD-SYMBOLS : <fl_field>       TYPE any,
                  <fl_value>       TYPE any,
                  <fl_value_filed> TYPE any.

  TYPES : BEGIN OF ty_vehi,
            vhcle       TYPE   vlc_vhcle,
            vhvin       TYPE   vlc_vhvin,
            vhcex       TYPE vlc_vhcex,
            dbm_bustype TYPE   /dbe/bustype,
          END OF ty_vehi.
  DATA : lt_vehi TYPE STANDARD TABLE OF ty_vehi,
         ls_vehi TYPE ty_vehi.
  DATA : lt_bseg TYPE STANDARD TABLE OF bseg.
  DATA: ls_bseg TYPE bseg.

  DATA : lv_dbm_vbeln TYPE /dbe/vbeln_va,
         lv_vguid     TYPE vlc_guid,
         lv_vhvin     TYPE vlc_vhvin.

  DATA: lv_zuonr1 TYPE dzuonr.  "added by ismail
*
  DATA: l_vhvin  TYPE vlcvehicle-vhvin.

  DATA : lv_cash_desk TYPE  /dbe/t_wp_log.

  CLEAR lv_spart.
*  READ TABLE t_bkpf INTO DATA(lw_bkpf) INDEX 1.
*  IF sy-subrc EQ 0.
*    lv_vbeln = lw_bkpf-xblnr.
*    SELECT SINGLE spart FROM vbrk INTO lv_spart WHERE vbeln EQ lv_vbeln.
*  ENDIF.

  READ TABLE t_bseg INTO DATA(wa) INDEX 1.
  IF sy-subrc EQ 0.
    lv_vbeln = wa-zuonr+3(10).
    SELECT SINGLE spart FROM /dbe/vbak_db INTO lv_spart WHERE vbeln EQ lv_vbeln..
  ENDIF.

  lt_bseg[] = t_bseg[].

  SELECT *  FROM zser_parts_prct
            INTO TABLE lt_zser_parts_prct
            FOR ALL ENTRIES IN t_bseg
            WHERE hkont = t_bseg-hkont
            AND spart = lv_spart.


  SELECT *
    FROM yfi_der_mm             "Derivations from MM to FI
    INTO TABLE lt_yfi_der_mm
     FOR ALL ENTRIES IN t_bseg
   WHERE bukrs = t_bseg-bukrs
     AND saknr = t_bseg-hkont.

  SORT lt_bseg ASCENDING BY bwtar.
  DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING bwtar.
  SELECT vhcle vhvin vhcex /dbe/bustype
    FROM vlcvehicle
    INTO TABLE lt_vehi
     FOR ALL ENTRIES IN lt_bseg
   WHERE vhcle = lt_bseg-bwtar.
*     %_HINTS DB2 'INDEX("VLCVEHICLE" "VLCVEHICLE-LOC")'.

  IF sy-subrc NE 0 AND lt_vehi IS INITIAL.
    READ TABLE lt_bseg INTO ls_bseg INDEX 1.
    IF sy-subrc = 0.
      lv_dbm_vbeln = ls_bseg-zuonr+3(10).

      SELECT vguid UP TO 1 ROWS
        FROM /dbe/vbak_db
        INTO lv_vguid
       WHERE vbeln = lv_dbm_vbeln ORDER BY PRIMARY KEY.
        EXIT.
      ENDSELECT.
      IF sy-subrc = 0.
        SELECT vhcle vhvin vhcex /dbe/bustype UP TO 1 ROWS
          FROM vlcvehicle
          INTO ls_vehi
         WHERE vguid = lv_vguid ORDER BY PRIMARY KEY.
          EXIT.
        ENDSELECT.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT t_bseg INTO ls_bseg.
    lv_tabix = sy-tabix.
    READ TABLE t_bsegsub INDEX lv_tabix.
    MOVE-CORRESPONDING ls_bseg TO t_bsegsub.
    READ TABLE lt_zser_parts_prct INTO ls_zser_parts_prct WITH KEY hkont = ls_bseg-hkont
                                                                   spart = lv_spart.
    IF sy-subrc EQ 0.
      t_bsegsub-prctr = ls_zser_parts_prct-prctr.

      SELECT SINGLE segment  FROM cepc
                             INTO lv_segment
                              WHERE prctr = t_bsegsub-prctr.
      IF sy-subrc = 0.
*        t_bsegsub-segment = lv_segment.
      ENDIF.
    ENDIF.


    DATA: lv_bwtar TYPE bwtar_d.
    CLEAR: lv_bwtar.
    IF ls_bseg-bwtar IS NOT INITIAL.
      lv_bwtar = ls_bseg-bwtar.
    ELSE.

      LOOP AT t_bseg INTO DATA(ls_bseg_bwtar) WHERE bwtar IS NOT INITIAL.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        lv_bwtar = ls_bseg_bwtar-bwtar.
      ENDIF.

    ENDIF.

    LOOP AT lt_yfi_der_mm ASSIGNING <fs_yfi_der_mm>
     WHERE bukrs = ls_bseg-bukrs AND saknr = ls_bseg-hkont.

      READ TABLE lt_vehi INTO ls_vehi WITH KEY vhcle = lv_bwtar.
      IF sy-subrc = 0.
        ASSIGN <fs_yfi_der_mm>-zzder_field TO <fl_field>.
        IF <fs_yfi_der_mm>-zzder_value = 'VIN1'.
          ASSIGN ls_vehi-vhvin TO  <fl_value> .
        ELSEIF <fs_yfi_der_mm>-zzder_value = 'COM1'.
          ASSIGN ls_vehi-vhcex TO  <fl_value> .
        ELSEIF <fs_yfi_der_mm>-zzder_value = 'BOL1'.
*          IF ls_bseg-bukrs = '2200' OR ls_bseg-bukrs = '2300'.
*            ASSIGN lv_bill_lad TO <fl_value>.
*          ENDIF.
        ENDIF.
        IF <fl_field> IS ASSIGNED.
          ASSIGN COMPONENT <fl_field> OF STRUCTURE t_bsegsub TO <fl_value_filed>.
          IF <fl_value_filed> IS ASSIGNED AND <fl_value> IS ASSIGNED.
            <fl_value_filed> = <fl_value>.
          ENDIF.
        ELSEIF ls_vehi IS NOT INITIAL.
          ASSIGN <fs_yfi_der_mm>-zzder_field TO <fl_field> .
          IF <fs_yfi_der_mm>-zzder_value = 'VIN1'.
            ASSIGN ls_vehi-vhvin TO  <fl_value> .
          ELSEIF <fs_yfi_der_mm>-zzder_value = 'COM1'.
            ASSIGN ls_vehi-vhcex TO  <fl_value> .
          ELSEIF <fs_yfi_der_mm>-zzder_value = 'BOL1'.
*            IF ls_bseg-bukrs = '2200' OR ls_bseg-bukrs = '2300'.
*              ASSIGN lv_bill_lad TO <fl_value>.
*            ENDIF.
          ENDIF.
          IF <fl_field> IS ASSIGNED.
            ASSIGN COMPONENT <fl_field> OF STRUCTURE t_bsegsub TO <fl_value_filed>.
            IF <fl_value_filed> IS ASSIGNED AND <fl_value> IS ASSIGNED.
              <fl_value_filed> = <fl_value>.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE. "that means no vehicle...  added for 8100004343
*  begin of new addition sales - stock- vehicle modification
        UNASSIGN : <fl_field>, <fl_value>.
*              READ TABLE lt_vbap
*              INTO lw_vbap
*              WITH KEY matnr18 = ls_bseg-matnr
*                       charg = ls_bseg-bwtar . "aufnr_re = ls_bseg-aufnr.
*              IF sy-subrc = 0.
        ASSIGN <fs_yfi_der_mm>-zzder_field TO <fl_field> .
        IF ls_bseg-bwtar IS NOT INITIAL.
          IF <fs_yfi_der_mm>-zzder_value = 'VIN1'.
            ASSIGN ls_bseg-bwtar TO  <fl_value> .
          ELSEIF <fs_yfi_der_mm>-zzder_value = 'COM1'.
*                 ASSIGN ' ' TO  <fl_value> .
          ELSEIF <fs_yfi_der_mm>-zzder_value = 'BOL1'.
*            IF ls_bseg-bukrs = '2200' OR ls_bseg-bukrs = '2300'.
*              ASSIGN lv_bill_lad TO <fl_value>.
*            ENDIF.
          ENDIF.
        ELSE.
          IF <fs_yfi_der_mm>-zzder_value = 'BOL1'.
*            IF ls_bseg-bukrs = '2200' OR ls_bseg-bukrs = '2300'.
*              ASSIGN lv_bill_lad TO <fl_value>.
*            ENDIF.
          ENDIF.
        ENDIF.
*--begin of new addition purchase - non stock- vehicle modification
        IF t_bkpf-awtyp = 'RMRP' AND ls_bseg-bwtar IS INITIAL.
          UNASSIGN :  <fl_value>.
*                FETCH the batch number from purchase order table WITH item (ls_bseg-eblen, ls_bseg-eblep).
          SELECT charg UP TO 1 ROWS
            FROM eket
            INTO @DATA(lv_charg)
           WHERE ebeln = @ls_bseg-ebeln
             AND ebelp = @ls_bseg-ebelp ORDER BY PRIMARY KEY.
            EXIT.
          ENDSELECT.
          IF sy-subrc = 0 AND lv_charg IS NOT INITIAL.
            SELECT vhvin UP TO 1 ROWS
              FROM vlcvehicle
              INTO @DATA(lv_vhvin1)
             WHERE charg = @lv_charg ORDER BY PRIMARY KEY.
              EXIT.
            ENDSELECT.
          ENDIF.
          IF <fs_yfi_der_mm>-zzder_value = 'VIN1' AND lv_vhvin1 IS NOT INITIAL.
            ASSIGN lv_vhvin1 TO  <fl_value> .
          ENDIF.
        ENDIF.
*-- end of addition
        IF <fl_field> IS ASSIGNED.
          ASSIGN COMPONENT <fl_field> OF STRUCTURE t_bsegsub TO <fl_value_filed>.
          IF <fl_value_filed> IS ASSIGNED AND <fl_value> IS ASSIGNED.
            <fl_value_filed> = <fl_value>.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    MODIFY t_bsegsub INDEX lv_tabix.
  ENDLOOP.


  IMPORT lv_cash_desk TO lv_cash_desk FROM MEMORY ID 'CASHDESK_ID'.
  IF sy-subrc = 0.
    t_bkpfsub-xref1_hd = lv_cash_desk.
    MODIFY t_bkpfsub INDEX 1.
    FREE MEMORY ID 'CASHDESK'.
  ENDIF.

ENDFUNCTION.
