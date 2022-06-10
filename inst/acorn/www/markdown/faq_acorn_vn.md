<div class = "alert alert-light">
Visit <a href='https://acornamr.net/' target='_blank'>https://acornamr.net/</a> to learn more about ACORN and <a href='https://twitter.com/ACORN_AMR' target='_blank'>Twitter for the latest developments.</a>
If you have questions about the project or the app, please <a href='mailto:acorn@tropmedres.ac'>contact the ACORN team.</a>
</div>

<div class = "alert alert-danger">
For more information on a specific element of the dashboard, refer to the <a href='https://acornamr.net/docs/ACORN2_dashboard_cheat_sheet.pdf' target='_blank'>ACORN Dashboard Cheat Sheet.</a>
</div>


## Dữ liệu vi sinh

### ⚠️ Sự trùng lặp dữ liệu nuôi cấy / phân lập vi khuẩn ⚠️

**Bởi đợt nhiễm trùng của bệnh nhân.** Bộ lọc này hạn chế sự phân lập đầu tiên của mỗi loài theo loại bệnh phẩm và đợt nhiễm trùng của bệnh nhân. Ví dụ: nếu E. coli được phân lập từ ba lần cấy máu và một lần cấy nước tiểu trong một đợt CAI, bộ lọc sẽ chỉ chọn mẫu phân lập nuôi cấy máu đầu tiên và mẫu phân lập nuôi cấy nước tiểu.

**Bởi ID bệnh nhân.** Bộ lọc này hạn chế sự phân lập đầu tiên của mỗi loài theo bệnh nhân, loại bệnh phẩm và loại nhiễm trùng (CAI hoặc HAI). Ví dụ, nếu một bệnh nhân nhập viện hai lần trong thời gian giám sát và có hai đợt nhiễm khuẩn E. coli mắc phải trong cộng đồng (hai lần cấy nước tiểu E. coli và một lần cấy vi khuẩn E. coli) và một lần nhiễm khuẩn bệnh viện E. coli thứ phát sau một biến chứng phẫu thuật, bộ lọc sẽ chỉ chọn dòng phân lập sớm nhất từ mỗi loại bệnh phẩm và loại nhiễm trùng (tức là E. coli từ mẫu cấy nước tiểu dương tính đầu tiên và mẫu cấy máu dương tính đầu tiên [CAI] cộng với E. coli từ mẫu cấy máu dương tính đầu tiên [HAI])

### ⚠️ Báo cáo kháng kháng sinh ⚠️

