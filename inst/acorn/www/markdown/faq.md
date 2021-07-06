### Updated Charlson Comorbidity Index (uCCI)

In ACORN, the CCI is calculated for adult patients (>= 18 y.o.) only.

Key reference: *Ternavasio-de la Vega HG et al (2018). The updated Charlson comorbidity index is a useful predictor of mortality in patients with Staphylococcus aureus bacteraemia. Epidemiology and Infection 146, 122–2130. https://doi.org/10.1017/S0950268818002480*


| Comorbid conditions                                                 | uCCI weights | ACORN comorbidity                         |
|---------------------------------------------------------------------|--------------|-------------------------------------------|
| Myocardial infarction                                               | 0            | NOT INCLUDED                              |
| Congestive heart failure                                            | 2            | Congestive heart failure                  |
| Peripheral vascular disease                                         | 0            | NOT INCLUDED                              |
| Cerebrovascular disease                                             | 0            | NOT INCLUDED                              |
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

</br></br>

Additional ACORN comorbidities (these were requested to be included by WHO GLASS as LMIC relevant): should not be included as part of CCI

- Malaria
- Malnutrition
- Peptic Ulcer
- Diabetes
- Tuberculosis
- HIV on ART
- HIV without ART



### How to read .acorn files in R

.acorn files can be read and loaded in memory with the command `base::load`.

for example `load(file = "/Users/olivier/Desktop/KH001_2021-06-24_01H59.acorn")` loads the following R objects:

- `redcap_f01f05_dta`: one patient enrolment per row. patient_id is hashed.
- `redcap_hai_dta`: one survey element per row.
- `corresp_org_antibio`: matrix of antibiotics and bugs.
- `acorn_dta`: one isolate per row. Contains only isolates that can be linked to a patient enrolment in `redcap_f01f05_dta`. patient_id is hashed.
- `meta`: metadata collected on generation of the .acorn file.


With each file NAME.acorn, a NAME.acorn_non_anonymised is also created.

This NAME.acorn_non_anonymised can also be loaded with the same command `load(file = "NAME.acorn_non_anonymised")` (supposing the file is located in the current working directory).

The file contains the same objects as NAME.acorn, but with patient ids NOT hashed in `redcap_f01f05_dta` and `acorn_dta`. The file contains one element in addition:

- `lab_dta`: one row per isolate as per the lab file provided on generation of the .acorn file.


### How to modify ACORN Dashboard theme

Every site can customize the ACORN dashboard.

You can update ACORN logo by providing a logo (pgn format)

You can ask for changes in the theme by providing a list of values for variables:

- Base theme is flatly: https://bootswatch.com/flatly/; [CSS](https://bootswatch.com/4/flatly/bootstrap.css)
- List of BS4 variables: https://github.com/rstudio/bslib/blob/master/inst/lib/bs/scss/_variables.scss 

Please contact the ACORN team for more information.

### Clinical and Lab data linkage

TODD: complete using Paul 'ACORN2 Clinical and Laboratory data linkage.docx'




