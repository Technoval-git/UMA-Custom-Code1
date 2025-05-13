*&---------------------------------------------------------------------*
*& Report ZFI_UPDATE_CCA
*&---------------------------------------------------------------------*
*& Please schedule this program in backgroud. Also please clear records
*& from table ZFI_UPDATE_CCA once update is done
*&---------------------------------------------------------------------*
REPORT zfi_update_cca.


TABLES: bseg.

DATA: lt_bseg TYPE TABLE OF bseg,
      ls_bseg TYPE bseg.

DATA: lv_new_kkber TYPE kkber ,  " Replace with the new KKBER value
      lv_old_kkber TYPE kkber.
*data lv_kkber type t014-kkber.
DATA lt_zfi_update_cca TYPE STANDARD TABLE OF zfi_update_cca.
DATA ls_zfi_update_cca TYPE zfi_update_cca.

START-OF-SELECTION.
  SELECT mandt bukrs belnr gjahr kkber FROM zfi_update_cca INTO TABLE lt_zfi_update_cca.

  LOOP AT lt_zfi_update_cca INTO ls_zfi_update_cca.
    " Select the document to be updated in BSEG
    SELECT  SINGLE kkber, augbl, vorgn INTO @DATA(lv_kkber)
           FROM bseg

          WHERE bukrs = @ls_zfi_update_cca-bukrs
             AND gjahr = @ls_zfi_update_cca-gjahr
             AND belnr = @ls_zfi_update_cca-belnr
*             AND augbl is not INITIAL
             AND vorgn = 'RFBU' AND koart = 'D'.
*  ENDSELECT.
    IF sy-subrc = 0 AND lv_kkber-augbl NE '' .
      " Check if the KKBER value needs to be updated in BSEG
      CLEAR lv_new_kkber.
      lv_new_kkber = ls_zfi_update_cca-kkber.
      lv_old_kkber = lv_kkber-kkber.
      IF lv_old_kkber NE lv_new_kkber.
        " Update the KKBER value in BSEG
        UPDATE bseg SET kkber = lv_new_kkber
               WHERE bukrs = ls_zfi_update_cca-bukrs
                 AND gjahr = ls_zfi_update_cca-gjahr
                 AND belnr = ls_zfi_update_cca-belnr.

        IF sy-subrc = 0.
          WRITE: / 'BSEG-KKBER Updated Successfully for ', ls_zfi_update_cca-bukrs, ls_zfi_update_cca-gjahr, ls_zfi_update_cca-belnr.
        ELSE.
          WRITE: / 'Error updating BSEG-KKBER:', sy-msgid, sy-msgty, sy-msgno, sy-msgty.
        ENDIF.
      ELSE.
        WRITE: / 'BSEG-KKBER is already set to the new value for ', ls_zfi_update_cca-bukrs, ls_zfi_update_cca-gjahr, ls_zfi_update_cca-belnr.
      ENDIF.
    ELSE.
      WRITE: / 'Document not found in BSEG.', ls_zfi_update_cca-bukrs, ls_zfi_update_cca-gjahr, ls_zfi_update_cca-belnr.
    ENDIF.

  ENDLOOP.
