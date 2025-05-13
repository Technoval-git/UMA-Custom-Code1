*&---------------------------------------------------------------------*
*& Include          ZXTOBU01
*&---------------------------------------------------------------------*
INCLUDE /pacg/rsm_exit_saplito0_001.

/pacg/cl_rsm_rent_enh=>exit_saplito0_001( EXPORTING iv_object_type   = i_object_type
                                                     iv_activity_type = i_activity_type
                                                     iv_deletion_flag = i_deletion_flag
                                                     iv_active_fcode  = i_active_fcode
                                                     is_data_equi     = i_data_equi
                                                     is_data_eqkt     = i_data_eqkt
                                                     is_data_equz     = i_data_equz
                                                     is_data_iloa     = i_data_iloa
                                                     is_data_iflo     = i_data_iflo
                                                     is_data_fleet    = i_data_fleet
                                           CHANGING  cs_equi        = equi
                                                     cv_subscreen   = e_subscreen_number ).
