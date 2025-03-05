
@EndUserText.label: 'Consumption View - WeightTolItem'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true 
define view entity ZC_WGTTOL_ITM as projection on ZI_WGTTOLITM
{
    key ZUuid,
   Uuid,
    Weightid,
    ZWeighttolid,
    ZToleranceweight,
    ZTolerancefrom,
    ZToleranceto,
    ZCreatedBy,
    ZCreatedAt,
    ZLastChangedBy,
    ZLastChangedAt,
    ZLocalLastChangedAt,
    /* Associations */
    _Root:redirected to parent ZC_WGTTOLERANCE
}
