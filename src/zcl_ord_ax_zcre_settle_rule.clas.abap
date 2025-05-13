class ZCL_ORD_AX_ZCRE_SETTLE_RULE definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_OE_ACTION_EXE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ORD_AX_ZCRE_SETTLE_RULE IMPLEMENTATION.


  METHOD /dbe/if_oe_action_exe~execution.
    DATA: lo_order TYPE REF TO /dbe/cl_order,
          lv_old,
          lv_subrc TYPE sysubrc.

    DATA : lt_mt_resb_com   TYPE /dbe/resb_com_tt,
           ls_mt_resb_com   TYPE /dbe/resb_com,
           ls_mt_splhdr_com TYPE /dbe/splhdr_job.

    TYPES: BEGIN OF t_veh_list,
             vguid       TYPE vlc_guid,
             dbm_coaufnr TYPE aufnr,
           END OF t_veh_list.
    TYPES: tt_veh_list TYPE STANDARD TABLE OF t_veh_list.
    TYPES: BEGIN OF t_aufnr_list,
             vguid TYPE vlc_guid,
             aufnr TYPE aufnr,
           END OF t_aufnr_list.
    TYPES: tt_aufnr_list TYPE STANDARD TABLE OF t_aufnr_list.

    DATA :lt_veh_list   TYPE tt_veh_list,
          ls_veh_list   TYPE t_veh_list,
          lt_aufnr_list TYPE tt_aufnr_list,
          ls_aufnr_list TYPE t_aufnr_list.


    lo_order  ?= io_ord_object.

*    lt_mt_resb_com[] = lo_order->mt_resb_com[].

*    READ TABLE lt_mt_resb_com INTO ls_mt_resb_com INDEX 1.
*    IF sy-subrc EQ 0.
*      READ TABLE lo_order->mt_splhdr_com INTO ls_mt_splhdr_com INDEX 1.
*      IF sy-subrc EQ 0.
*        ls_mt_splhdr_com-aufnr_rec = ls_mt_resb_com-aufnr.
*        APPEND ls_mt_splhdr_com TO lo_order->mt_splhdr_detail.
*        lo_order->splhdr_change( ).
*      ENDIF.

    LOOP AT lo_order->mt_splhdr_com INTO ls_mt_splhdr_com WHERE slctd_ext = 'X'.
      LOOP AT lo_order->mt_split_com ASSIGNING FIELD-SYMBOL(<fs_split_com>)
              WHERE splnr = ls_mt_splhdr_com-splnr
                AND slctd = abap_true.
        READ TABLE lo_order->mt_vbap_com ASSIGNING FIELD-SYMBOL(<fs_vbap_com>)
                                         WITH KEY posnr = <fs_split_com>-posnr BINARY SEARCH.
        IF sy-subrc EQ 0.
          CHECK <fs_vbap_com>-vguid IS NOT INITIAL.
          ls_veh_list-vguid = <fs_vbap_com>-vguid.
          APPEND ls_veh_list TO lt_veh_list.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

    IF lt_veh_list IS NOT INITIAL.
      SELECT vguid /dbe/coaufnr   FROM vlcvehicle INTO TABLE lt_aufnr_list
        FOR ALL ENTRIES IN lt_veh_list
        WHERE vguid = lt_veh_list-vguid.
    ENDIF.


    LOOP AT lo_order->mt_splhdr_com INTO ls_mt_splhdr_com WHERE slctd_ext = 'X'.
      LOOP AT lo_order->mt_split_com ASSIGNING <fs_split_com>
              WHERE splnr = ls_mt_splhdr_com-splnr
                AND slctd = abap_true.
        READ TABLE lo_order->mt_vbap_com ASSIGNING <fs_vbap_com>
                                         WITH KEY posnr = <fs_split_com>-posnr BINARY SEARCH.
        IF sy-subrc EQ 0.
          READ TABLE lt_aufnr_list INTO ls_aufnr_list WITH KEY vguid = <fs_vbap_com>-vguid.
          IF sy-subrc EQ 0.
            ls_mt_splhdr_com-aufnr_rec = ls_aufnr_list-aufnr. "ls_mt_resb_com-aufnr.
            APPEND ls_mt_splhdr_com TO lo_order->mt_splhdr_detail.
          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDLOOP.
    lo_order->splhdr_change( ).

