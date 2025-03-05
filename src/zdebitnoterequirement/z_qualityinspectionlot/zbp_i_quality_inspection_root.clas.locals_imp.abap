
CLASS lsc_zi_quality_inspection_root DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_quality_inspection_root IMPLEMENTATION.

  METHOD save_modified.



  ENDMETHOD.



ENDCLASS.

CLASS lhc_qualityinsitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS createitmaction FOR DETERMINE ON SAVE                       "Item Creation time
      IMPORTING keys FOR qualityinsitem~createitmaction.

ENDCLASS.

CLASS lhc_qualityinsitem IMPLEMENTATION.

  METHOD createitmaction.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_qualityinsroot DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR qualityinsroot RESULT result.
    METHODS calculatetotalweight FOR MODIFY
      IMPORTING keys FOR ACTION qualityinsroot~calculatetotalweight.
    METHODS createdebitnote FOR MODIFY
      IMPORTING keys FOR ACTION qualityinsroot~createdebitnote RESULT result.


    METHODS createitemcharacteristics FOR DETERMINE ON SAVE
      IMPORTING keys FOR qualityinsroot~createitemcharacteristics.
    METHODS inspectionlotvalidate FOR VALIDATE ON SAVE
      IMPORTING keys FOR qualityinsroot~inspectionlotvalidate.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR qualityinsroot RESULT result.




ENDCLASS.

CLASS lhc_qualityinsroot IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.


  METHOD calculatetotalweight.

    LOOP AT keys INTO DATA(ls_key).

**********************************************************Delete the old QA items**********************************************************
      SELECT  FROM zqualityins_item
FIELDS z_item_uuid
         WHERE z_inspectionlot_uuid = @ls_key-zinspectionlotuuid
         INTO TABLE @DATA(lt_old_records).  " For example, delete records older than a year.

      DATA:  found_item_cost    TYPE abap_bool.
      found_item_cost = abap_false.
      IF found_item_cost = abap_false.
        MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
        ENTITY qualityinsitem
          DELETE FROM VALUE #( FOR <ls_record> IN lt_old_records
                               ( zitemuuid = <ls_record>-z_item_uuid ) )  " Use key fields here
          FAILED DATA(failed_data)
          REPORTED DATA(reported_data).


        found_item_cost = abap_true.
      ENDIF.


**********************************************************Current Root Instance**********************************************************
      READ ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
       ENTITY qualityinsroot ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(insproot).
      IF insproot IS NOT INITIAL.
        LOOP AT insproot INTO DATA(ls_insproot).

*retrieves only the first row that matches the selection criteria
**********************************************************Inspection Lot Details**********************************************************
          SELECT SINGLE FROM i_inspectionlot WITH PRIVILEGED ACCESS AS insplot
             INNER JOIN i_supplier WITH PRIVILEGED ACCESS AS supplier
             ON supplier~supplier EQ insplot~supplier
          FIELDS insplot~purchasingdocument,insplot~purchasingdocumentitem,insplot~inspectionlotactualquantity,insplot~inspectionlotsamplequantity,
          insplot~insplotqtytofree,insplot~material,insplot~materialdocument,insplot~materialdocumentitem,
          insplot~inspectionlotsampleunit,supplier~suppliername
            WHERE insplot~inspectionlot = @ls_insproot-zinspectionlotid
          INTO @DATA(ltdata).

          IF ltdata IS NOT INITIAL.
**********************************************************Purchase Order Details**********************************************************
            SELECT SINGLE FROM i_purchaseorderitemapi01
          FIELDS netpriceamount,documentcurrency,orderquantity,material
          WHERE purchaseorder = @ltdata-purchasingdocument AND purchaseorderitem = @ltdata-purchasingdocumentitem
         INTO @DATA(ltpodata).
            IF ltpodata IS NOT INITIAL.
**********************************************************Material Document Details**********************************************************
              SELECT SINGLE FROM i_materialdocumentitem_2
              FIELDS quantityinentryunit,totalgoodsmvtamtincccrcy,entryunit,companycodecurrency,quantityindeliveryqtyunit
              WHERE materialdocument = @ltdata-materialdocument AND materialdocumentitem = @ltdata-materialdocumentitem
              INTO @DATA(matdocitem).
              IF matdocitem IS NOT INITIAL.
