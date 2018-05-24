/*
 * -------------------------------------------------------------------------------
 * birthCertificateRpt.js
 *
 * Produces the birth certificate. Expects to receive baby_id, top1 offset and left
 * offsets as parameters.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , PDFDocument = require('pdfkit')
  , fs = require('fs')
  , os = require('os')
  , path = require('path')
  , util = require('../util')
  , Baby = require('../models').Baby
  , BirthCertificate = require('../models').BirthCertificate
  , Labor = require('../models').Labor
  , LaborStage2 = require('../models').LaborStage2
  , Pregnancy = require('../models').Pregnancy
  , Patient = require('../models').Patient
  , User = require('../models').User
  , cfg = require('../config')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , FONTS = require('./reportGeneral').FONTS
  , centerText = require('./reportGeneral').centerText
  , loadFontAwesome = require('./reportGeneral').loadFontAwesome
  , blackColor = '#000'
  , greyDarkColor = '#999'
  , greyLightColor = '#AAA'
  , smallFont = 9
  , mediumFont = 11
  , currentPage = 0;    // Tracking the current page that is printing.
  ;

// --------------------------------------------------------
// These are the positions of all of the fields in the form.
// The numbers in the arrays are centimeters from the left
// edge of the form and the top edge of the form respectively.
// --------------------------------------------------------
var fldPos =
  { topOfForm:
      { province: [2.0, 2.8]
      , city: [3.3, 3.4]
      }
  , name:
      { first: [1.0, 4.4]
      , middle: [8.7, 4.4]
      , last: [14, 4.4]
      }
  , sex: [1.0, 5.4]
  , dob:
      { day: [9.9, 5.4]
      , month: [12.9, 5.4]
      , year: [16.2, 5.4]
      }
  , birthPlace:
      { name: [1.5, 6.4]
      , city: [9.5, 6.4]
      , province: [14.2, 6.4]
      }
  , birthType: [1.2, 7.7]
  , birthMultiple: [6.2, 7.7]
  , birthOrder: [11.2, 7.7]
  , weight: [15.7, 7.7]
  , motherName:
      { first: [3.5, 8.9]
      , middle: [8.7, 8.9]
      , last: [14.2, 8.9]
      }
  , motherCitizenship: [3.5, 9.9]
  , motherReligion: [10.0, 9.9]
  , motherNumBornAlive: [2.0, 11.1]
  , motherNumNowLiving: [5.0, 11.1]
  , motherNumNowDead: [8.2, 11.1]
  , motherOccupation: [10.3, 11.1]
  , motherAge: [17.0, 11.1]
  , motherResidence:
      { house: [1.0, 12.2]
      , city: [8.0, 12.2]
      , province: [12.0, 12.2]
      , country: [15.0, 12.2]
      }
  , fatherName:
      { first:[1.0, 13.3]
      , middle: [8.5, 13.3]
      , last: [14.0, 13.3]
      }
  , fatherCitizenship: [1.0, 14.5]
  , fatherReligion: [6.0, 14.5]
  , fatherOccupation: [11.5, 14.5]
  , fatherAge: [17.0, 14.5]
  , fatherResidence:
      { house: [1.0, 15.5]
      , city: [8.5, 15.5]
      , province: [12.0, 15.5]
      , country: [15.0, 15.5]
      }
  , marriage:
      { date:
          { month: [2.6, 17.1]
          , day: [4.2, 17.1]
          , year: [5.6, 17.1]
          }
      , place:
          { city: [8.0, 17.1]
          , province: [13.0, 17.1]
          , country: [15.7, 17.1]
          }
      }
  , attendant:
      { isPhysician: [0.5, 18.3]
      , isNurse: [3.2, 18.3]
      , isMidwife: [5.5, 18.3]
      , isHilot: [8.0, 18.3]
      , isOther: [13.3, 18.3]
      , other: [16.4, 18.3]
      , time: [11.5, 19.2]
      , fullname: [2.5, 20.6]
      , title: [2.5, 21.2]
      , addr1: [11.0, 20.0]
      , addr2: [11.0, 20.6]
      , date: [11.0, 21.2]
      }
  , informant:
      { fullname: [2.5, 23.6]
      , relationToChild: [3.5, 24.2]
      , address: [2.0, 24.75]
      , date: [2.0, 25.3]
      }
  , preparedBy:
      { fullname: [12.0, 23.7]
      , title: [12.0, 24.3]
      , date: [12.0, 24.9]
      }
  , paternity:
      { firstParent: [3.0, 1.4]
      , secondParent: [11.0, 1.4]
      , child: [9.0, 1.9]
      , date: [2.0, 2.3]
      , place: [7.5, 2.3]
      , fatherName: [2.0, 4.6]
      , motherName: [11.5, 4.6]
      , fatherName2: [2.0, 6.6]
      , motherName2: [8.0, 6.6]
      , commTaxNumber: [5.5, 7.2]
      , commTaxDate: [12.5, 7.2]
      , commTaxPlace: [1.0, 7.7]
      }
  , receivedBy:
    { name: [2.5, 26.9]
    , title: [2.5, 27.5]
    }
  , delayedRegistration:
    { name: [2.0, 12.7]
    , address: [5.5, 13.3]
    , birthCheckbox: [2.35, 15.9]
    , babyName: [5.2, 16.0]
    , clinicName: [14.0, 16.0]
    , babyBDay: [9.2, 16.5]
    , attendantName: [8.2, 17.2]
    , attendantAddress: [2.6, 17.75]
    , citizenOf: [7.5, 18.5]
    , marriedCheckbox: [7.2, 19.25]
    , marriedDate: [9.8, 19.3]
    , marriedPlace: [8.2, 19.7]
    , acknowledgedCheckbox: [7.2, 20.4]
    , fatherName: [12.0, 20.9]
    , reason1: [11.7, 21.7]
    , reason2: [2.3, 22.2]
    , iam: [12.0, 23.7]
    , affiateSignature: [11.0, 27.6]
    , notaryPlace: [1.0, 29.8]
    , affiateCommTaxNumber: [0.5, 30.3]
    , affiateCommTaxDate: [5.5, 30.3]
    , affiateCommTaxPlace: [11.0, 30.3]
    }
  };

// --------------------------------------------------------
// Converts centimeters to points.
// --------------------------------------------------------
var cmToPt = function(cm) {
  return Math.ceil(cm * 28.54);
};

/* --------------------------------------------------------
 * makeWriteFieldFunc()
 *
 * Returns a function which writes out a field with the
 * specified parameters preset. The top and left fields
 * are in points. The returned function expects the x and
 * y fields to be in centimeters.
 *
 * param       doc
 * param       top
 * param       left
 * param       isUpperCase
 * return      function
 * -------------------------------------------------------- */
