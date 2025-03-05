@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View Response'
define view entity ZI_RESPONSE_CDN
  as select from zresponse_dn_db
  association to parent ZI_QUALITY_INSPECTION_ROOT as _inspectionlotRoot on $projection.ZInspectionlotUuid = _inspectionlotRoot.ZInspectionlotUuid
{
  key zresponse_dn_db.z_response_uuid         as ZResponseUuid,
      zresponse_dn_db.z_inspectionlot_uuid    as ZInspectionlotUuid,
      zresponse_dn_db.z_inspectionlot_id      as ZInspectionlotId,
      @EndUserText.label: 'Supplier Invoice ID'
      zresponse_dn_db.z_debitnote_id          as ZDebitnoteId,
     @EndUserText.label: 'Response Code'

      zresponse_dn_db.z_result                as ZResult,
      @EndUserText.label: 'Remarks'
      zresponse_dn_db.z_response              as ZResponse,
     @EndUserText.label: 'Status'
      
      zresponse_dn_db.z_status                as ZStatus,
      @EndUserText.label: 'Created On'
      zresponse_dn_db.z_log_createdon         as ZLogCreatedon,
      zresponse_dn_db.z_created_by            as ZCreatedBy,
      zresponse_dn_db.z_created_at            as ZCreatedAt,
      zresponse_dn_db.z_last_changed_by       as ZLastChangedBy,
      zresponse_dn_db.z_last_changed_at       as ZLastChangedAt,
      zresponse_dn_db.z_local_last_changed_at as ZLocalLastChangedAt,
      _inspectionlotRoot
      // Make association public
}
