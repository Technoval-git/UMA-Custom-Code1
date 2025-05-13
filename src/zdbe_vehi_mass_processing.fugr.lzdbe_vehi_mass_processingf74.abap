*----------------------------------------------------------------------*
***INCLUDE /DBE/LVEHI_MASS_PROCESSINGF74 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcatalog .

  DATA: ls_special_groups  TYPE lvc_s_sgrp .
  DATA: t_sort TYPE lvc_s_sort.

  FIELD-SYMBOLS <fs_fieldcat> TYPE lvc_s_fcat.

  REFRESH gt_sort.

  CLEAR : gs_layout, gs_fieldcat, gt_fieldcatalog, gt_sort.
  gs_layout-smalltitle = abap_true.

  CASE gv_action.

    WHEN  /DBE/if_vms_constants=>c_qgrb.

      gs_layout-grid_title = text-152.

      gs_fieldcat-fieldname   = '/DBE/SELECTED'.
      gs_fieldcat-tech = 'X'.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype = 'CHAR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'VHCLE'.
      gs_fieldcat-coltext     = 'Int. Veh. No.'(102).
      gs_fieldcat-outputlen   = 15.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype    = 'VHCLE' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'WERKS'.
      gs_fieldcat-coltext   = 'Plant'(160).
      gs_fieldcat-outputlen = 8.
      gs_fieldcat-col_pos     = 2.
      gs_fieldcat-datatype = 'WERKS_D' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.


      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_NUMBER'.
      gs_fieldcat-coltext   = 'Purchase Order'(106).
      gs_fieldcat-outputlen = 13.
      gs_fieldcat-col_pos     = 6.
      gs_fieldcat-datatype = 'EBELN' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_ITEM'.
      gs_fieldcat-coltext   = 'Item'(115).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos     = 7.
      gs_fieldcat-datatype = 'EBELP' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

    WHEN  /DBE/if_vms_constants=>c_qgcb.

      gs_layout-grid_title = text-150.

      gs_fieldcat-fieldname   = '/DBE/SELECTED'.
      gs_fieldcat-tech = 'X'.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype = 'CHAR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'VHCLE'.
      gs_fieldcat-coltext     = 'Int. Veh. No.'(102).
      gs_fieldcat-outputlen   = 15.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype    = 'VHCLE' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'WERKS'.
      gs_fieldcat-coltext   = 'Plant'(160).
      gs_fieldcat-outputlen = 8.
      gs_fieldcat-col_pos     = 2.
      gs_fieldcat-datatype = 'WERKS_D' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'LGORT'.
      gs_fieldcat-coltext   = 'Storage Location'(161).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos     = 2.
      gs_fieldcat-datatype = 'LGORT_D' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.
*

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'MAT_DOC'.
      gs_fieldcat-coltext  = 'Material Document'(162).
      gs_fieldcat-datatype  = 'MBLNR' .
      gs_fieldcat-outputlen = 15.
      gs_fieldcat-col_pos   = 4.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname   = 'DOC_YEAR'.
      gs_fieldcat-coltext   = 'Mat. Doc. Year'(163).
      gs_fieldcat-datatype    = 'MJAHR' .
      gs_fieldcat-outputlen   = 8.
      gs_fieldcat-col_pos     = 4.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname  = 'REF_DOC_IT'.
      gs_fieldcat-coltext   = 'Matl. Doc. Item'(164).
      gs_fieldcat-outputlen = 12.
      gs_fieldcat-col_pos     = 6.
      gs_fieldcat-datatype = 'MBLPO' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname   = 'LFSNR'.
      gs_fieldcat-coltext    = 'Delivery Note'(165).
      gs_fieldcat-outputlen   = 13.
      gs_fieldcat-col_pos     = 7.
      gs_fieldcat-datatype = 'LFSNR'.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname   = 'FRBNR'.
      gs_fieldcat-coltext   = 'Bill of lading'(166).
      gs_fieldcat-outputlen   = 13.
      gs_fieldcat-col_pos     = 7.
      gs_fieldcat-datatype = 'FRBNR'.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

    WHEN  /DBE/if_vms_constants=>c_qirb.

      gs_layout-grid_title = text-151.

      gs_fieldcat-fieldname   = '/DBE/SELECTED'.
      gs_fieldcat-tech = 'X'.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype = 'CHAR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'VHCLE'.
      gs_fieldcat-coltext     = 'Int. Veh. No.'(102).
      gs_fieldcat-outputlen   = 15.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype    = 'VHCLE' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'WERKS'.
      gs_fieldcat-coltext   = 'Plant'(160).
      gs_fieldcat-outputlen = 8.
      gs_fieldcat-col_pos     = 2.
      gs_fieldcat-datatype = 'WERKS_D' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'LGORT'.
      gs_fieldcat-coltext   = 'Storage Location'(161).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos     = 3.
      gs_fieldcat-datatype = 'LGORT_D' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.