Mức độ kháng kháng sinh với fluoroquinolones,cephalosporins thế hệ 3, và carbapenems thì được tính toán tự động cho các tác nhân gây bệnh mục tiêu đã chọn. Kết quả kháng sinh đồ phù hợp với sinh vật được kết hợp sao cho nếu bất kỳ loại thuốc nào trong nhóm đó bị kháng, thì nhóm thuốc đó được xem như bị kháng. Kết quả của các xét nghiệm beta-lactamase và carbapenemase phổ mở rộng cũng sẽ được bao gồm.Phân loại độ nhạy cảm “intermediate” được tính là nhạy cảm (susceptible, do đó cung cấp một ước tính thận trọng về mức độ kháng thuốc. Nếu được đưa vào tệp dữ liệu và bản kiểm tra trong phòng thí nghiệm, kết quả của xét nghiệm beta-lactamase và clindamycin cảm ứng được đưa vào báo cáo về kết quả nhạy cảm với beta-lactam (penicillin / ampicillin) và macrolide. Các điểm đứt gãy do viêm màng não và không do viêm màng não được báo cáo riêng đối với Streptococcus pneumoniae và penicillin, ceftriaxone và cefotaxime.

### ⚠️ Tạp nhiễm trong cấy máu ⚠️

Có thể loại bỏ các loài vi khuẩn có nhiều khả năng là tạp nhiễm trên da khỏi danh sách và bảng vi sinh vật. Các nhóm sinh vật sau được coi là tạp nhiễm: tụ cầu âm tính coagulase, micrococci, trực khuẩn Gram dương / bạch hầu. Cấy máu có sự phát triển của> = 1 sinh vật tạp nhiễm được dán nhãn là bị tạp nhiễm, bất kể sự phát triển của mầm bệnh.

### Mầm bệnh mục tiêu

ACORN sẽ thu thập dữ liệu về sinh vật nuôi cấy. Tuy nhiên, các mục tiêu giám sát cụ thể là sinh vật liên quan đến nuôi cấy máu trong danh sách mầm bệnh của WHO GLASS (cập nhật năm 2021): *Acinetobacter* species, *Escherichia coli*, *Haemophilus influenzae*, *Klebsiella pneumoniae*, *Neisseria meningitidis*, *Pseudomonas aeruginosa*, *Salmonella enterica* (non-typhoidal and typhoidal), *Staphylococcus aureus*, *Streptococcus pneumoniae*.

## Quy trình dữ liệu

### Sổ thu tuyển/lỗi

Sổ thu tuyển cung cấp một bản tóm tắt thực tế về tất cả các trường hợp bệnh nhân được thu tuyển và các đợt nhiễm trùng.
Ngày 28 theo dõi là 28 ngày sau ngày thu tuyển cuối cùng cho đợt nhập viện (tức là nếu nhập viện 3 lần thu tuyển/ đợt nhiễm trùng, thì ngày 28 là 28 ngày sau ngày thu tuyển lần 3).
Tab thứ hai của file Sổ thu tuyển Excel chứa một bản tóm tắt về các lỗi dữ liệu cấu trúc, chẳng hạn như các phiếu F02 (Phiếu đợt nhiễm trùng), F03 (Phiếu kết quả ra viện), F04 (Phiếu ngày 28) hoặc F05 (Phiếu đợt nhiễm trùng máu BSI) không thể liên kết được với mẫu F01 (Phiếu thu tuyển). Những lỗi này có thể được tìm hiểu thêm bằng cách đăng nhập vào cơ sở dữ liệu ACORN REDCap và / hoặc bằng cách thảo luận với người quản lý dữ liệu ACORN.


### Kết nối dữ liệu lâm sàng và phòng xét nghiệm

Dưới đây chúng tôi mô tả cách dữ liệu phòng thí nghiệm vi sinh được thu thập thường xuyên được liên kết với dữ liệu lâm sàng trong ứng dụng.

#### Giả định

- Đợt nhiễm trùng có thể có thể được xác định duy nhất bằng ID bệnh nhân (có thể là ACORN ID, ID bệnh nhân, REDCap ID) và ngày thu tuyển đợt nhiễm trùng (F02 `hpd_dmdtc`).
- Biến ID bệnh nhân (`usubjid`) trong ACORN2 REDCap Phiếu F01 cũng được thể hiện trong tệp dữ liệu phòng thí nghiệm địa phương (tệp xuất LIMS hoặc tệp WHONET: biến địa phương được liên kết tới biến` patid` bằng từ điển dữ liệu ACORN2).
- Một mẫu bệnh phẩm (được xác định bởi `specnum` trong tệp dữ liệu phòng thí nghiệm - có thể có> 1 hàng nếu nhiều chủng phân lập (được xác định bởi` orgnum`)) phải được liên kết với một đợt nhiễm ACORN2 duy nhất (được xác định bằng một phiên bản của Phiếu F02).

#### Các quy tắc logic cho việc liên kết

Có sự khác biệt nhẹ giữa bệnh nhân CAI và HAI (F02 `ifd_surcate`).

**Đối với CAI**, chúng tôi mong muốn kết nối mẫu bệnh phẩm mà chúng tôi thu thập (file dữ liệu `specdate`) trong vòng 2 ngày kể từ ngày bệnh nhân nhập viện (F01 `hpd_adm_date`): ví dụ Ngày nhập viện + / - 2 ngày.

- Điều này rất quan trọng vì một số bệnh phẩm sẽ được thu thập ngay trước khi nhập viện (ví dụ từ khoa / phòng khám ngoại trú) và bệnh nhân được nhập viện sau khi biết kết quả hoặc khi có giường).
- Sự kết nối thì được thực hiện ở trên dữ liệu lâm sàng  (`usubjid` và `hpd_adm_date`) đến phòng xét nghiệm (`patid` và `specdate`).

**Với HAI**, chúng tôi muốn kết hợp các mẫu bệnh phẩm được thu thập trong 2 ngày sau ngày khởi phát nhiễm trùng (F02 `hpd_onset_date`): tức là ngày khởi phát nhiễm trùng + 2 ngày. Chúng tôi giả định rằng không có mẫu vật liên quan nào sẽ được thu thập trước khi bệnh nhân bắt đầu xuất hiện các triệu chứng của HAI.

- Liên kết được thực hiện trên lâm sàng (`usubjid` và` hpd_onset_date`) đến phòng thí nghiệm (`patid` và` specdate`).

** Các vấn đề cần xem xét:**

Hầu hết các bệnh nhân sẽ có một đợt nhiễm trùng duy nhất cho mỗi lần nhập viện, do đó sẽ không có vấn đề gì về liên kết.

- Bệnh nhân có CAI và HAI tách biệt rõ trong cùng một lần nhập viện cũng không có vấn đề gì: trường hợp {A} dưới đây.
- Bệnh nhân có CAI và HAI đã nêu khi bắt đầu nhập viện D2 sẽ là một vấn đề, nhưng những điều này sẽ không xảy ra trong ACORN2 (HAI được xem xét từ D3 trở đi - trường hợp {B} bên dưới).
- Vấn đề tiềm ẩn: nếu bệnh nhân được xuất viện và sau đó tái nhập viện nhanh chóng (trong vòng 2 ngày), thì các cửa sổ bệnh phẩm nhiễm trùng có thể chồng lên nhau (trường hợp {C} dưới đây, nhưng cũng có thể là trùng HAI - CAI).
- Đối với những thứ này, mẫu vật chỉ được liên kết ở tập đầu tiên (và liên kết sau đó bị loại bỏ).
<img src= "images/linkage_cases.png" style="width: 100%"/>