var makeWriteFieldFunc = function(doc, top, left, isUpperCase) {
  var lineHeight = Math.floor(doc.currentLineHeight());

  return function(x, y, value) {
    var val = _.isNull(value) || _.isUndefined(value)? '': '' + value;
    if (isUpperCase) val = val.toUpperCase();
    doc.text(val, cmToPt(x) + left, cmToPt(y) - lineHeight + top);
  };
};


/* --------------------------------------------------------
 * doFirstPage()
 *
 * Prints the first page of the Philippines Birth Certificate.
 * This is meant to be printed on a pre-printed form, so we
 * are just filling in the blanks.
 *
 * Municipal Form No. 102
 * (Revised January 2007)
 *
 * param       doc
 * param       data
 * param       opts
 * return      undefined
 * -------------------------------------------------------- */
var doFirstPage = function(doc, data, opts) {
  var top = opts.margins.top
    , left = opts.margins.left
    , writeField = makeWriteFieldFunc(doc, top, left)
    , writeFIELD = makeWriteFieldFunc(doc, top, left, true)
    , tmp
    ;

  // Top of the form.
  tmp = cfg.getKeyValue('birthCertProvinceTop')? cfg.getKeyValue('birthCertProvinceTop'): '';
  writeField(fldPos.topOfForm.province[0], fldPos.topOfForm.province[1], tmp);
  tmp = cfg.getKeyValue('birthCertCityTop')? cfg.getKeyValue('birthCertCityTop'): '';
  writeField(fldPos.topOfForm.city[0], fldPos.topOfForm.city[1], tmp);

  // 1. Name
  writeFIELD(fldPos.name.first[0], fldPos.name.first[1], data.baby.firstname);
  writeFIELD(fldPos.name.middle[0], fldPos.name.middle[1], data.baby.middlename);
  writeFIELD(fldPos.name.last[0], fldPos.name.last[1], data.baby.lastname);

  // 2. Sex
  if (data.baby.sex === 'F') {
    tmp = 'Female';
  } else if (data.baby.sex === 'M') {
    tmp = 'Male';
  } else {
    tmp = 'Ambiguous';
  }
  writeFIELD(fldPos.sex[0], fldPos.sex[1], tmp);

  // 3. Date of birth
  writeField(fldPos.dob.day[0], fldPos.dob.day[1], moment(data.ls2.birthDatetime).format('D'));
  writeField(fldPos.dob.month[0], fldPos.dob.month[1], moment(data.ls2.birthDatetime).format('MMMM'));
  writeField(fldPos.dob.year[0], fldPos.dob.year[1], moment(data.ls2.birthDatetime).format('YYYY'));

  // 4. Place of birth
  // Note: these settings can be changed per site in the Administrator role on
  // the configuration page.
  doc
    .font(FONTS.Helvetica)
    .fontSize(smallFont);
  tmp = cfg.getKeyValue('birthCertInstitution')? cfg.getKeyValue('birthCertInstitution'): '';
  writeField(fldPos.birthPlace.name[0], fldPos.birthPlace.name[1], tmp);
  tmp = cfg.getKeyValue('birthCertCity')? cfg.getKeyValue('birthCertCity'): '';
  writeField(fldPos.birthPlace.city[0], fldPos.birthPlace.city[1], tmp);
  tmp = cfg.getKeyValue('birthCertProvince')? cfg.getKeyValue('birthCertProvince'): '';
  writeField(fldPos.birthPlace.province[0], fldPos.birthPlace.province[1], tmp);

  // 5. Birth type, multiple, and order.
  // Notes:
  //  - 5.a Type of birth is derived from laborStage2.birthType.
  //  - 5.b is not handled yet because it is for multiple births and this EMR does not
  //    yet handle multiple births. We leave it blank for now.
  //  - 5.c Birth order is derived from birthCertificate.birthOrder.
  doc
    .fontSize(mediumFont);
  writeFIELD(fldPos.birthType[0], fldPos.birthType[1], data.ls2.birthType);
  writeField(fldPos.birthOrder[0], fldPos.birthOrder[1], data.bc.birthOrder);

  // 6. Weight
  writeField(fldPos.weight[0], fldPos.weight[1], data.baby.birthWeight);

  // 7. Mother name
  writeFIELD(fldPos.motherName.first[0], fldPos.motherName.first[1], data.bc.motherFirstname);
  writeFIELD(fldPos.motherName.middle[0], fldPos.motherName.middle[1], data.bc.motherMiddlename);
  writeFIELD(fldPos.motherName.last[0], fldPos.motherName.last[1], data.bc.motherMaidenLastname);

  // 8. Mother citizenship
  writeField(fldPos.motherCitizenship[0], fldPos.motherCitizenship[1], data.bc.motherCitizenship);

  // 9. Mother religion
  writeField(fldPos.motherReligion[0], fldPos.motherReligion[1], data.preg.religion);

  // 10.a, b, c Mother number children.
  writeField(fldPos.motherNumBornAlive[0], fldPos.motherNumBornAlive[1], data.bc.motherNumChildrenBornAlive);
  writeField(fldPos.motherNumNowLiving[0], fldPos.motherNumNowLiving[1], data.bc.motherNumChildrenLiving);
  writeField(fldPos.motherNumNowDead[0], fldPos.motherNumNowDead[1], data.bc.motherNumChildrenBornAliveNowDead);

  // 11. Mother occupation
  writeField(fldPos.motherOccupation[0], fldPos.motherOccupation[1], data.preg.work);

  // 12. Mother age
  writeField(fldPos.motherAge[0], fldPos.motherAge[1], moment().diff(data.patient.dob, 'years'));

  // 13. Mother residence
  writeField(fldPos.motherResidence.house[0], fldPos.motherResidence.house[1], data.bc.motherAddress);
  writeField(fldPos.motherResidence.city[0], fldPos.motherResidence.city[1], data.bc.motherCity);
  writeField(fldPos.motherResidence.province[0], fldPos.motherResidence.province[1], data.bc.motherProvince);
  writeField(fldPos.motherResidence.country[0], fldPos.motherResidence.country[1], data.bc.motherCountry);

  // 14. Father name
  writeFIELD(fldPos.fatherName.first[0], fldPos.fatherName.first[1], data.bc.fatherFirstname);
  writeFIELD(fldPos.fatherName.middle[0], fldPos.fatherName.middle[1], data.bc.fatherMiddlename);
  writeFIELD(fldPos.fatherName.last[0], fldPos.fatherName.last[1], data.bc.fatherLastname);

  // 15. Father citizenship
  writeField(fldPos.fatherCitizenship[0], fldPos.fatherCitizenship[1], data.bc.fatherCitizenship);

  // 16. Father religion
  writeField(fldPos.fatherReligion[0], fldPos.fatherReligion[1], data.bc.fatherReligion);

  // 17. Father occupation
  writeField(fldPos.fatherOccupation[0], fldPos.fatherOccupation[1], data.bc.fatherOccupation);

  // 18. Father age
  writeField(fldPos.fatherAge[0], fldPos.fatherAge[1], data.bc.fatherAgeAtBirth);

  // 19. Father residence
  writeField(fldPos.fatherResidence.house[0], fldPos.fatherResidence.house[1], data.bc.fatherAddress);
  writeField(fldPos.fatherResidence.city[0], fldPos.fatherResidence.city[1], data.bc.fatherCity);
  writeField(fldPos.fatherResidence.province[0], fldPos.fatherResidence.province[1], data.bc.fatherProvince);
  writeField(fldPos.fatherResidence.country[0], fldPos.fatherResidence.country[1], data.bc.fatherCountry);

  // 20. Marriage
  if (data.bc.dateOfMarriage) {
    writeField(fldPos.marriage.date.month[0], fldPos.marriage.date.month[1], moment(data.bc.dateOfMarriage).format('MM'));
    writeField(fldPos.marriage.date.day[0], fldPos.marriage.date.day[1], moment(data.bc.dateOfMarriage).format('D'));
    writeField(fldPos.marriage.date.year[0], fldPos.marriage.date.year[1], moment(data.bc.dateOfMarriage).format('YYYY'));
    writeField(fldPos.marriage.place.city[0], fldPos.marriage.place.city[1], data.bc.cityOfMarriage);
    writeField(fldPos.marriage.place.province[0], fldPos.marriage.place.province[1], data.bc.provinceOfMarriage);
    writeField(fldPos.marriage.place.country[0], fldPos.marriage.place.country[1], data.bc.countryOfMarriage);
  } else {
    writeFIELD(fldPos.marriage.date.month[0], fldPos.marriage.date.month[1], 'Not Married');
    writeFIELD(fldPos.marriage.place.city[0], fldPos.marriage.place.city[1], 'Not Married');
  }

  // 21.a Attendant
  if (data.bc.attendantType === 'Physician') {
    writeField(fldPos.attendant.isPhysician[0], fldPos.attendant.isPhysician[1], 'X');
  }
  if (data.bc.attendantType === 'Nurse') {
    writeField(fldPos.attendant.isNurse[0], fldPos.attendant.isNurse[1], 'X');
  }
  if (data.bc.attendantType === 'Midwife') {
    writeField(fldPos.attendant.isMidwife[0], fldPos.attendant.isMidwife[1], 'X');
  }
  if (data.bc.attendantType === 'Hilot') {
    writeField(fldPos.attendant.isHilot[0], fldPos.attendant.isHilot[1], 'X');
  }
  if (data.bc.attendantType === 'Other') {
    writeField(fldPos.attendant.isOther[0], fldPos.attendant.isOther[1], 'X');
    writeField(fldPos.attendant.other[0], fldPos.attendant.other[1], data.bc.attendantOther);
  }

  // 21.b Attendant certification
  doc
    .fontSize(smallFont);
  writeField(fldPos.attendant.time[0], fldPos.attendant.time[1], moment(data.ls2.birthDatetime).format('h:mm A'));
  writeFIELD(fldPos.attendant.fullname[0], fldPos.attendant.fullname[1], data.bc.attendantFullname);
  writeField(fldPos.attendant.title[0], fldPos.attendant.title[1], data.bc.attendantTitle);
  writeField(fldPos.attendant.addr1[0], fldPos.attendant.addr1[1], data.bc.attendantAddr1);
  writeField(fldPos.attendant.addr2[0], fldPos.attendant.addr2[1], data.bc.attendantAddr2);
  writeField(fldPos.attendant.date[0], fldPos.attendant.date[1], moment().format('DD-MMM-YYYY'));

  // 22. Informant certification
  writeFIELD(fldPos.informant.fullname[0], fldPos.informant.fullname[1], data.bc.informantFullname);
  writeField(fldPos.informant.relationToChild[0], fldPos.informant.relationToChild[1], data.bc.informantRelationToChild);
  writeField(fldPos.informant.address[0], fldPos.informant.address[1], data.bc.informantAddress);
  writeField(fldPos.informant.date[0], fldPos.informant.date[1], moment().format('DD-MMM-YYYY'));

  // 23. Prepared by
  writeFIELD(fldPos.preparedBy.fullname[0], fldPos.preparedBy.fullname[1], data.bc.preparedByFullname);
  writeField(fldPos.preparedBy.title[0], fldPos.preparedBy.title[1], data.bc.preparedByTitle);
  writeField(fldPos.preparedBy.date[0], fldPos.preparedBy.date[1], moment().format('DD-MMM-YYYY'));

  // 24. Received by
  writeFIELD(fldPos.receivedBy.name[0], fldPos.receivedBy.name[1], data.bc.receivedByName);
  writeField(fldPos.receivedBy.title[0], fldPos.receivedBy.title[1], data.bc.receivedByTitle);
};

