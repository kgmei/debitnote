@EndUserText.label: 'Consumption Inspection Char Item View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_INS_CHAR_ITEM as projection on ZINS_CHAR_ITEM
{
    key ZSubproductUuid,
    Z_Mainproduct_id,
    ZProductUuid,
    ZSupProductid,
    ZProductType,
ZSubProductID,
    ZSupprdPrice,
    ZSupprdCur,
    ZMainproductid,
    ZFormula,
    Descriptionitem,
@EndUserText.label: 'Pricing Type'

@Consumption.valueHelpDefinition: [{ entity:{name: 'ZI_PRICING_TYPE', element: 'text'} }]
    ZPricingType,
    ZProductName,
    ZCreatedBy,
    ZCreatedAt,
    ZLastChangedBy,
    ZLastChangedAt,
    ZLocalLastChangedAt,
    /* Associations */
    _Item:redirected to parent ZC_INS_CHAR 
}
