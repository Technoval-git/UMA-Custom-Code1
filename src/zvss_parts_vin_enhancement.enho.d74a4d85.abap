"Name: \PR:/DBE/SAPLORDER_UI\FO:F_SCREEN_MOD_ORDER_CREATION\SE:END\EI
ENHANCEMENT 0 ZVSS_PARTS_VIN_ENHANCEMENT.
  IF ls_ordertp-engine EQ 'MM'.

*    LOOP AT SCREEN.
*      IF screen-group1 EQ 'VEH'.
**   invisible
*        screen-active = 1.
*        screen-input  = 1.
*      ELSE.
***   visible, maintainable
*        screen-active = 1.
**        screen-input  = 0.
*      ENDIF.
*      MODIFY SCREEN.
*    ENDLOOP.
*    CLEAR /dbe/order_creation-no_vehicle.

    LOOP AT SCREEN.
      IF sy-calld IS INITIAL
      OR sy-binpt = 'X'.                                    "1233185
        IF screen-name = '/DBE/ORDER_CREATION-VHVIN'
        OR screen-name = '/DBE/ORDER_CREATION-LICPL'
        OR screen-name = '/DBE/ORDER_CREATION-LICPL_COUNTRY'
        OR screen-name = '/DBE/ORDER_CREATION-NO_VEHICLE'.
          screen-active = 1.
          screen-input  = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

      IF NOT sy-calld IS INITIAL
      AND sy-binpt IS INITIAL                               "1233185
      AND gv_enable_vehi_fields NE abap_true.               " 1386827
        IF screen-name = '/DBE/ORDER_CREATION-VHVIN'
         OR screen-name = '/DBE/ORDER_CREATION-LICPL'
         OR screen-name = '/DBE/ORDER_CREATION-LICPL_COUNTRY'
         OR screen-name = '/DBE/ORDER_CREATION-NO_VEHICLE'.
          screen-active = 1.
          screen-input  = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
      IF screen-name = '/DBE/ORDER_CREATION-MCODESD'.
        screen-active = 1.
        screen-input  = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    IF ls_ordertp-doc_type = '05'.
*        backeend does not allow value increase without vehicle
      LOOP AT SCREEN.
        IF screen-name = '/DBE/ORDER_CREATION-NO_VEHICLE'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDENHANCEMENT.