/* --------------------------------------------------------
 * doSecondPage()
 *
 * Prints the second page of the Certificate of Live Birth
 * form, but only the top section for Admission of Paternity.
 *
 * Note that this should not be called if the comm tax
 * fields are complete.
 *
 * param       doc
 * param       data
 * param       opts
 * return      undefined
 * -------------------------------------------------------- */
var doSecondPage = function(doc, data, opts) {
  var top = opts.margins.top
    , left = opts.margins.left
    , tmp
    , tmp2
    , writeField = makeWriteFieldFunc(doc, top, left)
    , writeFIELD = makeWriteFieldFunc(doc, top, left, true)
    ;

  doc
    .fontSize(mediumFont);

  // --------------------------------------------------------
  // Optional Admission of paternity
  // --------------------------------------------------------
  if (opts.printPaternity) {

    // I/We,
    writeFIELD(fldPos.paternity.firstParent[0], fldPos.paternity.firstParent[1],
        data.preg.firstname + ' ' + data.bc.motherMiddlename + ' ' + data.preg.lastname);
    // and
    writeFIELD(fldPos.paternity.secondParent[0], fldPos.paternity.secondParent[1],
        data.bc.fatherFirstname + ' ' + data.bc.fatherMiddlename + ' ' + data.bc.fatherLastname);
    // of legal age, am/are the natural mother and/or father of
    writeFIELD(fldPos.paternity.child[0], fldPos.paternity.child[1],
        data.baby.firstname + ' ' + data.baby.middlename + ' ' + data.baby.lastname);
    // who was born on
    writeFIELD(fldPos.paternity.date[0], fldPos.paternity.date[1], moment(data.ls2.birthDatetime).format('MMMM D, YYYY'));

    // at
    doc
      .fontSize(smallFont);
    tmp = cfg.getKeyValue('birthCertInstitution')? cfg.getKeyValue('birthCertInstitution'): '';
    writeField(fldPos.paternity.place[0], fldPos.paternity.place[1], tmp);

    // I am/We are executing the affidavit to attest to the ...
    doc
      .fontSize(mediumFont);
    writeFIELD(fldPos.paternity.fatherName[0], fldPos.paternity.fatherName[1],
        data.bc.fatherFirstname + ' ' + data.bc.fatherMiddlename + ' ' + data.bc.fatherLastname);
    writeFIELD(fldPos.paternity.motherName[0], fldPos.paternity.motherName[1],
        data.preg.firstname + ' ' + data.bc.motherMiddlename + ' ' + data.preg.lastname);

    // SUBSCRIBED AND SWORN
    // NOTE: the date fields are left blank.

    // by
    writeFIELD(fldPos.paternity.fatherName2[0], fldPos.paternity.fatherName2[1],
        data.bc.fatherFirstname + ' ' + data.bc.fatherMiddlename + ' ' + data.bc.fatherLastname);
    // and
    writeFIELD(fldPos.paternity.motherName2[0], fldPos.paternity.motherName2[1],
        data.preg.firstname + ' ' + data.bc.motherMiddlename + ' ' + data.preg.lastname);
    // who exhinited to me (his/her) Community Tax Cert No.
    writeField(fldPos.paternity.commTaxNumber[0], fldPos.paternity.commTaxNumber[1], data.bc.commTaxNumber);
    // issued on
    writeField(fldPos.paternity.commTaxDate[0], fldPos.paternity.commTaxDate[1], moment(data.bc.commTaxDate).format('DD-MMM-YYYY'));
    // at
    writeField(fldPos.paternity.commTaxPlace[0], fldPos.paternity.commTaxPlace[1], data.bc.commTaxPlace);

  }

  // --------------------------------------------------------
  // Optional Affidavit for delayed registration of birth
  // --------------------------------------------------------
  if (opts.printRegistration) {
    // I
    writeFIELD(fldPos.delayedRegistration.name[0], fldPos.delayedRegistration.name[1], data.bc.affiateName);
    // of legal age, with residence and postal address at
    writeField(fldPos.delayedRegistration.address[0], fldPos.delayedRegistration.address[1], data.bc.affiateAddress);

    // 1. That I am the applicator for the delayed registration of:
    writeFIELD(fldPos.delayedRegistration.birthCheckbox[0], fldPos.delayedRegistration.birthCheckbox[1], "X");
    // the birth of
    writeFIELD(fldPos.delayedRegistration.babyName[0], fldPos.delayedRegistration.babyName[1], data.baby.firstname + " " + data.baby.middlename + " " + data.baby.lastname);
    // who was born in
    doc
      .font(FONTS.Helvetica)
      .fontSize(smallFont);
    tmp = cfg.getKeyValue('birthCertInstitution')? cfg.getKeyValue('birthCertInstitution'): '';
    writeField(fldPos.delayedRegistration.clinicName[0], fldPos.delayedRegistration.clinicName[1], tmp);
    // on
    doc
      .font(FONTS.Helvetica)
      .fontSize(mediumFont);
    writeField(fldPos.delayedRegistration.babyBDay[0], fldPos.delayedRegistration.babyBDay[1], moment(data.ls2.birthDatetime).format('DD-MMM-YYYY'));
    // 2. That I/he/she was attended at birth by
    writeFIELD(fldPos.delayedRegistration.attendantName[0], fldPos.delayedRegistration.attendantName[1], data.bc.attendantFullname);
    // who resides at
    writeField(fldPos.delayedRegistration.attendantAddress[0], fldPos.delayedRegistration.attendantAddress[1],
        data.bc.attendantAddr1 + " " + data.bc.attendantAddr2);
    // 3. That I am/he/she is a citizen of
    writeField(fldPos.delayedRegistration.citizenOf[0], fldPos.delayedRegistration.citizenOf[1], data.bc.affiateCitizenshipCountry);
    // 4. That my/his/her parents were
    if (data.bc.dateOfMarriage && _.isDate(data.bc.dateOfMarriage)) {
      writeFIELD(fldPos.delayedRegistration.marriedCheckbox[0], fldPos.delayedRegistration.marriedCheckbox[1], 'X');
      // married on
      writeField(fldPos.delayedRegistration.marriedDate[0], fldPos.delayedRegistration.marriageDate[1],
          moment(data.bc.dateOfMarriage).format('MMMM D, YYYY'));
      // at
      writeField(fldPos.delayedRegistration.marriedPlace[0], fldPos.delayedRegistration.marriedPlace[1],
          data.bc.cityOfMarriage + " " + data.bc.provinceOfMarriage + " " + data.bc.countryOfMarriage);
    } else {
      writeFIELD(fldPos.delayedRegistration.acknowledgedCheckbox[0], fldPos.delayedRegistration.acknowledgedCheckbox[1], 'X');
      // not married but I/he/she was acknowledged/not acknowledged by my/his/her father whose name is
      writeFIELD(fldPos.delayedRegistration.fatherName[0], fldPos.delayedRegistration.fatherName[1],
          data.bc.fatherFirstname + " " + data.bc.fatherMiddlename + " " + data.bc.fatherLastname);
    }

    // 5. That the reason for the delay in registering my/his/her birth was
    // First line can hold 180 points of data and the remainder goes on the second line.
    tmp = util.splitStringOnWordAtPerc(data.bc.affiateReason, ((180 * 100)/doc.widthOfString(data.bc.affiateReason)));
    writeField(fldPos.delayedRegistration.reason1[0], fldPos.delayedRegistration.reason1[1], tmp[0]);
    writeField(fldPos.delayedRegistration.reason2[0], fldPos.delayedRegistration.reason2[1], tmp[1]);

    // 6. That I am the
    writeField(fldPos.delayedRegistration.iam[0], fldPos.delayedRegistration.iam[1], data.bc.affiateIAm);

    // Signature over printed name of Affiant
    writeFIELD(fldPos.delayedRegistration.affiateSignature[0], fldPos.delayedRegistration.affiateSignature[1], data.bc.affiateName);

    // Notary stuff
    // at
    tmp = cfg.getKeyValue('birthCertCity')? cfg.getKeyValue('birthCertCity'): '';
    tmp2 = cfg.getKeyValue('birthCertProvince')? cfg.getKeyValue('birthCertProvince'): '';
    if (tmp.length > 0) {
      writeField(fldPos.delayedRegistration.notaryPlace[0], fldPos.delayedRegistration.notaryPlace[1], tmp);
    }
    if (tmp2.length > 0) {
      // Need to place it after where city was written.
      writeField(fldPos.delayedRegistration.notaryPlace[0] + doc.widthOfString(tmp) + 10,
          fldPos.delayedRegistration.notaryPlace[1], tmp2);
    }

    // affiant who exhibited to me his Community Tax Cert.
    writeField(fldPos.delayedRegistration.affiateCommTaxNumber[0], fldPos.delayedRegistration.affiateCommTaxNumber[1],
        data.bc.affiateCommTaxNumber);
    // issued on
    writeField(fldPos.delayedRegistration.affiateCommTaxDate[0], fldPos.delayedRegistration.affiateCommTaxDate[1],
        moment(data.bc.affiateCommTaxDate).format('MMMM D, YYYY'));
    // at
    writeField(fldPos.delayedRegistration.affiateCommTaxPlace[0], fldPos.delayedRegistration.affiateCommTaxPlace[1],
        data.bc.affiateCommTaxPlace);
  }
};