*

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'INVOICEDOCNUMBER'.
      gs_fieldcat-coltext  = 'Invoice Document'(401).
      gs_fieldcat-datatype  = 'RE_BELNR' .
      gs_fieldcat-outputlen = 13.
      gs_fieldcat-col_pos   = 4.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname   = 'FISCALYEAR'.
      gs_fieldcat-coltext   = 'Fiscal Year'(402).
      gs_fieldcat-datatype    = 'GJAHR' .
      gs_fieldcat-outputlen   = 13.
      gs_fieldcat-col_pos     = 5.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname   = 'REF_DOC_NO'.
      gs_fieldcat-coltext   = 'Ref. Doc. Number'(403).
      gs_fieldcat-datatype    = 'XBLNR1' .
      gs_fieldcat-outputlen   = 13.
      gs_fieldcat-col_pos     = 6.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

    WHEN  /DBE/if_vms_constants=>c_qadc OR /DBE/if_vms_constants=>c_qapo.

      IF gv_action = /DBE/if_vms_constants=>c_qadc.
        gs_layout-grid_title = text-156.
      ELSEIF gv_action = /DBE/if_vms_constants=>c_qapo.
        gs_layout-grid_title = text-157.
      ENDIF.

      gs_fieldcat-fieldname   = '/DBE/SELECTED'.
      gs_fieldcat-tech = 'X'.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype = 'CHAR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'VHCLE'.
      gs_fieldcat-coltext     = 'Int. Veh. No.'(102).
      gs_fieldcat-outputlen   = 11.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype    = 'VHCLE' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = '/DBE/VSRESULT'.
      gs_fieldcat-fieldname   = 'MATNRTXT'.
      gs_fieldcat-coltext     = 'Vehicle Model'(408).
      gs_fieldcat-outputlen   = 11.
      gs_fieldcat-col_pos     = 2.
      gs_fieldcat-datatype    = 'VLC_MAKTX' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'LIFNR'.
      gs_fieldcat-coltext   = 'Vendor'(409).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos     = 3.
      gs_fieldcat-datatype = 'VLC_LIFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = '/DBE/COAUFNR'.
      gs_fieldcat-coltext     = 'Order Number'(410).
      gs_fieldcat-outputlen   = 15.
      gs_fieldcat-col_pos     = 4.
      gs_fieldcat-datatype    = 'AUFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = '/DBE/VLC_AC_PO'.
      gs_fieldcat-fieldname   = 'COST'.
      gs_fieldcat-cfieldname  = 'CURRENCY'.                "N:2304203
      gs_fieldcat-edit        = 'X'.
      gs_fieldcat-coltext     = 'Cost'(412).
      gs_fieldcat-outputlen   = 18. "12.
      gs_fieldcat-decimals    = 2. "6.
      gs_fieldcat-intlen      = 13. "12.
      gs_fieldcat-col_pos     = 5.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.


      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'CURRENCY'.
      gs_fieldcat-coltext   = 'Currency'(411).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos   = 7.
      gs_fieldcat-datatype = 'VLCACTDATA_HEAD_S-CURRENCY' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.


    WHEN  /DBE/if_vms_constants=>c_qagr.

      gs_layout-grid_title = text-154.

      gs_fieldcat-fieldname   = '/DBE/SELECTED'.
      gs_fieldcat-tech = 'X'.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype = 'CHAR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'VHCLE'.
      gs_fieldcat-coltext     = 'Int. Veh. No.'(102).
      gs_fieldcat-outputlen   = 11.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype    = 'VHCLE' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = '/DBE/VSRESULT'.
      gs_fieldcat-fieldname   = 'MATNRTXT'.
      gs_fieldcat-coltext     = 'Vehicle Model'(408).
      gs_fieldcat-outputlen   = 12.
      gs_fieldcat-col_pos     = 2.
      gs_fieldcat-datatype    = 'VLC_MAKTX' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname = 'EXT_SERVICE_LIFNR'.
      gs_fieldcat-coltext   = 'Service Vendor'(711).
      gs_fieldcat-outputlen = 12.
      gs_fieldcat-col_pos     = 3.
      gs_fieldcat-datatype = 'VLC_LIFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = '/DBE/COAUFNR'.
      gs_fieldcat-coltext     = 'Order Number'(410).
      gs_fieldcat-outputlen   = 15.
      gs_fieldcat-col_pos     = 4.
      gs_fieldcat-datatype    = 'AUFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-fieldname   = 'COST'.
      gs_fieldcat-coltext     = 'Cost'(412).
      gs_fieldcat-cfieldname  = 'CURRENCY'.                "N:2304203
      gs_fieldcat-outputlen   = 10.
      gs_fieldcat-col_pos     = 5.
      gs_fieldcat-datatype    = 'CURR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'CURRENCY'.
      gs_fieldcat-coltext   = 'Currency'(411).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos   = 7.
      gs_fieldcat-datatype = 'VLCACTDATA_HEAD_S-CURRENCY' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_NUMBER'.
      gs_fieldcat-coltext   = 'Purchase Order'(106).
      gs_fieldcat-outputlen = 13.
      gs_fieldcat-col_pos     = 8.
      gs_fieldcat-datatype = 'EBELN' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_ITEM'.
      gs_fieldcat-coltext   = 'Item'(115).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos     = 9.
      gs_fieldcat-datatype = 'EBELP' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-fieldname   = 'BUDAT'.
      gs_fieldcat-coltext   = 'Posting Date'(169).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos     = 10.
      gs_fieldcat-datatype = 'DATS' .
      gs_fieldcat-f4availabl = 'X'.
      gs_fieldcat-edit = 'X'.
      gs_fieldcat-tech = 'X'.
      gs_fieldcat-tabname = 'D'.

      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.


    WHEN  /DBE/if_vms_constants=>c_qain.

      gs_layout-grid_title = text-155.

      gs_fieldcat-fieldname   = '/DBE/SELECTED'.
      gs_fieldcat-tech = 'X'.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype = 'CHAR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'VHCLE'.
      gs_fieldcat-coltext     = 'Int. Veh. No.'(102).
      gs_fieldcat-outputlen   = 11.
      gs_fieldcat-col_pos     = 1.
      gs_fieldcat-datatype    = 'VHCLE' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = '/DBE/VSRESULT'.
      gs_fieldcat-fieldname   = 'MATNRTXT'.
      gs_fieldcat-coltext     = 'Vehicle Model'(408).
      gs_fieldcat-outputlen   = 12.
      gs_fieldcat-col_pos     = 2.
      gs_fieldcat-datatype    = 'VLC_MAKTX' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname = 'EXT_SERVICE_LIFNR'.
      gs_fieldcat-coltext   = 'Service Vendor'(711).
      gs_fieldcat-outputlen = 12.
      gs_fieldcat-col_pos     = 3.
      gs_fieldcat-datatype = 'VLC_LIFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = '/DBE/COAUFNR'.
      gs_fieldcat-coltext     = 'Order Number'(410).
      gs_fieldcat-outputlen   = 13.
      gs_fieldcat-col_pos     = 4.
      gs_fieldcat-datatype    = 'AUFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-fieldname   = 'COST'.
      gs_fieldcat-coltext     = 'Cost'(412).
      gs_fieldcat-cfieldname  = 'CURRENCY'.                "N:2304203
      gs_fieldcat-outputlen   = 10.
      gs_fieldcat-col_pos     = 5.
      gs_fieldcat-datatype    = 'CURR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'CURRENCY'.
      gs_fieldcat-coltext   = 'Currency'(411).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos   = 6.
      gs_fieldcat-datatype = 'VLCACTDATA_HEAD_S-CURRENCY' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.


      gs_fieldcat-fieldname = 'TAX_AMOUNT'.
      gs_fieldcat-coltext   = 'Tax Amount'(094).
      gs_fieldcat-cfieldname  = 'CURRENCY'.                "N:2304203
      gs_fieldcat-outputlen = 13.
      gs_fieldcat-col_pos   = 7.
      gs_fieldcat-datatype  = 'CURR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-fieldname = 'REF_DOC'.
      gs_fieldcat-coltext  = 'Material Document'(162).
      gs_fieldcat-datatype  = 'MBLNR' .
      gs_fieldcat-outputlen = 13.
      gs_fieldcat-col_pos   = 8.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-fieldname   = 'REF_DOC_YEAR'.
      gs_fieldcat-coltext   = 'Mat. Doc. Year'(163).
      gs_fieldcat-datatype    = 'MJAHR' .
      gs_fieldcat-outputlen   = 8.
      gs_fieldcat-col_pos     = 9.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.


    WHEN /DBE/if_vms_constants=>c_qaic.

      gs_layout-sel_mode = 'A'.
      gs_layout-no_rowmark = abap_true.

