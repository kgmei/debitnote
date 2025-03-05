@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view - SupplierweightToItm'
define view entity ZI_WGTTOLITM as select from zweighttol_itm
association to parent ZI_WGTTOLERANCE as _Root
    on $projection.Uuid = _Root.Uuid
{
    key z_uuid as ZUuid,
     @EndUserText.label: 'Root UUID'
  uuid as Uuid,
   @EndUserText.label: 'Weight ID'
    weightid as Weightid,
    
    z_weighttolid as ZWeighttolid,
     @EndUserText.label: 'Tolerance Weight KG'
    z_toleranceweight as ZToleranceweight,
     @EndUserText.label: 'Tolerance From KG'
    z_tolerancefrom as ZTolerancefrom,
     @EndUserText.label: 'Tolerance To KG'
    z_toleranceto as ZToleranceto,
    @Semantics.user.createdBy: true
    z_created_by as ZCreatedBy,
    @Semantics.systemDateTime.createdAt: true
    z_created_at as ZCreatedAt,
    @Semantics.user.localInstanceLastChangedBy: true
    z_last_changed_by as ZLastChangedBy,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    z_last_changed_at as ZLastChangedAt,
    @Semantics.systemDateTime.lastChangedAt: true
    z_local_last_changed_at as ZLocalLastChangedAt,
    _Root // Make association public
}
