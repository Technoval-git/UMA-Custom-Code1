*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGO28 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GENERATE_ALVGRID_ININVOICE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE generate_alvgrid_ininvoice OUTPUT.

    PERFORM f_create_alv_grid_inv.

ENDMODULE.                 " GENERATE_ALVGRID_ININVOICE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  m_currency_update_vm13 OUTPUT                 N:2304203
*&---------------------------------------------------------------------*
MODULE m_currency_update_vm13 OUTPUT.

    PERFORM f_currency_update_vm13.

ENDMODULE.                 " m_currency_ininvoice  OUTPUT


*&---------------------------------------------------------------------*
*&      Form  f_currency_update_vm13                          N:2304203
*&---------------------------------------------------------------------*
FORM f_currency_update_vm13.
  FIELD-SYMBOLS: <ekko> TYPE ekko,
                 <rbkp> TYPE rbkp.

* currency is set by action prepare FMs e.g. /DBE/VM13_QINV_PREPARE in function group /DBE/VM13 so take it over N:2304203
  ASSIGN ('(/DBE/SAPLVM13)ekko') TO <ekko>.
  IF <ekko> IS ASSIGNED.
    ekko-waers = <ekko>-waers.
  ENDIF.

  ASSIGN ('(/DBE/SAPLVM13)rbkp') TO <rbkp>.
  IF <rbkp> IS ASSIGNED.
    rbkp-waers = <rbkp>-waers.
  ENDIF.

ENDFORM.