*     status icon                                                    N:2348422
      gs_fieldcat-fieldname   = 'ICON'.
      gs_fieldcat-coltext     = 'Status'(178).
      gs_fieldcat-outputlen   = 2.
      gs_fieldcat-col_pos     = 1.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      CLEAR  gs_fieldcat.
      gs_fieldcat-fieldname   = gc_is_selected.
      gs_fieldcat-coltext = 'Select'(008).
      gs_fieldcat-outputlen = 6.
      gs_fieldcat-col_pos     = 2.                                   "N:2348422
      gs_fieldcat-checkbox = abap_true.
      gs_fieldcat-edit = abap_true.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = '/DBE/VLC_AC_PO'.
      gs_fieldcat-fieldname   = 'INV_NUMBER'.
      gs_fieldcat-coltext   = 'Invoice Doc. No'(175).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos     = 3.                                   "N:2348422
      gs_fieldcat-datatype = 'RE_BELNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = '/DBE/VLC_AC_PO'.
      gs_fieldcat-fieldname   = 'INV_YEAR'.
      gs_fieldcat-coltext   = 'Year'(168).
      gs_fieldcat-outputlen = 4.
      gs_fieldcat-col_pos     = 4.                                   "N:2348422
      gs_fieldcat-datatype = 'GJAHR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_NUMBER'.
      gs_fieldcat-coltext     = 'Purchase Order'(113).
      gs_fieldcat-outputlen   = 10.
      gs_fieldcat-col_pos     = 5.                                   "N:2348422
      gs_fieldcat-datatype    = 'BSTNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_ITEM'.
      gs_fieldcat-coltext     = 'Item'(115).
      gs_fieldcat-outputlen   = 5.
      gs_fieldcat-col_pos     = 6.                                   "N:2348422
      gs_fieldcat-datatype    = 'EBELP' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'VHCLE'.
      gs_fieldcat-coltext     = 'Int. Veh. No.'(102).
      gs_fieldcat-outputlen   = 10.
      gs_fieldcat-col_pos     = 7.                                   "N:2348422
      gs_fieldcat-datatype    = 'VHCLE' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = '/DBE/VSRESULT'.
      gs_fieldcat-fieldname   = 'MATNRTXT'.
      gs_fieldcat-coltext     = 'Vehicle Model'(408).
      gs_fieldcat-outputlen   = 12.
      gs_fieldcat-col_pos     = 8.                                   "N:2348422
      gs_fieldcat-datatype    = 'VLC_MAKTX' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname = 'EXT_SERVICE_LIFNR'.
      gs_fieldcat-coltext   = 'Service Vendor'(711).
      gs_fieldcat-outputlen = 12.
      gs_fieldcat-col_pos     = 9.                                   "N:2348422
      gs_fieldcat-datatype = 'VLC_LIFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = '/DBE/COAUFNR'.
      gs_fieldcat-coltext     = 'Order Number'(410).
      gs_fieldcat-outputlen   = 12.
      gs_fieldcat-col_pos     = 10.                                  "N:2348422
      gs_fieldcat-datatype    = 'AUFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname = '/DBE/VLC_AC_PO'.
      gs_fieldcat-fieldname   = 'COST'.
      gs_fieldcat-coltext     = 'Cost'(412).
      gs_fieldcat-cfieldname  = 'CURRENCY'.                "N:2304203
      gs_fieldcat-col_pos     = 11.                                  "N:2348422
      gs_fieldcat-datatype    = '/DBE/NETAMT' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'CURRENCY'.
      gs_fieldcat-coltext   = 'Currency'(411).
      gs_fieldcat-outputlen = 5.
      gs_fieldcat-col_pos   = 12.                                    "N:2348422
      gs_fieldcat-datatype = 'VLCACTDATA_HEAD_S-CURRENCY' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'REF_DOC'.
      gs_fieldcat-coltext   = 'Goods Receipt No.'(167).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos     = 13.                                  "N:2348422
      gs_fieldcat-datatype = 'MBLNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'REF_DOC_YEAR'.
      gs_fieldcat-coltext   = 'Year'(177).
      gs_fieldcat-outputlen = 4.
      gs_fieldcat-col_pos   = 14.                                    "N:2348422
      gs_fieldcat-datatype = 'MJAHR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      REFRESH gt_sort.
      t_sort-fieldname = 'INV_NUMBER'.
      t_sort-spos = 1.
      t_sort-up = abap_true.
      APPEND t_sort TO gt_sort.

    WHEN /DBE/if_vms_constants=>c_qacc.

      t_sort-fieldname = 'PO_NUMBER'.
      t_sort-spos = 1.
      t_sort-up = abap_true.
      APPEND t_sort TO gt_sort.

      t_sort-fieldname = 'PO_ITEM'.
      t_sort-spos = 2.
      t_sort-up = abap_true.
      APPEND t_sort TO gt_sort.

      gs_layout-sel_mode = 'A'.
      gs_layout-no_rowmark = abap_true.

      CLEAR gs_fieldcat.

