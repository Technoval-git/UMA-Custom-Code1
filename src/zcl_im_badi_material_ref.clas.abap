class ZCL_IM_BADI_MATERIAL_REF definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MATERIAL_REFERENCE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_BADI_MATERIAL_REF IMPLEMENTATION.


  METHOD if_ex_material_reference~create_material.
    DATA : ls_mm_mat_constant TYPE zmm_mat_constant.
*    data : LT_Ct_pur_tax type STANDARD TABLE OF tt_mat_steumm.
    DATA : ls_ct_pur_tax TYPE mg03steumm.
    DATA : ls_ct_sales_tax TYPE mg03steuer.
    IF i_mara-meins IS INITIAL.
      MOVE-CORRESPONDING i_mara TO e_marau.
      e_marau-meins = 'EA'.
      IF i_mara-spart IS  INITIAL.
        e_marau-spart = '00'.
      ENDIF.
    ENDIF.
    SELECT SINGLE * FROM zmm_mat_constant INTO ls_mm_mat_constant WHERE mtart EQ i_mara-mtart AND
                                                                        matkl EQ i_mara-matkl.
    IF sy-subrc EQ 0.

      SELECT SINGLE land1 INTO ls_ct_pur_tax-aland FROM t001w WHERE werks = i_marc-werks.
      IF sy-subrc = 0.
        ls_ct_pur_tax-taxim = ls_mm_mat_constant-taxim.
        APPEND ls_ct_pur_tax TO ct_pur_tax.
        IF i_marc-werks CP '2***'.
          SELECT SINGLE tatyp INTO  ls_ct_sales_tax-tatyp FROM tstl WHERE talnd = ls_ct_pur_tax-aland .

          IF sy-subrc = 0.

            READ TABLE ct_sales_tax ASSIGNING FIELD-SYMBOL(<fs_ct_sales_tax>) WITH KEY aland = ls_ct_pur_tax-aland.
            IF sy-subrc = 0.
              <fs_ct_sales_tax>-tatyp = ls_ct_sales_tax-tatyp.
              <fs_ct_sales_tax>-taxkm = ls_mm_mat_constant-taklv.
            ENDIF.
          ENDIF.
*          Changes Begins for SA
        ELSEIF i_marc-werks CP '1***'.

       SELECT SINGLE tatyp INTO  ls_ct_sales_tax-tatyp FROM tstl WHERE talnd = 'SA'.
          IF sy-subrc = 0.
            READ TABLE ct_sales_tax ASSIGNING FIELD-SYMBOL(<fs_ct_sales_tax1>) WITH KEY aland = 'SA'.
            IF sy-subrc = 0.
              <fs_ct_sales_tax1>-tatyp = ls_ct_sales_tax-tatyp.
              <fs_ct_sales_tax1>-taxkm = ls_mm_mat_constant-taklv.
            ENDIF.

          ENDIF.


*          changes ends here
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING i_mara TO e_marau.

      MOVE-CORRESPONDING i_marc TO e_marcu.
      MOVE-CORRESPONDING i_mard TO e_mardu.



      e_marau-spart = ls_mm_mat_constant-spart.
      e_marcu-mtvfp = ls_mm_mat_constant-mtvfp.
      e_marau-tragr = ls_mm_mat_constant-tragr.
      e_marcu-ladgr = ls_mm_mat_constant-ladgr.
      c_mbew-bklas = ls_mm_mat_constant-bklas.
      e_marcu-bwtty = ls_mm_mat_constant-bwtty.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_mm_mat_constant-prctr
        IMPORTING
          output = e_marcu-prctr.

      c_mvke-ktgrm = ls_mm_mat_constant-ktgrm.
      c_mvke-versg = ls_mm_mat_constant-versg.
      c_mvke-kondm = ls_mm_mat_constant-kondm.

      e_MARAu-raube = ls_mm_mat_constant-raube.
      e_MARAu-taklv = ls_mm_mat_constant-taklv.
      e_MARCu-dismm = ls_mm_mat_constant-dismm.
      e_MARCu-dispo = ls_mm_mat_constant-dispo.
      e_MARCu-disls = ls_mm_mat_constant-disls.
      c_MPOP-prmod = ls_mm_mat_constant-prmod.
      IF c_mpop-gewgr IS INITIAL.
        c_mpop-gewgr = ls_mm_mat_constant-gewgr.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
