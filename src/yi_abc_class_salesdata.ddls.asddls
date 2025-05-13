@AbapCatalog.sqlViewName: 'YABC_CD_SALDATA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get Sales Data'
define view YI_ABC_CLASS_SALSEDATA as 
      select from vbrk as vbrk
       inner join vbrp as vbrp
               on vbrk.vbeln = vbrp.vbeln  
{
//    vbrk.vbeln as vbeln,
    vbrp.matnr as matnr,
    vbrp.werks as werks,
    sum( vbrp.fkimg ) as fkimg
//    vbrk.fkdat as fkdat,
//    vbrk.fksto as fksto

}group by matnr,
          werks