*    ENDIF.

    CALL FUNCTION 'ZDBE_CO_ACT_CREATE_SETTLE_RULE'
      EXPORTING
        iv_action      = iv_action
        io_order       = lo_order
        lt_aufnr_list  = lt_aufnr_list
      EXCEPTIONS
        internal_error = 1
        nothing_done   = 2
        action_error   = 3
        OTHERS         = 4.

    lv_subrc = sy-subrc.

    CASE lv_subrc.
      WHEN 0.
        cv_success = /dbe/cl_order_engine=>c_action_ok.
      WHEN 1.
*     pass faulty action to wrapper for error log
        lo_order->mo_wrapper->ms_oe_control-action = lo_order->ms_oe_control-action.
        IF sy-msgty IS NOT INITIAL.
          lo_order->bal_add_symessage( ).
        ENDIF.
        MOVE-CORRESPONDING:
          lo_order->ms_dialog_control TO lo_order->ms_oe_control,
          lo_order->ms_dialog_control TO lo_order->ms_ord_dialog_control.
        RAISE EXCEPTION TYPE /dbe/cx_oe_internal_error.
      WHEN 2.
        IF cv_success IS INITIAL OR cv_success = 'X'.
          IF sy-msgno IS NOT INITIAL.
            lo_order->bal_add_symessage( ).
          ENDIF.
          cv_success = /dbe/cl_order_engine=>c_action_not_done.
        ENDIF.
      WHEN 3.
        cv_success = /dbe/cl_order_engine=>c_action_error.
*     pass faulty action to wrapper for error log
        lo_order->mo_wrapper->ms_oe_control-action = lo_order->ms_oe_control-action.
        MOVE-CORRESPONDING:
          lo_order->ms_dialog_control TO lo_order->ms_oe_control,
          lo_order->ms_dialog_control TO lo_order->ms_ord_dialog_control.
        RAISE EXCEPTION TYPE /dbe/cx_oe_action_error.
      WHEN OTHERS.
    ENDCASE.
    CALL METHOD lo_order->bal_ac_error_handling
      EXCEPTIONS
        action_error   = 1
        internal_error = 2
        OTHERS         = 3.
    CASE sy-subrc.
      WHEN 1.
        cv_success = /dbe/cl_order_engine=>c_action_error.
*     pass faulty action to wrapper for error log
        lo_order->mo_wrapper->ms_oe_control-action = lo_order->ms_oe_control-action.
        MOVE-CORRESPONDING:
          lo_order->ms_dialog_control TO lo_order->ms_oe_control,
          lo_order->ms_dialog_control TO lo_order->ms_ord_dialog_control.
        RAISE EXCEPTION TYPE /dbe/cx_oe_action_error.
      WHEN 2.
*     pass faulty action to wrapper for error log
        lo_order->mo_wrapper->ms_oe_control-action = lo_order->ms_oe_control-action.
        MOVE-CORRESPONDING:
          lo_order->ms_dialog_control TO lo_order->ms_oe_control,
          lo_order->ms_dialog_control TO lo_order->ms_ord_dialog_control.
        RAISE EXCEPTION TYPE /dbe/cx_oe_internal_error.
      WHEN OTHERS.
    ENDCASE.

    MOVE-CORRESPONDING:
      lo_order->ms_dialog_control TO lo_order->ms_oe_control,
      lo_order->ms_dialog_control TO lo_order->ms_ord_dialog_control.
  ENDMETHOD.
ENDCLASS.
