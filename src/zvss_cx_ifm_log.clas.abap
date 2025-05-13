CLASS zvss_cx_ifm_log DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

*    METHODS constructor
*      IMPORTING
*        !textid   LIKE if_t100_message=>t100key OPTIONAL
*        !previous LIKE previous OPTIONAL
*        !msgv1    TYPE msgv1 OPTIONAL
*        !msgv2    TYPE msgv2 OPTIONAL
*        !msgv3    TYPE msgv3 OPTIONAL
*        !msgv4    TYPE msgv4 OPTIONAL .

    CONSTANTS:
      BEGIN OF cannot_create_log,
        msgid TYPE symsgid VALUE 'ZVSS_IFM_LOGX',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF cannot_create_log .
    CONSTANTS:
      BEGIN OF log_is_full,
        msgid TYPE symsgid VALUE 'ZVSS_IFM_LOGX',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF log_is_full .
    CONSTANTS:
      BEGIN OF log_fail_save,
        msgid TYPE symsgid VALUE 'ZVSS_IFM_LOGX',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF log_fail_save .
    CONSTANTS:
      BEGIN OF log_fail_open,
        msgid TYPE symsgid VALUE 'ZVSS_IFM_LOGX',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF log_fail_open .
    CONSTANTS:
      BEGIN OF log_fail_export,
        msgid TYPE symsgid VALUE 'ZVSS_IFM_LOGX',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF log_fail_export .
    CONSTANTS:
      BEGIN OF log_fail_import,
        msgid TYPE symsgid VALUE 'ZVSS_IFM_LOGX',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF log_fail_import .

    DATA msgv1 TYPE msgv1 .
    DATA msgv2 TYPE msgv2 .
    DATA msgv3 TYPE msgv3 .
    DATA msgv4 TYPE msgv4 .

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        !msgv1    TYPE msgv1 OPTIONAL
        !msgv2    TYPE msgv2 OPTIONAL
        !msgv3    TYPE msgv3 OPTIONAL
        !msgv4    TYPE msgv4 OPTIONAL .
protected section.
private section.
ENDCLASS.



CLASS ZVSS_CX_IFM_LOG IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MSGV1 = MSGV1 .
me->MSGV2 = MSGV2 .
me->MSGV3 = MSGV3 .
me->MSGV4 = MSGV4 .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