var doPages = function(doc, data, opts) {
  // First page with margins as originally set for page one.
  doFirstPage(doc, data, opts);

  // --------------------------------------------------------
  // We only print the second page if paternity or registration
  // requested by the user.
  // --------------------------------------------------------
  if (opts.printPaternity || opts.printRegistration) {
    // Second page set with page two margins.
    opts.margins = opts.margins2;
    delete opts.margins2;
    doc.addPage(opts);
    doSecondPage(doc, data, opts);
  }

};

/* --------------------------------------------------------
 * getData()
 *
 * Queries the database for the required information. Returns
 * a promise that resolves to an array of data.
 *
 * param      babyId
 * return     Promise
 * -------------------------------------------------------- */
var getData = function(babyId) {
  var data = {}
    ;

  return new Promise(function(resolve, reject) {
    // --------------------------------------------------------
    // First get the baby record that we are interested in.
    // --------------------------------------------------------
    new Baby().query()
      .where('id', babyId)
      .select(['lastname', 'firstname', 'middlename', 'sex', 'birthWeight', 'labor_id' ])
      .then(function(baby) {
        data.baby = baby[0];
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the birth certificate.
        // --------------------------------------------------------
        return new BirthCertificate().query()
          .where('baby_id', babyId)
          .select();
      })
      .then(function(birthCert) {
        data.bc = birthCert[0];
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the pregnancy.
        // --------------------------------------------------------
        return new Pregnancy().query()
          .join('labor', 'pregnancy.id', 'labor.pregnancy_id')
          .where('labor.id', '=', data.baby.labor_id)
          .select();
      })
      .then(function(preg) {
        data.preg = preg[0];
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the patient.
        // --------------------------------------------------------
        return new Patient().query()
          .where('patient.id', '=', data.preg.patient_id)
          .select();
      })
      .then(function(pat) {
        data.patient = pat[0];
      })
      .then(function() {
        // --------------------------------------------------------
        // Get the labor stage 2 record.
        // --------------------------------------------------------
        return new LaborStage2().query()
          .where('laborStage2.labor_id', '=', data.baby.labor_id)
          .select();
      })
      .then(function(ls2) {
        data.ls2 = ls2[0];
      })
      .then(function() {
        // --------------------------------------------------------
        // Convert null/undefined into empty strings for string fields.
        // --------------------------------------------------------
        // Baby
        fixNullUndefined(data.baby, ['firstname', 'middlename', 'lastname']);

        // Birth certificate
        fixNullUndefined(data.bc,
          [ 'birthOrder', 'motherMaidenLastname', 'motherMiddlename',
            'motherFirstname', 'motherCitizenship', 'motherAddress', 'motherCity',
            'motherProvince', 'motherCountry', 'fatherLastname', 'fatherMiddlename',
            'fatherFirstname', 'fatherCitizenship', 'fatherReligion',
            'fatherOccupation', 'fatherAddress', 'fatherCity', 'fatherProvince',
            'fatherCountry', 'cityOfMarriage', 'provinceOfMarriage',
            'countryOfMarriage', 'attendantOther', 'attendantFullname',
            'attendantTitle', 'attendantAddr1', 'attendantAddr2', 'informantFullname',
            'informantRelationToChild', 'informantAddress', 'preparedByFullname',
            'preparedByTitle', 'commTaxNumber', 'commTaxPlace', 'receivedByName',
            'receivedByTitle', 'affiateName', 'affiateAddress',
            'affiateCitizenshipCountry', 'affiateReason', 'affiateIAm',
            'affiateCommTaxNumber', 'affiateCommTaxPlace', 'comments'
          ]
        );

        // Pregnancy
        fixNullUndefined(data.preg, ['religion', 'work', 'lastname']);

        // Labor stage 2
        fixNullUndefined(data.ls2, ['birthType']);
      })
      .then(function() {
        resolve(data);
      })
      .caught(function(err) {
        logError(err);
        reject(err);
      });
  })
  .caught(function(err) {
    return err;
  });
};

