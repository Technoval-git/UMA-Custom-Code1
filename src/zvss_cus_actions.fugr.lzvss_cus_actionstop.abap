FUNCTION-POOL ZVSS_CUS_ACTIONS.             "MESSAGE-ID ..


TYPE-POOLS: /dbe/,
            kabrt.

INCLUDE /dbe/vsales_constants.

CONSTANTS: gc_xflag      TYPE char1            VALUE 'X',
           gc_space      TYPE char1            VALUE ' ',
*          gc_vehicle(2)       TYPE c                VALUE 'SD',
           gc_obj_type   TYPE awtyp            VALUE 'DBMSO',
           gc_co_vaart_1 TYPE co_vaart         VALUE '1',
           gc_kurst      TYPE kurst            VALUE 'M',
           gc_versn      TYPE versn            VALUE '000',
           gc_wrttp      TYPE co_wrttp         VALUE '04',
           gc_selart     TYPE kass_selart      VALUE 'OR',
           gc_ok_ausf    TYPE syucomm          VALUE 'AUSF',
           gc_ok_stor    TYPE syucomm          VALUE 'STOR',
           gc_vrgng      TYPE co_vorgang       VALUE 'KOAO',
           gc_revers     TYPE xfeld            VALUE 'X'.


*- > /DBE/CO_ACT_LBR_COST_BOOK
TYPES: BEGIN OF t_vbap_plus.
         INCLUDE               TYPE /dbe/vbap_com AS /dbe/vbap_com.
TYPES:   kstar     TYPE kstar,
         lstar     TYPE lstar,
         kostl     TYPE tvauk-kostl,
         bmeng     TYPE bmeng,
         bwart_lbr TYPE /dbe/bwart_lbr,
         aufnr     TYPE aufnr,
       END OF t_vbap_plus.

TYPES: tt_vbap_plus   TYPE STANDARD TABLE OF t_vbap_plus.


*-> /DBE/CO_ACT_CREATE_SETTLE_RULE
TYPES: BEGIN OF t_settle_work,
         ursch   TYPE /dbe/co_settle-ursch,
         urzuo   TYPE /dbe/co_settle-urzuo,
         value   TYPE /dbe/co_settle-value,
         merkmal TYPE /dbe/co_settle-merkmal,
       END OF t_settle_work.

TYPES: tt_settle_work TYPE STANDARD TABLE OF t_settle_work.


*-> /DBE/CO_ACT_ITEM_REPOST_CANCEL
TYPES: BEGIN OF t_belnr,
         co_belnr TYPE co_belnr,
         refbn    TYPE co_refbn,
         awtyp    TYPE awtyp,
         aworg    TYPE aworg,
       END OF t_belnr.

TYPES: tt_belnr TYPE STANDARD TABLE OF t_belnr.

TYPES: BEGIN OF t_cost_belnr,
         splnr  TYPE /dbe/splnr,
         posnr  TYPE /dbe/posnr,
         docnum TYPE /dbe/docnum,
       END OF t_cost_belnr.


*-> /DBE/CO_ACT_INT_BILL_VIA_CO
TYPES BEGIN OF ty_bapircitm_plus.
INCLUDE STRUCTURE bapircitm.
TYPES     katyp TYPE katyp.
TYPES END OF ty_bapircitm_plus.
TYPES ty_bapircitm_tt_plus TYPE STANDARD TABLE OF ty_bapircitm_plus.

TYPES BEGIN OF ty_bapirritm_plus.
INCLUDE STRUCTURE bapirritm.
TYPES     katyp TYPE katyp.
TYPES END OF ty_bapirritm_plus.
TYPES ty_bapirritm_tt_plus TYPE STANDARD TABLE OF ty_bapirritm_plus.

TYPES: BEGIN OF ty_posnr,
         posnr TYPE /dbe/posnr,
       END OF ty_posnr.
TYPES ty_posnr_tt TYPE STANDARD TABLE OF ty_posnr.

DATA: gv_dbm_call TYPE c1.

*-> /DBE/CO_ACT_SETTLE_RULE_UPD
TYPES: BEGIN OF t_veh_list,
         dbm_coaufnr TYPE aufnr,
         vguid       TYPE vlc_guid,
       END OF t_veh_list.
TYPES: tt_veh_list TYPE STANDARD TABLE OF t_veh_list.
TYPES: BEGIN OF t_aufnr_list,
         aufnr TYPE aufnr,
       END OF t_aufnr_list.
TYPES: tt_aufnr_list TYPE STANDARD TABLE OF t_aufnr_list.
