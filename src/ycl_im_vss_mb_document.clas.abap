class YCL_IM_VSS_MB_DOCUMENT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MB_DOCUMENT_BADI .
protected section.
private section.
ENDCLASS.



CLASS YCL_IM_VSS_MB_DOCUMENT IMPLEMENTATION.


  METHOD if_ex_mb_document_badi~mb_document_before_update.
    DATA: l_mseg  TYPE mseg,
          l_mkpf  TYPE mkpf,
          wa_mseg TYPE mseg,
          wa_mkpf TYPE mkpf,
          lt_mseg TYPE TABLE OF mseg,
          lt_mkpf TYPE TABLE OF mkpf.

    READ TABLE xmkpf INTO l_mkpf INDEX 1.
    READ TABLE xmseg INTO l_mseg INDEX 1.
    lt_mseg = xmseg.
    lt_mkpf = xmkpf.

    EXPORT l_mkpf_memory FROM l_mkpf TO MEMORY ID 'MSG'.
    EXPORT l_mseg_memory FROM l_mseg TO MEMORY ID 'MSG'.
    EXPORT l_mkpf_memory2 FROM lt_mkpf TO MEMORY ID 'MSGT'.
    EXPORT l_mseg_memory2 FROM lt_mseg TO MEMORY ID 'MSGT'.
  ENDMETHOD.


  method IF_EX_MB_DOCUMENT_BADI~MB_DOCUMENT_UPDATE.

  endmethod.
ENDCLASS.