**********************************************************Update Root table with the above details**********************************************************
                MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
                 ENTITY qualityinsroot
                 UPDATE SET FIELDS WITH VALUE #( ( %tky = ls_key-%tky
                 zpurchaseorderid = ltdata-purchasingdocument
                 zunrestrictedqty = ltdata-insplotqtytofree
                 zsamplesize = ltdata-inspectionlotsamplequantity
                 zsamplesizeunit = ltdata-inspectionlotsampleunit
                  zgrnqty = matdocitem-quantityinentryunit
                  zgrnqtyunit = matdocitem-entryunit
                 zgrnid = ltdata-materialdocument
                 zpoprice = ltpodata-netpriceamount
                 zpopricecurrency = ltpodata-documentcurrency
                 zinitialbillamnt = matdocitem-totalgoodsmvtamtincccrcy
                 zinitialbillamntcurrency = matdocitem-companycodecurrency ) )
                 REPORTED DATA(update_reported).
                reported = CORRESPONDING #( DEEP update_reported ).



**********************************************************Inspection Characteristics details (Result Record)**********************************************************
*Consider only info fields 1
                SELECT FROM i_inspectioncharacteristic
                  FIELDS inspspecinformationfield1,inspspecinformationfield2,inspspecinformationfield3,inspectioncharacteristic,inspectioncharacteristictext,
                  \_inspectionresult-inspectionresultmeanvalue,\_inspectionresult-inspresulthasmaximumvalue,\_inspectionresult-inspresultnmbrofrecordedrslts
                  WHERE inspectionlot = @ls_insproot-zinspectionlotid AND inspspecinformationfield1 IN ('DNMP', 'DNSP', 'DNOP', 'DNT', 'DNSB', 'DNTP')    "DNMP - Main Product, DNSP - Supplementary Product,
                  "DNOP - Other Product, DNSB - Separate Bale Product, DNT - tolerance Weight, DNTP - Tolerance Percentage
                 INTO TABLE @DATA(lt_customeritems1).
                IF lt_customeritems1 IS NOT INITIAL.
                  DATA : mainprd TYPE string.
*DELETE ADJACENT DUPLICATES FROM lt_customeritems1 COMPARING InspSpecInformationField1.
                  LOOP AT lt_customeritems1 INTO DATA(ls_item1).
                    IF ls_item1-inspspecinformationfield1 = 'DNMP'.



                      mainprd = ls_item1-inspspecinformationfield2.
                    ENDIF.
                  ENDLOOP.

**********************************************************Create the item table using above data**********************************************************
                  LOOP AT lt_customeritems1 INTO DATA(ls_item).

                    DATA: resultmean      TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                          unrestricted    TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                          sample          TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                          div             TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                          poprice         TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                          popricecurr     TYPE c LENGTH 3,      " 3-character string for currency code
                          suppprice       TYPE p DECIMALS 2,   " Packed number with 2 decimal places
                          supppricecurr   TYPE c LENGTH 3,      " 3-character string for currency code
                          totalamnt       TYPE p DECIMALS 2,
                          totalamntcurr   TYPE c LENGTH 3,
                          poorderqty      TYPE p DECIMALS 2,
                          totwgttol       TYPE p DECIMALS 2,
                          toleranceweight TYPE p DECIMALS 2,
                          calwgttol       TYPE p DECIMALS 2.





                    poorderqty = ltpodata-orderquantity.        "PO Qty
                    poprice = ltpodata-netpriceamount.          "PO Price
                    popricecurr = ltpodata-documentcurrency.       "PO currency

                    CLEAR: resultmean,unrestricted,sample,div,suppprice,supppricecurr,totalamnt,totalamntcurr.

                    resultmean = ls_item-inspectionresultmeanvalue.     "Result Data from the Result recording screen

                    unrestricted = ltdata-insplotqtytofree.             "Unrestricted Qty
*            sample = ltdata-inspectionlotsamplequantity.
                    sample = ls_item-inspresultnmbrofrecordedrslts.         "Sample Size
                    div = ( resultmean * unrestricted ) / sample.
                    IF ls_item-inspspecinformationfield1 = 'DNMP'.          "DNMP
                      suppprice = poprice.
                      supppricecurr = popricecurr.
                    ENDIF.

                    DATA: lt_product_table TYPE TABLE OF zinsp_charitm_db,
                          ls_product_table TYPE zinsp_charitm_db,
                          lv_product_id    TYPE matnr,
                          lv_supproductid  TYPE purchasingdocument.
                    lv_supproductid = ls_item-inspspecinformationfield2.
                    IF lv_supproductid IS NOT INITIAL.
                      DATA: lv_value  TYPE string,
                            lv_length TYPE i.

                      lv_value = lv_supproductid.
                      lv_length = 18.  " Set the desired total length, e.g., 18 characters

                      " Ensure the value is condensed (no leading spaces)
                      CONDENSE lv_value.

                      " Add leading zeros to match the required length
                      WHILE strlen( lv_value ) < lv_length.
                        lv_value = '0' && lv_value.
                      ENDWHILE.