*     status icon                                                    N:2348422
      gs_fieldcat-fieldname   = 'ICON'.
      gs_fieldcat-coltext     = 'Status'(178).
      gs_fieldcat-outputlen   = 2.
      gs_fieldcat-col_pos     = 1.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-fieldname   = gc_is_selected.
      gs_fieldcat-coltext = 'Select'(008).
      gs_fieldcat-outputlen = 6.
      gs_fieldcat-col_pos     = 2.                                   "N:2348422
      gs_fieldcat-checkbox = abap_true.
      gs_fieldcat-edit = abap_true.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_NUMBER'.
      gs_fieldcat-coltext     = 'Purchase Order'(113).
      gs_fieldcat-outputlen   = 11.
      gs_fieldcat-col_pos     = 3.                                   "N:2348422
      gs_fieldcat-datatype    = 'BSTNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_ITEM'.
      gs_fieldcat-coltext     = 'Item'(115).
      gs_fieldcat-outputlen   = 5.
      gs_fieldcat-col_pos     = 4.                                   "N:2348422
      gs_fieldcat-datatype    = 'EBELP' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'VHCLE'.
      gs_fieldcat-coltext     = 'Int. Veh. No.'(102).
      gs_fieldcat-outputlen   = 10.
      gs_fieldcat-col_pos     = 5.                                   "N:2348422
      gs_fieldcat-datatype    = 'VHCLE' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = '/DBE/VSRESULT'.
      gs_fieldcat-fieldname   = 'MATNRTXT'.
      gs_fieldcat-coltext     = 'Vehicle Model'(408).
      gs_fieldcat-outputlen   = 10.
      gs_fieldcat-col_pos     = 6.                                   "N:2348422
      gs_fieldcat-datatype    = 'VLC_MAKTX' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname = 'EXT_SERVICE_LIFNR'.
      gs_fieldcat-coltext   = 'Service Vendor'(711).
      gs_fieldcat-outputlen = 12.
      gs_fieldcat-col_pos   = 7.                                     "N:2348422
      gs_fieldcat-datatype = 'VLC_LIFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = '/DBE/COAUFNR'.
      gs_fieldcat-coltext     = 'Order Number'(410).
      gs_fieldcat-outputlen   = 12.
      gs_fieldcat-col_pos     = 8.
      gs_fieldcat-datatype    = 'AUFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname = '/DBE/VLC_AC_PO'.
      gs_fieldcat-fieldname   = 'COST'.
      gs_fieldcat-coltext     = 'Cost'(412).
      gs_fieldcat-cfieldname  = 'CURRENCY'.                "N:2304203
      gs_fieldcat-col_pos     = 9.                                   "N:2348422
      gs_fieldcat-datatype    = 'CURR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'CURRENCY'.
      gs_fieldcat-coltext   = 'Currency'(411).
      gs_fieldcat-outputlen = 5.
      gs_fieldcat-col_pos   = 10.                                    "N:2348422
      gs_fieldcat-datatype = 'VLCACTDATA_HEAD_S-CURRENCY' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'REF_DOC'.
      gs_fieldcat-coltext   = 'Goods Receipt No.'(167).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos     = 11.                                  "N:2348422
      gs_fieldcat-datatype = 'MBLNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'REF_DOC_YEAR'.
      gs_fieldcat-coltext   = 'Year'(177).
      gs_fieldcat-outputlen = 4.
      gs_fieldcat-col_pos     = 12.                                  "N:2348422
      gs_fieldcat-datatype = 'MJAHR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = '/DBE/VLC_AC_PO'.
      gs_fieldcat-fieldname   = 'INV_NUMBER'.
      gs_fieldcat-coltext   = 'Invoice Doc. No'(175).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos     = 13.                                  "N:2348422
      gs_fieldcat-datatype = 'RE_BELNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = '/DBE/VLC_AC_PO'.
      gs_fieldcat-fieldname   = 'INV_YEAR'.
      gs_fieldcat-coltext   = 'Year'(168).
      gs_fieldcat-outputlen = 4.
      gs_fieldcat-col_pos   = 14.                                    "N:2348422
      gs_fieldcat-datatype = 'GJAHR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

    WHEN  /DBE/if_vms_constants=>c_qagc.

      gs_layout-sel_mode = 'A'.
      gs_layout-no_rowmark = abap_true.

      t_sort-fieldname = 'REF_DOC'.
      t_sort-spos = 1.
      t_sort-up = abap_true.
      APPEND t_sort TO gt_sort.

      t_sort-fieldname = 'PO_NUMBER'.
      t_sort-spos = 2.
      t_sort-up = abap_true.
      APPEND t_sort TO gt_sort.
      CLEAR gs_fieldcat.

      t_sort-fieldname = 'PO_ITEM'.
      t_sort-spos = 3.
      t_sort-up = abap_true.
      APPEND t_sort TO gt_sort.

      CLEAR gs_fieldcat.

