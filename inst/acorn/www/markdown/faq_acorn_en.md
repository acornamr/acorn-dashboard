### FAQ Content

- [Microbiology data](#h10)
  - [Deduplication of culture / bacterial isolate data](#h11)
  - [Antimicrobial resistance reporting](#h12)
  - [Blood culture contaminants](#h13)
  - [Target pathogens](#h14)
  - [Definition of Updated Charlson Comorbidity Index (uCCI)](#h15)
- [Data Processing](#h20)
  - [Enrolment/Error Log](#h21)
  - [Clinical and Lab data linkage](#h22)
- [Contact ACORN Team](#h30)
- [Acknowledgments and Credits](#h40)

### <a name="h10"></a> Microbiology data

#### <a name="h11"></a> ⚠️ Deduplication of culture / bacterial isolate data ⚠️

**By patient-episode.** This filter restricts to the first isolation of each species by specimen type and patient infection episode. For example, if E. coli was isolated from three blood cultures and one urine culture during a single CAI episode, the filter would select just the first blood culture isolate and the urine culture isolate.

**By patient ID.** This filter restricts to the first isolation of each species by patient, specimen type, and infection category (CAI or HAI). For example, if a patient was admitted two times during the surveillance period and had two episodes of community-acquired E. coli urosepsis (two E. coli urine cultures and one E. coli bacteraemia) and one hospital acquired E. coli bacteraemia secondary to a surgical complication, the filter would select just the earliest isolate from each specimen type and infection category (i.e. the E. coli from the first positive urine culture and the first positive blood culture [CAI] plus the E. coli from the first positive blood culture [HAI]).

#### <a name="h12"></a> ⚠️ Antimicrobial resistance reporting ⚠️

Class-level resistance to fluoroquinolones, 3rd generation cephalosporins, and carbapenems is calculated automatically for selected target organisms. Organism appropriate AST results are combined such that if any drug in the group is resistant, then the class is labelled resistant. Results of extended spectrum beta-lactamase and carbapenemase tests are included. For this calculation, the intermediate category is counted as susceptible, thus providing a conservative estimate of resistance. Where included in the laboratory testing repertoire and data file, results of beta-lactamase and inducible clindamycin testing are incorporated into reporting of beta-lactam (penicillin / ampicillin) and macrolide susceptibility results. Meningitis and non-meningitis breakpoints are reported separately for Streptococcus pneumoniae and penicillin, ceftriaxone, and cefotaxime.

#### <a name="h13"></a> ⚠️Blood culture contaminants ⚠️

It is possible to remove bacterial species which have a high probability of being a skin contaminant from the microbiology organism lists and tables. The following organism groups are considered contaminants: coagulase negative staphylococci, micrococci, Gram positive bacilli / diphtheroids. Blood cultures with of growth of >= 1 contaminant organism are labelled as contaminated, irrespective of growth of pathogens.

#### <a name="h14"></a> Target pathogens

ACORN will capture data on cultured organisms. However, specific surveillance targets are the blood culture relevant organism on WHO GLASS pathogen list (2021 update): *Acinetobacter* species, *Escherichia coli*, *Haemophilus influenzae*, *Klebsiella pneumoniae*, *Neisseria meningitidis*, *Pseudomonas aeruginosa*, *Salmonella enterica* (non-typhoidal and typhoidal), *Staphylococcus aureus*, *Streptococcus pneumoniae*.

#### <a name="h15"></a> Definition of Updated Charlson Comorbidity Index (uCCI)

In ACORN, the uCCI is calculated for adult patients (>= 18 y.o.) only.

Key reference: *Ternavasio-de la Vega HG et al (2018). The updated Charlson comorbidity index is a useful predictor of mortality in patients with Staphylococcus aureus bacteraemia. Epidemiology and Infection 146, 122–2130. https://doi.org/10.1017/S0950268818002480*


| Comorbid conditions                                                 | uCCI weights | ACORN comorbidity                         |
|---------------------------------------------------------------------|--------------|-------------------------------------------|
| Myocardial infarction                                               | 0            | NOT INCLUDED*                             |
| Congestive heart failure                                            | 2            | Congestive heart failure                  |
| Peripheral vascular disease                                         | 0            | NOT INCLUDED*                             |
| Cerebrovascular disease                                             | 0            | NOT INCLUDED*                             |
| Dementia                                                            | 2            | Dementia                                  |
| Chronic pulmonary disease                                           | 1            | Chronic pulmonary disease                 |
| Rheumatic disease                                                   | 1            | Connective tissue / rheumatologic disease |
| Peptic ulcer disease                                                | 0            | Peptic ulcer*                             |
| Mild liver disease                                                  | 2            | Mild liver disease                        |
| Diabetes without chronic complication                               | 0            | Diabetes*                                 |
| Diabetes with chronic complication                                  | 1            | Diabetes with end organ damage            |
| Hemiplegia or paraplegia                                            | 2            | Hemi- or paraplegia                       |
| Renal disease                                                       | 1            | Renal disease                             |
| Any malignancy without metastasis, including leukaemia and lymphoma | 2            | Cancer/leukaemia                          |
| Moderate or severe liver disease                                    | 4            | Moderate or severe liver disease          |
| Metastatic solid tumour                                             | 6            | Metastatic solid tumour                   |
| AIDS (excluded asymptomatic infection)                              | 4            | AIDS                                      |
| Maximum comorbidity score                                           | 24           |                                           |

</br>

Additional ACORN comorbidities, which were requested to be included by the WHO GLASS team as LMIC relevant, are not included as part of the uCCI: malaria, malnutrition, peptic ulcer\*, diabetes\*, tuberculosis, HIV on ART, HIV without ART (those marked with an \* were included in the original CCI).


### <a name="h20"></a> Data Processing

#### <a name="h21"></a> Enrolment/Error Log

The enrolment log provides a real-time summary of all patient enrolments and infection episodes.
The expected 28 day follow-up date is 28 days following the final enrolment date for the admission (i.e. if 3 enrolments / infection episodes in admission, the 28 day follow-up was 28 days after enrolment #3).
The second tab of the enrolment log Excel file contains a high-level summary of structural data errors, such as where an F02 (Infection episode form), F03 (Infection hospital outcome form), F04 (D28 form), or F05 (BSI episode form) cannot be linked to a F01 (Enrolment form). These errors can be further investigated by logging into the ACORN REDCap database and/or by discussion with the ACORN data manager.

#### <a name="h22"></a> Clinical and Lab data linkage

We describe below how routinely collected microbiology laboratory data is linked to clinical data in the app.

##### Assumptions

- Infection episodes can be uniquely identified by a patient ID (could be ACORN ID, patient ID, REDCap ID) and episode enrolment date (F02 `hpd_dmdtc`).
- The patient ID variable (`usubjid`) in ACORN2 REDCap form F01 is also represented in the local laboratory data file (either LIMS export or WHONET file: local variable mapped to the `patid` variable using the ACORN2 data dictionary).
- One specimen (identified by `specnum` in the laboratory data file – may have >1 row if multiple isolates (identified by `orgnum`)) should be associated with a single ACORN2 infection episode (identified by an instance of form F02).

##### Logic rules for the linkage

These are slightly different for CAI and HAI (F02 `ifd_surcate`).

**For CAI**, we wish to associate specimens that were collected (lab data file `specdate`) from within 2 days of the patient hospital admission date (F01 `hpd_adm_date`): i.e. admission date + / - 2 days.

- This is important since some specimens will be collected just before admission (i.e. from out-patient department / clinic) and the patient admitted once result is known or when a bed becomes available).
- Linkage is performed on clinical (`usubjid` and `hpd_adm_date`) to lab (`patid` and `specdate`).


**For HAI**, we wish to associate specimens that were collected in the 2 days following the infection onset date (F02 `hpd_onset_date`): i.e. infection onset date + 2 days. We assume that no relevant specimens will be collected before the patient begins to develop symptoms of the HAI.

- Linkage is performed on clinical (`usubjid` and `hpd_onset_date`) to lab (`patid` and `specdate`).

**Issues to consider:**

Most patients will have a single infection episode per admission, so will present no problems for linkage.

- Patients with well separated CAI and HAI during the same admission are also no problem: case {A} below.
- Patients with a CAI and a stated HAI onset of admission D2 would be a problem, but these should not happen in ACORN2 (HAI considered from D3 onwards – case {B} below).
- Potential problem: if a patient is discharged and then rapidly re-admitted (within 2 days), then infection specimen windows could overlap (case {C} below, but could also be HAI – CAI overlap).
- For these, the specimen is linked the first episode only (and the later linkage removed).

<img src= "images/linkage_cases.png" style="width: 100%"/>

### <a name="h30"></a> Contact ACORN Team

If you have questions about the project or the app, please [contact the ACORN team.](mailto:acorn@tropmedres.ac)

### <a name="h40"></a> Acknowledgments and Credits

App Development Team: [Olivier Celhay](https://olivier.celhay.net), [Paul Turner](mailto:Pault@tropmedres.ac). With contributions from Naomi Waithira, Prapass Wannapinij, Elizabeth Ashley, Rogier van Doorn. 

Software:

- R Core Team (2021). R: A language and environment for statistical computing. R Foundation for Statistical
  Computing, Vienna, Austria. URL https://www.R-project.org/.
- Winston Chang, Joe Cheng, JJ Allaire, Carson Sievert, Barret Schloerke, Yihui Xie, Jeff Allen, Jonathan McPherson,
  Alan Dipert and Barbara Borges (2021). shiny: Web Application Framework for R. R package version 1.6.0.
  https://CRAN.R-project.org/package=shiny
- Will Beasley (2020). REDCapR: Interaction Between R and REDCap. R package version 0.11.0.
  https://CRAN.R-project.org/package=REDCapR