### Đọc .acorn files trên R

.acorn files có thể được đọc và tải lên trong bộ nhớ với lệnh `base::load`.

Ví dụ `load(file = "/Users/olivier/Desktop/KH001_2023-08-24_01H59.acorn")` tải lên các đối tượng R sau:

- `redcap_f01f05_dta`: một bệnh nhân thu tuyển mỗi dòng. patient_id thì được chia nhỏ (hash)
- `redcap_hai_dta`: một thành phần khảo sát trên mỗi hàng.
- `corresp_org_antibio`: ma trận kháng sinh và vi trùng theo 
- `acorn_dta`: một chủng phân lập 1 dòng. Chỉ chứa các chủng phân lập có thể được liên kết với một bệnh nhân thu tuyển trong `redcap_f01f05_dta`. patient_id is hashed.
- `data_dictionary`: tất cả dữ liệu file từ điển dữ liệu phòng thí nghiệm tại điểm nghiên cứu đã được sử dụng trong quá trình tạo tệp .acorn.
- `lab_code`: tất cả dữ liệu của tệp mã phòng thí nghiệm ACORN2 đã được sử dụng trong quá trình tạo tệp .acorn.
- `meta`: siêu dữ liệu (metadata) được thu thập khi tạo tệp .acorn.

Với mỗi file NAME.acorn, a NAME.acorn_non_anonymised cũng được tạo.

Tệp NAME.acorn_non_anonymised cũng có thể được tải lên với cùng lệnh `load(file = "NAME.acorn_non_anonymised")` (giả sử tệp nằm trong thư mục làm việc hiện tại).

Tệp chứa các đối tượng giống như NAME.acorn, nhưng ID của bệnh nhân thì KHÔNG hashed Ở `redcap_f01f05_dta` và `acorn_dta`. Ngoài ra, tệp còn chứa một phần tử:

- `lab_dta`: một hàng cho mỗi chủng phân lập theo tệp phòng thí nghiệm được cung cấp khi tạo .acorn file.

File non_anonmyised `.acorn` phải được xử lý cẩn thận và an toàn, vì chúng chứa mã nhận dạng của bệnh nhân: các tệp này có thể được các nghiên cứu viên ở điểm nghiên cứu sử dụng để liên kết dữ liệu / vi khuẩn phân lập với các dự án nghiên cứu bổ sung / hoạt động cải tiến chất lượng. Vui lòng liên hệ với nhóm ACORN để biết thêm thông tin.

## Quản lý Dashboard

### Sửa đổi chủ đề / ngôn ngữ Dashboard

Mỗi điểm nghiên cứu có thể cụ thể hóa ACORN dashboard.

Bạn có thể cập nhật logo ACORN bằng việc cung cấp một logo (pgn format)

Bạn có thể yêu cầu các thay đổi trong chủ đề bằng cách cung cấp danh sách các giá trị cho các biến:

- Chủ đề cơ sở thì bằng phẳng (flatly): https://bootswatch.com/flatly/; [CSS](https://bootswatch.com/4/flatly/bootstrap.css)
- Danh sách các biến BS4: https://github.com/rstudio/bslib/blob/master/inst/lib/bs/scss/_variables.scss 

Dashboard có thể được thực hiện bằng bất kỳ ngôn ngữ nào được cung cấp với các phần tử được dịch ở định dạng bảng. Vui lòng liên hệ với nhóm ACORN để biết thêm thông tin.

## Liên hệ ACORN Team

Nếu bạn có câu hỏi về dự án hoặc ứng dụng, vui lòng [liên hệ với nhóm ACORN.](mailto:acorn@tropmedres.ac)

## Acknowledgments và Credits

Ứng dụng Development Team: [Olivier Celhay](https://olivier.celhay.net), [Paul Turner](mailto:Pault@tropmedres.ac). With contributions from Naomi Waithira, Prapass Wannapinij, Elizabeth Ashley, Rogier van Doorn. 

Phần mềm:

- R Core Team (2021). R: Một ngôn ngữ và môi trường cho tính toán thống kê. R Foundation for Statistical
  Computing, Vienna, Austria. URL https://www.R-project.org/.
- Winston Chang, Joe Cheng, JJ Allaire, Carson Sievert, Barret Schloerke, Yihui Xie, Jeff Allen, Jonathan McPherson,
  Alan Dipert and Barbara Borges (2021). shiny: Web Application Framework for R. R package version 1.6.0.
  https://CRAN.R-project.org/package=shiny
- Will Beasley (2020). REDCapR: Interaction Between R and REDCap. R package version 0.11.0.
  https://CRAN.R-project.org/package=REDCapR
