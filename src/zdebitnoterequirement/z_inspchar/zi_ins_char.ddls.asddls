@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inspection Character Interface View'
define root view entity ZI_INS_CHAR as select from zinsp_char_db as Product
composition [0..*] of ZINS_CHAR_ITEM as _Root
composition [0..*] of ZI_CHANGEHIS as _his
association [0..1] to I_ProductDescription as _prd on _prd.Product = Product.z_curr_mainproductid


{
    key z_product_uuid as ZProductUuid,
  @EndUserText.label: 'ProductID' 
   key z_mainproduct_id as Z_Mainproduct_id,
   z_curr_mainproductid as ZCurrMainProductID,
    @EndUserText.label: 'Product Name' 
   z_curr_mainproductname as ZCurrMainProductName,
    @EndUserText.label: 'Product ID' 
    z_mainproductid as ZMainproductid,
    @EndUserText.label: 'Price' 
    z_mainproductprice as ZMainproductprice,
    @EndUserText.label: 'Currency' 
    z_mainproductpricecur as ZMainproductpricecur,
    _prd.ProductDescription as description,
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
    _Root,
    _his,
    _prd // Make association public
}
