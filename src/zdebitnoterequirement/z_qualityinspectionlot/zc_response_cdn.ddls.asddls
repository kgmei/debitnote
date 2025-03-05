@EndUserText.label: 'Consumption View Response DebitNote'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_RESPONSE_CDN
  as projection on ZI_RESPONSE_CDN
{
  key ZResponseUuid,
      ZInspectionlotUuid,
      ZInspectionlotId,
      ZDebitnoteId,
      ZResult,
      ZResponse,
      ZStatus,
      ZLogCreatedon,
      ZCreatedBy,
      ZCreatedAt,
      ZLastChangedBy,
      ZLastChangedAt,
      ZLocalLastChangedAt,
      /* Associations */
      _inspectionlotRoot : redirected to parent ZC_QUALITY_INSPECTION_ROOT
}
