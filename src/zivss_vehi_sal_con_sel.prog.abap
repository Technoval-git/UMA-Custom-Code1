*&---------------------------------------------------------------------*
*& Include          ZIVSS_VEHI_SAL_CON_SEL
*&---------------------------------------------------------------------*

SELECT-OPTIONS : s_bukrs FOR vbrk-bukrs,
                 s_vkorg FOR vbrk-vkorg,
                 s_spart FOR vbrk-spart,
                 s_vtweg FOR vbrk-vtweg,
                 s_fkdat FOR vbrk-fkdat,
                 s_fkart FOR vbrk-fkart,
                 s_vhvin FOR vlcvehicle-vhvin.
PARAMETERS : p_pom TYPE c AS CHECKBOX,
             p_veh TYPE c AS CHECKBOX.
