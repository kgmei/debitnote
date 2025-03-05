CLASS zbp_i_ins_char DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zi_ins_char.

CLASS-DATA: BEGIN OF item,

            material             TYPE string,
            productdes    TYPE string,
            price TYPE decfloat16,
          END OF item.

CLASS-DATA: it_item LIKE TABLE OF item,
             wa_item LIKE item.



protected section.
private section.
ENDCLASS.



CLASS ZBP_I_INS_CHAR IMPLEMENTATION.
ENDCLASS.
