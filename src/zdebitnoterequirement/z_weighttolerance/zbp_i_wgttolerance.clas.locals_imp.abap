CLASS lhc_zi_wgttolerance DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_wgttolerance RESULT result.

    METHODS weighttolerance FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_wgttolerance~weighttolerance.
    METHODS weighttolvalidation FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_wgttolerance~weighttolvalidation.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR zi_wgttolerance RESULT result.

ENDCLASS.

CLASS lhc_zi_wgttolerance IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD weighttolerance.
  ENDMETHOD.

  METHOD WeightTolValidation.
*    READ ENTITIES OF zi_wgttolerance  IN LOCAL MODE
*           ENTITY zi_wgttolerance
*           FIELDS ( Weightid ) WITH CORRESPONDING #( keys )
*           RESULT DATA(resweighttol).
*    LOOP AT resweighttol INTO DATA(ls_resweighttol).
*      SELECT SINGLE FROM zweighttolerance
*             FIELDS weightid
*             WHERE weightid = @ls_resweighttol-Weightid
*            INTO @DATA(lt_resweighttol).
*
*      IF lt_resweighttol is initial or lt_resweighttol <> 'ROOT' .
*        APPEND VALUE #( %tky = ls_resweighttol-%tky ) TO failed-zi_wgttolerance.
*        APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                        %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text = |Create/Update Not Allowed.|
*                         )  )
*                         TO reported-zi_wgttolerance.
*
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_features.


      SELECT SINGLE FROM zweighttolerance
             FIELDS weightid
             WHERE weightid = 'ROOT'
            INTO @DATA(lt_resweighttol).

      IF lt_resweighttol is not initial.

    DATA lv_allowed_create TYPE abap_boolean.

*    lv_allowed_create = zcl_qm_claim=>get_global_create_allowed( ).
    IF lv_allowed_create = abap_false.

      result-%create =  if_abap_behv=>fc-o-disabled.
    ENDIF.
      ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_wgttolerance DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_wgttolerance IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
