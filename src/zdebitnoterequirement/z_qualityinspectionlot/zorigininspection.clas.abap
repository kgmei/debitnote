CLASS zorigininspection DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_ex_qc_cert_spec_origin .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZORIGININSPECTION IMPLEMENTATION.


  METHOD if_ex_qc_cert_spec_origin~execute.
  DATA(typ) = '12'.

  ENDMETHOD.
ENDCLASS.
