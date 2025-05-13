@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aavailablity'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
//@OData.publish: true
@UI.headerInfo: {
    typeName: 'Equipment Availablity',
    typeNamePlural: 'Equipments Availablity',
    title: {
        type: #STANDARD,
        label: 'Tavel',
        value: 'EquipmentNumber'
    }

}
define view entity ZV_availablity
  as select from equi
    inner join   jest on equi.objnr = jest.objnr
{
/*      @UI.facet: [{ id: 'Equipment Availablity',
        purpose: #STANDARD,
        position: 10,
        label: 'Travel',
        type: #IDENTIFICATION_REFERENCE }]   */

      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
  key equi.equnr as EquipmentNumber,
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      equi.herst as ManufacturerOfAsset,
      @UI.identification: [{ position: 30 }]
      @UI.lineItem: [{ position: 30 }]
      equi.serge as ManufacturerSerialNumber,
      @UI.identification: [{ position: 40 }]
      @UI.lineItem: [{ position: 40 }]
      equi.objnr as ObjectNumber,
      @UI.identification: [{ position: 50 }]
      @UI.lineItem: [{ position: 50 }]
      equi.werk  as Plant,
      @UI.identification: [{ position: 60 }]
      @UI.lineItem: [{ position: 60 }]
      @UI.selectionField: [{ position: 20 }]
      equi.erdat as RecordCreatedOn,
      @UI.identification: [{ position: 70 }]
      @UI.lineItem: [{ position: 70 }]
      equi.ernam as PersonCreatedTheObject

}
where
      jest.stat  = 'I0099'
  and jest.inact = ' '
