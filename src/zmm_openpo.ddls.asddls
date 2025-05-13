@AbapCatalog.sqlViewName: 'Z_OPENPO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'For OPEN PO'
@Metadata.ignorePropagatedAnnotations: true
define view ZMM_OpenPO
as select from ekko as k
inner join mdbs as e on k.ebeln = e.ebeln
{
    key e.matnr,
    key e.ebeln,
    key e.werks,
        //e.ebelp,
        e.loekz,
        e.retpo,
        case when e.retpo = 'X' then
         (sum(e.menge) * -1) - (sum(e.wemng) * -1)
        else
         sum(e.menge) - sum(e.wemng)
        end as openpo,
        k.bsart,
        e.bstyp,
        e.elikz
}group by   e.matnr,
            e.ebeln,
            e.loekz,
            e.werks,
            e.retpo,
            k.bsart,
            e.bstyp,
            e.elikz
            
            
            
            
            
            
            
