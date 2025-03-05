@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View of Quality Inspection'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity ZC_QUALITY_INSPECTION_ROOT
  provider contract transactional_query
  as projection on ZI_QUALITY_INSPECTION_ROOT
{
  key ZInspectionlotUuid,
      ZInspectionlotId,
      ZGrnId,
      ZPurchaseorderId,
      ZSubsequentCrdtFlag,
      ZGrnQtyUnit,
      @Semantics.quantity.unitOfMeasure : 'ZGrnQtyUnit'
      ZGrnQty,
      ZUnrestrictedqtyUnit,
      @Semantics.quantity.unitOfMeasure : 'ZUnrestrictedqtyUnit'
      ZUnrestrictedQty,
      ZSamplesizeUnit,
      
      @Semantics.quantity.unitOfMeasure : 'ZSamplesizeUnit'
      ZSamplesize,
     @Semantics.quantity.unitOfMeasure : 'ZSamplesizeUnit'
      ZAfterQC,
      ZQualityinsStatus,
      ZPOPriceCurrency,
      ZPOPrice,
      ZInitialBillAmnt,
      ZInitialBillAmntCurrency,
      ZCreatedBy,
      ZCreatedAt,
      ZLastChangedBy,
      ZLastChangedAt,
      ZLocalLastChangedAt,
      ZDifferenceDebit,
      /* Associations */
      _inspectionLotItm : redirected to composition child ZC_QUALITY_INSPECTION_ITEM,
      _ResponseDN       : redirected to composition child ZC_RESPONSE_CDN
}