**********************************************************Read the Pricing Configuration Item**********************************************************
                      SELECT SINGLE FROM zinsp_char_db
                     FIELDS z_product_uuid
                     WHERE z_curr_mainproductid = @ltpodata-material
                    INTO @DATA(inscharroot).
                      IF inscharroot IS NOT INITIAL.
                        SELECT SINGLE FROM zinsp_charitm_db
                        FIELDS z_pricing_type,z_supprd_price
                        WHERE z_subproductid = @lv_value AND z_product_uuid = @inscharroot
                       INTO @DATA(inschar).
* Check if data is found
                        IF sy-subrc = 0.


                          IF inschar-z_pricing_type = 'Variable'.
                            suppprice =   poprice + inschar-z_supprd_price.
                          ELSEIF inschar-z_pricing_type = 'Fixed'.
                            suppprice =   inschar-z_supprd_price.
                          ENDIF.

                        ENDIF.
                      ENDIF.
                    ENDIF.
**********************************************************DNT Calculation**********************************************************
                    IF ls_item-inspspecinformationfield1 = 'DNT'.           "DNT - Tolerance
*                      calwgttol = matdocitem-quantityindeliveryqtyunit - matdocitem-quantityinentryunit.
*                      IF calwgttol LT 25.
*                        div = 0.
*                      ELSEIF calwgttol GE 25.
                      SELECT SINGLE FROM zweighttolerance
           FIELDS weightid,uuid
           WHERE weightid = 'ROOT'
          INTO @DATA(resweightroot).
**********************************************************Read the Weight tolerance**********************************************************
                      READ ENTITY zi_wgttolerance
                    BY \_item
                    ALL FIELDS
                     WITH VALUE #( (  %key-uuid = resweightroot-uuid
                                      ) )
                     RESULT DATA(lt_weight_tol)
                     FAILED DATA(failed_rba_weight_tol).
* Check if data is found
                      IF sy-subrc = 0.
                        LOOP AT lt_weight_tol INTO DATA(ls_wgt_tol).
                          DATA: lv_int    TYPE i,
                                lv_from   TYPE i,
                                lv_to     TYPE i,
                                lv_weight TYPE i.


                          lv_int = CONV i( matdocitem-quantityindeliveryqtyunit ).
                          lv_from = CONV i( ls_wgt_tol-ztolerancefrom ).

                          lv_weight = CONV i( ls_wgt_tol-ztoleranceweight ).


                          lv_to = COND i( WHEN ls_wgt_tol-ztoleranceto = 'above' THEN 999999999
                                          ELSE CONV i( ls_wgt_tol-ztoleranceto ) ).

                          IF lv_int BETWEEN lv_from AND lv_to.
                            toleranceweight = lv_weight.                  "Total Weight of DNT

                          ENDIF.
                          CLEAR lv_weight.
                        ENDLOOP.
                      ENDIF.
                      calwgttol = matdocitem-quantityindeliveryqtyunit - matdocitem-quantityinentryunit.

                      IF calwgttol LT toleranceweight.
                        div = calwgttol.
                      ELSEIF calwgttol GE toleranceweight.
                        div = toleranceweight.
                      ENDIF.


                      suppprice = poprice.              "Same PO price
                      supppricecurr = popricecurr.
                    ENDIF.
********************************************************** DNSB TYPE **********************************************************
                    IF ls_item-inspspecinformationfield1 = 'DNSB'.           "DNSB - Separate Bale
                      div = resultmean.
                    ENDIF.
********************************************************** DNTP Type **********************************************************
                    DATA: total_wgt_spop TYPE p DECIMALS 2 VALUE 0,
                          varianceweight TYPE p DECIMALS 2.
                    IF ls_item-inspspecinformationfield1 = 'DNTP'.
*                      varianceweight = ( total_wgt_spop / matdocitem-quantityinentryunit ) * 100.

                      SELECT SINGLE
                      FROM zi_tolpercentitem
                      FIELDS itmzuuid,rootuuid,zmainproductdes,ztolpercent,zproductid
                     WHERE zproductid = @ltdata-Material INTO @DATA(tb_tolpercent).

                      IF sy-subrc = 0.
                        IF tb_tolpercent-ztolpercent is not initial.
                          div = ( tb_tolpercent-ztolpercent * matdocitem-quantityinentryunit ) / 100.
                       ENDIF.
                         suppprice = poprice.              "Same PO price
                      ENDIF.
                    ENDIF.

                    totalamnt = div * suppprice.

