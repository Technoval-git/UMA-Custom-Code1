*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_ACTION_CONS
*&---------------------------------------------------------------------*
** INPUT-TYPE OF FIELDS THAT ARE INCLUDED ON THE ACTION-SCREENS
*  Mandatory entry fields

  CONSTANTS:
    gc_main_status(8)      TYPE c              VALUE 'MAIN1000',
    gc_back_fc(4)          TYPE c              VALUE 'BACK',
    gc_exit_fc(4)          TYPE c              VALUE 'EXIT',
    gc_cancel_fc(6)        TYPE c              VALUE 'CANCEL',
    gc_vehdetail_fc(9)     TYPE c              VALUE 'VEHDETAIL',
    gc_actionvm_fc(8)      TYPE c              VALUE 'ACTIONVM',
    gc_searchvm(8)         TYPE c              VALUE 'SEARCHVM',
    gc_new_fc(3)           TYPE c              VALUE 'NEW',
    gc_save_fc(4)          TYPE c              VALUE 'SAVE',
    gc_edit_fc(4)          TYPE c              VALUE 'EDIT',
    gc_order_fc(5)         TYPE c              VALUE 'ORDER',
    gc_proc_fc(5)          TYPE c              VALUE 'PROC',
    gc_dms_fc(3)           TYPE c              VALUE 'DMS',
    gc_adp1_fc(4)          TYPE c              VALUE 'ADP1',
    gc_adp2_fc(4)          TYPE c              VALUE 'ADP2',
    gc_adp3_fc(4)          TYPE c              VALUE 'ADP3',
*Hide Storage Goods in Release 1.0, VGM to be added in the future releases
*    gc_stg_fc(4)           TYPE c              VALUE '&STG',
    gc_bupa_fc(4)          TYPE c              VALUE 'BUPA',
    gc_bp_new_fc(6)        TYPE c              VALUE 'BP_NEW',
    gc_stg(8)              TYPE c              VALUE '/DBE/STG',
    gc_dms_tran(10)        TYPE c              VALUE '/DBE/VMDMS',
    gc_notification(4)     TYPE c              VALUE 'NOTI',
    gc_0(1)                TYPE c              VALUE '0',
    gc_1(1)                TYPE c              VALUE '1',
    gc_2(1)                TYPE c              VALUE '2',
    gc_3(1)                TYPE c              VALUE '3',
    gc_4(1)                TYPE c              VALUE '4',
    gc_a(1)                TYPE c              VALUE 'A',
    gc_e(1)                TYPE c              VALUE 'E',
    gc_i(1)                TYPE c              VALUE 'I',
    gc_u(1)                TYPE c              VALUE 'U',
    gc_d(1)                TYPE c              VALUE 'D',
    gc_w(1)                TYPE c              VALUE 'W',
    gc_y(1)                TYPE c              VALUE 'Y',
    gc_c(1)                TYPE c              VALUE 'C',
    gc_dms_par1(8)         TYPE c              VALUE 'CALLMODE',
    gc_dms_par2(8)         TYPE c              VALUE 'EDITMODE',
    gc_dms_par3(5)         TYPE c              VALUE 'VGUID',
    gc_iobj_single         TYPE string         VALUE '/DBE/IOBJ_DATA_SINGLE_S',
    gc_iobj_multi          TYPE string         VALUE '/DBE/IOBJ_DATA_MULTI_S',
    gc_stru(4)             TYPE c              VALUE 'STRU',
    gc_ttyp(4)             TYPE c              VALUE 'TTYP',
    gc_factsheet_fc(10)    TYPE c              VALUE 'FACT_SHEET',
*alv-control: save modes for ALV variants
    gc_alv_var_save        TYPE c              VALUE 'A',
*Field's groups
    gc_ftype_in1(3)        TYPE c              VALUE 'IN1',
    gc_ftype_in2(3)        TYPE c              VALUE 'IN2',
    gc_ftype_in0(3)        TYPE c              VALUE 'IN0',
    gc_ftype_hin(3)        TYPE c              VALUE 'HIN', "hide field if new car
    gc_ftype_hiu(3)        TYPE c              VALUE 'HIU', "hide field if used car
*Output fields only
    gc_xxxx_fc             TYPE sy-ucomm       VALUE 'XXXX',
    gc_xflag               TYPE c              VALUE 'X',
    gc_aflag               TYPE c              VALUE 'A',
    gc_star                TYPE c              VALUE '*',
*Technical fields in Iobject multi
    gc_prod_guid(12)       TYPE c              VALUE 'PRODUCT_GUID',
    gc_valid_from(10)      TYPE c              VALUE 'VALID_FROM',
    gc_valid_to(8)         TYPE c              VALUE 'VALID_TO',
    gc_upname(6)           TYPE c              VALUE 'UPNAME',
    gc_histex(6)           TYPE c              VALUE 'HISTEX',
    gc_logsys(6)           TYPE c              VALUE 'LOGSYS',
    gc_client(6)           TYPE c              VALUE 'CLIENT',
*Search transaction
    gc_search_tr(12)       TYPE c              VALUE '/DBE/VSEARCH',
*Vehicle main transaction
    gc_vm_tr(7)            TYPE c              VALUE '/DBE/VM',
