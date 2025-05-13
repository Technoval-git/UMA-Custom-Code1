*&---------------------------------------------------------------------*
*& Report ZVSS_CORRECT_STATUS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvss_correct_status.

*** type pools
TYPE-POOLS: slis.

*** tables
TABLES: /dbe/vbap, /dbe/job, /dbe/split, /dbe/splhdr_db.

*** types
TYPES: BEGIN OF t_data,
         vbeln      TYPE /dbe/vbak_db-vbeln,
         posnr      TYPE /dbe/vbap-posnr,
         jobnr      TYPE /dbe/job-jobnr,
         splnr      TYPE /dbe/split-splnr,
         splhdr     TYPE /dbe/splhdr_db-splnr,
         status     TYPE c,
         status_new TYPE c,
         box        TYPE c,
       END OF t_data.

*** internal tables
DATA: it_vbakst   TYPE STANDARD TABLE OF /dbe/oe_vbakst,
      it_vbapst   TYPE STANDARD TABLE OF /dbe/oe_vbapst,
      it_jobst    TYPE STANDARD TABLE OF /dbe/oe_jobst,
      it_splitst  TYPE STANDARD TABLE OF /dbe/oe_splitst,
      it_splhdr   TYPE STANDARD TABLE OF /dbe/oe_splhdrst,
      it_fieldcat TYPE slis_t_fieldcat_alv,
      it_data     TYPE STANDARD TABLE OF t_data.

DATA: lo_order          TYPE REF TO /dbe/cl_order,
      is_dialog_control TYPE /dbe/oe_dialog_control.
DATA lt_return TYPE bapiret2_t.
DATA: ls_return       LIKE LINE OF lt_return,
      wa_fieldcat     TYPE slis_fieldcat_alv,
      wa_layout       TYPE slis_layout_alv,
      lv_dummy        TYPE c,
      lv_message(100) TYPE c.

*** work areas
DATA: wa_vbakst  TYPE /dbe/oe_vbakst,
      wa_vbapst  TYPE /dbe/oe_vbapst,
      wa_jobst   TYPE /dbe/oe_jobst,
      wa_splitst TYPE /dbe/oe_splitst,
      wa_splhdr  TYPE /dbe/oe_splhdrst,
      wa_data    TYPE t_data.

*** selection screen
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_vbeln TYPE /dbe/vbak_db-vbeln OBLIGATORY.
  SELECT-OPTIONS: s_posnr FOR /dbe/vbap-posnr NO INTERVALS NO-EXTENSION,
                  s_jobnr FOR /dbe/job-jobnr NO INTERVALS NO-EXTENSION,
                  s_splnr FOR /dbe/split-splnr NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK a.

SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_action TYPE /dbe/oe_stat_id-status_id OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b.

SELECTION-SCREEN BEGIN OF BLOCK c WITH FRAME TITLE TEXT-003.
  PARAMETERS: p_header RADIOBUTTON GROUP g1,
              p_item   RADIOBUTTON GROUP g1,
              p_job    RADIOBUTTON GROUP g1,
              p_splhdr RADIOBUTTON GROUP g1,
              p_split  RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK c.

*** initialization
INITIALIZATION.
  DEFINE fill_fieldcat.
    CLEAR wa_fieldcat.
    wa_fieldcat-fieldname = &1.
    wa_fieldcat-reptext_ddic = &2.
    wa_fieldcat-outputlen = &3.
    APPEND wa_fieldcat TO it_fieldcat.

  END-OF-DEFINITION. "fill_fieldcat

*** start of selection
START-OF-SELECTION.

