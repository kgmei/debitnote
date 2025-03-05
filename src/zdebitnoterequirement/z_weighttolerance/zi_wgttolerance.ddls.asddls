@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view - SupplierweightTol'
define root view entity ZI_WGTTOLERANCE as select from zweighttolerance
composition[0..*]  of ZI_WGTTOLITM as _Item
{
    key uuid as Uuid,
    @EndUserText.label: 'ID'
    weightid as Weightid,
    z_weighttolid as ZWeighttolid,
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
    _Item
}
