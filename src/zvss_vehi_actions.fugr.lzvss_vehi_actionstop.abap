FUNCTION-POOL zvss_vehi_actions.            "MESSAGE-ID ..

* INCLUDE LZVSS_VEHI_ACTIONSD...             " Local class definition

TYPE-POOLS: vlch,   " Vehicle Management System
            abap,
            kabrt,
            ibxx,   " IBase
            mrm,    " Incoming Invoice
            mmcr,   " Material Management
            vlcc.

* VMS Constant include
*INCLUDE lvelo02con.

TABLES: /dbe/v_ivehicle,
        /dbe/order_search,
        ekko,                                               "1124034
        rbkp.                                                            "End of 1124034

CONSTANTS:
  gc_action_program          TYPE syrepid VALUE 'SAPLZVSS_VEHI_ACTIONS'.


**Constants definition
*INCLUDE: /dbm/lvm08con.
**Init constants
*INCLUDE: /dbm/lvm01ini.
**Type definition
*INCLUDE: /dbm/lvm08typ.
**Comunication variables
*INCLUDE: /dbm/lvm08var.
**Class definition/implementation for addtional data table view
*INCLUDE /dbm/lvm08cl1.
**Class definition/implementation for multi Iobject table controll
*INCLUDE /dbm/lvm08cl2.
**Communication pbo/pai
**INCLUDE /dbm/lvm08com.
**include LVELO15ACT.


* types
TYPES:
  BEGIN OF t_s_ordnr_f4,
    vbeln      TYPE /dbe/vbeln_va,
    aufart     TYPE /dbe/aufart,
    aufart_txt TYPE /dbe/aufart_txt,
    engine     TYPE /dbe/c_order_engine,
    engine_txt TYPE /dbe/c_order_engine_txt,
  END OF t_s_ordnr_f4.
TYPES:
 t_t_ordnr_f4  TYPE STANDARD TABLE OF t_s_ordnr_f4.

TYPES: tt_emseg   TYPE STANDARD TABLE OF emseg.


DATA: badi_qccv_execute_go TYPE REF TO /dbe/badi_qccv_execute.
DATA: badi_qcas_execute_go TYPE REF TO /dbe/badi_qcas_execute.
DATA: badi_cpgm_execute    TYPE REF TO /dbe/badi_cpgm_execute.
DATA: badi_qrcc_execute    TYPE REF TO /dbe/badi_qrcc_execute.


************************************************************************
* Constants for /dbe/VM13_PO_ITEMS_GENERATE

CONSTANTS:
*--> Account assignment category for
  gc_acctasscat   TYPE c                VALUE 'K',
  gc_acctasscat_k TYPE c                VALUE 'K',
  gc_acctasscat_f TYPE c                VALUE 'F',

*-->Item Category for PO
  gc_item_cat     TYPE c                VALUE '0'.


************************************************************************
* Global data for BuPa creation
*{   DELETE         "by ismail
*DATA: gv_partner TYPE bu_partner,
*      go_bp      TYPE REF TO /dbe/cl_cu_business_partner.
*{   DELETE         "by ismail
DATA: gv_text_press_save TYPE string.

* Global table of item data containing all vehicles involved in the
* action in process.
DATA:    vlcactdata_item_gt TYPE STANDARD TABLE OF vlcactdata_item_s
                         WITH KEY vguid.
* Global table of additional vehicle data containing all vehicles
* involved in the action in process.
DATA:    vlcadddata_item_gt TYPE TABLE OF vlcadddata_item_s
                          WITH KEY vguid.
* Global table of additional vehicle data containing the selected
* vehicle only.
DATA:    vlcadddata_vhcl_gt TYPE TABLE OF vlcadddata_vhcl_s.

* Global data for assignment of a sales document to a vehicle
DATA:    vlcactdata_assignment_gs TYPE vlcactdata_assignment.
