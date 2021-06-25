# How to read .acorn files in R

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