* get the order object
  PERFORM get_order_object.

  IF lo_order IS BOUND.

    IF p_header = 'X'.
      PERFORM get_header_status.
      IF it_vbakst IS NOT INITIAL.
        PERFORM display_header_status.
      ELSE.
        MESSAGE 'No status read' TYPE 'S'.
      ENDIF.

    ELSEIF p_item = 'X'.
      PERFORM get_item_status.
      IF it_vbapst IS NOT INITIAL.
        PERFORM display_item_status.
      ELSE.
        MESSAGE 'No status read' TYPE 'S'.
      ENDIF.

    ELSEIF p_job = 'X'.
      PERFORM get_job_status.
      IF it_jobst IS NOT INITIAL.
        PERFORM display_job_status.
      ELSE.
        MESSAGE 'No status read' TYPE 'S'.
      ENDIF.

    ELSEIF p_split = 'X'.
      PERFORM get_split_status.
      IF it_splitst IS NOT INITIAL.
        PERFORM display_split_status.
      ELSE.
        MESSAGE 'No status read' TYPE 'S'.
      ENDIF.

    ELSEIF p_splhdr = 'X'.
      PERFORM get_splhdr_status.
      IF it_splhdr IS NOT INITIAL.
        PERFORM display_splhdr_status.
      ELSE.
        MESSAGE 'No status read' TYPE 'S'.
      ENDIF.

    ENDIF.

  ENDIF.



*&---------------------------------------------------------------------*
*&      Form  get_order_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_order_object.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_vbeln
    IMPORTING
      output = p_vbeln.

* Create the order object in change mode
  is_dialog_control-actvt = /dbe/cl_order_engine=>c_actvt_change.

  CALL FUNCTION '/DBE/OE_MAIN_GET'
    EXPORTING
      iv_vbeln          = p_vbeln
      is_dialog_control = is_dialog_control
    IMPORTING
      eo_order          = lo_order
    EXCEPTIONS
      internal_error    = 1
      nothing_selected  = 2
      action_error      = 3
      OTHERS            = 4.
* if failed to instantiate the order object, throw message
  IF sy-subrc <> 0.
    lt_return = lo_order->bal_export( ).
    DELETE lt_return WHERE type NE 'A' AND type NE 'E'.
    IF lt_return IS NOT INITIAL.
      READ TABLE lt_return INTO ls_return INDEX 1.
      MESSAGE e999(/dbe/common) WITH ls_return-message.
    ENDIF.
  ENDIF.

ENDFORM.                    "get_order_object

*&---------------------------------------------------------------------*
*&      Form  get_header_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_header_status.

  SELECT *
    FROM /dbe/oe_vbakst
    INTO TABLE it_vbakst
    WHERE vbeln  = p_vbeln
    AND   action = p_action.

ENDFORM.                    "get_header_status

*&---------------------------------------------------------------------*
*&      Form  get_item_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_item_status.

  SELECT *
    FROM /dbe/oe_vbapst
    INTO TABLE it_vbapst
    WHERE vbeln  = p_vbeln
    AND   posnr  IN s_posnr
    AND   action = p_action.

ENDFORM.                    "get_item_status

*&---------------------------------------------------------------------*
*&      Form  get_job_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_job_status.

  SELECT *
    FROM /dbe/oe_jobst
    INTO TABLE it_jobst
    WHERE vbeln = p_vbeln
    AND   jobnr IN s_jobnr
    AND   action = p_action.

ENDFORM.                    "get_job_status

*&---------------------------------------------------------------------*
*&      Form  get_split_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_split_status.

  SELECT *
    FROM /dbe/oe_splitst
    INTO TABLE it_splitst
    WHERE vbeln = p_vbeln
    AND posnr IN s_posnr
    AND splnr IN s_splnr
    AND action = p_action.

ENDFORM.                    "get_split_status

*&---------------------------------------------------------------------*
*&      Form  display_header_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_header_status.

  REFRESH: it_fieldcat, it_data.

  fill_fieldcat 'VBELN' 'Order No.' 10.
  fill_fieldcat 'STATUS' 'Original Status' 20.
  fill_fieldcat 'STATUS_NEW' 'New Status' 20.

  LOOP AT it_vbakst INTO wa_vbakst.
    CLEAR wa_data.
    wa_data-vbeln = wa_vbakst-vbeln.
    wa_data-status = wa_vbakst-status.
    wa_data-status_new = wa_vbakst-status.
    APPEND wa_data TO it_data.
  ENDLOOP.

  PERFORM call_alv_display.

