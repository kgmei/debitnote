@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view - Change history'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_CHANGEHIS as select from zchangehis
association to parent ZI_INS_CHAR as _Item on 
$projection.ProductId = _Item.ZProductUuid  and $projection.MainProductID = _Item.Z_Mainproduct_id
{
    key change_id as ChangeId,
   z_mainproduct_id as MainProductID,
  
    field_name as FieldName,
    z_product_uuid as ProductId,
    
    old_value as OldValue,
  
    new_value as NewValue,
    changed_by as ChangedBy,
   
    change_timestamp as ChangeTimestamp,
   
    change_operation as ChangeOperation,
    _Item
}
