*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_ACTION_CLAS
*&---------------------------------------------------------------------*


CLASS lcl_adddata_event_handler DEFINITION.

  PUBLIC SECTION.
* perform the necessary checks of input values
    METHODS:
      handle_data_changed
         FOR EVENT data_changed OF cl_gui_alv_grid
             IMPORTING er_data_changed.

  PRIVATE SECTION.
* This flag is set if any error occured in one of the following methods
    DATA: error_in_data TYPE c.

* check if mandatory fields are filled
    METHODS:
      perform_changetype_checks
         IMPORTING
            pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

* check mt_good_cells semantically
    METHODS:
      perform_semantic_checks
         IMPORTING
            pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.


ENDCLASS.                    "lcl_adddata_event_handler DEFINITION
*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_adddata_event_handler
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_adddata_event_handler IMPLEMENTATION.
  METHOD handle_data_changed.
    error_in_data = space.

*   In case of ALV data_changed event PBO is not executed so navigation
*   block flag is not cleared at the end of PBO in f_error_show->clear it here
    CALL FUNCTION '/DBE/VM08_ERROR_SET'
      EXPORTING
        iv_block_navigation = abap_false.

* check if mandatory fields are filled
    CALL METHOD perform_changetype_checks( er_data_changed ).

* check mt_good_cells semantically
    CALL METHOD perform_semantic_checks( er_data_changed ).

* check if an error occured -> raise the error protocoll
    IF error_in_data = 'X'.
      CALL METHOD er_data_changed->display_protocol.
      CALL FUNCTION '/DBE/VM08_ERROR_SET'
        EXPORTING
          iv_block_navigation = abap_true.
    ENDIF.

  ENDMETHOD.                    "handle_data_changed

*----------------------------------------------------------------------


  METHOD perform_changetype_checks.

    DATA: good_ls TYPE lvc_s_modi,
          qausp_lv TYPE vlc_qtext,
          ls_vlcadddata TYPE vlcadddata_item_s.


    LOOP AT pr_data_changed->mt_good_cells INTO good_ls.

      IF good_ls-fieldname = 'QAUSP'.

        CALL METHOD pr_data_changed->get_cell_value
          EXPORTING
            i_row_id    = good_ls-row_id
            i_fieldname = good_ls-fieldname
          IMPORTING
            e_value     = qausp_lv.

        READ TABLE gt_vlcadddata
                     INTO ls_vlcadddata INDEX good_ls-row_id.

*--> verify if the mandatory fields are filled; otherwise raise an error
        IF ls_vlcadddata-ftype = gc_ftype_in1
                                        AND qausp_lv IS INITIAL.
          CALL METHOD pr_data_changed->add_protocol_entry
            EXPORTING
              i_msgid     = 'VELO'
              i_msgno     = '173'
              i_msgty     = 'E'
              i_msgv1     = ls_vlcadddata-aqtxt
              i_fieldname = good_ls-fieldname
              i_row_id    = good_ls-row_id.

          error_in_data = 'X'.
        ENDIF.

      ENDIF.                           " IF GOOD_ls-FIELDNAME = 'QAUSP'

    ENDLOOP.      " LOOP AT PR_DATA_CHANGED->MT_GOOD_CELLS INTO GOOD_LS

  ENDMETHOD.                    "perform_changetype_checks

*-----------------------------------------------------------------------

  METHOD perform_semantic_checks.

    DATA: good_ls TYPE lvc_s_modi,
          qausp_lv TYPE vlc_qtext,
          ls_vlcadddata TYPE vlcadddata_item_s.


    LOOP AT pr_data_changed->mt_good_cells INTO good_ls.

      IF good_ls-fieldname = 'QAUSP'.

        CALL METHOD pr_data_changed->get_cell_value
          EXPORTING
            i_row_id    = good_ls-row_id
            i_fieldname = good_ls-fieldname
          IMPORTING
            e_value     = qausp_lv.

        READ TABLE gt_vlcadddata
                     INTO ls_vlcadddata INDEX good_ls-row_id.

      ENDIF.                          " IF GOOD_ls-FIELDNAME = 'QAUSP'.

    ENDLOOP.    " LOOP AT PR_DATA_CHANGED->MT_GOOD_CELLS INTO GOOD_LS.

  ENDMETHOD.                    "perform_semantic_checks

ENDCLASS.               "lcl_adddata_event_handler
