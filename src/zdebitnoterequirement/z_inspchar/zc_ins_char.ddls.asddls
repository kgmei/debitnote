@EndUserText.label: 'Consumption Inspection Character View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_INS_CHAR 
provider contract transactional_query
as projection on ZI_INS_CHAR
{
    key ZProductUuid,
key Z_Mainproduct_id,
    ZMainproductid,
    description,
    ZCurrMainProductID,
    ZCurrMainProductName,
    ZMainproductprice,
    ZMainproductpricecur,
    ZCreatedBy,
    ZCreatedAt,
    ZLastChangedBy,
    ZLastChangedAt,
    ZLocalLastChangedAt,
    /* Associations */
    _Root:redirected to composition child ZC_INS_CHAR_ITEM,
    _his:redirected to composition child ZC_CHANGEHIS
 
    
}
