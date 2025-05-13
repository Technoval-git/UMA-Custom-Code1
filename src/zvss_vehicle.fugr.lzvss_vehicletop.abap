FUNCTION-POOL zvss_vehicle.                 "MESSAGE-ID ..

* INCLUDE LZVSS_VEHICLED...                  " Local class definition
* databases
TABLES: ekan,
        lfm1,
        lfa1,
        ekko,
        ekpo,
        ekkn,
        eket,
        ekek,
        ekeh,
        mt06e,
        mtcor,
        mtcom,
        bqpim,
        bqpex,
        t160d,
        t001,
        t001w,
        t001k,
        t024w,
        t024z,
        t163k,
        eban,
        ebkn,
        eina,
        eine,
        makt,
        mara,
        marc,
        mbew,
        thead,
        rkpf,
        resb,
        t134w.                                              "155013

TYPES: return_type LIKE bapireturn OCCURS 0.
TYPES: komv_type LIKE komv OCCURS 0.
TYPES: conditiondata_type LIKE bbp_cond OCCURS 0.
TYPES: inbdelivlist_type LIKE bbp_inbd_l OCCURS 0.
TYPES: inbdelivdetail_type LIKE bbp_inbd_d OCCURS 0.
TYPES: inbdelivheader_type LIKE bbp_inbd_l OCCURS 0.
TYPES: inbd_po_items_type LIKE bbp_inbd_po_view OCCURS 0.
TYPES: bbpmatnrlst LIKE bapiekpo-material OCCURS 0.

DATA: exitflag,
      no_authority,
      read_header,
      read_item,
      h_frgrl LIKE ekko-frgrl.

DATA: mask1(2) VALUE '*+',
      mask2(4) VALUE '+_*%'.

*- FIELDS FOR THE AUTHORITY CHECK  ------------------------------------*
DATA: xobjekt(10).
DATA: xactvt LIKE tact-actvt.
DATA: not_open_for_receipt.

DATA: refe1(16) TYPE p.
DATA: f1 TYPE f.

*- internal table for the errors --------------------------------------*
DATA: BEGIN OF h_return.
        INCLUDE STRUCTURE bapireturn.
DATA: END OF h_return.

*- structure for the message-variables --------------------------------*
DATA: BEGIN OF msg,
        ty LIKE syst-msgty,
        id LIKE syst-msgid,
        no LIKE syst-msgno,
        v1 LIKE syst-msgv1,
        v2 LIKE syst-msgv2,
        v3 LIKE syst-msgv3,
        v4 LIKE syst-msgv4,
      END OF msg.

*- internal format PO-header - table for array select -----------------*
DATA: BEGIN OF sekko OCCURS 10.
        INCLUDE STRUCTURE ekko.
DATA: END OF sekko.

*- internal format PO-header-Key --------------------------------------*
DATA: BEGIN OF kekko OCCURS 10,
        ebeln LIKE ekko-ebeln,
      END OF kekko.

*- internal format PO-items - table for array select ------------------*
DATA: BEGIN OF sekpo OCCURS 10.
        INCLUDE STRUCTURE ekpo.
DATA: END OF sekpo.

*- internal format PO-history - EKBE     ------------------------------*
DATA: BEGIN OF cekbe OCCURS 10.
        INCLUDE STRUCTURE ekbe.
DATA: END OF cekbe.

*- internal format PO-history - EKBZ     ------------------------------*
DATA: BEGIN OF cekbz OCCURS 10.
        INCLUDE STRUCTURE ekbz.
DATA: END OF cekbz.

*- internal format PO-history - EKBES    ------------------------------*
DATA: BEGIN OF cekbes OCCURS 10.
        INCLUDE STRUCTURE ekbes.
DATA: END OF cekbes.
DATA: BEGIN OF betskey,
        ebelp LIKE ekbe-ebelp,
        zekkn LIKE ekbe-zekkn,
      END OF betskey.

*- internal format PO-history - EKBEZ    ------------------------------*
DATA: BEGIN OF cekbez OCCURS 10.
        INCLUDE STRUCTURE ekbez.
DATA: END OF cekbez.

*- internal format PO-history - EKBNK    ------------------------------*
DATA: BEGIN OF cekbnk OCCURS 10.
        INCLUDE STRUCTURE ekbnk.
DATA: END OF cekbnk.

*- internal tables for the dynamic select -----------------------------*
DATA: BEGIN OF stab1 OCCURS 1,
        bed(72),
      END OF stab1.

DATA: BEGIN OF stab2 OCCURS 1,
        bed(72),
      END OF stab2.
*- save key from ekko -------------------------------------------------*
DATA: BEGIN OF ekkokey,
        mandt LIKE ekko-mandt,
        ebeln LIKE ekko-ebeln,
      END OF ekkokey.

RANGES: " rp_frggr for ekko-frggr,
        rp_ebeln FOR ekko-ebeln,
        rp_bsart FOR ekko-bsart,
        rp_bedat FOR ekko-bedat,
        rp_ekgrp FOR ekko-ekgrp,
        rp_ekorg FOR ekko-ekorg,
        rp_lifnr FOR ekko-lifnr,
        rp_reswk FOR ekko-reswk,
        rp_ematn FOR ekpo-ematn,
        rp_matkl FOR ekpo-matkl,
        rp_pstyp FOR ekpo-pstyp,
        rp_knttp FOR ekpo-knttp,
        rp_werks FOR ekpo-werks,
        rp_bednr FOR ekpo-bednr.
