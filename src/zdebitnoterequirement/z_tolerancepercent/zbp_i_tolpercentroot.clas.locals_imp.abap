CLASS lhc_zi_tolpercentitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS TolPercentPrd FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_TOLPERCENTITEM~TolPercentPrd.

ENDCLASS.

CLASS lhc_zi_tolpercentitem IMPLEMENTATION.

  METHOD TolPercentPrd.
    READ ENTITIES OF zi_tolpercentroot  IN LOCAL MODE
           ENTITY zi_tolpercentitem
           FIELDS ( Zproductid ) WITH CORRESPONDING #( keys )
           RESULT DATA(restolpercentitm).
    LOOP AT restolpercentitm INTO DATA(ls_itm).
      SELECT SINGLE FROM ztolpercent_item
             FIELDS z_productid
             WHERE z_productid = @ls_itm-Zproductid
            INTO @DATA(resitm).

 DATA(lv_mainproductid) = resitm.
SHIFT lv_mainproductid LEFT DELETING LEADING '0'.




      IF resitm IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_itm-%tky ) TO failed-zi_tolpercentitem.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = |This Product ( { lv_mainproductid } ) is already created.|
                         )  )
                         TO reported-zi_tolpercentitem.
              ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zi_tolpercentroot DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_tolpercentroot RESULT result.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR zi_tolpercentroot RESULT result.

ENDCLASS.

CLASS lhc_zi_tolpercentroot IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_features.
* Fetch the root instance only
    SELECT SINGLE FROM ztolpercent_root
             FIELDS z_tolpercentid
             WHERE z_tolpercentid = 'ROOT'
            INTO @DATA(lt_tolpercent).

      IF lt_tolpercent is not initial.

    DATA lv_allowed_create TYPE abap_boolean.

*    lv_allowed_create = zcl_qm_claim=>get_global_create_allowed( ).
    IF lv_allowed_create = abap_false.

      result-%create =  if_abap_behv=>fc-o-disabled.
    ENDIF.
      ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_tolpercentroot DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_tolpercentroot IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