*     status icon                                                    N:2348422
      gs_fieldcat-fieldname   = 'ICON'.
      gs_fieldcat-coltext     = 'Status'(178).
      gs_fieldcat-outputlen   = 2.
      gs_fieldcat-col_pos     = 1.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-fieldname   = gc_is_selected.
      gs_fieldcat-coltext = 'Select'(008).
      gs_fieldcat-outputlen = 6.
      gs_fieldcat-col_pos     = 2.                                   "N:2348422
      gs_fieldcat-checkbox = abap_true.
      gs_fieldcat-edit = abap_true.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'REF_DOC'.
      gs_fieldcat-coltext   = 'Goods Receipt No.'(167).
      gs_fieldcat-outputlen = 13.
      gs_fieldcat-col_pos     = 3.                                   "N:2348422
      gs_fieldcat-datatype = 'MBLNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'REF_DOC_YEAR'.
      gs_fieldcat-coltext   = 'GR. Year'(177).
      gs_fieldcat-outputlen = 4.
      gs_fieldcat-col_pos   = 4.                                     "N:2348422
      gs_fieldcat-datatype = 'MJAHR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_NUMBER'.
      gs_fieldcat-coltext     = 'Purchase Order'(113).
      gs_fieldcat-outputlen   = 13.
      gs_fieldcat-col_pos     = 5.                                   "N:2348422
      gs_fieldcat-datatype    = 'BSTNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_ITEM'.
      gs_fieldcat-coltext     = 'Item'(115).
      gs_fieldcat-outputlen   = 5.
      gs_fieldcat-col_pos     = 6.                                   "N:2348422
      gs_fieldcat-datatype    = 'EBELP' .
      APPEND gs_fieldcat TO gt_fieldcatalog.

      CLEAR  gs_fieldcat.
      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'VHCLE'.
      gs_fieldcat-coltext     = 'Int. Veh. No.'(102).
      gs_fieldcat-outputlen   = 13.
      gs_fieldcat-col_pos     = 7.                                   "N:2348422
      gs_fieldcat-datatype    = 'VHCLE' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = '/DBE/VSRESULT'.
      gs_fieldcat-fieldname   = 'MATNRTXT'.
      gs_fieldcat-coltext     = 'Vehicle Model'(408).
      gs_fieldcat-outputlen   = 15.
      gs_fieldcat-col_pos     = 8.                                   "N:2348422
      gs_fieldcat-datatype    = 'VLC_MAKTX' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname = 'EXT_SERVICE_LIFNR'.
      gs_fieldcat-coltext   = 'Service Vendor'(711).
      gs_fieldcat-outputlen = 12.
      gs_fieldcat-col_pos    = 9.                                    "N:2348422
      gs_fieldcat-datatype = 'VLC_LIFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = '/DBE/COAUFNR'.
      gs_fieldcat-coltext     = 'Order Number'(410).
      gs_fieldcat-outputlen   = 12.
      gs_fieldcat-col_pos     = 10.                                  "N:2348422
      gs_fieldcat-datatype    = 'AUFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname = '/DBE/VLC_AC_PO'.
      gs_fieldcat-fieldname   = 'COST'.
      gs_fieldcat-coltext     = 'Cost'(412).
      gs_fieldcat-cfieldname  = 'CURRENCY'.                "N:2304203
      gs_fieldcat-col_pos     = 11.                                  "N:2348422
      gs_fieldcat-datatype    = 'CURR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'CURRENCY'.
      gs_fieldcat-coltext   = 'Currency'(411).
      gs_fieldcat-outputlen = 10.
      gs_fieldcat-col_pos   = 12.                                    "N:2348422
      gs_fieldcat-datatype = 'VLCACTDATA_HEAD_S-CURRENCY' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

    WHEN /DBE/if_vms_constants=>c_qapc.

      gs_layout-sel_mode = 'A'.
      gs_layout-no_rowmark = abap_true.

      t_sort-fieldname = 'PO_NUMBER'.
      t_sort-spos = 1.
      t_sort-up = abap_true.
      APPEND t_sort TO gt_sort.

      t_sort-fieldname = 'PO_ITEM'.
      t_sort-spos = 2.
      t_sort-up = abap_true.
      APPEND t_sort TO gt_sort.

