FUNCTION-POOL ZDBE_VEHI_MASS_PROCESSING.    "MESSAGE-ID ..

CONTROLS:  mass TYPE TABSTRIP.
DATA : go_ac_create                   TYPE REF TO cl_gui_alv_grid.
DATA : go_ac_cancel                   TYPE REF TO cl_gui_alv_grid.
DATA : go_pdi_ordcrt                  TYPE REF TO cl_gui_alv_grid.
DATA : go_pdi_order                   TYPE REF TO /dbe/cl_api_pdi_order.

DATA : gv_ekorg_0600_visible          TYPE abap_bool.       "N:2711659
DATA : gv_ekgrp_0600_visible          TYPE abap_bool.

CONSTANTS:
  gv_pricing_new  TYPE /dbe/veh_pricingtype  VALUE '1',
  gv_pricing_used TYPE /dbe/veh_pricingtype  VALUE '2'.
*data  gc_receiv.
*Types

INCLUDE /dbe/vehi_mass_procesng_ty01.

*Constants
INCLUDE /dbe/vehi_mass_procesng_con01.

*Data Declarations and References
INCLUDE /dbe/vehi_mass_procesng_var01.

*Tables
INCLUDE /dbe/vehi_mass_procesng_t01.

*Selection Screen - 2200
INCLUDE /dbe/lvehi_mass_processingsel.

*Class Definitions and Implemenatation.
INCLUDE /dbe/vehi_mass_procesng_cl01.

*Input Modules
INCLUDE /dbe/vehi_mass_procesng_imod01.

*Output Modules
INCLUDE /dbe/vehi_mass_procesng_omod01.

*References
INCLUDE /dbe/vehi_mass_procesng_var02.
INCLUDE /dbe/lvehi_mass_processingf79.
