@EndUserText.label: 'Consumption View - WeightTolItem'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true 
define view entity zc_tolpercentitem as projection on ZI_TOLPERCENTITEM
{
    key ItmzUuid,
    Rootuuid,
    Zproductid,
    ZMainproductdes,
    ZTolpercent,
    ZCreatedBy,
    ZCreatedAt,
    ZLastChangedBy,
    ZLastChangedAt,
    ZLocalLastChangedAt,
    /* Associations */
    _Root:redirected to parent ZC_TOLPERCENTROOT
}