/* --------------------------------------------------------
 * fixNullUndefined()
 *
 * Modifies the object passed according to the list of fields
 * passed and sets the field in the object to an empty string
 * if the field evaluates to null or undefined.
 *
 * param       obj
 * param       array of fields
 * return      undefined
 * -------------------------------------------------------- */
var fixNullUndefined = function(obj, flds) {
  _.each(flds, function(fld) {
    if (_.has(obj, fld) && (_.isNull(obj[fld]) || _.isUndefined(obj[fld]))) {
      obj[fld] = '';
    }
  });
};

/* --------------------------------------------------------
 * doReport()
 *
 * Create the birth certificate for the baby.
 *
 * param      babyId
 * param      top1
 * param      left1
 * param      top2
 * param      left2
 * param      printPaternity
 * param      printRegistration
 * param      writable
 * return     undefined
 * -------------------------------------------------------- */
var doReport = function doReport(babyId, top1, left1, top2, left2, printPaternity, printRegistration, writable) {
  var options = {
        bufferPages: true      // Allow writing to prior pages if desired.
        , layout: 'portrait'
        , size: 'legal'
        , info: {
            Title: 'Birth Certificate'
            , Author: 'Midwife-EMR Application'
            , Subject: 'Birth Certificate Report'
        }
      }
    , top1Pts = _.isNaN(Number.parseInt(top1))? 0: Number.parseInt(top1)
    , left1Pts = _.isNaN(Number.parseInt(left1))? 0: Number.parseInt(left1)
    , top2Pts = _.isNaN(Number.parseInt(top2))? 0: Number.parseInt(top2)
    , left2Pts = _.isNaN(Number.parseInt(left2))? 0: Number.parseInt(left2)
    , doc
    , opts = {}
    ;

  // --------------------------------------------------------
  // Setup our document.
  // The pre-printed Birth Certificate form is 527 points
  // wide and 930 points long leaving a margin all around of
  // 1/2 inch assuming that the pre-printed form is perfectly
  // centered. There are 72 points per inch, therefore the
  // sanity check below.
  // --------------------------------------------------------
  options.margins = {};
  options.margins.top = Math.abs(top1Pts + 36);
  options.margins.bottom = Math.abs(36 - top1Pts);
  options.margins.left = Math.abs(left1Pts + 36);
  options.margins.right = Math.abs(36 - left1Pts);

  options.margins2 = {};
  options.margins2.top = Math.abs(top2Pts + 36);
  options.margins2.bottom = Math.abs(36 - top2Pts);
  options.margins2.left = Math.abs(left2Pts + 36);
  options.margins2.right = Math.abs(36 - left2Pts);

  if (options.margins.top + options.margins.bottom !== 72) console.log('Warning: margin error top/bottom page one.');
  if (options.margins.left + options.margins.right !== 72) console.log('Warning: margin error left/right page one.');
  if (options.margins2.top + options.margins2.bottom !== 72) console.log('Warning: margin error top/bottom page two.');
  if (options.margins2.left + options.margins2.right !== 72) console.log('Warning: margin error left/right page two.');

  doc = new PDFDocument(options);

  opts.margins = options.margins;
  opts.margins2 = options.margins2;
  opts.pageWidth = doc.page.width;
  opts.pageHeight = doc.page.height;
  opts.size = options.size;
  opts.layout = options.layout;
  opts.info = options.info;

  // Optional sections of the birth certificate.
  opts.printPaternity = printPaternity;
  opts.printRegistration = printRegistration;

  currentPage = 0;   // Tracking what page we are printing to now, zero based.

  // --------------------------------------------------------
  // Write the report to the writable stream passed.
  // --------------------------------------------------------
  doc.pipe(writable);

  getData(babyId)
    .then(function(data) {
      doPages(doc, data, opts);
    })
    .then(function() {
      doc.end();
    });
};

var run = function run(req, res) {
  var babyId = req.params.babyId
    , top1 = req.params.top1
    , left1 = req.params.left1
    , top2 = req.params.top2
    , left2 = req.params.left2
    , printPaternity = req.params.paternity? req.params.paternity === 'Y': false
    , printRegistration = req.params.registration? req.params.registration === 'Y': false
    , filePath = path.join(cfg.site.tmpDir, 'rpt-' + (Math.random() * 9999999999) + '.pdf')
    , writable = fs.createWriteStream(filePath)
    , success = false
    , fieldsReady = true
    ;

  // --------------------------------------------------------
  // When the report is fully built, write it back to the caller.
  // --------------------------------------------------------
  writable.on('finish', function() {
    fs.stat(filePath, function(err, stats) {
      if (err) return logError(err);
      var size = stats.size;

      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', 'inline; BirthCertificate.pdf');
      res.setHeader('Content-Transfer-Encoding', 'binary');
      res.setHeader('Content-Length', ('' + size));
      fs.createReadStream(filePath).pipe(res);
      fs.unlink(filePath);
    });
  });

  doReport(babyId, top1, left1, top2, left2, printPaternity, printRegistration, writable);
};


module.exports = {
  run
};

