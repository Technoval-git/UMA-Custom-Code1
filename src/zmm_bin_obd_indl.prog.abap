*&---------------------------------------------------------------------*
*& Report ZMM_BIN_OBD_INDL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_bin_obd_indl.
* ALV Declaration
DATA : it_fieldcat TYPE slis_t_fieldcat_alv,
       wa_fieldcat TYPE slis_fieldcat_alv.
DATA lt_ZMM_BIN_OBD_STR TYPE STANDARD TABLE OF  zmm_bin_obd_str.
DATA ls_ZMM_BIN_OBD_STR TYPE zmm_bin_obd_str.
DATA gv_dlv TYPE char10.
PARAMETERS p_matnr TYPE matnr OBLIGATORY.

START-OF-SELECTION.


  IMPORT gv_dlv = gv_dlv FROM MEMORY ID 'ZMM_BIN_OBD'.

  IF gv_dlv = 'Outbound'.

    SELECT h~vbeln i~posnr h~ernam h~erdat h~vstel h~vkorg h~lfart h~kunnr h~gbstk h~kostk
     i~matnr i~matkl i~werks i~lgort i~lfimg i~meins i~vrkme i~vgbel i~vgpos i~bwart
     FROM likp AS h INNER JOIN lips AS i
     ON h~vbeln = i~vbeln
     INTO CORRESPONDING FIELDS OF TABLE lt_ZMM_BIN_OBD_STR  " @Data(lt_del)
     WHERE i~matnr = p_matnr AND
     ( h~gbstk = 'A' OR h~gbstk = 'B') AND
     ( h~kostk = 'A' OR h~kostk = 'B' ) AND
     ( h~lfart = 'YLPO' OR h~lfart = 'YSTO' ).
  ELSE.


    SELECT h~vbeln i~posnr h~ernam h~erdat h~vstel h~vkorg h~lfart h~kunnr h~gbstk h~kostk
      i~matnr i~matkl i~werks i~lgort i~lfimg i~meins i~vrkme i~vgbel i~vgpos i~bwart
      FROM likp AS h INNER JOIN lips AS i
      ON h~vbeln = i~vbeln
      INTO CORRESPONDING FIELDS OF TABLE lt_ZMM_BIN_OBD_STR  " @Data(lt_del)
      WHERE i~matnr = p_matnr AND
      ( h~gbstk = 'A' OR h~gbstk = 'B') AND
      ( h~kostk = 'A' OR h~kostk = 'B' ) AND
      h~lfart = 'EL'.


  ENDIF.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZMM_BIN_OBD_STR'
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
  READ TABLE it_fieldcat INTO wa_fieldcat WITH KEY fieldname = 'CHECK'.
  IF sy-subrc = 0.
    wa_fieldcat-edit = 'X'.
    wa_fieldcat-checkbox = 'X'.
    wa_fieldcat-seltext_m   = 'Check'.
    wa_fieldcat-col_pos     = 2.
    wa_fieldcat-outputlen = 5.
    MODIFY it_fieldcat FROM wa_fieldcat INDEX sy-tabix.
  ENDIF.

  CLEAR wa_fieldcat.


  IF gv_dlv = 'Outbound'.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = sy-repid
        it_fieldcat              = it_fieldcat
        i_callback_pf_status_set = 'ZSTANDARD1'
        i_callback_user_command  = 'USER_COMMAND'
        i_save                   = 'X'
        i_grid_title             = 'Outbound Delivery'
      TABLES
        t_outtab                 = lt_ZMM_BIN_OBD_STR.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = sy-repid
        it_fieldcat              = it_fieldcat
        i_callback_pf_status_set = 'ZSTANDARD1'
        i_callback_user_command  = 'USER_COMMAND'
        i_save                   = 'X'
        i_grid_title             = 'Inbound Delivery'
      TABLES
        t_outtab                 = lt_ZMM_BIN_OBD_STR.
  ENDIF.

  FREE MEMORY.



FORM zstandard1 USING rt_extab TYPE slis_t_extab..
  SET PF-STATUS 'ZSTANDARD1'.
ENDFORM.                    "su_pf_status

FORM user_command USING r_ucomm  LIKE sy-ucomm
                          rs_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN '&PGI'.
      IF gv_dlv = 'Outbound'.

      ELSE.
        MESSAGE 'Post Goods Issue' TYPE 'I'.
*        Code to post inbound delivery,  Post Goods Issue
      ENDIF.
    WHEN '&PGR'.
      IF gv_dlv = 'Outbound'.
        MESSAGE 'Post Goods Receipt' TYPE 'I'.
*        code to post outbound delivery, Pst Goods Receipt
      ELSE.

      ENDIF.
  ENDCASE.

ENDFORM.                    "user_command
