*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF27 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  IOBJ_SINGLE_MOVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM iobj_single_move  USING    pv_move_method.

  DATA: lt_category_id  TYPE /dbe/exts_tab_category_id.
  DATA: lt_ext_single   TYPE /dbe/exts_tab_set_id.
  DATA: lv_ext_single   TYPE /dbe/exts_set_id.
  DATA: lv_value        TYPE string.
  DATA: lv_objfam       TYPE /dbe/exts_obj_family.

  FIELD-SYMBOLS:
    <lf_iobj> TYPE any,
    <lf_stru> TYPE any.

* Get the iobject family
  IF gv_iobj_family IS INITIAL.
    PERFORM f_get_default USING gc_iobj_family
                                lv_value.
    lv_objfam = lv_value.
    gv_iobj_family = lv_objfam.
  ELSE.
    lv_objfam = gv_iobj_family.
  ENDIF.

* Get the appends from IObject structures
  CALL FUNCTION '/DBE/VM02_META_OBJFAM_GET'
    EXPORTING
      iv_iobj_family = lv_objfam
    IMPORTING
      et_category_id = lt_category_id
      et_ext_single  = lt_ext_single
    EXCEPTIONS
      error          = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Loop over all the structures appends
  LOOP AT lt_ext_single INTO lv_ext_single.
*   Get the structures content from global IObject structure
    ASSIGN COMPONENT lv_ext_single OF STRUCTURE gs_iobj_single TO <lf_iobj>.
    IF sy-subrc EQ 0.
*     Get content of append structure from screen - has to be defined
*     in the TOP INCLUDE
      ASSIGN (lv_ext_single) TO  <lf_stru>.
*     If this structure is defined...
      IF sy-subrc EQ 0.
*       Get method - get data from buffer and set it on the screen
        IF pv_move_method EQ gc_0.
          MOVE-CORRESPONDING <lf_iobj> TO <lf_stru>.
*       Set Method - set data on the screen from buffer
        ELSEIF pv_move_method EQ gc_1.
          MOVE-CORRESPONDING <lf_stru> TO <lf_iobj>.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " IOBJ_SINGLE_MOVE
