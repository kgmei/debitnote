CLASS lhc_zins_char_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setproductname FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zins_char_item~setproductname.
    METHODS calculatecomponent FOR DETERMINE ON SAVE
      IMPORTING keys FOR zins_char_item~calculatecomponent.

ENDCLASS.

CLASS lhc_zins_char_item IMPLEMENTATION.

  METHOD setproductname.



  ENDMETHOD.





  METHOD calculatecomponent.
    LOOP AT keys INTO DATA(ls_key).
      DATA: calcomponent TYPE i.

      READ ENTITIES OF zi_ins_char IN LOCAL MODE
             ENTITY zins_char_item FIELDS ( zproductuuid )
             WITH CORRESPONDING #( keys )
             RESULT DATA(resins).
      LOOP AT resins INTO DATA(ls_resins).

        READ ENTITY zi_ins_char
      BY \_root
      ALL FIELDS
      ##NO_LOCAL_MODE
      WITH VALUE #( (  %key-zproductuuid = ls_resins-zproductuuid


                       ) )

      RESULT DATA(lt_inschar)
      FAILED DATA(lt_inschar_fail).
        LOOP AT lt_inschar INTO DATA(ls_inschar).
          calcomponent = calcomponent + 1.
        ENDLOOP.
        MODIFY ENTITIES OF zi_ins_char IN LOCAL MODE
     ENTITY zins_char_item
      UPDATE SET FIELDS WITH VALUE #( ( %tky-zsubproductuuid = ls_key-zsubproductuuid
      zsupproductid = calcomponent ) )
       REPORTED DATA(update_reported).
        reported = CORRESPONDING #( DEEP update_reported ).
        CLEAR calcomponent.
      ENDLOOP.
    ENDLOOP.
    SELECT z_sup_productid
      FROM zinsp_charitm_db
       WHERE z_formula = ''
      ORDER BY z_sup_productid ASCENDING

      INTO TABLE @DATA(lt_table).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_ins_char DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_ins_char IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_custom_table_old1 TYPE TABLE OF zinsp_char_db,
          lt_change_log1       TYPE TABLE OF zchangehis,
          ls_change_log1       TYPE zchangehis.


    DATA(current_time1) = cl_abap_context_info=>get_system_time( ).


    SELECT FROM zchangehis FIELDS COUNT( change_id ) WHERE change_operation EQ 'U' INTO @DATA(lv_changehis).

    " Processing zi_ins_char updates
    IF update-zi_ins_char IS NOT INITIAL.

      " Read entities based on the update structure "New Data
      READ ENTITIES OF zi_ins_char IN LOCAL MODE
        ENTITY zi_ins_char ALL FIELDS
        WITH CORRESPONDING #( update-zi_ins_char )
        RESULT DATA(ltres_ins_char).

      LOOP AT ltres_ins_char INTO DATA(ls_up_char).

        "Old Data
        SELECT SINGLE FROM zinsp_char_db
   FIELDS z_mainproductprice,z_curr_mainproductid
   WHERE z_product_uuid = @ls_up_char-zproductuuid
  INTO @DATA(resoldvalue).

        IF ls_up_char-zmainproductprice <> resoldvalue-z_mainproductprice.
          lv_changehis = lv_changehis + 1.
          ls_change_log1 = VALUE #(
            change_id = lv_changehis
            z_product_uuid   = ls_up_char-zproductuuid
            field_name = 'Price'
            old_value = resoldvalue-z_mainproductprice
            new_value = ls_up_char-zmainproductprice
            changed_by = sy-uname
            change_timestamp = current_time1
            change_operation = 'U'   " 'C' for create, 'U' for update, 'D' for delete
          ).
          APPEND ls_change_log1 TO lt_change_log1.
        ENDIF.

        DATA(lv_mainproductid) = resoldvalue-z_curr_mainproductid.
        DATA(lv_new_mainprdid) = ls_up_char-zcurrmainproductid.
        SHIFT lv_mainproductid LEFT DELETING LEADING '0'.
        SHIFT lv_new_mainprdid LEFT DELETING LEADING '0'.



        IF ls_up_char-zcurrmainproductid <> resoldvalue-z_curr_mainproductid.
          lv_changehis = lv_changehis + 1.
          ls_change_log1 = VALUE #(
            change_id = lv_changehis
            z_product_uuid   = ls_up_char-zproductuuid
            field_name = 'Product'
            old_value = lv_mainproductid
            new_value = lv_new_mainprdid
            changed_by = sy-uname
            change_timestamp = current_time1
            change_operation = 'U'   " 'C' for create, 'U' for update, 'D' for delete
          ).
          APPEND ls_change_log1 TO lt_change_log1.
        ENDIF.




*        ENDIF.
      ENDLOOP.


    ENDIF.

    " Processing zins_char_item updates
    IF update-zins_char_item IS NOT INITIAL.
      " Read entities based on the update structure
      READ ENTITIES OF zi_ins_char IN LOCAL MODE
        ENTITY zins_char_item ALL FIELDS
        WITH CORRESPONDING #( update-zins_char_item )
        RESULT DATA(lt_ins_char).

      LOOP AT lt_ins_char INTO DATA(ls_up).

        "Old Data
        SELECT SINGLE FROM zinsp_charitm_db
   FIELDS z_supprd_price,z_subproductid
   WHERE z_subproduct_uuid = @ls_up-zsubproductuuid
  INTO @DATA(resitmdata).


        IF ls_up-zsupprdprice <> resitmdata-z_supprd_price.
          lv_changehis = lv_changehis + 1.
          ls_change_log1 = VALUE #(
            change_id = lv_changehis
            z_product_uuid   = ls_up-zproductuuid
            field_name = 'Price'
            old_value = resitmdata-z_supprd_price
            new_value = ls_up-zsupprdprice
            changed_by = sy-uname
            change_timestamp = current_time1
            change_operation = 'U'   " 'C' for create, 'U' for update, 'D' for delete
          ).
          APPEND ls_change_log1 TO lt_change_log1.
        ENDIF.


        DATA(lv_subproductid) = resitmdata-z_subproductid.
        DATA(lv_new_subprdid) = ls_up-zsubproductid.
        SHIFT lv_subproductid LEFT DELETING LEADING '0'.
        SHIFT lv_new_subprdid LEFT DELETING LEADING '0'.



        IF ls_up-zsubproductid <> resitmdata-z_subproductid.
          lv_changehis = lv_changehis + 1.
          ls_change_log1 = VALUE #(
            change_id = lv_changehis
            z_product_uuid   = ls_up-zproductuuid
            field_name = 'Product'
            old_value = lv_subproductid
            new_value = lv_new_subprdid
            changed_by = sy-uname
            change_timestamp = current_time1
            change_operation = 'U'   " 'C' for create, 'U' for update, 'D' for delete
          ).
          APPEND ls_change_log1 TO lt_change_log1.
        ENDIF.


      ENDLOOP.
    ENDIF.
    " Insert the change logs into the change history table
    INSERT zchangehis FROM TABLE @lt_change_log1.
  ENDMETHOD.



ENDCLASS.

CLASS lhc_zi_ins_char DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_ins_char RESULT result.
    METHODS createitemcharacteristics FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_ins_char~createitemcharacteristics.
    METHODS setmainproductname FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_ins_char~setmainproductname.



ENDCLASS.

CLASS lhc_zi_ins_char IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.



  METHOD createitemcharacteristics.



  ENDMETHOD.

  METHOD setmainproductname.



  ENDMETHOD.




ENDCLASS.
