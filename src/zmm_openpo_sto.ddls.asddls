@AbapCatalog.sqlViewName: 'Z_OPENPO_STO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'For OPEN PO STO'
@Metadata.ignorePropagatedAnnotations: true
define view ZMM_OPENPO_STO
as select from ekko as k
inner join mdbs as e on k.ebeln = e.ebeln
{
    key e.matnr,
    key e.ebeln,
    key k.reswk,
        //e.ebelp,
        e.loekz,
        e.retpo,
        sum(e.menge) - sum(e.wemng)  as openpo_sto,
    
        e.bstyp,
        e.elikz
}group by   e.matnr,
            e.ebeln,
            e.loekz,
            k.reswk,
            e.retpo,
       
            e.bstyp,
            e.elikz
            
            
            
            
            
            
            
