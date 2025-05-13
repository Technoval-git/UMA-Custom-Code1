*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF16 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_werks.

  DATA:
      ls_errmsg   TYPE string,
      ls_error    TYPE bapiret2,
      lt_errors   TYPE bapiret2_t,
      ls_t001w    TYPE t001w,
      lv_value    TYPE string.
* -------------------------------------------------------------------

* Get defaults
  IF vlcactdata_head_s-werks IS INITIAL.
    PERFORM f_get_default USING gc_werks lv_value.
    vlcactdata_head_s-werks = lv_value.
  ELSE.
    SELECT SINGLE * FROM  t001w
                    INTO  ls_t001w
                    WHERE werks =  vlcactdata_head_s-werks.
    IF sy-subrc <> 0.
      MESSAGE e102(m3) WITH vlcactdata_head_s-werks INTO ls_errmsg.
      ls_error-message    = ls_errmsg.
      ls_error-type       = sy-msgty.
      ls_error-id         = sy-msgid.
      ls_error-number     = sy-msgno.
      ls_error-message_v1 = vlcactdata_head_s-werks.
      APPEND ls_error TO lt_errors.

      CALL FUNCTION '/DBE/CO_APLG_MSG_DISP_POPUP'
        EXPORTING
          it_error_tab2 = lt_errors.

      gv_cursor_on_field = 'VLCACTDATA_HEAD_S-WERKS'.
      RETURN.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_check_werks

*&---------------------------------------------------------------------*
*&      Form  f_check_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_check_catalog .

* -------------------------------------------------------------------

* Model catalog
  DATA lv_mcatalog         TYPE        /DBE/mcatalog.
  DATA ls_mcatalogt        TYPE        /DBE/v_mcatalogt.
  DATA ls_t001w            TYPE        t001w.
* For vehicle ini-file handling
  DATA lv_value            TYPE        string.

* -------------------------------------------------------------------

  IF vlcactdata_item_s-/DBE/spart IS INITIAL.
    PERFORM f_get_default USING gc_spart
                               lv_value.
    vlcactdata_item_s-/DBE/spart = lv_value.
  ENDIF.
  vlcactdata_head_s-spart = vlcactdata_item_s-/DBE/spart.
  vlcactdata_head_s-/DBE/spart = vlcactdata_item_s-/DBE/spart.

* The determination of the model catalog was encapsulated
* in a function module so that it can be used elsewhere, too
  CALL FUNCTION '/DBE/VM08_MODCAT_DETERMINE'
    EXPORTING
      is_vlcactdata_head = vlcactdata_head_s
      is_vlcactdata_item = vlcactdata_item_s
      it_vlcadddata      = gt_vlcadddata
      is_iobj_single     = gs_iobj_single
      is_iobj_multi      = gs_iobj_multi
      iv_iobj_catid      = gv_iobj_catid
    IMPORTING
      ev_mcatalog        = lv_mcatalog
      es_mcatalogt       = ls_mcatalogt.


* Update general model catalog data
  IF lv_mcatalog IS INITIAL.
    CLEAR /DBE/V_IMODEL.
    CLEAR gv_mcatalog.
    CLEAR gs_iobj_single-/DBE/V_IMODEL.
  ELSE.
    gv_mcatalog = lv_mcatalog.
  ENDIF.

* Update general model catalog text data
  IF ls_mcatalogt IS INITIAL.
    CLEAR /DBE/v_mcatalogt.
    /DBE/v_mcatalogt-mcatalog = lv_mcatalog.
  ELSE.
    /DBE/v_mcatalogt = ls_mcatalogt.
  ENDIF.

* -------------------------------------------------------------------
ENDFORM.                    " F_CHECK_CATALOG
