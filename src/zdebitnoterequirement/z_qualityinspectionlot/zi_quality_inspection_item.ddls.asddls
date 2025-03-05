@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Quality Inspection Item - Interface View'
define view entity ZI_QUALITY_INSPECTION_ITEM as select from zqualityins_item
association to parent ZI_QUALITY_INSPECTION_ROOT as _inspectionlotRoot
    on $projection.ZInspectionlotUuid = _inspectionlotRoot.ZInspectionlotUuid
{
   key z_item_uuid as ZItemUuid,
  // z_material_id as ZMaterialId,
    z_inspectionlot_uuid as ZInspectionlotUuid,
    
//    z_material_description as ZMaterialDescription,
     z_total_weight_unit as ZTotalWeightUOM,
     z_mat_des as ZMatDescription,
    @Semantics.quantity.unitOfMeasure : 'ZTotalWeightUOM'
  
    z_total_weight as ZTotalWeight,
     z_infofield1 as ZInfoField1,
      z_infofield2 as ZInfoField2,
    
       z_total_price               as ZTotalPrice,
      z_total_price_curr           as ZTotalPriceCurrency,
      z_total_amount    as ZTotalAmount,
      z_total_amount_curr   as ZTotalAmountCurrency,
      @Semantics.user.createdBy: true
      z_created_by            as ZCreatedBy,
       @Semantics.systemDateTime.createdAt: true
      z_created_at            as ZCreatedAt,
        @Semantics.user.localInstanceLastChangedBy: true
      z_last_changed_by       as ZLastChangedBy,
       @Semantics.systemDateTime.localInstanceLastChangedAt: true
      z_last_changed_at       as ZLastChangedAt,
       @Semantics.systemDateTime.lastChangedAt: true
      z_local_last_changed_at as ZLocalLastChangedAt,
    _inspectionlotRoot // Make association public
      
}
