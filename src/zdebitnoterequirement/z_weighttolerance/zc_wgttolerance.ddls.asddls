@EndUserText.label: 'Consumption View - WeightTolRoot'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_WGTTOLERANCE
provider contract transactional_query
 as projection on ZI_WGTTOLERANCE
{
    key Uuid,
    Weightid,
    ZWeighttolid,
    ZCreatedBy,
    ZCreatedAt,
    ZLastChangedBy,
    ZLastChangedAt,
    ZLocalLastChangedAt,
    /* Associations */
    _Item:redirected to composition child ZC_WGTTOL_ITM
}
