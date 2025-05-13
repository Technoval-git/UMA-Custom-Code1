*&---------------------------------------------------------------------*
*& Include          ZMM_STO_DELIVERY_FORM_TOP
*&---------------------------------------------------------------------*
TABLES : nast,                  "Messages
         tnapr,                 "Progrms and Forms
         itcpo.                 "Communication Area for Spool

"Local Clas Declaration.
CLASS lcl_print_form DEFINITION DEFERRED.


"Data Declaration
DATA go_print_form TYPE REF TO lcl_print_form.
