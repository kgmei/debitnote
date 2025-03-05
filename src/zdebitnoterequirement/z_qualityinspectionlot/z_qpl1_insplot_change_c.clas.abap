CLASS z_qpl1_insplot_change_c DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_ex_qpl1_change_at_create4cl .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z_QPL1_INSPLOT_CHANGE_C IMPLEMENTATION.


  METHOD if_ex_qpl1_change_at_create4cl~execute_change.

  DATA(typ) = '32'.
IF inspectionlotdata-inspectionlot IS NOT INITIAL.



ENDIF.
  ENDMETHOD.
ENDCLASS.
