@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View of QualityInspecItem'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZC_QUALITY_INSPECTION_ITEM  as projection on ZI_QUALITY_INSPECTION_ITEM
{
    key ZItemUuid,
   // ZMaterialId,
    ZInspectionlotUuid,
 //   ZMaterialDescription,
    ZMatDescription,    
    ZInfoField1,
    ZInfoField2,
     ZTotalWeightUOM,
    @Semantics.quantity.unitOfMeasure : 'ZTotalWeightUOM'
    ZTotalWeight,
   ZTotalPrice,
   ZTotalPriceCurrency,
   ZTotalAmount,
   ZTotalAmountCurrency,
       ZCreatedBy,
      ZCreatedAt,
      ZLastChangedBy,
      ZLastChangedAt,
      ZLocalLastChangedAt,
    /* Associations */
    _inspectionlotRoot:redirected to parent ZC_QUALITY_INSPECTION_ROOT
}