ENDFORM.                    "display_header_status

*&---------------------------------------------------------------------*
*&      Form  display_item_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_item_status.

  REFRESH: it_fieldcat, it_data.

  fill_fieldcat 'VBELN' 'Order No.' 10.
  fill_fieldcat 'POSNR' 'Item' 6.
  fill_fieldcat 'JOBNR' 'Job' 6.
  fill_fieldcat 'STATUS' 'Original Status' 20.
  fill_fieldcat 'STATUS_NEW' 'New Status' 20.

  LOOP AT it_vbapst INTO wa_vbapst.
    CLEAR wa_data.
    wa_data-vbeln = wa_vbapst-vbeln.
    wa_data-posnr = wa_vbapst-posnr.
    wa_data-jobnr = wa_vbapst-jobnr.
    wa_data-status = wa_vbapst-status.
    wa_data-status_new = wa_vbapst-status.
    APPEND wa_data TO it_data.
  ENDLOOP.

  PERFORM call_alv_display.

ENDFORM.                    "display_item_status

*&---------------------------------------------------------------------*
*&      Form  display_job_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_job_status.

  REFRESH: it_fieldcat, it_data.

  fill_fieldcat 'VBELN' 'Order No.' 10.
  fill_fieldcat 'JOBNR' 'Job' 6.
  fill_fieldcat 'STATUS' 'Original Status' 20.
  fill_fieldcat 'STATUS_NEW' 'New Status' 20.

  LOOP AT it_jobst INTO wa_jobst.
    CLEAR wa_data.
    wa_data-vbeln = wa_jobst-vbeln.
    wa_data-jobnr = wa_jobst-jobnr.
    wa_data-status = wa_jobst-status.
    wa_data-status_new = wa_jobst-status.
    APPEND wa_data TO it_data.
  ENDLOOP.

  PERFORM call_alv_display.


ENDFORM.                    "display_job_status

*&---------------------------------------------------------------------*
*&      Form  display_split_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_split_status.

  REFRESH: it_fieldcat, it_data.

  fill_fieldcat 'VBELN' 'Order No.' 10.
  fill_fieldcat 'POSNR' 'Item' 6.
  fill_fieldcat 'SPLNR' 'Split' 6.
  fill_fieldcat 'STATUS' 'Original Status' 20.
  fill_fieldcat 'STATUS_NEW' 'New Status' 20.

  LOOP AT it_splitst INTO wa_splitst.
    CLEAR wa_data.
    wa_data-vbeln = wa_splitst-vbeln.
    wa_data-posnr = wa_splitst-posnr.
    wa_data-splnr = wa_splitst-splnr.
    wa_data-status = wa_splitst-status.
    wa_data-status_new = wa_splitst-status.
    APPEND wa_data TO it_data.
  ENDLOOP.

  PERFORM call_alv_display.

ENDFORM.                    "display_split_status

