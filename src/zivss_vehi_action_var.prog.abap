*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_ACTION_VAR
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           /DBE/LVM08VAR
*&---------------------------------------------------------------------*

*Global variable needed for all action,navigation, screens.
DATA: actiontext_gv TYPE vlc_actiont.
*VMS Comunication structures
DATA: gs_vlcdiavehi        TYPE vlcdiavehi.
DATA: gs_vlcactdata_head   TYPE vlcactdata_head_s.
DATA: gs_vlcactdata_item   TYPE vlcactdata_item_s.
DATA: gt_vlcadddata        TYPE vlcadddata_item_t.
*IObject communication structures
DATA: gs_iobj_single       TYPE /dbe/iobj_data_single_com_s.
DATA: gs_iobj_multi        TYPE /dbe/iobj_data_multi_com_s.
DATA: /dbe/v_imodel_old     TYPE /dbe/v_imodel.
*IObject id
DATA: gv_iobj_guid         TYPE /dbe/exts_ouid.
*IObject logical system in case external data system
DATA: gv_iobj_logsys       TYPE logsys.
*IObject family
DATA: gv_iobj_family       TYPE /dbe/exts_obj_family.
*IObject category id
DATA: gv_iobj_catid        TYPE /dbe/exts_category_id.
*Screens tables declaration
*VMS structures
TABLES:
*Global structure of header data used on the subscreens
  vlcactdata_head_s,
*Global structure of item data used on the subscreens
  vlcactdata_item_s,
  vlcdiavehi,
* Partner data,used on the subscreens
  /dbe/v_ipartner_dynp.

CLASS lcl_adddata_event_handler  DEFINITION DEFERRED.
CLASS lcl_iobj_multi_alv_control DEFINITION DEFERRED.

*Type for IObject multi controls
TYPES: BEGIN OF control_type,
         progname           TYPE progname,
         dynnr              TYPE dynnr,
         control_name(40)   TYPE c,
         tabname            TYPE tabname,
         tabname_ext        TYPE tabname,
         alv_ref            TYPE REF TO cl_gui_alv_grid,
         event_receiver_ref TYPE REF TO lcl_iobj_multi_alv_control,
         container_ref      TYPE REF TO cl_gui_custom_container,
       END OF control_type.
TYPES: control_type_t TYPE STANDARD TABLE OF control_type.

*Global table for IObject controls
DATA:  gt_iobj_multi_control TYPE control_type_t.

*Type for registered settypes
TYPES: BEGIN OF scr_settype_type,
         progname     TYPE progname,
         dynnr        TYPE dynnr,
         settype_name TYPE /dbe/exts_set_id,
       END OF scr_settype_type.

TYPES: scr_settype_type_t TYPE STANDARD TABLE OF scr_settype_type.
*Global table for registered settypes
DATA:  gt_registered_settypes TYPE scr_settype_type_t.

*Type for additional data - qualifiers
TYPES: BEGIN OF adddata_type,
         progname          TYPE progname,
         dynnr             TYPE dynnr,
         container_adddata TYPE REF TO cl_gui_custom_container,
         alv_control       TYPE REF TO cl_gui_alv_grid,
       END OF adddata_type.

TYPES: adddata_type_t TYPE STANDARD TABLE OF adddata_type.
*Global table for additional table control
DATA: gt_adddata_cntrl   TYPE adddata_type_t.

* Global table of additional vehicle data
DATA: gt_vlcadddata_vhcl     TYPE TABLE OF vlcadddata_vhcl_s.
*function-code
DATA: gv_ok_code LIKE sy-ucomm.
DATA: ok_code LIKE sy-ucomm.
DATA: gv_cursor_field(40).

*Set by /DBE/VM08_LAUNCH_VM when called from outside.
*The caller can specify the desired function to be able to
*distinguish why VM was called, e.g. vehicle assignment.
DATA: gv_external_function TYPE syucomm.

* fill the screen short texts
TABLES: tspat,
        cvlc13t,
        tvkot,
        tvtwt,
        /dbe/v_bustypet,
        t001w,
        t001l,
        comt_categoryt,
        t161t,
        t024e,
        t024,
        m_kostn,
        lfa1,
        m_anlka,
        /dbe/sch_rgrdeft,
        p1000,
        /dbe/s_veh_shorttext_plant1,
        /dbe/s_veh_shorttext_plant2,
        /dbe/s_veh_shorttext_strloc1,
        /dbe/s_veh_shorttext_strloc2.

* Global data for BuPa creation
DATA: gv_partner TYPE bu_partner,                           "N:2651732
      go_bp      TYPE REF TO /dbe/cl_cu_business_partner.