*ActDocTypes
    gc_aba_qror            TYPE vlc_actdoctype VALUE 'QROR',
    gc_aba_qrgr            TYPE vlc_actdoctype VALUE 'QRGR',
    gc_aba_qrgi            TYPE vlc_actdoctype VALUE 'QRGI',
    gc_aba_qrsd            TYPE vlc_actdoctype VALUE 'QRSD',
    gc_aba_qrbd            TYPE vlc_actdoctype VALUE 'QRBD',
    gc_aba_qcuo            TYPE vlc_actdoctype VALUE 'QCUO',
    gc_aba_qdca            TYPE vlc_actdoctype VALUE 'QDCA',
    gc_aba_qoff            TYPE vlc_actdoctype VALUE 'QOFF',
    gc_aba_qgis            TYPE vlc_actdoctype VALUE 'QGIS',
    gc_aba_qgir            TYPE vlc_actdoctype VALUE 'QGIR',
    gc_aba_qoiv            TYPE vlc_actdoctype VALUE 'QOIV',
    gc_aba_qoir            TYPE vlc_actdoctype VALUE 'QOIR',
    gc_aba_qcsd            TYPE vlc_actdoctype VALUE 'QCSD',
    gc_aba_qcso            TYPE vlc_actdoctype VALUE 'QCSO',
    gc_aba_qcsq            TYPE vlc_actdoctype VALUE 'QCSQ',
    gc_aba_qcpo            TYPE vlc_actdoctype VALUE 'QCPO',
    gc_aba_qcph            TYPE vlc_actdoctype VALUE 'QCPH',
    gc_aba_qgrp            TYPE vlc_actdoctype VALUE 'QGRP',
    gc_aba_qgrh            TYPE vlc_actdoctype VALUE 'QGRH',
    gc_aba_qord            TYPE vlc_actdoctype VALUE 'QORD',
    gc_aba_qinv            TYPE vlc_actdoctype VALUE 'QINV',
    gc_aba_ass1            TYPE vlc_actdoctype VALUE 'ASS1',  "ASSET for vehicle
    gc_aba_ass2            TYPE vlc_actdoctype VALUE 'ASS2',  "vehicle from asset
    gc_aba_qntf            TYPE vlc_actdoctype VALUE 'QNTF',  "Assign Notification to Vehicle
    gc_aba_qof1            TYPE vlc_actdoctype VALUE 'QOF1',
* DBM Document Category
    gc_vbtyp_c             TYPE c              VALUE 'C',
    gc_vbtyp_h             TYPE c              VALUE 'H',
*Log object name
    gc_log_obj             TYPE balobj_d       VALUE '/DBE/',
    gc_log_subobj          TYPE balsubobj      VALUE 'VEHICLE',
    gc_ddtext(6)           TYPE c              VALUE 'DDTEXT',
*Control's type name
    gc_iobj_cntrl_type(14) TYPE c             VALUE 'CONTROL_TYPE_T',
    gc_addd_cntrl_type(14) TYPE c             VALUE 'ADDDATA_TYPE_T',
*Usage for model catalog determination
    gc_veh_mc(11)          TYPE c             VALUE '/DBE/VEH_MC',
    gc_veh_pro(12)         TYPE c             VALUE '/DBE/VEH_PRO',
    gc_init(4)             TYPE c             VALUE 'INIT',
*Parameter name
    gc_v_edit_mode(16)     TYPE c             VALUE '/DBE/V_EDIT_MODE',
*Longtext editor
    gc_longtxt_fc(20)      TYPE c             VALUE 'LONGTXT',
    gc_lovor               TYPE jest-stat     VALUE 'I0076',
*Partner functions SD
    gc_part_ow(2)          TYPE c             VALUE 'OW',
    gc_part_de(2)          TYPE c             VALUE 'DE',
*Dynamic VMS DBM fields
    gc_category_fieldname  TYPE string        VALUE '/DBE/CATEGORY_ID',
    gc_modelguid_fieldname TYPE string        VALUE '/DBE/MODEL_GUID',
    gc_fintype_fd          TYPE fieldname     VALUE 'FINTYPE',
    gc_finvalp_fd          TYPE fieldname     VALUE 'FINVALP',
    gc_leatype_fd          TYPE fieldname     VALUE 'LEATYPE',
    gc_leavalp_fd          TYPE fieldname     VALUE 'LEAVALP',
    gc_value_org_s         TYPE ddbool_d      VALUE 'S',
*Kinds of vehicle pricing (see /DBE/VM08_FIND_PRICING_TYPE)
    gc_vehipricing_used    TYPE /dbe/veh_pricingtype VALUE '2',
    gc_vehipricing_new     TYPE /dbe/veh_pricingtype VALUE '1',
    gc_assign_vehicle_fc   TYPE syucomm       VALUE 'ASSIGN',
*New vehicle UI main screen
    gc_dynnr_vm_new        TYPE sydynnr      VALUE '2000',
    gc_dynnr_vm_new2       TYPE sydynnr      VALUE '2001',
*Vehicle master main program (needed for call screens
    gc_cprog_vm            TYPE sycprog      VALUE '/DBE/SAPLVM08',
    gc_toe(3)              VALUE 'TOE',
    gc_tot(3)              VALUE 'TOT',
    gc_equi_data_equi      TYPE sy-ucomm      VALUE 'DBE_EQUI',
    gc_equi_data_sernr     TYPE sy-ucomm      VALUE 'DBE_SERNR'.
