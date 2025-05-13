*&---------------------------------------------------------------------*
*& Include          YABC_I_CLASSIFICATION_CLS_IM_1
*&---------------------------------------------------------------------*

CLASS lcl_selectionScreen IMPLEMENTATION.

  METHOD screen_validation.
    LOOP AT SCREEN.
      CASE 'X'.
        WHEN rb_upl.
          IF screen-group1 = 'UPR' OR screen-group1 = 'UPD'.
            screen-active = 0.
          ENDIF.

        WHEN rb_upd.
          IF screen-group1 = 'UPL'.
            screen-active = 0.
          ENDIF.

        WHEN rb_rep.
          IF screen-group1 = 'UPD' OR screen-group1 = 'UPL'.
            screen-active = 0.
          ENDIF.

      ENDCASE.

      MODIFY SCREEN.
    ENDLOOP.

  ENDMETHOD.
  METHOD file_f4help.

    DATA:lv_rc     TYPE i,
         lv_file   TYPE filetable,
         lv_action TYPE i.

    cl_gui_frontend_services=>file_open_dialog(
      EXPORTING
        file_filter             = |xlsx (*.xlsx)\|*.xlsx\|{ cl_gui_frontend_services=>filetype_all }|    " File Extension Filter String
      CHANGING
        file_table              =  lv_file  " Table Holding Selected Files
        rc                      =  lv_rc    " Return Code, Number of Files or -1 If Error Occurred
        user_action             =  lv_action   " User Action (See Class Constants ACTION_OK, ACTION_CANCEL)
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5 ).
    READ TABLE lv_file INDEX 1 INTO DATA(wa_file).
    IF sy-subrc = 0.
      p_file = wa_file-filename.
    ENDIF.



  ENDMETHOD.
ENDCLASS.
