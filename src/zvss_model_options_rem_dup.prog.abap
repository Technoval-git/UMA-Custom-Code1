*&---------------------------------------------------------------------*
*& Report ZVSS_MODEL_OPTIONS_REM_DUP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvss_model_options_rem_dup.

DATA : gv_catelog TYPE /dbe/mcatalog,
       gv_model   TYPE /dbe/modcode_sale.

SELECT-OPTIONS : s_cat FOR gv_catelog,
                 s_model FOR gv_model.
PARAMETERS : p_del_d RADIOBUTTON GROUP del DEFAULT 'X' MODIF ID d1,
             p_del_m RADIOBUTTON GROUP del MODIF ID d1,
             p_del_f RADIOBUTTON GROUP del MODIF ID d1.

START-OF-SELECTION.

  SELECT * FROM /dbe/v_model INTO TABLE @DATA(lt_model) WHERE mcatalog IN @s_cat AND
                                                               mcodesd IN @s_model.

  IF lt_model IS NOT INITIAL.

    SELECT * FROM /dbe/v_moptions INTO TABLE @DATA(lt_m_options)
                              FOR ALL ENTRIES IN  @lt_model
                              WHERE model_guid EQ @lt_model-model_guid.

    SORT lt_m_options ASCENDING BY model_guid opclass optyp opkey.
    DELETE ADJACENT DUPLICATES FROM lt_m_options COMPARING model_guid opclass optyp opkey.

    IF p_del_d EQ 'X'.

      LOOP AT lt_model INTO DATA(ls_model).
        READ TABLE lt_m_options INTO DATA(ls_m_options) WITH KEY model_guid = ls_model-model_guid.
        IF sy-subrc EQ 0.
          DELETE FROM /dbe/v_moptions WHERE model_guid = ls_model-model_guid.
        ENDIF.
      ENDLOOP.

      MODIFY /dbe/v_moptions FROM TABLE lt_m_options.

    ELSEIF p_del_m EQ 'X'.

      LOOP AT lt_model INTO ls_model.
        DELETE FROM /dbe/v_model WHERE model_guid = ls_model-model_guid.
      ENDLOOP.


    ELSEIF p_del_f EQ 'X'.

      LOOP AT lt_model INTO ls_model.
        READ TABLE lt_m_options INTO ls_m_options WITH KEY model_guid = ls_model-model_guid.
        IF sy-subrc EQ 0.
          DELETE FROM /dbe/v_moptions WHERE model_guid = ls_model-model_guid.
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDIF.
