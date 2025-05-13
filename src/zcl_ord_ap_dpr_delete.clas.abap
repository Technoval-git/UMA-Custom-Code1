class ZCL_ORD_AP_DPR_DELETE definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /DBE/IF_OE_ACTION_PRE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ORD_AP_DPR_DELETE IMPLEMENTATION.


  METHOD /dbe/if_oe_action_pre~prepare.
    DATA : lo_order   TYPE REF TO /dbe/cl_order,
           lo_dpr     TYPE REF TO /dbe/cl_ord_dpr,
           lv_index_i TYPE sytabix,
           lv_index_h TYPE sytabix,
           lv_dummy   TYPE c.

    FIELD-SYMBOLS:
      <objects>    LIKE LINE OF lo_order->mt_objects,
      <splhdr_com> LIKE LINE OF lo_order->mt_splhdr_com,
      <header>     LIKE LINE OF lo_dpr->mt_header_com,
      <item>       LIKE LINE OF lo_dpr->mt_item_com.

    lo_order ?= io_ord_object.
    TRY.

        READ TABLE lo_order->mt_objects ASSIGNING <objects>
          WITH KEY classname = '/DBE/CL_ORD_DPR'.
        IF sy-subrc = 0.
          lo_dpr ?= <objects>-objref.
        ELSE.
          MESSAGE e030(/dbe/oe) WITH '/DBE/CL_ORD_DPR'
            INTO lv_dummy.
          lo_order->bal_add_symessage( ).
        ENDIF.

        READ TABLE lo_dpr->mt_header_com INTO DATA(ls_dpr_head_com) WITH KEY slctd_ext = 'X'.
        IF sy-subrc NE 0.
          LOOP AT lo_order->mt_splhdr_com INTO DATA(lv_splhdr_com).
            lo_order->ext_slctd_set( EXPORTING iv_index = sy-tabix iv_tabname = 'MT_SPLHDR_COM'
              EXCEPTIONS
                parameter_error = 1
                OTHERS          = 2 ).

            lo_order->int_slctd_set( EXPORTING iv_index = sy-tabix iv_tabname = 'MT_SPLHDR_COM'
              EXCEPTIONS
                parameter_error = 1
                OTHERS          = 2 ).


            LOOP AT lo_dpr->mt_header_com ASSIGNING <header>  WHERE splnr = lv_splhdr_com-splnr.

              lo_dpr->ext_slctd_set( EXPORTING iv_index = sy-tabix iv_tabname = 'MT_HEADER_COM'
                EXCEPTIONS
                  parameter_error = 1
                  OTHERS          = 2 ).

            ENDLOOP.
          ENDLOOP.
        ENDIF.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
