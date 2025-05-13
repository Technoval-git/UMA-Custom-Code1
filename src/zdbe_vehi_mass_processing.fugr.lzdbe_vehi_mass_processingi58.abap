*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGI58 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SHOW_HIDE_FIELDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_hide_fields INPUT.

  LOOP AT SCREEN.

    CASE gv_action.
      WHEN /DBE/if_vms_constants=>c_qapo.
        IF vlcactdata_head_s-bldat = 'X'
          OR vlcactdata_head_s-budat = 'X'.
          screen-invisible = 'X'.
        ENDIF.
        MODIFY SCREEN.
      WHEN /DBE/if_vms_constants=>c_qagr.
      WHEN /DBE/if_vms_constants=>c_qain.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " SHOW_HIDE_FIELDS  INPUT
