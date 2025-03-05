@EndUserText.label: 'Consumption View - WeightTolRoot'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TOLPERCENTROOT
provider contract transactional_query
 as projection on ZI_TOLPERCENTROOT
{
    key Rootuuid,
    ZTolpercentid,
    ZCreatedBy,
    ZCreatedAt,
    ZLastChangedBy,
    ZLastChangedAt,
    ZLocalLastChangedAt,
    /* Associations */
    _Item:redirected to composition child zc_tolpercentitem
}
