*----------------------------------------------------------------------*
***INCLUDE LZVSS_VEHI_ACTIONSF06.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form f_check_entry_fields_filled
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_check_entry_fields_filled .
* This form is used by all action-subscreens to check if all
* mandatory entry fields have been filled.
  DATA:
* Structure for vehicle "item" data
    vlcactdata_item_ls   TYPE vlcactdata_item_s,
* Fields needed to find out if item data for other vehicles is filled
    trash_lv(17)         TYPE c,
    fieldname_lv(30)     TYPE c,
    actdata_field_lv(49) TYPE c,
    v_name1(30) type c,
    v_name2(30) type c,
    v_name3(30) type c,
    v_name4(30) type c.
* Content of the input field on the screen
  FIELD-SYMBOLS <input_field>.
* Content of a field in VLCACTDATA_ITEM_GT
  FIELD-SYMBOLS <actdata_field>.
*----------------------------------------------------------------------
* Check: User wants the MM-action to be performed ?
  IF sy-ucomm = fc_aktn_gc.
    LOOP AT SCREEN.
*     Check: Field is an entry field and belongs to group IN1 ?
      IF screen-input = 1 AND screen-group1 = ftype_in1_gc.
        ASSIGN (screen-name) TO <input_field>.
*       Check: Is entry field filled ?
        IF <input_field> IS INITIAL.
*         Problem exists between chair and computer:
*         The user wants to perform an action without having filled
*         all mandatory entry fields on the subscreen.
          SET CURSOR FIELD screen-name.
*         Make sure that it's possible to enter a value into the empty
*         mandatory field
          screen-input = 1.
          MODIFY SCREEN.
*         Tell the user what went wrong. This error message does not
*         return a vehicle number because it is used for header data as
*         well.
*          MESSAGE e087.
        ELSE.                          " <INPUT_FIELD> IS INITIAL
*         Check mandatory fields which are currently not displayed on
*         the subscreen of the action
*         Find out if the field is an item field. If this is the case it
*         has to be checked if the field is not only filled on the
*         screen but for all vehicles of the action
          IF screen-name CP 'VLCACTDATA_ITEM_S-*'.
            LOOP AT vlcactdata_item_gt INTO vlcactdata_item_ls.
*             The field names in VLCACTDATA_ITEM_S and VLCACTDATA_ITEM
*             _LS are identical. For each VLCACTDATA_ITEM_S used on the
*             subscreen as IN1 field, the content of VLCACTDATA_ITEM_GT
*             has to be checked.
*             vlcactdata_item_ls ... vehicle data currently checked
*             vlcactdata_item_s  ... vehicle data currently displayed
              IF NOT vlcactdata_item_ls-vguid = vlcactdata_item_s-vguid.
*               If the vehicle is the one which is currently displayed
*               on the subscreen(vlcactdata_item_s) , the data was
*               already checked (--> e087 in case of missing data).
*               In addition, the latest changes to the currently
*               displayed vehicle's data is not yet included in
*               vlcactdata_item_gt. F_CHECK_ENTRY_FIELDS_FILLED is
*               called before F_MODIFY_ITAB_FROM_DISP is called.
                SPLIT screen-name AT '-'
                      INTO trash_lv fieldname_lv.
                CONCATENATE 'VLCACTDATA_ITEM_LS-' fieldname_lv
                      INTO actdata_field_lv.
                ASSIGN (actdata_field_lv) TO <actdata_field>.
*               Field actdata_field_lv contains the name of the field in
*               VLCACTDATA_ITEM_LS which has to be checked, field symbol
*               actdata_field contains the value of this field.
                IF <actdata_field> IS INITIAL.
*                 The user didn't maintain mandatory data for at least
*                 one vehicle. It is not the currently selected vehicle.
*                 Problem exists between chair and computer:
*                 The user wants to perform an action without having
*                 filled all mandatory data.
                  SET CURSOR FIELD screen-name.
*                 Make sure that it's possible to enter data
                  screen-input = 1.
                  MODIFY SCREEN.
*                 Tell the user what went wrong.
*                  MESSAGE e097 WITH vlcactdata_item_ls-vhcle.
                ENDIF.       " IF <actdata_field> IS INITIAL.
              ENDIF.         " IF NOT vlcactdata_item_ls-vguid = ...
            ENDLOOP.         " LOOP AT VLCACTDATA_ITEM_GT INTO ...
          ENDIF.             " IF SCREEN-NAME CA 'VLCACTDATA_ITEM_S'.
        ENDIF.               " <INPUT_FIELD> IS INITIAL
      ENDIF.                 " SCREEN-INPUT = 1
    ENDLOOP.                 " LOOP AT SCREEN.
  ENDIF.                     " SY-UCOMM = FC_AKTN_GC

  IF sy-ucomm = 'ENTE'.
    SELECT SINGLE * FROM t001w WHERE werks EQ vlcactdata_head_s-werks.
    IF sy-subrc EQ 0.
      MOVE t001w-name1 TO /DBE/S_VEH_SHORTTEXT_PLANT2-DESCR.
    ENDIF.
    select single * from t001l where lgort eq vlcactdata_head_s-lgort.
      if sy-subrc eq 0.
        move t001l-lgobe to /DBE/S_VEH_SHORTTEXT_STRLOC2-LGOBE.
      endif.
      select single * from t001w where werks eq vlcactdata_head_s-umwerks.
        if sy-subrc eq 0.
          move t001w-name1  to /DBE/S_VEH_SHORTTEXT_PLANT1-DESCR.
        endif.
        select single * from t001l where lgort eq vlcactdata_head_s-umlgo.
          if sy-subrc eq 0.
            move t001l-lgobe to /DBE/S_VEH_SHORTTEXT_STRLOC1-LGOBE.
          endif..
  ENDIF.
ENDFORM.                    " F_CHECK_ENTRY_FIELDS_FILLED