*&---------------------------------------------------------------------*
*&      Form  set_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'YSTANDARD'.
ENDFORM.                    "set_pf_status

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm rs_selfield TYPE
slis_selfield.

  IF r_ucomm = 'OPEN'.
    PERFORM update_status USING p_action /dbe/cl_oe_status_handling=>c_open.


  ELSEIF r_ucomm = 'PARTIAL'.
    PERFORM update_status USING p_action /dbe/cl_oe_status_handling=>c_partial.

  ELSEIF r_ucomm = 'COMP'.
    PERFORM update_status USING p_action /dbe/cl_oe_status_handling=>c_complete.

  ELSEIF r_ucomm = 'CLOSE'.
    PERFORM exit_order.
  ENDIF.

ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  update_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ACTION   text
*      -->STATUS     text
*----------------------------------------------------------------------*
FORM update_status USING p_action status.

  DATA: v_lines TYPE i.
  DATA: v_index TYPE sy-tabix.
  IF p_header = 'X'.
    CALL METHOD lo_order->mo_status->set_header
      EXPORTING
        iv_action = p_action
        iv_status = status.
    READ TABLE it_data INTO wa_data INDEX 1.
    MESSAGE s398(00) WITH 'Order Header Status Changed from ' wa_data-status_new ' to ' status.
    MESSAGE s398(00) WITH 'Order Header Status Changed from ' wa_data-status_new ' to ' status INTO lv_dummy.
    lo_order->bal_add_symessage( ).
    wa_data-status_new = status.
    MODIFY it_data FROM wa_data INDEX 1.
    PERFORM call_alv_display.

  ELSEIF p_item = 'X'.
    CLEAR v_lines.
    LOOP AT it_data INTO wa_data WHERE box = 'X'.
      v_lines = v_lines + 1.
    ENDLOOP.
    IF v_lines = 0.
      MESSAGE s398(00) WITH 'Please select one record'.
    ELSEIF v_lines = 1.
      READ TABLE it_data INTO wa_data WITH KEY box = 'X'.
      v_index = sy-tabix.
      CALL METHOD lo_order->mo_status->set_item
        EXPORTING
          iv_action = p_action
          iv_status = status
          iv_posnr  = wa_data-posnr
          iv_jobnr  = wa_data-jobnr
          iv_tasknr = '000000'.
      CONCATENATE 'Order Item' wa_data-posnr 'Status Changed from' wa_data-status_new 'to' status INTO lv_message SEPARATED BY space.
      MESSAGE s398(00) WITH lv_message.
      MESSAGE s398(00) WITH lv_message INTO lv_dummy.
      lo_order->bal_add_symessage( ).
      wa_data-status_new = status.
      MODIFY it_data FROM wa_data INDEX v_index.
      PERFORM call_alv_display.
    ELSEIF v_lines > 1.
      MESSAGE s398(00) WITH 'Please select only one record'.
    ENDIF.


  ELSEIF p_job = 'X'.
    CLEAR v_lines.
    LOOP AT it_data INTO wa_data WHERE box = 'X'.
      v_lines = v_lines + 1.
    ENDLOOP.
    IF v_lines = 0.
      MESSAGE s398(00) WITH 'Please select one record'.
    ELSEIF v_lines = 1.
      READ TABLE it_data INTO wa_data WITH KEY box = 'X'.
      v_index = sy-tabix.
      CALL METHOD lo_order->mo_status->set_job
        EXPORTING
          iv_action = p_action
          iv_status = status
          iv_jobnr  = wa_data-jobnr.

      CONCATENATE 'Order Job' wa_data-jobnr 'Status Changed from' wa_data-status_new 'to' status INTO lv_message SEPARATED BY space.
      MESSAGE s398(00) WITH lv_message.
      MESSAGE s398(00) WITH lv_message INTO lv_dummy.
      lo_order->bal_add_symessage( ).
      wa_data-status_new = status.
      MODIFY it_data FROM wa_data INDEX v_index.
      PERFORM call_alv_display.
    ELSEIF v_lines > 1.
      MESSAGE s398(00) WITH 'Please select only one record'.
    ENDIF.
  ELSEIF p_split = 'X'.
    READ TABLE it_data INTO wa_data WITH KEY box = 'X'.
    v_index = sy-tabix.
    CALL METHOD lo_order->mo_status->set_split
      EXPORTING
        iv_action = p_action
        iv_status = status
        iv_posnr  = wa_data-posnr
        iv_splnr  = wa_data-splnr.
    CONCATENATE 'Order Split' wa_data-splnr 'Status Changed from' wa_data-status_new 'to' status INTO lv_message SEPARATED BY space.
    MESSAGE s398(00) WITH lv_message.
    MESSAGE s398(00) WITH lv_message INTO lv_dummy.
    lo_order->bal_add_symessage( ).
    wa_data-status_new = status.
    MODIFY it_data FROM wa_data INDEX v_index.
    PERFORM call_alv_display.

  ELSEIF p_splhdr = 'X'.
    READ TABLE it_data INTO wa_data WITH KEY box = 'X'.
    v_index = sy-tabix.
    CALL METHOD lo_order->mo_status->set_splhdr
      EXPORTING
        iv_action = p_action
        iv_status = status
