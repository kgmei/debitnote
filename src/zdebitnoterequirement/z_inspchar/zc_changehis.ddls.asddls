@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View - Change history'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZC_CHANGEHIS as projection on ZI_CHANGEHIS
{
    key ChangeId,
    MainProductID,
    
    FieldName,
    ProductId,
    OldValue,
    NewValue,
    ChangedBy,
    ChangeTimestamp,
    ChangeOperation,
    /* Associations */
    _Item:redirected to parent ZC_INS_CHAR 
}
