<div class = "alert alert-light">
Visit <a href='https://acornamr.net/' target='_blank'>https://acornamr.net/</a> to learn more about ACORN and <a href='https://twitter.com/ACORN_AMR' target='_blank'>Twitter for the latest developments.</a>
If you have questions about the project or the app, please <a href='mailto:acorn@tropmedres.ac'>contact the ACORN team.</a>
</div>

<div class = "alert alert-danger">
For more information on a specific element of the dashboard, refer to the <a href='https://acornamr.net/pdf/ACORN2_dashboard_cheat_sheet.pdf' target='_blank'>ACORN Dashboard Cheat Sheet.</a>
</div>

- [Clinical data](#h00)
- [ទិន្ន័យមីក្រូជីវសាស្រ្ត](#h10)
  - [ការលុបទិន្ន័យដូចគ្នានៃការបណ្តុះមេរោគ ឬបាក់តេរី isolate](#h11)
  - [របាយការណ៍ភាពសុំារបស់ឱសថប្រឆាំងនឹងមេរោគ](#h12)
  - [ការបណ្តុះមេរោគក្នុងឈាមដែល contaminant](#h13)
  - [មេរោគគោលដៅ](#h14)
  - [Definition of Updated Charlson Comorbidity Index (uCCI)](#h15)
  - [AWaRe classification](#h16)
- [ដំណើរការទិន្នន័យ](#h20)
  - [បញ្ជីអ្នកចូលរួមអង្កេតតាមដាន/ បញ្ជីកំហុសឆ្គង](#h21)
  - [Clinical and Lab data linkage](#h22)
- [Miscellaneous](#h30)
  - [Save Plot as Image](#h31)
- [Acknowledgments and Credits](#h40)


### <a name="h00"></a> Clinical data

Healthcare associated infections (HCAI) are defined as a subset of CAI, where the patient was known to have had exposure to healthcare facilities in the three months prior to admission.

### <a name="h10"></a> ទិន្ន័យមីក្រូជីវសាស្រ្ត

#### <a name="h11"></a> ⚠️ ការលុបទិន្ន័យដូចគ្នានៃការបណ្តុះមេរោគ ឬបាក់តេរី isolate  ⚠️

<img src= "images/table_dedup_no_dedup.png" style="width: 80%"/>

**តាមវគ្គបង្ករោគរបស់អ្នកជំងឺ** ការកំណត់តម្រងនេះគឺ រឹតបន្តឹងទៅលើ isolate ទីមួយរបស់បាក់តេរីនីមួយៗទៅតាមប្រភេទនៃវត្ថុវិភាគ និងវគ្គបង្ករោគរបស់អ្នកជំងឺ។ ឧទាហរណ៍ ប្រសិនបើ E. coli ត្រូវបាន isolate ពីការបណ្តុះមេរោគក្នុងឈាមបីដង និងការបណ្តុះមេរោគក្នុងទឹកនោមមួយដងអំឡុងពេលបង្ករោគដែលមានប្រភពពីសហគមន៍មួយ ការកំណត់តម្រងនេះ គឺជ្រើសយកតែ isolate លើកទីមួយពីការបណ្តុះមេរោគក្នុងឈាម និង isolate ពីការបណ្តុះមេរោគក្នុងទឹកនោម តែប៉ុណ្ណោះ។

<img src= "images/table_dedup_patient_episode.png" style="width: 80%"/>

**តាមអត្តសញ្ញាណរបស់អ្នកជំងឺ** ការកំណត់តម្រងនេះគឺ រឹតបន្តឹងទៅលើ isolation ទីមួយរបស់បាក់តេរីនីមួយៗទៅតាម អ្នកជំងឺ ប្រភេទនៃវត្ថុវិភាគ និងប្រភេទនៃការបង្ករោគ (ការបង្ករោគដែលមានប្រភពពីសហគមន៍ ឬការបង្ករោគដែលមានប្រភពពីមន្ទីពេទ្យ) ។ ឧទាហរណ៍ ប្រសិនអ្នកជំងឺម្នាក់ត្រូវបានចូលសម្រាកនៅមន្ទីពេទ្យពីរដងអំឡុងពេលការអង្កេតតាមដាន ហើយមានការបង្ករោគដោយ E. coli urosepsis មានចំនួនពីរវគ្គដែលមានប្រភពពីសហគមន៍ (មេរោគ E. coli ដុះ ២ ដងក្នុងការបណ្តុំមេរោគក្នុងទឹកនោម និង E. coli ដុះក្នុងឈាមមួយ) ហើយមានការបង្ករោគ E. coli bacteraemia ដែលមានប្រភពពីមន្ទីពេទ្យតាមរយ:មុខរបួសវះកាត់នោះ ការកំណត់តម្រងនឹងត្រូវជ្រើសយក isolate ដំបូងរបស់ប្រភេទនៃវត្ថុវិភាគនីមួយៗ និងប្រភេទនៃការបង្ករោគ (ឧទាហរណ៍ E. coli ដែលបានដុះពីការបណ្តុះមេរោគក្នុងទឹកនោមដំបូង និងការដុះមេរោគពីការបណ្តុះមេរោគក្នុងឈាម [CAI] ដំបូង ហើយក៏ដូចជាការដុះមេរោគពីការបណ្តុះមេរោគក្នុងឈាម [HAI])។ 

<img src= "images/table_dedup_patient_id.png" style="width: 80%"/>

#### <a name="h12"></a> ⚠️ របាយការណ៍ភាពសុំារបស់ឱសថប្រឆាំងនឹងមេរោគ  ⚠️

កម្រិតថ្នាក់នៃភាពសុំាទៅនឹង fluoroquinolones,  cephalosporins ជំនាន់ទី៣ និង carbapenem គឺត្រូវបានគណនាដោយស្វ័យប្រវត្តិសម្រាប់មេរោគគោលដៅដែលបានជ្រើសរើស។ លទ្ធផល AST ដែលសមស្របរបស់មេរោគគឺត្រូវបានរួមបញ្ចូលគ្នា ដូច្នេះប្រសិនបើថ្នាំណាមួយក្នុងក្រុមសុំានោះ គេចាត់ថ្នាក់ដាក់ស្លាកថាសុំា។ លទ្ធផលនៃការធ្វើតេស្ត  extended spectrum beta-lactamase និង carbapenemase គឺត្រូវបានដាក់បញ្ចូល។ សម្រាប់ការគណនាមួយនេះ ប្រភេទ intermediate គឺត្រូវបានចាត់ទុកថា susceptible  ដូច្នេះ ផ្តល់នូវការបាន់ប្រមាណបែបអភិរក្សទៅលើភាពសុំា។ លទ្ធផលនៃការធ្វើតេស្តរបស់ lactamase និង inducible clindamycin គឺត្រូវបានដាក់រួមបញ្ចូលក្នុងការរាយការណ៍អំពី beta-lactam (penicillin / ampicillin) និងលទ្ធផល macrolide susceptibility ដែលនិងត្រូវបញ្ជូលការគ្នាក្នុងឯកសារតេស្តមន្ទីរពិសោធន៍  និងទិន្នន័យ។ Meningitis and non-meningitis breakpoint ត្រូវបានរាយកាណ៍ដោយឡែកពីគ្នាសម្រាប់ Streptococcus pneumoniae និង penicillin, ceftriaxone, និង cefotaxime។

#### <a name="h13"></a> ⚠️ ការបណ្តុះមេរោគក្នុងឈាមដែល contaminant ⚠️

យើងអាចលុបចោលប្រភេទមេរោគដែលមានភាគរយខ្ពស់ដែលរស់នៅលើស្បែក ពីតារាងនិងបញ្ជីឈ្មោះរបស់មេរោគមីក្រូជីវសាស្ត្រ។ ក្រុមមេរោគដែលគេសន្មត់ថា contaminants មានដូចជា: coagulase negative staphylococci, micrococci, Gram positive bacilli / diphtheroids។ ការបណ្តុះមេរោគក្នុងឈាមដែលមានការដុះមេរោគដែល contaminant >= ១ គឺត្រូវបានចាត់ទុកថា contaminant ដោយមិនគិតថាវាជាមេរោគដែលបង្កជំងឺនោះឡើយ។

#### <a name="h14"></a> មេរោគគោលដៅ

ACORN នឹងចាប់យកទិន្នន័យមេរោគដែលបានមកពីការបណ្តុះមេរោគ។ យ៉ាងណាមិញ ការអង្កេតតាមដានមានគោលដៅជាក់លាក់លើប្រភេទមេរោគដែលបានមកពីការបណ្តុះមេរោគក្នុងបញ្ជីឈ្មោះមេរោគរបស់ WHO GLASS (ដែលធ្វើបច្ចុប្បន្នភាពនៅឆ្នាំ២០២១) ដូចជា: *Acinetobacter* species, *Escherichia coli*, *Haemophilus influenzae*, *Klebsiella pneumoniae*, *Neisseria meningitidis*, *Pseudomonas aeruginosa*, *Salmonella enterica* (non-typhoidal and typhoidal), *Staphylococcus aureus*, *Streptococcus pneumoniae*.

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

#### <a name="h16"></a> AWaRe classification

The "Empiric Antibiotic Testing" plot of the "Overview" tab is colored based on the <a href="https://www.who.int/publications/i/item/WHOEMPIAU2019.11" target="_blank">2019 WHO AWaRe classification of antibiotics for evaluation and monitoring of use.</a> 

### <a name="h20"></a> ដំណើរការទិន្នន័យ

#### <a name="h21"></a> បញ្ជីអ្នកចូលរួមអង្កេតតាមដាន/ បញ្ជីកំហុសឆ្គង

បញ្ជីអ្នកចូលរួមអង្កេតតាមដាន គឺបានសង្ខេបគ្រប់អ្នកជំងឺដែលចូលរួមអង្កេតតាមដាន និងវគ្គ ការបង្ករោគ។ 
ថ្ងៃ២៨ដែលបានរំពឹងទុកសម្រាប់ការតាមដានបន្ត គឺជាថ្ងៃទី២៨ ដែលរាប់ចាប់ពីថ្ងៃចុះឈ្មោះចូលរួមការអង្កេតតាមដាន (ឧទាហរណ៍ ប្រសិនបើការចូលរួមអង្កេតតាមដាន / វគ្គបង្ករោគក្នុងពេលសម្រាកព្យាបាលចំនួន៣ដង ការតាមដានបន្តថ្ងៃទី២៨  គឺជាថ្ងៃទី២៨បន្ទាប់ពីការចូលរួមអង្កេតតាមដានលើកទី៣។ 
ផ្ទាំងទីពីរនៃសុំណុំឯកសារ Excel របស់បញ្ជីអ្នកចូលរួមអង្កេតតាមដានមានផ្ទុកនៅសេចក្តីសង្ខេបកម្រិតខ្ពស់នៃរចនាសម្ព័ន្ធទិន្នន័យដែលមានកំហុសឆ្គងដូចជា នៅពេលដែល F02 (ទម្រង់វគ្គបង្ករោគ) F03 (ទម្រង់លទ្ធផលនៃការបង្ករោគ) F04 (ទម្រង់ស្ថានភាព២៨ថ្ងៃ) ឬ F05 (ទម្រង់ការដុះមេរោគក្នុងឈាម) មិនអាចភ្ជាប់ជាមួយ F01 (ទម្រង់នៃការចូលរួមអង្កេតតាមដាន)។ កំហុសឆ្គងទាំងនេះគឺអាចពិនិត្យមើលបន្ថែមដោយចូលទៅក្នុងទិន្នន័យរបស់ ACORN REDCap និង / ឬ ដោយការពិភាក្សារជាមួយអ្នកគ្រប់គ្រងទិន្នន័យ ACORN។

#### <a name="h22"></a> Clinical and Lab data linkage

We describe below how routinely collected microbiology laboratory data is linked to clinical data in the app.

##### Assumptions

- Infection episodes can be uniquely identified by a patient ID (could be ACORN ID, patient ID, REDCap ID) and episode enrolment date (F02 `hpd_dmdtc`).
- The patient ID variable (`usubjid`) in ACORN2 REDCap form F01 is also represented in the local laboratory data file (either LIMS export or WHONET file: local variable mapped to the `patid` variable using the ACORN2 data dictionary).
- One specimen (identified by `specnum` in the laboratory data file – may have >1 row if multiple isolates (identified by `orgnum`)) should be associated with a single ACORN2 infection episode (identified by an instance of form F02).

##### Logic rules for the linkage

These are slightly different for HCAI/CAI and HAI (F02 `ifd_surcate`).

**For HCAI/CAI**, we wish to associate specimens that were collected (lab data file `specdate`) from within 2 days of the patient hospital admission date (F01 `hpd_adm_date`): i.e. admission date + / - 2 days.

- This is important since some specimens will be collected just before admission (i.e. from out-patient department / clinic) and the patient admitted once result is known or when a bed becomes available).
- Linkage is performed on clinical (`usubjid` and `hpd_adm_date`) to lab (`patid` and `specdate`).


**For HAI**, we wish to associate specimens that were collected in the 2 days following the infection onset date (F02 `hpd_onset_date`): i.e. infection onset date + 2 days. We assume that no relevant specimens will be collected before the patient begins to develop symptoms of the HAI.

- Linkage is performed on clinical (`usubjid` and `hpd_onset_date`) to lab (`patid` and `specdate`).

**Issues to consider:**

Most patients will have a single infection episode per admission, so will present no problems for linkage.

- Patients with well separated HCAI/CAI and HAI during the same admission are also no problem: case {A} below.
- Patients with a HCAI/CAI and a stated HAI onset of admission D2 would be a problem, but these should not happen in ACORN2 (HAI considered from D3 onwards – case {B} below).
- Potential problem: if a patient is discharged and then rapidly re-admitted (within 2 days), then infection specimen windows could overlap (case {C} below, but could also be HAI – HCAI/CAI overlap).
- For these, the specimen is linked the first episode only (and the later linkage removed).

<img src= "images/linkage_cases.png" style="width: 100%"/>

### <a name="h30"></a> Miscellaneous

####  <a name="h31"></a> Save Plot as Image

<img src= "images/save_plot_image.gif" style="width: 80%"/>

### <a name="h40"></a> Acknowledgments and Credits

App Development Team: <a href="https://olivier.celhay.net" target="_blank">Olivier Celhay</a>, [Paul Turner](mailto:Pault@tropmedres.ac). With contributions from Naomi Waithira, Prapass Wannapinij, Elizabeth Ashley, Rogier van Doorn. 

Software:

- R Core Team (2021). R: A language and environment for statistical computing. R Foundation for Statistical
  Computing, Vienna, Austria. URL https://www.R-project.org/.
- Winston Chang, Joe Cheng, JJ Allaire, Carson Sievert, Barret Schloerke, Yihui Xie, Jeff Allen, Jonathan McPherson,
  Alan Dipert and Barbara Borges (2021). shiny: Web Application Framework for R. R package version 1.6.0.
  https://CRAN.R-project.org/package=shiny
- Will Beasley (2020). REDCapR: Interaction Between R and REDCap. R package version 0.11.0.
  https://CRAN.R-project.org/package=REDCapR