*       iv_posnr  = wa_data-posnr
        iv_splnr  = wa_data-splnr.
    CONCATENATE 'Split header' wa_data-splnr 'Status Changed from' wa_data-status_new 'to' status INTO lv_message SEPARATED BY space.
    MESSAGE s398(00) WITH lv_message.
    MESSAGE s398(00) WITH lv_message INTO lv_dummy.
    lo_order->bal_add_symessage( ).
    wa_data-status_new = status.
    MODIFY it_data FROM wa_data INDEX v_index.
    PERFORM call_alv_display.
  ENDIF.

ENDFORM.                    "update_status

*&---------------------------------------------------------------------*
*&      Form  call_alv_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_alv_display .

  wa_layout-zebra = 'X'.
  wa_layout-box_fieldname = 'BOX'.
  wa_layout-box_tabname = 'IT_DATA'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
*     I_BYPASSING_BUFFER       = ' '
*     I_BUFFER_ACTIVE          = ' '
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE   = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME         =
*     I_BACKGROUND_ID          = ' '
*     I_GRID_TITLE             =
*     I_GRID_SETTINGS          =
      is_layout                = wa_layout
      it_fieldcat              = it_fieldcat
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        =
*     IT_SORT                  =
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     I_DEFAULT                = 'X'
*     I_SAVE                   = ' '
*     IS_VARIANT               =
*     IT_EVENTS                =
*     IT_EVENT_EXIT            =
*     IS_PRINT                 =
*     IS_REPREP_ID             =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
*     I_HTML_HEIGHT_TOP        = 0
*     I_HTML_HEIGHT_END        = 0
*     IT_ALV_GRAPHICS          =
*     IT_HYPERLINK             =
*     IT_ADD_FIELDCAT          =
*     IT_EXCEPT_QINFO          =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
*     ES_EXIT_CAUSED_BY_USER   =
    TABLES
      t_outtab                 = it_data
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " call_alv_display

*&---------------------------------------------------------------------*
*&      Form  EXIT_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM exit_order.

  CALL FUNCTION '/DBE/OE_MAIN_CONTROL'
    EXPORTING
      iv_event         = /dbe/cl_order_engine=>c_ord_exit
      io_order         = lo_order
    EXCEPTIONS
      internal_error   = 1
      nothing_selected = 2
      action_error     = 3
      OTHERS           = 4.

  SUBMIT zvss_correct_status VIA SELECTION-SCREEN
  WITH p_vbeln = p_vbeln
  WITH p_action = p_action.


ENDFORM.                    "EXIT_ORDER
*&---------------------------------------------------------------------*
*&      Form  get_splhdr_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM get_splhdr_status .

  SELECT *
   FROM /dbe/oe_splhdrst
   INTO TABLE it_splhdr
   WHERE vbeln = p_vbeln
*   AND posnr IN s_posnr
   AND splnr IN s_splnr
   AND action = p_action.


ENDFORM.                    " get_splhdr_status
*&---------------------------------------------------------------------*
*&      Form  display_splhdr_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_splhdr_status .

  REFRESH: it_fieldcat, it_data.

  fill_fieldcat 'VBELN' 'Order No.' 10.
*  fill_fieldcat 'POSNR' 'Item' 6.
  fill_fieldcat 'SPLNR' 'Split' 6.
  fill_fieldcat 'STATUS' 'Original Status' 20.
  fill_fieldcat 'STATUS_NEW' 'New Status' 20.

  LOOP AT it_splhdr INTO wa_splhdr.
    CLEAR wa_data.
    wa_data-vbeln = wa_splhdr-vbeln.
*    wa_data-posnr = wa_splitst-posnr.
    wa_data-splnr = wa_splhdr-splnr.
    wa_data-status = wa_splhdr-status.
    wa_data-status_new = wa_splhdr-status.
    APPEND wa_data TO it_data.
  ENDLOOP.

  PERFORM call_alv_display.

ENDFORM.                    " display_splhdr_status
