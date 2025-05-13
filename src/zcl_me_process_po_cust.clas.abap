class ZCL_ME_PROCESS_PO_CUST definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_ME_PROCESS_PO_CUST .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ME_PROCESS_PO_CUST IMPLEMENTATION.


  method IF_EX_ME_PROCESS_PO_CUST~CHECK.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~CLOSE.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_HEADER.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_HEADER_REFKEYS.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_ITEM.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_ITEM_REFKEYS.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~INITIALIZE.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~OPEN.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~POST.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~PROCESS_ACCOUNT.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~PROCESS_HEADER.
  endmethod.


  METHOD if_ex_me_process_po_cust~process_item.

    DATA v_data_item TYPE mepoitem.
    DATA lv_phas1 TYPE coas-phas1.
    data lw_low type RVARI_VAL_255.
*    * Retrieve item data.
    CALL METHOD im_item->get_data
      RECEIVING
        re_data = v_data_item.

    SELECT SINGLE low INTO lw_low FROM tvarvc WHERE name = 'VSS_PO_BLOCK' AND type = 'P'.
      IF lw_low = 'X'.
        v_data_item-insmk = 'S' .
**      ELSEIF v_data_item-bednr <> ''.
**
**        SELECT SINGLE phas1 FROM coas INTO lv_phas1 WHERE     /dbe/vbeln  = v_data_item-bednr.
**        IF sy-subrc = 0.
**          v_data_item-insmk = 'S' .
**        ENDIF.

      ENDIF.


*update changes
      CALL METHOD im_item->set_data( v_data_item ).
    ENDMETHOD.


  method IF_EX_ME_PROCESS_PO_CUST~PROCESS_SCHEDULE.
  endmethod.
ENDCLASS.