*     status icon                                                    N:2348422
      CLEAR gs_fieldcat.
      gs_fieldcat-fieldname   = 'ICON'.
      gs_fieldcat-coltext     = 'Status'(178).
      gs_fieldcat-outputlen   = 2.
      gs_fieldcat-col_pos     = 1.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      CLEAR gs_fieldcat.
      gs_fieldcat-fieldname   = gc_is_selected.
      gs_fieldcat-coltext = 'Selected'(008).
      gs_fieldcat-outputlen = 6.
      gs_fieldcat-col_pos     = 2.                                   "N:2348422
      gs_fieldcat-checkbox = abap_true.
      gs_fieldcat-edit = abap_true.
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_NUMBER'.
      gs_fieldcat-coltext     = 'Purchase Order'(113).
      gs_fieldcat-outputlen   = 14.
      gs_fieldcat-col_pos     = 3.                                   "N:2348422
      gs_fieldcat-datatype    = 'BSTNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'PO_ITEM'.
      gs_fieldcat-coltext     = 'Item'(115).
      gs_fieldcat-outputlen   = 6.
      gs_fieldcat-col_pos     = 4.                                   "N:2348422
      gs_fieldcat-datatype    = 'EBELP' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = 'VHCLE'.
      gs_fieldcat-coltext     = 'Int. Veh. No.'(102).
      gs_fieldcat-outputlen   = 12.
      gs_fieldcat-col_pos     = 5.                                   "N:2348422
      gs_fieldcat-datatype    = 'VHCLE' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = '/DBE/VSRESULT'.
      gs_fieldcat-fieldname   = 'MATNRTXT'.
      gs_fieldcat-coltext     = 'Vehicle Model'(408).
      gs_fieldcat-outputlen   = 18.
      gs_fieldcat-col_pos     = 6.                                   "N:2348422
      gs_fieldcat-datatype    = 'VLC_MAKTX' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname = 'EXT_SERVICE_LIFNR'.
      gs_fieldcat-coltext   = 'Service Vendor'(711).
      gs_fieldcat-outputlen = 12.
      gs_fieldcat-col_pos     = 7.                                   "N:2348422
      gs_fieldcat-datatype = 'VLC_LIFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname     = 'VLCACTDATA_ITEM_S'.
      gs_fieldcat-fieldname   = '/DBE/COAUFNR'.
      gs_fieldcat-coltext     = 'Order Number'(410).
      gs_fieldcat-outputlen   = 13.
      gs_fieldcat-col_pos     = 8.                                   "N:2348422
      gs_fieldcat-datatype    = 'AUFNR' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname = '/DBE/VLC_AC_PO'.
      gs_fieldcat-fieldname   = 'COST'.
      gs_fieldcat-coltext     = 'Cost'(412).
      gs_fieldcat-cfieldname  = 'CURRENCY'.                "N:2304203
      gs_fieldcat-col_pos     = 9.                                   "N:2348422
      gs_fieldcat-datatype    = '/DBE/NETAMT' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

      gs_fieldcat-tabname   = 'VLCACTDATA_HEAD_S'.
      gs_fieldcat-fieldname = 'CURRENCY'.
      gs_fieldcat-coltext   = 'Currency'(411).
      gs_fieldcat-outputlen = 5.
      gs_fieldcat-col_pos   = 10.                                    "N:2348422
      gs_fieldcat-datatype = 'VLCACTDATA_HEAD_S-CURRENCY' .
      APPEND gs_fieldcat TO gt_fieldcatalog.
      CLEAR  gs_fieldcat.

    WHEN /DBE/if_vms_constants=>c_qpdi.



      CLEAR gt_fieldcatalog.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = '/DBE/VMASS_PDI'
        CHANGING
          ct_fieldcat            = gt_fieldcatalog
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.


      LOOP AT gt_fieldcatalog ASSIGNING <fs_fieldcat>.
        CASE <fs_fieldcat>-fieldname.

          WHEN 'JOBNR'.

            <fs_fieldcat>-coltext     = 'Sl. No.'(703).
            <fs_fieldcat>-outputlen   = 10.
            <fs_fieldcat>-col_pos     = 1.

          WHEN 'JOB_DESCR'.

            <fs_fieldcat>-coltext     = 'Job Description'(704).
            <fs_fieldcat>-outputlen   = 30.
            <fs_fieldcat>-col_pos     = 2.
            <fs_fieldcat>-edit        =  abap_true.

          WHEN 'PACKAGE_ID'.

            <fs_fieldcat>-coltext     = text-714.
            <fs_fieldcat>-tooltip     = text-714.
            <fs_fieldcat>-outputlen   = 18.
            <fs_fieldcat>-col_pos      = 3.
            <fs_fieldcat>-ref_field    = 'PACKAGE_ID' .
            <fs_fieldcat>-ref_table    = '/DBE/VMASS_PDI' .
            <fs_fieldcat>-f4availabl = abap_true.
            <fs_fieldcat>-edit        =  abap_true.

          WHEN 'PACKAGE_DESCR'.

            <fs_fieldcat>-coltext     = 'Package Description'(708).
            <fs_fieldcat>-outputlen   = 30.
            <fs_fieldcat>-col_pos     = 4.
            <fs_fieldcat>-edit        =  abap_false.

          WHEN 'VARIANT_ID'.

            <fs_fieldcat>-col_pos     = 4.
            <fs_fieldcat>-edit        =  abap_true.

          WHEN 'PRICE_LIMIT'.

            <fs_fieldcat>-coltext     = 'Price Limit'(712).
            <fs_fieldcat>-outputlen   = 15.
            <fs_fieldcat>-col_pos     = 5.
            <fs_fieldcat>-edit        =  abap_true.

          WHEN 'PRICE_LIMIT_CUKY'.

            <fs_fieldcat>-coltext     = 'Limit Currency'(713).
            <fs_fieldcat>-outputlen   = 14.
            <fs_fieldcat>-col_pos     = 6.
            <fs_fieldcat>-edit        =  abap_false.

          WHEN 'PRICE_LIMIT_TYPE'.

            <fs_fieldcat>-coltext     = 'Gross/Net Limit'(715).
            <fs_fieldcat>-outputlen   = 15.
            <fs_fieldcat>-col_pos     = 7.
            <fs_fieldcat>-edit        =  abap_true.

        ENDCASE.
      ENDLOOP.



  ENDCASE.

ENDFORM.                    " BUILD_FIELDCATALOG
