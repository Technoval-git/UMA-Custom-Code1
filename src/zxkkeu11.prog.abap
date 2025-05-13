*&---------------------------------------------------------------------*
*& Include          ZXKKEU11
*&---------------------------------------------------------------------*

FIELD-SYMBOLS : <fs_copa_item> TYPE any.
FIELD-SYMBOLS : <fs_wwveh>     TYPE char18.
FIELD-SYMBOLS : <fs_rkaufnr>   TYPE char12.

DATA: lv_vguid   TYPE vlc_guid.
DATA: lv_global  TYPE kedrcopa.
*CHECK i_operating_concern = 'S001'.
CASE i_step_id.
  WHEN 'U901'.  "Benutzerdefinierter Name des Schritts aus KEDR
    lv_global    = i_global.
* vlcvehicle #er Fahrzeuginnenauftragsnummer lesen

    ASSIGN i_copa_item TO <fs_copa_item> .
    ASSIGN COMPONENT 'WWVEH' OF STRUCTURE <fs_copa_item> TO <fs_wwveh>.
    IF <fs_wwveh> IS ASSIGNED AND <fs_wwveh> IS NOT INITIAL.
      SELECT SINGLE vguid FROM  vlcvehicle INTO lv_vguid
             WHERE  vhvin  = <fs_wwveh>.
      IF NOT lv_vguid IS INITIAL.
        lv_global-usertemp8 = lv_vguid.
        e_global =  lv_global.
        e_exit_is_active = 'X'.
      ENDIF.
    ENDIF.

    ASSIGN COMPONENT 'RKAUFNR' OF STRUCTURE <fs_copa_item> TO <fs_rkaufnr>.
    IF <fs_rkaufnr> IS ASSIGNED AND <fs_rkaufnr> IS NOT INITIAL.
      SELECT SINGLE /dbe/vlc_guid FROM aufk INTO lv_vguid
             WHERE aufnr = <fs_rkaufnr>.
      IF NOT lv_vguid IS INITIAL.
        lv_global-usertemp8 = lv_vguid.
        e_global =  lv_global.
        e_exit_is_active = 'X'.
      ENDIF.
    ENDIF.
ENDCASE.
