*&---------------------------------------------------------------------*
*& Include          ZMM_PPC_POOL_LIST_PBO_PAI
*&---------------------------------------------------------------------*

MODULE status_1001 OUTPUT.
  SET PF-STATUS 'PR_REQ'.
  SET TITLEBAR 'PR_TITLE'.
  PERFORM split_container.
  PERFORM f_material_stock.
ENDMODULE.

*&**********************************************************************
*&   Author           : Gaurav                                         *
*&   Date             : 15-07-2017                                     *
*&   Company          : Maventic Innovative solutions Pvt. Ltd.        *
*&   Module Name      : USER_COMMAND_1001  INPUT                       *
*
*&**********************************************************************
*& Module Definition  : PAI module (DE1K905556)                        *
*&
*&**********************************************************************
*& MODULE CHANGES / Modification Logs :                                *
*&**********************************************************************
*&   Date   | Request    | Programmer   |     Changes                  *
*&+-------------------------------------------------------------------+*
*& 15.07.17 | DE1K905556 | Gaurav       |       New                    *
*&+-------------------------------------------------------------------+*
MODULE user_command_1001 INPUT.
  DATA: ls_eban TYPE ty_eban.

  FIELD-SYMBOLS: <fs_eban> TYPE ty_eban.

  CASE sy-ucomm.
    WHEN 'BACK'.
      PERFORM f_clear_global_variables.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL' OR 'EXIT'.
      PERFORM f_clear_global_variables.
      LEAVE PROGRAM.
    WHEN 'FC_PO'.
*      it_eban = it_eban_prev.
      LOOP AT it_eban ASSIGNING <fs_eban>.
        READ TABLE it_eban_prev INTO ls_eban
          WITH KEY banfn = <fs_eban>-banfn
                   bnfpo = <fs_eban>-bnfpo.
        IF sy-subrc = 0.
          <fs_eban>-menge = ls_eban-menge.
        ENDIF.
      ENDLOOP.
      PERFORM f_validate_po_creation.
      it_eban_prev = it_eban.
      PERFORM f_display_pr.
    WHEN 'FC_CANCEL'.
      PERFORM f_cancel_pr.
  ENDCASE.
ENDMODULE.
