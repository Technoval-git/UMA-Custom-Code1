@AbapCatalog.sqlViewName: 'YI_ABC_CLA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABC Classification Repot'
define view YI_ABC_CLASSIFICATION
  as select from    mara  as mara
    inner join      marc  as marc  on mara.matnr = marc.matnr
    left outer join makt  as makt  on  makt.matnr = mara.matnr
                                   and makt.spras = $session.system_language
    left outer join t023t as t023t on  makt.spras = $session.system_language
                                   and mara.matkl = t023t.matkl
{

  mara.matnr  as matnr, //Material Number
  makt.maktx  as maktx, //Material Descreption
  mara.matkl  as matkl, //Material Group
  t023t.wgbez as wgbez, //Material Group Description 
  marc.werks  as werks, //Plant
  marc.maabc  as maabc, //ABC Indicator
  marc.eisbe  as eisbe  //Safety Stock


}
