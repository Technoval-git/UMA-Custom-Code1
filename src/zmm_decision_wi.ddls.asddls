@AbapCatalog.sqlViewName: 'ZMM_DWI'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Decision WorkItem'
@Metadata.ignorePropagatedAnnotations: true
define view zmm_decision_WI as select from swwwihead as s
inner join sww_wi2obj as o on s.wi_id = o.wi_id

association [1..1] to usr21 as UName on bname = s.wi_aagent or bname = s.wi_mod_by
{
s.wi_id as WI_ID,
s.wi_text as wi_text,
substring(wi_text,24,10) as ebeln,
s.wi_cd as wi_cd,
s.wi_stat as Status,
//s.wi_aagent,
//s.wi_mod_by,
case when UName.techdesc is not initial then 
UName.techdesc else 
(case when s.wi_aagent is not initial then 
s.wi_aagent else 
s.wi_mod_by end ) end as Approver,

UName.persnumber as ApproverID,

s.wi_cruser as wi_cruser

    
} where o.wi_rh_task = 'TS00800531' // and o.wi_reltype = '11'
