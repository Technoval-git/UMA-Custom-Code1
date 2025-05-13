*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_ACTION_INI
*&---------------------------------------------------------------------*
*&
*& This include contains the constant value keys of the DBM vehicle API-
*& and buffer-layer which are used in the INI-file.
*&
*& In /DBE/CTRL_OBJ, SAP defines the default values for these keys
*& In /DBE/CTRL_OBJ_C, customers can overwrite the SAP defaults. Table
*& /DBE/CTRL_OBJ_C is be delivered empty by SAP
*&
*& The constants defined in this include should be defined in a way
*& that it's possible to define a SET/GET-parameter of the same name.
*& The reason for that is the fact that in /DBE/VM15_GET_INI_VALUE,
*& the function module which reads the INI-file, also tries to read a
*& SET/GET-parameter which has the same name as the constant defined
*& here.
*&
*& Please do NOT use this include to define constants which are
*& not relevant for the INI file.
*&
*& The values assigned to this constants ...
*& - must start with /DBE/
*& - must not be longer than CHAR20
*&
*&---------------------------------------------------------------------*

CONSTANTS:

* ORDER TYPES

* Default internal order type (CO)
  gc_auart_co             TYPE /dbe/ctrl_object  VALUE '/DBE/V_AUART', "#EC

* Default order type for partner determination
  gc_auart_pd             TYPE /dbe/ctrl_object  VALUE '/DBE/V_AUART_PD', "#EC

* ------

* VMS ACTIONS

* Default VMS vehicle creation action
  gc_actn_cre             TYPE /dbe/ctrl_object  VALUE '/DBE/V_ACT_CREATE', "#EC

* Default VMS lean vehicle creation action; incl cust assignment
  gc_actn_clv             TYPE /dbe/ctrl_object  VALUE '/DBE/V_ACT_CREALV', "#EC

* Default for generic VMS vehicle change action
  gc_actn_chg             TYPE /dbe/ctrl_object  VALUE '/DBE/V_ACT_CHANGE', "#EC

* Default VMS action: Assign customer
  gc_actn_cas             TYPE /dbe/ctrl_object  VALUE '/DBE/V_ACT_CUSTASSGN', "#EC

* Default VMS action: Unassign customer
  gc_actn_ucs             TYPE /dbe/ctrl_object  VALUE '/DBE/V_ACT_CUSTREMOV', "#EC

* Default VMS action: Create Offer
  gc_ini_act_oeoff_cre    TYPE /dbe/ctrl_object VALUE '/DBE/V_ACT_OEOFF_CRE',
*

* Default VMS action: Create Order
  gc_ini_act_oeord_cre    TYPE /dbe/ctrl_object VALUE '/DBE/V_ACT_OEORD_CRE',


* Default VMS action: Create Service-Order
  gc_ini_act_svord_cre    TYPE /dbe/ctrl_object VALUE '/DBE/V_ACT_SVORD_CRE',
*

* Default VMS aktion: Vehicle transfer between Plants
  gc_ini_act_vhtra_plt    TYPE /dbe/ctrl_object VALUE '/DBE/V_ACT_STOCK_TRP',

*Default VMS aktion: Vehicle transfer between Companys
  gc_ini_act_vhtra_cmp    TYPE /dbe/ctrl_object VALUE '/DBE/V_ACT_STOCK_TRC',

* ------

* DBM ACTIONS

*DBM action: Update vehicle History for Notifications
  gc_ini_act_qntf_cre     TYPE /dbe/ctrl_object VALUE '/DBE/V_ACT_QNTF_CRE',

*DBM action: Repurchase used vehicle
  gc_actn_qrpu            TYPE /dbe/ctrl_object VALUE '/DBE/V_ACT_REPRCH',

* -----

* IOBJECT

* Default object family for iobject
  gc_iobj_family          TYPE /dbe/ctrl_object  VALUE '/DBE/V_OBJ_FAMILY', "#EC *

* Language for IObject multi texts, if in loggon language doesn't exist
  gc_iobj_text_langu(20)  TYPE c VALUE '/DBE/V_IOBJ_TEXT_LAN', "#EC *

* -----

* UNITS OF MEASUREMENT

* Default cubic capacity unit of measurement
  gc_eng_cubc_unit        TYPE /dbe/ctrl_object VALUE '/DBE/V_ENG_CUBC_UNIT', "#EC *

* Default engine performanve unit of measurement
  gc_eng_prfm_unit        TYPE /dbe/ctrl_object VALUE '/DBE/V_ENG_PRFM_UNIT', "#EC *

* Default unit of measurement for odometer reading / distance
  gc_uom_distance         TYPE /dbe/ctrl_object  VALUE '/DBE/V_UOM_DIST', "#EC *

* Default currency
  gc_v_def_curr           TYPE /dbe/ctrl_object VALUE '/DBE/V_DEF_CURR', "#EC *

