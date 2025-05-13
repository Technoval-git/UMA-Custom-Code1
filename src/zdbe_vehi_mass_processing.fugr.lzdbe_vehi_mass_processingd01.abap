**&---------------------------------------------------------------------*
**&  Include           /DBE/LVEHI_MASS_PROCESSINGD01
**&---------------------------------------------------------------------*
*
*
*TABLES: vlcselvehi, vlcvehicle, vlcdiavehi, vlcgreceipt, vlcincinvoice, /DBE/V_IPRICES, /DBE/V_IPARTNER, vlcporder,
*        /DBE/V_IMODEL, /DBE/vbak_db, /DBE/wtyd_order, /DBE/v_model, /DBE/V_IWTY,/DBE/V_IVEHICLE, "/DBE/wty_std,
*        vlcactdata_item_s ,vlcactdata_head_s ,/DBE/v_mcatalogt,/DBE/v_bustypet ,
*        tspat ,cvlc13t ,t001w ,comt_categoryt ,tvkot ,tvtwt,/DBE/V_IPARTNER_DYNP_SV,
*        /DBE/v_modelt ,/DBE/vm_fields_crea,/DBE/veh_blk_act ,t001l,cvlc03 ,cvlc03t.
*
*TYPES: BEGIN OF tty_invoice_info ,
*          vhcle         TYPE vlcactdata_item_s-vhcle ,"vlc_vhcle,
*          netpr         TYPE bprei,
*          currency      TYPE waers,
*          werks         TYPE werks,
*          gross_amount  TYPE rmwwr,
*          tax_code      TYPE vlcactdata_head_s-tax_code ,"mwskz,
*          tax_amount    TYPE wmwst,
*       END OF tty_invoice_info.
*
*TYPES: BEGIN OF tty_po_info ,
*          vguid         TYPE vlcactdata_item_s-vguid,
*          vhcle         TYPE vlcactdata_item_s-vhcle ,"vlc_vhcle,
*          netpr         TYPE bprei,
*          currency      TYPE vlcactdata_head_s-currency,
*          po_number     TYPE vlcactdata_item_s-po_number,
*          eindt_changed TYPE vlcactdata_item_s-eindt_changed,
*       END OF tty_po_info,
*
*       BEGIN OF tty_po_del_info ,
*          vguid         TYPE vlcactdata_item_s-vguid,
*          vhcle         TYPE vlcactdata_item_s-vhcle ,"vlc_vhcle,
*          po_number     TYPE vlcactdata_item_s-po_number,
*          po_item       TYPE vlcactdata_item_s-po_item,
*          ekorg         TYPE vlcactdata_head_s-ekorg,
*          ekgrp         TYPE vlcactdata_head_s-ekgrp,
*       END OF tty_po_del_info.
*
*TYPES: BEGIN OF ty_po_cre_diff_delvdate,
*         vguid          TYPE vlc_guid,
*         vhcle          TYPE vlc_vhcle,
*         netpr          TYPE netpr,
*         currency       TYPE vlcactdata_head_s-currency,
*         eindt          TYPE eindt,
*       END OF ty_po_cre_diff_delvdate.
*
**Type for screen actions
*TYPES: BEGIN OF action_type.
**include structure CVLC03.
*TYPES:  action          TYPE cvlc03.
*TYPES:  actiont         TYPE vlc_actiont.
*TYPES:  authority       TYPE c.
*TYPES:  naventry        TYPE /DBE/naventry,
*       END OF action_type.
*
**Type for registered settypes
*TYPES: BEGIN OF scr_settype_type,
*        progname        TYPE progname,
*        dynnr           TYPE dynnr,
*        settype_name    TYPE comt_frgtype_id,
*      END OF scr_settype_type.
*
*TYPES: scr_settype_type_t TYPE STANDARD TABLE OF scr_settype_type.
*
**Type for IObject multi controls
*TYPES: BEGIN OF control_type,
*        progname          TYPE progname,
*        dynnr             TYPE dynnr,
*        control_name(40)  TYPE c,
*        tabname           TYPE tabname,
*        tabname_ext       TYPE tabname,
*        alv_ref           TYPE REF TO cl_gui_alv_grid,
*        container_ref     TYPE REF TO cl_gui_custom_container,
*      END OF control_type.
*
*TYPES: control_type_t TYPE STANDARD TABLE OF control_type.
*
*
*
**--------------------------------------------------------------------------------------------------------------------*
**-------------------------------------------Constanst Delcarations----------------------------------------------------
**--------------------------------------------------------------------------------------------------------------------*
*
*
*CONSTANTS:
**--> common constants
*  xflag_gc                            TYPE c                VALUE 'X',
*  noflag_gc                           TYPE c                VALUE ' ',
*  true_gc                             TYPE c                VALUE 'X',
*  false_gc                            TYPE c                VALUE space,
*  fc_supp_gc                          TYPE sy-ucomm         VALUE 'SUPP', " supplier data input
*  before_act_gc                       TYPE i                VALUE '1',
*  vlc_mcat_authority_object           TYPE tobj-objct       VALUE '/DBE/VMCAT',
*  vlc_authority_object_gc             TYPE tobj-objct       VALUE 'C_AUTO_VMS'.
*CONSTANTS:
*gc_first_subscreen_dynpro             TYPE scradnum         VALUE '2000',
*gc_result_subscr_dynpro               TYPE dynnr            VALUE '1400',
*gc_criteria_subscreen_dynpro          TYPE dynnr            VALUE '2200',
*gc_mass_main_program                  TYPE program          VALUE '/DBE/SAPLVEHI_MASS_PROCESSING',
*gc_mass_crit_subscreen_dynpro         TYPE dynnr            VALUE '2200',
*gc_new_fc(3)                          TYPE C                VALUE 'NEW',
*gc_vehdetail_fc(9)                    TYPE c                VALUE 'VEHDETAIL',
*gc_actionvm_fc(8)                     TYPE c                VALUE 'ACTIONVM',
*gc_searchvm(8)                        TYPE c                VALUE 'SEARCHVM',
*gc_save_fc(4)                         TYPE c                VALUE 'SAVE',
*gc_exec_fc(7)                         TYPE c                VALUE 'ACT_EXE',
*gc_set_action(8)                      TYPE c                VALUE 'SET_ACTN',
*gc_ente_fc(5)                         TYPE c                VALUE 'ENTER',
*gc_create_fc(6)                       TYPE c                VALUE 'CREATE',
*gc_delete_fc(6)                       TYPE c                VALUE 'DELETE',
*gc_f4_fc(4)                           TYPE c                VALUE 'F4SH',
*gc_ftype_in1(3)                       TYPE c                VALUE 'IN1',
*gc_init(4)                            TYPE c                VALUE 'INIT',
*gc_0(1)                               TYPE c                VALUE '0',
*gc_1(1)                               TYPE c                VALUE '1',
*gc_2(1)                               TYPE c                VALUE '2',
*gc_e(1)                               TYPE c                VALUE 'E',
*gc_x                                  TYPE c                VALUE 'X', "#EC *
*gc_xflag                              TYPE c                VALUE 'X',
*
** Fields on creation screen
** Werks
*gc_werks(3)                           TYPE c                VALUE 'WRK', "#EC *
*
** Sparte
*gc_spart(3)                           TYPE c                 VALUE 'SPA', "#EC *
*gc_model_guid(10)                                            VALUE 'MODEL_GUID',
*gc_vehipricing_new                    TYPE /DBE/veh_pricingtype VALUE '1',
*gc_mcatalog(8)                                                VALUE 'MCATALOG', "#EC *
** screens and programs
* gc_default_action_program            TYPE program            VALUE '/DBE/SAPLVEHI_MASS_PROCESSING',
* gc_default_action_dynpro             TYPE dynnr              VALUE '3000'.
*
**************** Selection Variants Data
*
*
**Data used in screen 301
*CONSTANTS: g_container TYPE scrfname VALUE 'SELECTION_VARIANTS'.
*CONSTANTS: gc_mass_svariant_def TYPE memoryid VALUE '/DBE/VM_SVARDEF'.
** dynpros and programs
*CONSTANTS :
*    gc_execute_fc(7)          TYPE c VALUE 'EXECUTE',
*    gc_searchvm_fc(8)         TYPE c VALUE 'SEARCHVM',
*    gc_createveh_fc(8)         TYPE c VALUE 'MASS_FC2',
*    gc_mass_search_fc(11)     TYPE c VALUE 'MASS_SEARCH',
*    gc_external_call(13)      TYPE c VALUE 'EXTERNAL_CALL',
*    gc_worklist_fc(8)         TYPE c VALUE 'WORKLIST',
*    gc_log_fc(8)              TYPE c VALUE 'MASS_FC4',
*    gc_main_status(8)         TYPE c VALUE 'MAIN1000',
*    gc_back_fc(4)             TYPE c VALUE 'BACK',
*    gc_exit_fc(4)             TYPE c VALUE 'EXIT',
*    gc_cancel_fc(6)           TYPE c VALUE 'CANCEL',
*    gc_search_fc(6)           TYPE c VALUE 'SEARCH',
*    gc_extsearchvm_fc(7)      TYPE c VALUE 'ESEARCH',
*    gc_searchcrit(10)         TYPE c VALUE 'SEARCHCRIT',
*    gc_searchstring(12)       TYPE c VALUE 'SEARCHSTRING',
*    gc_searchmode(10)         TYPE c VALUE 'SEARCHMODE',
*    gc_svar_fc(4)             TYPE c VALUE 'SVAR',
*    gc_listbox_fc(7)          TYPE c VALUE 'LISTBOX',
*    gc_clear_fc(5)            TYPE c VALUE 'CLEAR',
*    gc_mass_parid_desc(34)    TYPE c VALUE 'Default selection variant for user'.
*CONSTANTS: BEGIN OF gc_find,
*             gc_tab1 LIKE sy-ucomm VALUE 'SEARCHVM',
*             gc_tab2 LIKE sy-ucomm VALUE 'MASS_FC2',
*             gc_tab3 LIKE sy-ucomm VALUE 'WORKLIST',
*             gc_tab4 LIKE sy-ucomm VALUE 'MASS_FC4',
*           END OF gc_find.
*
*
*
*
*
*
**--------------------------------------------------------------------------------------------------------------------*
**-------------------------------------------Data Declarations----------------------------------------------------------
**--------------------------------------------------------------------------------------------------------------------*
*
*DATA : ls_po_del_info                 TYPE tty_po_del_info.
*DATA : gt_po_del_info                 TYPE TABLE OF tty_po_del_info.
*DATA : ls_invoice_info                TYPE tty_invoice_info.
*DATA : gt_ininvoice_info              TYPE TABLE OF tty_invoice_info.
*DATA : gt_seletion.
*DATA : gt_ininvoice_cancel_info       TYPE TABLE OF vlcactdata_head_s.
*DATA:  gt_iobj_single                 TYPE  /DBE/iobj_data_single_com_t.
*DATA:  gt_iobj_multi                  TYPE  /DBE/iobj_data_multi_com_t.
*DATA : gt_po_upd_info                 TYPE TABLE OF tty_po_info.
*DATA : gt_po_item_diff_delv           TYPE TABLE OF ty_po_cre_diff_delvdate.
*
*DATA : gc_tab_result_dynpro           TYPE dynnr VALUE '1400',
*       gc_mass_main_subscreen_dynpro  TYPE dynnr VALUE '1100'.
*DATA : has_same_delv_date             TYPE c,
*       has_diff_delv_date             TYPE c.
*
*DATA : gt_mass_alv_var                TYPE TABLE OF /DBE/alv_var.
*DATA : gv_mass_icon_okay              TYPE /DBE/icon_defvar.
*DATA : gv_mass_icon_cancel            TYPE /DBE/icon_defvar.
*DATA : gt_mass_svariant_buf           TYPE SORTED TABLE OF /DBE/vm_svariant WITH UNIQUE KEY mandt uname svar.
*DATA : gv_mass_svariant_def           TYPE xuvalue.
*DATA : gt_mass_svariant               TYPE SORTED TABLE OF /DBE/vm_svariant WITH UNIQUE KEY mandt uname svar.
*DATA : gt_mass_svartxt_buf            TYPE SORTED TABLE OF /DBE/vm_svartxt
*                                      WITH UNIQUE KEY mandt uname svar spras.
*DATA : gt_mass_svartxt                TYPE SORTED TABLE OF /DBE/vm_svartxt
*                                      WITH UNIQUE KEY mandt uname svar spras.
*DATA : gt_mass_user_svcrit_buf        TYPE SORTED TABLE OF /DBE/vm_svcrit
*                                      WITH UNIQUE KEY mandt uname svar scinterfacefield.
*DATA : gt_mass_user_svcrit            TYPE SORTED TABLE OF /DBE/vm_svcrit
*                                      WITH UNIQUE KEY mandt uname svar scinterfacefield.
*DATA : gt_mass_user_svval_buf         TYPE SORTED TABLE OF /DBE/vm_svval
*                                      WITH UNIQUE KEY mandt uname svar scinterfacefield svind.
*DATA : gt_mass_user_svval             TYPE SORTED TABLE OF /DBE/vm_svval
*                                      WITH UNIQUE KEY mandt uname svar scinterfacefield svind.
*DATA : gv_external_function           TYPE syucomm.
*DATA : gt_mass_search_crit            TYPE /DBE/veh_searchcrit_t,
*       gt_search_crit_ext             TYPE /DBE/veh_searchcrit_t,
*       gt_mass_search_crit_buf        TYPE /DBE/veh_searchcrit_t.
*DATA : gt_mass_usparam                TYPE SORTED TABLE OF usparam WITH UNIQUE KEY parid.
*DATA : gv_mass_usparam_exists         TYPE flag.
*DATA : gv_prog_name                   TYPE sy-repid.
*DATA : gv_prog_name_ext               TYPE sy-repid.
*DATA : gv_dynnr_name                  TYPE scradnum.
*DATA : gv_dynnr_name_ext              TYPE scradnum.
*DATA: gv_flag                         TYPE boolean.
*
** archive search flag
*DATA: gv_no_archive_search            TYPE boole_d VALUE abap_false.
*
*
** search criteria definition
*DATA: vlcsearchcrit_lt                TYPE vlch_searchcrit_pt.
*DATA: controlerr_lt                   TYPE TABLE OF vlcsearchcontrol.
*DATA : gv_mcatalog                    TYPE /DBE/mcatalog.
*
**Global table for registered settypes
*DATA:  gt_registered_settypes         TYPE scr_settype_type_t.
*
**IObject family
*DATA: gv_iobj_family                  TYPE comt_product_object_family.
*DATA: gv_iobj_catid                   TYPE comt_category_id.
*
**IObject communication structures
*DATA: gs_iobj_single                  TYPE /DBE/iobj_data_single_com_s.
*DATA: gs_iobj_multi                   TYPE /DBE/iobj_data_multi_com_s.
*
**Global table for IObject controls
*DATA: gt_iobj_multi_control           TYPE control_type_t.
*DATA: gv_ok_code                      LIKE sy-ucomm.
*DATA: gv_cursor_field(40).
*
**VMS Comunication structures
*DATA: gs_vlcdiavehi                   TYPE vlcdiavehi.
*DATA: gt_vsresult                     TYPE STANDARD TABLE OF /DBE/vsresult,
*      gs_vsresult                     TYPE /DBE/vsresult,
*      gt_vsresult_selection           TYPE TABLE OF /DBE/vsresult.
*
*DATA: gt_vehicles                     LIKE STANDARD TABLE OF gs_vlcdiavehi.
*DATA: gs_vehicles                     LIKE LINE OF gt_vehicles.
*DATA: gt_selection                    LIKE STANDARD TABLE OF /DBE/vsresult.
*DATA: gs_selection                    TYPE /DBE/vsresult.
*DATA : gt_return                      TYPE TABLE OF bapiret2.
*DATA: gs_vlcactdata_head              TYPE vlcactdata_head_s.
*DATA: gs_vlcactdata_item              TYPE vlcactdata_item_s.
*DATA: gt_vlcadddata                   TYPE vlcadddata_item_t.
*DATA /DBE/V_IMODEL_old                 TYPE /DBE/V_IMODEL.
*
**If error during the set method occured
*DATA: gv_set_error                    TYPE c.
*
*DATA: gv_block_navigation             TYPE boole_d VALUE abap_false.
*
**Errors table
*DATA: gt_bapireturn                   TYPE bapiret2_t.
*DATA: gt_bulk_actions                 TYPE TABLE OF cvlc03.
*DATA: gt_cvlc03t                      TYPE TABLE OF cvlc03t.
*DATA : gs_bulk_actions                TYPE cvlc03.
*DATA : gc_action                      TYPE vrm_id VALUE 'CVLC03-AKTION'.
*DATA : gv_action                      TYPE cvlc03-aktion.
*
*
*DATA: gv_main_subscreen_program       TYPE program,
*      gv_main_subscreen_dynpro        TYPE dynnr,
*      gv_subscreen_dynpro             TYPE dynnr,
*      gc_variant_subscreen            TYPE dynnr VALUE '1200',
*      gc_search_subscreen             TYPE dynnr VALUE '1100',
*      gc_result_subscreen             TYPE dynnr VALUE '1300',
*      gc_create_subscreen             TYPE dynnr VALUE '0101',
*      gc_log_subscreen                TYPE dynnr VALUE '1500',
*      gv_subscreen_program            TYPE program,
*      gv_last_sy_ucomm                TYPE syucomm,
*      gv_mass_search_filled           TYPE xfeld VALUE abap_false,
*      gv_extsearch_filled             TYPE xfeld VALUE abap_false,
*      gv_default_search_screen        TYPE dynnr ,
*
** Storing the last search screen is necessary. If back
** button is pressed, the previous search screen need to
** be set.
*      gv_last_search_tab(8)           TYPE c,
*      gv_error_search                 TYPE flag,
*      gv_searchmode                   TYPE trexd_term_action,
*      gt_ok                           TYPE sy-ucomm,
*      ok_code                         LIKE sy-ucomm.
*
*DATA: gv_read_oem_opt_texts           TYPE xfeld.
*DATA: gv_searchstring                 TYPE string.
*
** transaction called from outside - directly to search results
*DATA: gv_external_mode(1).
*DATA: gt_ext_search_var_fields        TYPE /DBE/veh_searchcrit_t.
*
*DATA: BEGIN OF g_find,
*         subscreen                    LIKE sy-dynnr,
*         prog                         LIKE sy-repid VALUE '/DBE/SAPLVEHI_MASS_PROCESSING',
*         pressed_tab                  LIKE sy-ucomm VALUE gc_find-gc_tab1,
*           END OF g_find.
*
*
*DATA: suche_tab(128)                  TYPE c,
*      searchtab2(128)                 TYPE c.
*
*
*DATA : gv_tabname                     TYPE tabname VALUE '/DBE/VSRESULT'.
*DATA : gt_alv_fieldcat                TYPE lvc_t_fcat.
*DATA : gt_fieldcatalog                TYPE lvc_t_fcat.
*DATA : gs_fieldcat                    TYPE lvc_s_fcat.
*DATA : gs_layout                      TYPE lvc_s_layo.
*
** vehicle data structures
*DATA : gt_vlcdiavehi                  TYPE vlcdiavehi_t.
*DATA : gt_vlcdisplalv                 TYPE STANDARD TABLE OF vlcdisplalv.
*DATA : gs_vlcdisplalv                 LIKE LINE OF gt_vlcdisplalv.
*
*
** screens and programs
*DATA : gv_tab_subscreen_program       TYPE program,
*       gv_tab_subscreen_dynpro        TYPE dynnr.
** screens and programs
*DATA : gv_action_screen_program       TYPE program,
*       gv_action_screen_dynpro        TYPE dynnr.
*DATA: gv_badi_program                 TYPE program,
*      gv_badi_dynpro                  TYPE dynnr.
*DATA : action                         TYPE /DBE/veh_blk_act-aktiont.
*DATA :
*      gv_po_same_deldate_flag         TYPE abap_bool VALUE abap_true,
*      gv_po_diff_deldate_flag         TYPE abap_bool.
*
*
*
**-------------------------------------------------------------------------------------------------------------------
**-------------------------------------------Field Symbols-----------------------------------------------------------
**--------------------------------------------------------------------------------------------------------------------*
*
*FIELD-SYMBOLS: <gf_varlistitem_shown> TYPE any,
*               <gf_text>              TYPE any,
*               <gf_fuzzy>             TYPE any,
*               <gf_exact>             TYPE any,
*               <gf_archived>          TYPE any,
*               <gf_srcintr>           TYPE any.
*
*RANGES: gt_mcodesd FOR /DBE/s_veh_alv_option_search-mcodesd.
*
*CONTROLS:  mass TYPE TABSTRIP.
