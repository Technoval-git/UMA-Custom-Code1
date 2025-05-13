FUNCTION ZDBE_SH_CONTACT_PERSON.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------
  DATA:
    lv_bp              TYPE bu_partner,
    lv_lines           TYPE /dbe/hits,
    lt_rel             TYPE STANDARD TABLE OF esd_kna1_but051,
    lo_vehicle         TYPE REF TO /dbe/cl_veh_dbmvehicle,
    lo_veh_buf         TYPE REF TO /dbe/cl_veh_buf,
    lt_bob             TYPE /dbe/t_veh_bob,
    ls_bob             TYPE /dbe/s_veh_bob,
    lr_item_data       TYPE REF TO data,
    lr_vlcactdata_item TYPE REF TO vlcactdata_item_s,
    ls_fieldprop       LIKE LINE OF shlp-fieldprop.


  IF callcontrol-step <> 'SELECT' AND
     callcontrol-step <> 'RETURN'.
    EXIT.
  ENDIF.

************************************************************************
* Display Customer relations
************************************************************************
  lv_bp = vlcactdata_item_s-endcu.

  IF lv_bp IS INITIAL.
    lo_veh_buf = /dbe/cl_veh_buf=>get_instance( ).
    TRY.
        CALL METHOD lo_veh_buf->get_all
          RECEIVING
            rt_bob = lt_bob.
    ENDTRY.

    READ TABLE lt_bob INTO ls_bob INDEX 1.
    IF sy-subrc = 0.
      lo_vehicle ?= ls_bob-bobref.
      TRY.
          lr_item_data  = lo_vehicle->get_data_com( lo_vehicle->gc_vlcactdata_item_s ).
        CATCH /dbe/cx_veh_layer_not_found .
      ENDTRY.
      IF lr_item_data IS BOUND.
        lr_vlcactdata_item ?= lr_item_data.
      ENDIF.
    ENDIF.

    lv_bp = lr_vlcactdata_item->*-endcu.
  ENDIF.

  SELECT
      *
    FROM esd_kna1_but051
    INTO TABLE lt_rel[]
    WHERE
      partner = lv_bp.
  IF sy-subrc <> 0.
    "No values found - not an error
    RETURN.
  ENDIF.

  CALL FUNCTION 'F4UT_RESULTS_MAP'
    TABLES
      shlp_tab    = shlp_tab
      record_tab  = record_tab
      source_tab  = lt_rel[]
    CHANGING
      shlp        = shlp
      callcontrol = callcontrol.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  "If only one entry exists return data, no selection needed
  DESCRIBE TABLE lt_rel[] LINES lv_lines.
  IF lv_lines = 1 OR lv_lines = 0.
    callcontrol-step = 'RETURN'.
  ELSE.
    callcontrol-step = 'DISP'.
  ENDIF.

  IF callcontrol-step = 'RETURN'.
    "Select fields for output
    LOOP AT shlp-fieldprop INTO ls_fieldprop.
      IF 'RELATIONSPARNR_BP_NAME' CS ls_fieldprop-fieldname.
        ls_fieldprop-shlpoutput = 'X'.
        MODIFY shlp-fieldprop FROM ls_fieldprop.
      ENDIF.
    ENDLOOP.
    EXIT.
  ENDIF.


ENDFUNCTION.
