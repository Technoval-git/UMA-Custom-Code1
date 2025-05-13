*&---------------------------------------------------------------------*
*& Include          ZMM_PICKING_SLIP_PRINT_TOP
*&---------------------------------------------------------------------*
"Table Declarations
TABLES : nast,                  "Messages
         tnapr,                 "Progrms and Forms
         itcpo.                 "Communication Area for Spool

"Local Clas Declaration.
CLASS lcl_print_form DEFINITION DEFERRED.

"Constant Declaration.
*CONSTANTS lc_prntev_new  VALUE '1'.

"Data Declaration
DATA go_print_form TYPE REF TO lcl_print_form.
*DATA go_output_po TYPE REF TO cl_purchase_order_output.
