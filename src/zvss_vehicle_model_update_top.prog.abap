*&---------------------------------------------------------------------*
*& Include          ZVSS_VEHICLE_MODEL_UPDATE_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_data,
         vhvin TYPE vlc_vhvin,
         matnr TYPE vlc_matnr,
       END OF ty_data.
DATA: gt_source TYPE STANDARD TABLE OF ty_data,
      gw_source TYPE ty_data.


CONSTANTS:gc_csv_sep TYPE char01 VALUE ','.
