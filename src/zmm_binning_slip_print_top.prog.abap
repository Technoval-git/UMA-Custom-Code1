*&---------------------------------------------------------------------*
*& Include          ZMM_PICKING_SLIP_PRINT_TOP
*&---------------------------------------------------------------------*
"Table Declarations
TABLES : nast,                  "Messages
         tnapr,                 "Progrms and Forms
         itcpo.                 "Communication Area for Spool

"Local Clas Declaration.
CLASS lcl_print_form DEFINITION DEFERRED.


"Data Declaration
DATA go_print_form TYPE REF TO lcl_print_form.