**********************************************************Create the Qa items**********************************************************
                    MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
                      ENTITY qualityinsroot

                      CREATE BY \_inspectionlotitm FROM VALUE #( (

                                       zinspectionlotuuid = ls_key-zinspectionlotuuid
                                       %target = VALUE #( ( %cid = '080'

                                                            zmatdescription = ls_item-inspectioncharacteristictext
                                                            zinspectionlotuuid = ls_key-zinspectionlotuuid
                                                            zinfofield1 = ls_item-inspspecinformationfield1
                                                            zinfofield2 = ls_item-inspspecinformationfield2
                                                            ztotalweight = div
                                                            ztotalprice = suppprice
                                                            ztotalamount = totalamnt
                                                            %control = VALUE #(
                                                                                  zmatdescription = if_abap_behv=>mk-on
                                                                                zinspectionlotuuid = if_abap_behv=>mk-on
                                                                                zinfofield1 = if_abap_behv=>mk-on
                                                                                zinfofield2 = if_abap_behv=>mk-on
                                                                                ztotalweight = if_abap_behv=>mk-on
                                                                                ztotalprice = if_abap_behv=>mk-on
                                                                                ztotalamount = if_abap_behv=>mk-on
                                                                              )
                                                          )
                                                      )
                                                  ) )
                MAPPED DATA(lt_mapped)
                FAILED DATA(lt_failed)
                REPORTED DATA(lt_reported).
*            ENDIF.


                    IF ls_item-inspspecinformationfield1 EQ 'DNSP' OR ls_item-inspspecinformationfield1 EQ 'DNOP'.
                      total_wgt_spop = total_wgt_spop + div.
                    ENDIF.
*                          total_price_supp TYPE p DECIMALS 2 VALUE 0.
*                    IF ls_item-inspspecinformationfield1 <> 'DNSP'.
*                      total_price = total_price + totalamnt.  " Example calculation
*
*                    ELSEIF ls_item-inspspecinformationfield1 = 'DNSP'.
*                      total_price_supp = total_price_supp + totalamnt.
*                    ENDIF.






                  ENDLOOP.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

        DATA: diff         TYPE p DECIMALS 2 VALUE 0,
              supp_prd_add TYPE p DECIMALS 2 VALUE 0.


        DATA: lt_quality_inspection_root TYPE TABLE OF zi_quality_inspection_root,
              ls_quality_inspection_root TYPE zi_quality_inspection_root.






**********************************************************Calculate the Difference Amount**********************************************************
*        IF total_price IS NOT INITIAL.

        READ ENTITY zi_quality_inspection_root
##NO_LOCAL_MODE
                          BY \_inspectionlotitm
                          ALL FIELDS
                           WITH VALUE #( (  %key-zinspectionlotuuid = ls_key-zinspectionlotuuid
                                            ) )
                           RESULT DATA(lt_qualityitm)
                           FAILED DATA(failed_lt_qualityitm).
        IF lt_qualityitm IS NOT INITIAL.
          LOOP AT lt_qualityitm INTO DATA(ls_lt_qualityitm).
            supp_prd_add = ls_lt_qualityitm-ztotalamount + supp_prd_add.
          ENDLOOP.
*        ENDIF.
*            supp_prd_add = total_price + total_price_supp.
          diff = matdocitem-totalgoodsmvtamtincccrcy - supp_prd_add.

          MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
            ENTITY qualityinsroot
            UPDATE SET FIELDS WITH VALUE #( ( %tky = ls_key-%tky
                                                   zafterqc =  supp_prd_add
                                                   zdifferencedebit = diff
                                                   ) )
                  REPORTED DATA(update_reported1).
          reported = CORRESPONDING #( DEEP update_reported1 ).
        ENDIF.




**********************************************************Create the QA default items (Supplier, Total, Difference)**********************************************************
        TYPES: BEGIN OF ty_quality_entry,
                 zinspectionlotuuid TYPE sysuuid_x16,
                 zmatdescription    TYPE string,
                 ztotalamount       TYPE p LENGTH 10 DECIMALS 2,
                 ztotalweight       TYPE string,
                 ztotalprice        TYPE string,

               END OF ty_quality_entry.

        DATA: lt_quality_entries TYPE TABLE OF ty_quality_entry,
              ls_quality_entry   TYPE ty_quality_entry,
              tolamount_supp     TYPE p DECIMALS 2.

        " Select Root data
        READ ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
             ENTITY qualityinsroot ALL FIELDS
             WITH CORRESPONDING #( keys )
             RESULT DATA(lt_insproot).
        LOOP AT lt_insproot INTO DATA(ls_insperoot).


