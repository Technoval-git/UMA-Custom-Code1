*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHICLEF02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FILL_BAPIRETURN
*&---------------------------------------------------------------------*
FORM FILL_BAPIRETURN TABLES RETURN STRUCTURE BAPIRETURN
                 USING FBR_MSTYP
                       FBR_MSGID
                       FBR_MSGNO
                       FBR_MSGV1
                       FBR_MSGV2
                       FBR_MSGV3
                       FBR_MSGV4.

  DATA: H_RETURN LIKE BAPIRETURN.
  DATA: BEGIN OF MSG,
           TY LIKE SYST-MSGTY,
           ID LIKE SYST-MSGID,
           NO LIKE SYST-MSGNO,
           V1 LIKE SYST-MSGV1,
           V2 LIKE SYST-MSGV2,
           V3 LIKE SYST-MSGV3,
           V4 LIKE SYST-MSGV4,
        END OF MSG.


  CLEAR H_RETURN.
  CLEAR MSG.
  MOVE: FBR_MSTYP TO MSG-TY,
        FBR_MSGID TO MSG-ID,
        FBR_MSGNO TO MSG-NO,
        FBR_MSGV1 TO MSG-V1,
        FBR_MSGV2 TO MSG-V2,
        FBR_MSGV3 TO MSG-V3,
        FBR_MSGV4 TO MSG-V4.

  CALL FUNCTION 'BALW_BAPIRETURN_GET'
       EXPORTING
            TYPE       = MSG-TY
            CL         = MSG-ID
            NUMBER     = MSG-NO
            PAR1       = MSG-V1
            PAR2       = MSG-V2
            PAR3       = MSG-V3
            PAR4       = MSG-V4
       IMPORTING
            BAPIRETURN = H_RETURN.

  CLEAR RETURN.
  MOVE H_RETURN TO RETURN.
  APPEND RETURN.
ENDFORM.                               " FILL_BAPIRETURN
*&---------------------------------------------------------------------*
*&      Form  CHECK_MFRPN_IDENTICAL
*&---------------------------------------------------------------------*
*       Check if all the material in the list is the same
*----------------------------------------------------------------------*
*      -->IT_MATLIST       MARA entries
*      <--CF_ALL_THE_SAME  Flag, indicating, if all mfrpn entries are
*                          the same.
*----------------------------------------------------------------------*
FORM CHECK_MFRPN_IDENTICAL
                  USING    IT_MATLIST TYPE  BBPMATNRLST
                  changing cf_all_the_same type i.
* ----------------------------------------------------------------------
* Local Variables
* ----------------------------------------------------------------------
  DATA LF_MATLIST_WA TYPE LINE OF BBPMATNRLST.
  DATA LS_MATERIAL_DATA LIKE BAPIMATDOA.
  DATA LS_RETURN LIKE BAPIRETURN.
  DATA LF_MANU_MAT LIKE BAPIMATDOA-MANU_MAT.
* ----------------------------------------------------------------------
* Program Code
* ----------------------------------------------------------------------
* Assume all mfrpn entries are the same...
  move 1 to cf_all_the_same.

* Initialize loop
  READ TABLE IT_MATLIST INTO LF_MATLIST_WA INDEX 1.
* Get detailed information on material
  CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
       exporting
            MATERIAL              = LF_MATLIST_WA
       importing
            material_general_data = ls_material_data
            RETURN                = LS_RETURN.

  move ls_material_data-manu_mat to lf_manu_mat.

* Loop over all table entries
  LOOP AT IT_MATLIST INTO LF_MATLIST_WA FROM 2.
*   Get detailed information on material
    CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
         exporting
              MATERIAL              = LF_MATLIST_WA
         importing
              material_general_data = ls_material_data
              RETURN                = LS_RETURN.

    if ls_material_data-manu_mat ne lf_manu_mat.
      move 0 to cf_all_the_same.
      exit.
    endif.
  endloop.
ENDFORM.                    " CHECK_MFRPN_IDENTICAL
