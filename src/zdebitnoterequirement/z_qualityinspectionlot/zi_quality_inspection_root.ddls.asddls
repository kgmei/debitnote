@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Definition for Quality Inspection'
@Metadata.allowExtensions: true
define root view entity ZI_QUALITY_INSPECTION_ROOT
  as select from zqualityins_root
  composition [0..*] of ZI_QUALITY_INSPECTION_ITEM as _inspectionLotItm
  composition [0..*] of ZI_RESPONSE_CDN            as _ResponseDN
{
  key z_inspectionlot_uuid    as ZInspectionlotUuid,
      z_inspectionlot_id      as ZInspectionlotId,
      z_grn_id                as ZGrnId,
      z_purchaseorder_id      as ZPurchaseorderId,
      z_subsequentcrdt_flag   as ZSubsequentCrdtFlag,
      z_grn_qty_unit          as ZGrnQtyUnit,
      @Semantics.quantity.unitOfMeasure : 'ZGrnQtyUnit'
      z_grn_qty               as ZGrnQty,
      z_unrestrictedqty_unit  as ZUnrestrictedqtyUnit,
      @Semantics.quantity.unitOfMeasure : 'ZUnrestrictedqtyUnit'
      z_unrestricted_qty      as ZUnrestrictedQty,
      z_samplesize_unit       as ZSamplesizeUnit,
      @Semantics.quantity.unitOfMeasure : 'ZSamplesizeUnit'
      z_samplesize            as ZSamplesize,
      @Semantics.quantity.unitOfMeasure : 'ZSamplesizeUnit'
      z_after_qc              as ZAfterQC,
      z_qualityins_status     as ZQualityinsStatus,
      z_poprice               as ZPOPrice,
      z_poprice_cur           as ZPOPriceCurrency,
      z_initbill              as ZInitialBillAmnt,
      z_initbill_cur          as ZInitialBillAmntCurrency,
      z_difference_debit      as ZDifferenceDebit,
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
      _inspectionLotItm,
      _ResponseDN // Make association public
}
