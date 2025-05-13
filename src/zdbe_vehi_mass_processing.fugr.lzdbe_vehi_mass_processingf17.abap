*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF17 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_MODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_mode .

  DATA:
    wa_indx TYPE indx,
    lv_id(20) TYPE c.

* for calling search from outside -autmatical execute

  GET PARAMETER ID gc_external_call FIELD gv_external_mode. "#EC EXISTS

  IF NOT gv_external_mode IS INITIAL.

    SET PARAMETER ID gc_external_call FIELD space.          "#EC EXISTS

* import search criteria table
    wa_indx-aedat = sy-datum.
    wa_indx-usera = sy-uname.
    wa_indx-pgmid = sy-repid.
    CONCATENATE sy-uname sy-datum INTO lv_id.

    IMPORT tab = gt_mass_search_crit FROM SHARED MEMORY indx(xy) TO wa_indx
      ID lv_id.
    DELETE FROM SHARED MEMORY indx(xy) ID lv_id.

*    PERFORM execute_search.
    mass-activetab = gc_worklist_fc.
    gv_subscreen_dynpro = '1300'.
    gv_subscreen_program = '/DBE/SAPLVEHI_MASS_PROCESSING'.
    gv_external_mode = space.

  ENDIF.

ENDFORM.                    " CHECK_MODE