* Fuel Consumption Combined unit of measurement
  gc_fuelcon_com_unit     TYPE /dbe/ctrl_object VALUE '/DBE/V_FUELCON_COM_U', "#EC *

* Fuel Cons. City unit of measurement
  fc_fuelcon_cit_unit     TYPE /dbe/ctrl_object VALUE '/DBE/V_FUELCON_CIT_U', "#EC *

* Fuel Cos.Out Of City unit of measurement
  fc_fuelcon_out_unit     TYPE /dbe/ctrl_object VALUE '/DBE/V_FUELCON_OUT_U', "#EC *

* Fuel Tank Capacity unit of measurement
  fc_fuelcapa_unit        TYPE /dbe/ctrl_object VALUE '/DBE/V_FUELCAPA_U', "#EC *

* Unloaded Weight unit of measurement
  fc_weight_unlo_unit     TYPE /dbe/ctrl_object VALUE '/DBE/V_WEIGHT_UNLO_U', "#EC *

* Maximum Weight unit of measurement
  fc_weight_maxi_unit     TYPE /dbe/ctrl_object VALUE '/DBE/V_WEIGHT_MAXI_U', "#EC *

* CO2 emission unit of measurement
  fc_co2_emissio_unit     TYPE /dbe/ctrl_object VALUE '/DBE/V_CO2_EMISSIO_U', "#EC *

* Fuel reserve capacity unit
  gc_fueltank_capa_unit   TYPE /dbe/ctrl_object VALUE '/DBE/V_RESCAPA_U', "#EC *

* AdBlue capacity unit
  gc_adblue_capa_unit     TYPE /dbe/ctrl_object VALUE '/DBE/V_ADBLUECAPA_U', "#EC *

* Battery capacity unit
  gc_bat_capa_unit        TYPE /dbe/ctrl_object VALUE '/DBE/V_BATCAPA_U', "#EC *

* max charging current unit
  gc_maxcharg_curr_unit   TYPE /dbe/ctrl_object VALUE '/DBE/V_MAXCHARGCUR_U', "#EC *

* engine performance unit
  gc_eng_performance_unit TYPE /dbe/ctrl_object VALUE '/DBE/V_ENG_PRFM_UNIT', "#EC *

* torque performance unit
  gc_tor_performance_unit TYPE /dbe/ctrl_object VALUE '/DBE/V_TOR_PRFM_UNIT', "#EC *

* electric consumption unit
  gc_el_cons_unit         TYPE /dbe/ctrl_object VALUE '/DBE/V_ELECCON_COM_U', "#EC *

* total consumption unit
  gc_tot_cons_unit        TYPE /dbe/ctrl_object VALUE '/DBE/V_TOTACON_COM_U', "#EC *

* electric range unit
  gc_el_range_unit        TYPE /dbe/ctrl_object VALUE '/DBE/V_ELRANGE_U', "#EC *


* -----

* BUSINESS TRANSACTION TYPES

* Default business type for new cars
  gc_bustype_nc           TYPE /dbe/ctrl_object  VALUE '/DBE/V_BUSTYPE_NC', "#EC *

* Default business type for used cars
  gc_bustype_uc           TYPE /dbe/ctrl_object  VALUE '/DBE/V_BUSTYPE_UC', "#EC *

* -----

* VALUATION CLASSES

* Default valuation class for new cars
  gc_valclass_nc          TYPE  /dbe/ctrl_object VALUE '/DBE/V_VALCLASS_NVEH', "#EC *

* Default valuation class for used cars
  gc_valclass_uc          TYPE  /dbe/ctrl_object VALUE '/DBE/V_VALCLASS_UVEH', "#EC *
* -----

* PURCHASE ORDER CONDITION TYPES

* Condition type for new vehicle option
  gc_cond_optnew          TYPE  /dbe/ctrl_object VALUE '/DBE/V_COND_OPTNEW',

* Condition type for vehicle damage markdown
  gc_cond_damage          TYPE  /dbe/ctrl_object VALUE '/DBE/V_COND_DAMAGE',

* Condition type for vehicle net price
  gc_cond_netprice        TYPE  /dbe/ctrl_object VALUE '/DBE/V_COND_NETPRICE',

* Material group for missing handover items
  gc_matkl_feature        TYPE  /dbe/ctrl_object VALUE '/DBE/V_MATKL_FEATURE',

* Material group for dealer cost item
  gc_matkl_dealcos        TYPE  /dbe/ctrl_object   VALUE '/DBE/V_MATKL_DEALCOS',

* -----

* VEHICLE MODEL

* Length of model list in /DBE/VMODEL overview
  gc_mod_maxrows          TYPE  /dbe/ctrl_object VALUE '/DBE/V_VMOD_MAX_ROWS'.
