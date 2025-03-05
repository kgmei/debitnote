@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view - Tol Percent Item'
@Metadata.allowExtensions: true
define view entity ZI_TOLPERCENTITEM as select from ztolpercent_item
association to parent ZI_TOLPERCENTROOT as _Root
    on $projection.Rootuuid = _Root.Rootuuid
{
    key itmz_uuid as ItmzUuid,
    rootuuid as Rootuuid,
     @EndUserText.label: 'Product ID'
    z_productid as Zproductid,
      @EndUserText.label: 'Product Description'
    z_mainproductdescription as ZMainproductdes,
     @EndUserText.label: 'Tolerance Percentage'
    z_tolpercent as ZTolpercent,
    z_created_by as ZCreatedBy,
    z_created_at as ZCreatedAt,
    z_last_changed_by as ZLastChangedBy,
    z_last_changed_at as ZLastChangedAt,
    z_local_last_changed_at as ZLocalLastChangedAt,
    _Root
}
