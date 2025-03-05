@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view - Tol Percent Root'
@Metadata.allowExtensions: true
define root view entity ZI_TOLPERCENTROOT as select from ztolpercent_root
composition[0..*]  of ZI_TOLPERCENTITEM as _Item
{
    key rootuuid as Rootuuid,
      @EndUserText.label: 'Tolerance Percent ID'
   
    z_tolpercentid as ZTolpercentid,
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
    _Item
}