* First entry
          ls_quality_entry-zinspectionlotuuid = ls_key-zinspectionlotuuid.
          ls_quality_entry-zmatdescription = 'TOTAL'.
          ls_quality_entry-ztotalamount = ls_insperoot-zafterqc.
          APPEND ls_quality_entry TO lt_quality_entries.
          CLEAR: ls_quality_entry.

          "Second Entry
          tolamount_supp = matdocitem-quantityindeliveryqtyunit * ls_insperoot-zpoprice.
          ls_quality_entry-zinspectionlotuuid = ls_key-zinspectionlotuuid.
          ls_quality_entry-zmatdescription = ltdata-suppliername.
          ls_quality_entry-ztotalweight = matdocitem-quantityindeliveryqtyunit.
          ls_quality_entry-ztotalprice = ls_insperoot-zpoprice.
          ls_quality_entry-ztotalamount = tolamount_supp.
          APPEND ls_quality_entry TO lt_quality_entries.
          CLEAR: ls_quality_entry.
          "Third Entry
          ls_quality_entry-zinspectionlotuuid = ls_key-zinspectionlotuuid.
          ls_quality_entry-zmatdescription = 'Subsequent Credit'.
          ls_quality_entry-ztotalamount = tolamount_supp - ls_insperoot-zafterqc.
          APPEND ls_quality_entry TO lt_quality_entries.
          CLEAR: ls_quality_entry.
          LOOP AT lt_quality_entries INTO DATA(ls_list).
            MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
                           ENTITY qualityinsroot

                           CREATE BY \_inspectionlotitm FROM VALUE #( (

                                            zinspectionlotuuid = ls_key-zinspectionlotuuid
                                            %target = VALUE #( ( %cid = '080'

                                                                 zmatdescription = ls_list-zmatdescription
                                                                 zinspectionlotuuid = ls_list-zinspectionlotuuid
                                                                   ztotalweight = ls_list-ztotalweight
                                                                   ztotalprice = ls_list-ztotalprice
                                                                 ztotalamount = ls_list-ztotalamount
                                                                 %control = VALUE #(
                                                                                       zmatdescription = if_abap_behv=>mk-on
                                                                                     zinspectionlotuuid = if_abap_behv=>mk-on
                                                                                       ztotalprice = if_abap_behv=>mk-on
                                                                                       ztotalweight = if_abap_behv=>mk-on
                                                                                     ztotalamount = if_abap_behv=>mk-on
                                                                                   )
                                                               )
                                                           )
                                                       ) )
                     MAPPED DATA(wl_lt_mapped)
                     FAILED DATA(wl_lt_failed)
                     REPORTED DATA(wl_lt_reported).
          ENDLOOP.
          CLEAR: lt_quality_entries,ls_list,inschar.
        ENDLOOP.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.



  METHOD createdebitnote.

