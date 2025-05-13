@AbapCatalog.sqlViewName: 'ZCDSMAP_PRICE'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'mbew source'
define view Zcds_map_price as select from Mbv_Mbew as a
{
    key a.matnr,
 //   key a.bwtar,
        @Semantics.quantity.unitOfMeasure : 'mara.meins'
        sum( a.lbkum ) as lbkum,
        
        @Semantics.amount.currencyCode : 't001.waers'
        sum( a.salk3 ) as salk3
    
        
} 
where  a.bwkey like '1%' or a.bwkey like '2%'
group by a.matnr
