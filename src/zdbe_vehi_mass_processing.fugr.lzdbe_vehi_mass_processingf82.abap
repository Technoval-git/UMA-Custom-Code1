**----------------------------------------------------------------------*
****INCLUDE /DBE/LVEHI_MASS_PROCESSINGF82 .
**----------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Form  F_CALL_RFC_WAIT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM f_call_rfc_wait .
*
*  DATA lv_mssg(80).                                         "#EC NEEDED
*
** Wait in a task
*  CALL FUNCTION 'RFC_PING_AND_WAIT' STARTING NEW TASK '001'
*    PERFORMING f_task_end ON END OF TASK
*    EXPORTING
*      seconds               = 5        " Refresh time
*      busy_waiting          = space
*    EXCEPTIONS
*      resource_failure      = 1
*      communication_failure = 2  MESSAGE lv_mssg
*      system_failure        = 3  MESSAGE lv_mssg
*      OTHERS                = 4.
*
*ENDFORM.                    " F_CALL_RFC_WAIT