*    LOOP AT keys INTO DATA(ls_key).
*
*      "ROOT STRUCTURE
*      DATA: BEGIN OF root,
*              companycode                   TYPE string,
*              supplierinvoiceiscreditmemo   TYPE string,
*              documentdate                  TYPE string,
*              postingdate                   TYPE string,
*              supplierinvoiceidbyinvcgparty TYPE string,
*              documentcurrency              TYPE string,
*              invoicegrossamount            TYPE string,
*              taxdeterminationdate          TYPE string,
*              taxiscalculatedautomatically  TYPE string,
*              in_gstplaceofsupply           TYPE string,
*              businessplace                 TYPE string,
*              businesssectioncode           TYPE string,
*            END OF root.
*
*      "ITEM STRUCTURE
*      DATA: BEGIN OF item,
*              issubsequentdebitcredit     TYPE string,
*              supplierinvoiceitem         TYPE string,
*              purchaseorder               TYPE string,
*              purchaseorderitem           TYPE string,
*              documentcurrency            TYPE string,
*              quantityinpurchaseorderunit TYPE string,
*              purchaseorderquantityunit   TYPE string,
*              supplierinvoiceitemamount   TYPE string,
*              taxcode                     TYPE string,
*            END OF item.
*
*      "INTERNAL TABLES
*      DATA it_root LIKE TABLE OF root.
*      DATA it_item LIKE TABLE OF item.
*
*      "WORK AREAS
*      DATA wa_root LIKE root.
*      DATA wa_item LIKE item.
*
*      TYPES: ty_date_time TYPE c LENGTH 16.
*
*      DATA: lv_current_date TYPE ty_date_time,
*            lv_date         TYPE c LENGTH 8,
*            lv_time         TYPE c LENGTH 6,
*            placeofsupply   TYPE string,
*            businessplace   TYPE string,
*            sectioncode     TYPE string.
*
*      lv_date = cl_abap_context_info=>get_system_date( ).
*      lv_time = cl_abap_context_info=>get_system_time( ).
*
*      CONCATENATE lv_date+0(4) '-' lv_date+4(2) '-' lv_date+6(2) 'T' lv_time+0(2) ':' lv_time+2(2) INTO lv_current_date.
*
*      READ ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
*           ENTITY qualityinsroot ALL FIELDS
*           WITH CORRESPONDING #( keys )
*           RESULT DATA(insproot).
*      LOOP AT insproot INTO DATA(ls_insproot).
*        CONCATENATE 'PO - ' ls_insproot-zpurchaseorderid INTO DATA(lv_po).
*
*        SELECT SINGLE FROM i_purchaseorderitemapi01
*      FIELDS plant,purchaseorderquantityunit
*      WHERE purchaseorder = @ls_insproot-zpurchaseorderid
*     INTO @DATA(ltpodata).
*        IF ltpodata-plant EQ 'U002'.
*          placeofsupply = 'TS'.
*          businessplace = 'TS'.
*          sectioncode = '1840'.
*        ELSEIF ltpodata-plant EQ 'C001'.
*          placeofsupply = 'TS'.
*          businessplace = 'TS'.
*          sectioncode = '1840'.
*        ELSEIF ltpodata-plant EQ 'U001'.
*          placeofsupply = 'TS'.
*          businessplace = 'TS'.
*          sectioncode = '1840'.
*        ELSEIF ltpodata-plant EQ 'U003'.
*          placeofsupply = 'TN'.
*          businessplace = 'TN'.
*          sectioncode = '1841'.
*        ELSEIF ltpodata-plant EQ 'U004'.
*          placeofsupply = 'OD'.
*          businessplace = 'OD'.
*          sectioncode = '1835'.
*        ENDIF.
*        "ROOT DATA
*        wa_root-companycode = 'SC01'.
*        wa_root-supplierinvoiceiscreditmemo =  'X'.
*        wa_root-documentdate = lv_current_date.
*        wa_root-postingdate = lv_current_date.
*        wa_root-taxdeterminationdate = lv_current_date.
*        wa_root-supplierinvoiceidbyinvcgparty = lv_po. "ls_insproot-ZGrnId.
*        wa_root-invoicegrossamount = ls_insproot-zdifferencedebit.
*        wa_root-documentcurrency = ls_insproot-zpopricecurrency.
*        wa_root-taxiscalculatedautomatically = 'false'.
*        wa_root-in_gstplaceofsupply = placeofsupply.
*        wa_root-businessplace = businessplace.
*        wa_root-businesssectioncode = sectioncode.
*
*        APPEND wa_root TO it_root.
*        CLEAR wa_root.
*
*        "ITEM DATA
*        wa_item-issubsequentdebitcredit = 'X'.
*        wa_item-supplierinvoiceitem = '00001'.
*        wa_item-purchaseorder = ls_insproot-zpurchaseorderid.
*        wa_item-purchaseorderitem = '00010'.
*        wa_item-documentcurrency = ls_insproot-zpopricecurrency.
*        wa_item-quantityinpurchaseorderunit = '0.001'.
*        wa_item-purchaseorderquantityunit = ltpodata-purchaseorderquantityunit.
*        wa_item-supplierinvoiceitemamount = ls_insproot-zdifferencedebit.
*        wa_item-taxcode = 'G4'.
*        APPEND wa_item TO it_item.
*        CLEAR wa_item.
*      ENDLOOP.
*
*      "JSON (ROOT)
*      DATA jsonbody_root TYPE string.
*
*      LOOP AT it_root INTO DATA(lwa_root).
*        IF lwa_root IS NOT INITIAL.
*          jsonbody_root =  '"CompanyCode": "' &&  lwa_root-companycode && '",' && '"SupplierInvoiceIsCreditMemo": "' &&  lwa_root-supplierinvoiceiscreditmemo && '",' && '"DocumentDate": "' &&  lwa_root-documentdate && '",' &&
*  '"PostingDate": "' &&  lwa_root-postingdate && '",'
*  && '"SupplierInvoiceIDByInvcgParty": "' &&  lwa_root-supplierinvoiceidbyinvcgparty && '",'
*  && '"DocumentCurrency": "' &&  lwa_root-documentcurrency && '",'
*  && '"InvoiceGrossAmount": "' &&  lwa_root-invoicegrossamount &&
*  '",' && '"TaxDeterminationDate": "' &&  lwa_root-taxdeterminationdate && '",'
*  && '"TaxIsCalculatedAutomatically": ' &&  lwa_root-taxiscalculatedautomatically && ','
*  && '"IN_GSTPlaceOfSupply": "' &&  lwa_root-in_gstplaceofsupply && '",'
*  && '"BusinessPlace": "' &&  lwa_root-businessplace && '",'.
*        ENDIF.
*      ENDLOOP.
*
*      "JSON (ITEM)
*      DATA jsonbody_item TYPE string.
*      LOOP AT it_item INTO DATA(lwa_item).
*        IF lwa_item IS NOT INITIAL.
**        IF jsonbody_item IS NOT INITIAL.
*          jsonbody_item = jsonbody_item && '{"IsSubsequentDebitCredit": "' &&  lwa_item-issubsequentdebitcredit && '",'
*          && '"SupplierInvoiceItem": "' &&  lwa_item-supplierinvoiceitem && '",' && '"PurchaseOrder": "' &&  lwa_item-purchaseorder && '",'
*          && '"PurchaseOrderItem": "' &&  lwa_item-purchaseorderitem && '",' && '"DocumentCurrency": "' &&  lwa_item-documentcurrency && '",'
*          && '"QuantityInPurchaseOrderUnit": "' &&  lwa_item-quantityinpurchaseorderunit && '",'
*          && '"PurchaseOrderQuantityUnit": "' &&  lwa_item-purchaseorderquantityunit && '",'
*          && '"SupplierInvoiceItemAmount": "' &&  lwa_item-supplierinvoiceitemamount && '",'
*          && '"TaxCode": "' &&  lwa_item-taxcode && '"}'.
**       ENDIF.
*        ENDIF.
*      ENDLOOP.
*      IF jsonbody_item IS NOT INITIAL.
*        jsonbody_item = '"to_SuplrInvcItemPurOrdRef": [' && jsonbody_item && ']'.
*      ENDIF.
*
*
*      "PREPARING JSON
*      jsonbody_root = '{' && jsonbody_root && jsonbody_item && '}'.
*
*
*      DATA: lo_http_destination       TYPE REF TO if_http_destination,
*            lo_web_http_client        TYPE REF TO if_web_http_client,
*            lo_web_http_get_request   TYPE REF TO if_web_http_request,
*            lo_web_http_get_response  TYPE REF TO if_web_http_response,
*            lo_web_http_post_request  TYPE REF TO if_web_http_request,
*            lo_web_http_post_response TYPE REF TO if_web_http_response,
*            lv_response               TYPE string,
*            lv_response_code          TYPE string,
*            lv_csrf_token             TYPE string,
*            lv_responce_supid         TYPE string,
*            lv_responce_error         TYPE string,
*            lv_response_remarks       TYPE string.
*
*      TRY.
*          lo_http_destination = cl_http_destination_provider=>create_by_comm_arrangement( comm_scenario = 'ZSUBSEQUENTCREDIT_CS' ).
*
*          lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
*
*          lo_web_http_get_request = lo_web_http_client->get_http_request( ).
*
*          lo_web_http_get_request->set_header_fields( VALUE #( ( name = 'x-csrf-token' value = 'fetch' ) ) ).
*
*          lo_web_http_get_response = lo_web_http_client->execute( if_web_http_client=>get ).
*
*          lv_csrf_token = lo_web_http_get_response->get_header_field( i_name = 'x-csrf-token' ).
*
*          IF lv_csrf_token IS NOT INITIAL.
*
*            lo_web_http_post_request = lo_web_http_client->get_http_request( ).
*
*            lo_web_http_post_request->set_header_fields( VALUE #( ( name = 'x-csrf-token' value = lv_csrf_token ) ) ).
*
*            lo_web_http_post_request->set_content_type( content_type = 'application/json' ).
**          lo_web_http_post_request->set_header_fields( VALUE #( ( name = 'Accept' value = 'application/json' ) ) ).
*
*            IF jsonbody_root IS NOT INITIAL.
*              lo_web_http_post_request->set_text( jsonbody_root ).
*
*              lo_web_http_post_response = lo_web_http_client->execute( if_web_http_client=>post ).
*
*              lv_response = lo_web_http_post_response->get_text( ).
*              lv_response_code = lo_web_http_post_response->get_status( )-code.
*              lv_response_remarks = lo_web_http_post_response->get_status( )-reason.
*
*
*              "Creating XML
*              DATA(lv_resp_xml) = cl_abap_conv_codepage=>create_out( )->convert( lv_response ).
*              "iXML
*              DATA(lo_ixml_pa) = cl_ixml_core=>create( ).
*              DATA(lo_stream_factory_pa) = lo_ixml_pa->create_stream_factory( ).
*              DATA(lo_document_pa) = lo_ixml_pa->create_document( ).
*              "XML Parser
*              DATA(lo_parser_pa) = lo_ixml_pa->create_parser(
*              istream = lo_stream_factory_pa->create_istream_xstring( string = lv_resp_xml )
*              document = lo_document_pa stream_factory = lo_stream_factory_pa ).
*              "Check XML Parser
*              DATA(lv_parsing_check) = lo_parser_pa->parse( ).
*              "IF XML Parser contains no error
*              IF lv_parsing_check = 0.
*                "Iterator
*                DATA(lo_iterator_pa) = lo_document_pa->create_iterator( ).
*                DO.
*                  DATA(lv_node_i) = lo_iterator_pa->get_next( ).
*                  IF lv_node_i IS INITIAL.
*                    EXIT.
*                  ELSE.
*                    GET TIME STAMP FIELD DATA(zv_tsl).
*                    IF lv_response_code = 201.
*                      IF lv_node_i->get_name( ) = 'SupplierInvoice'.
*                        lv_responce_supid = lv_node_i->get_value( ).
*                        MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
*                         ENTITY qualityinsroot
*                         UPDATE SET FIELDS WITH VALUE #( ( %tky = ls_key-%tky
*                        zsubsequentcrdtflag = 'success' ) )
*                         REPORTED DATA(update_reported).
*                        reported = CORRESPONDING #( DEEP update_reported ).
*                        EXIT.
*                      ENDIF.
*                    ELSE.
*                      IF lv_node_i->get_name( ) = 'message'.
*                        lv_responce_supid = '-'.
*                        lv_response_remarks = lv_node_i->get_value( ).
*
*                        EXIT.
*                      ENDIF.
*                    ENDIF.
*
*
*
*
*                  ENDIF.
*                ENDDO.
*                MODIFY ENTITIES OF zi_quality_inspection_root IN LOCAL MODE
*ENTITY qualityinsroot
*
*CREATE BY \_responsedn FROM VALUE #( (
*
*zinspectionlotuuid = ls_key-zinspectionlotuuid
*%target = VALUE #( ( %cid = 'log'
*
*zdebitnoteid = lv_responce_supid
*zinspectionlotuuid = ls_key-zinspectionlotuuid
*zresponse = lv_response_remarks
*zlogcreatedon = zv_tsl
*zresult = lv_response_code
*
*
*%control = VALUE #(
*zdebitnoteid = if_abap_behv=>mk-on
*zinspectionlotuuid = if_abap_behv=>mk-on
*zresponse = if_abap_behv=>mk-on
*zlogcreatedon = if_abap_behv=>mk-on
*zresult = if_abap_behv=>mk-on
*)
*)
*)
*) )
*MAPPED DATA(lt_fail_mapped)
*FAILED DATA(lt_fail_failed)
*REPORTED DATA(lt_fail_reported).
*              ENDIF.
*
*
*
*
*            ENDIF.
*          ENDIF.
*
*        CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
*
*      ENDTRY.
*    ENDLOOP.
  ENDMETHOD.

  METHOD createitemcharacteristics.


  ENDMETHOD.

  METHOD inspectionlotvalidate.
    READ ENTITIES OF zi_quality_inspection_root  IN LOCAL MODE
           ENTITY qualityinsroot
           FIELDS ( zinspectionlotid ) WITH CORRESPONDING #( keys )
           RESULT DATA(inspids).
    LOOP AT inspids INTO DATA(inspid).
      SELECT SINGLE FROM zqualityins_root
             FIELDS z_inspectionlot_id
             WHERE z_inspectionlot_id = @inspid-zinspectionlotid
            INTO @DATA(resinspid).
      IF resinspid IS NOT INITIAL.
        APPEND VALUE #( %tky = inspid-%tky ) TO failed-qualityinsroot.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = |This Inspection ( { resinspid } ) is already created.|
                         )  )
                         TO reported-qualityinsroot.
        DATA(y) = '4'.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.
    MOVE-CORRESPONDING keys TO result.
    READ ENTITIES OF zi_quality_inspection_root  IN LOCAL MODE
         ENTITY qualityinsroot
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(inspids).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<fs>).
      READ TABLE inspids INTO DATA(ls_inspids) WITH KEY zinspectionlotuuid = <fs>-zinspectionlotuuid.
      IF sy-subrc EQ 0.
        CASE ls_inspids-zsubsequentcrdtflag.
          WHEN 'success'.
            <fs>-%action-createdebitnote = if_abap_behv=>fc-o-disabled.
          WHEN OTHERS.
            <fs>-%action-createdebitnote = if_abap_behv=>fc-o-enabled.
        ENDCASE.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.



ENDCLASS.
