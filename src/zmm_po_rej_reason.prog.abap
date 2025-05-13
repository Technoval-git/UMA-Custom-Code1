*&---------------------------------------------------------------------*
*& Report ZMM_PO_REJ_REASON
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_po_rej_reason.
TABLES:ekko.
DATA : ls_line TYPE tline,
       lt_line TYPE STANDARD TABLE OF tline.

TYPES :BEGIN OF ty_str,
         reason TYPE char255,
       END OF ty_str.
DATA lt_str TYPE STANDARD TABLE OF ty_str.
DATA lw_str TYPE ty_str.

SELECT-OPTIONS : s_EBELN FOR ekko-ebeln,
                 s_date FOR ekko-aedat.


TYPES: BEGIN OF ty_DWI,
         PURDOC     TYPE ebeln,
         ID         TYPE sww_wiid,
         ORDERTYPE  TYPE bsart,
         CHANGEDON  TYPE aedat,
         CREATED  TYPE ernam,
         SUPPLIER  TYPE lifnr,
         Status type sww_wistat,
         LASTAGENT type sww_aagent,
         ApproverID type ZApproverID,
         DelayDays Type ZDELAYDAYS,
         reason TYPE ZMM_REASON, "char255,
       END OF  ty_DWI.
DATA :lt_DWI TYPE STANDARD TABLE OF ty_DWI,
      lw_dwI TYPE ty_DWI.

data: diffrenceInDays type p.

START-OF-SELECTION.

  SELECT b~ebeln a~wi_id b~bsart b~aedat b~ernam  b~lifnr a~Status a~Approver a~ApproverID FROM zmm_DWI AS a INNER JOIN ekko AS b
                ON a~ebeln = b~ebeln
                INTO TABLE  lt_DWI
    WHERE b~frgrl = 'X' AND a~wi_cd IN s_date AND a~ebeln IN s_ebeln.
* WHERE a~wi_cd IN s_date  AND a~ebeln IN s_ebeln. AND a~wi_cd IN s_date  AND a~ebeln IN s_ebeln
  LOOP AT lt_DWI INTO lw_DWI.

    CLEAR lt_line.
    CALL FUNCTION 'ZMM_DECISION_TEXT'
      EXPORTING
        im_wiid = lw_DWI-id
      TABLES
        return  = lt_line.

    CLEAR : lw_str.
    CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
      EXPORTING
        language    = sy-langu
      TABLES
        itf_text    = lt_line
        text_stream = lt_str.

    READ TABLE lt_str INTO lw_str INDEX 1.
    CLEAR lw_DWI-reason.
    lw_DWI-reason = lw_str-reason.


    CALL FUNCTION '/SDF/CMO_DATETIME_DIFFERENCE'
     EXPORTING
       DATE1                  = sy-datum
       DATE2                  = lw_DWI-CHANGEDON

     IMPORTING
       DATEDIFF               = diffrenceInDays
              .


    lw_DWI-delaydays = diffrenceInDays.

    MODIFY lt_DWI FROM lw_DWI TRANSPORTING reason delaydays.
*    insert ZTABLE_DWI from lw_dwi.
*    commit work.
  ENDLOOP.

*  export lt_DWI to MEMORY ID 'ZZ_KW_TEST'.



 delete ADJACENT DUPLICATES FROM lt_DWI COMPARING ALL FIELDS.
  CALL FUNCTION 'ZMM_ALV_POPUP'
    EXPORTING
      i_start_column = 5
      i_start_line   = 5
      i_end_column   = 200
      i_end_line     = 100
      i_title        = 'ALV'
      i_popup        = 'X'
    TABLES
      it_alv         = lt_DWI.
