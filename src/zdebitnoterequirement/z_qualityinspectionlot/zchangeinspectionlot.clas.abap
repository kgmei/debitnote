CLASS zchangeinspectionlot DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_ex_qpl1_change_at_create4cl .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCHANGEINSPECTIONLOT IMPLEMENTATION.


  METHOD if_ex_qpl1_change_at_create4cl~execute_change.
  DATA(a) = '3'.
   DATA(ba) = '32'.
  ENDMETHOD.
ENDCLASS.
