# GEPD Data Production Template

 An easy to use work flow for going from raw Global Education Policy Dashboard (GEPD) data to a set of key microdata files and indicators.


## License

The files are licensed under a [Creative Commons/CC-BY-4.0 license](https://creativecommons.org/licenses/by/4.0/). 

You are free to:

Share — copy and redistribute the material in any medium or format for any purpose, even commercially.
Adapt — remix, transform, and build upon the material for any purpose, even commercially.

The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:

Attribution - You must give appropriate credit , provide a link to the license, and indicate if changes were made . You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.

No additional restrictions - You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.

## Weights

Each file from the school survey (school.dta, teachers.dta, fourth_grade_assessment.dta, and first_grade_assessment.dta) contains a set of weights to make statistics nationally representative.

Stratified random sampling was done, where schools were selected in strata with probability proportional to size.

A column named `strata` can be found in the data identifying the strata from which the school came.

Means can be estimated by appropriately applying weights.  Examples are shown below at the school, teacher, and student levels.

School Example:

```
svyset school_code, strata($strata) singleunit(scaled) weight(school_weight)
svy: mean inputs
```

Teacher Content Knowledge Example:

```
svyset school_code, strata($strata) singleunit(scaled) weight(school_weight)   || unique_teach_id, weight(teacher_content_weight)
svy: mean content_proficiency
```

Teacher Absence Example:

```
svyset school_code, strata($strata) singleunit(scaled) weight(school_weight)   || unique_teach_id, weight(teacher_abs_weight)
svy: mean absence_rate
```

Teacher Questionnaire Example:


svyset school_code, strata($strata) singleunit(scaled) weight(school_weight)   || unique_teach_id, weight(teacher_questionnaire_weight)
svy: mean intrinsic_motivation acceptable_absent students_deserve_attention growth_mindset motivation_teaching motivation_teaching_1
```

Fourth Grade Example:

```
svyset school_code, strata($strata) singleunit(scaled) weight(school_weight)   || fourth_grade_assessment__id, weight(g4_stud_weight_component)
foreach var in student_knowledge student_proficient {
svy: mean `var'
}
```

First Grade Example:

```
svyset school_code, strata($strata) singleunit(scaled) weight(school_weight)   || ecd_assessment__id, weight(g1_stud_weight_component)
svy: mean ecd_student_proficiency

```

## Organization

The template is organized into four main folders: 

1. `01_GEPD_raw_data` contains the raw data files downloaded from your GEPD Survey Solutions Server.  This folder contains three subfolders: a `School` folder for school data, a `Public_Officials` folder for data from the Survey of Public Officials, and an `Expert_Survey` folder for data from the Expert Policy Survey.  

2. `02_programs` contains the scripts that will be used to clean and process the raw data. There are separate sub-folders for each of the three data sources: `School`, `Public_Officials`, and `Expert_Survey`. 

3. `03_GEPD_anonymized_data` contains the cleaned and anonymized data files. There are separate sub-folders for each of the three data sources: `School`, `Public_Officials`, and `Expert_Survey`.   

4. `04_GEPD_Indicators` contains the set of final GEPD indicators

## Instructions

Clone this repository and save locally to your computer.

1. Download the raw data files from your GEPD Survey Solutions Server and place them in the `01_GEPD_raw_data` folder.

2. Run the `profile_GEPD.do` script.  This script will establish your directory paths and define a few important globals used throughout the scripts.

3. Run the `run_GEPD.do` script. This will clean the raw data files and save the cleaned data files in the `03_GEPD_anonymized_data` folder.


Do not, under any circumstances, push the raw data files to github.  The raw data files will contain personally identifiable information, and should not be stored in a public location such as github.

## Data Requirements

The scripts are setup to run the data files produced using the GEPD questionnaires programmed on Survey Solutions. 

### School Survey

 It is expected that the following data files will be present in the `01_GEPD_raw_data/School` folder in Stata format:

| ID | Name |
| --- | --- |
| F1 | EPDash.dta |
| F2 | questionnaire_roster.dta |
| F3 | teacher_assessment_answers.dta |
| F4 | TEACHERS.dta |
| F5 | etri_roster.dta |
| F6 | ecd_assessment.dta |
| F7 | fourth_grade_assessment.dta |
| F8 | random_list.dta |
| F9 | before_after_closure.dta |
| F10 | climatebeliefs.dta |
| F11 | teacherimpact.dta |
| F12 | direct_instruction_etri.dta |
| F13 | planning_lesson_etri.dta |
| F14 | ability_to_use_etri.dta |
| F15 | digital_use_inschool_etri.dta |
| F16 | use_outsideschool_etri.dta |
| F17 | proficiency_ict_etri.dta |
| F18 | schoolcovid_roster.dta |

## Survey of Public Officials

| ID | Name |
| --- | --- |
| F1 | public_officials.dta |

## Codebook

Below are column names and descriptions for variables found in the input GEPD data.

#### School Data Codebook

| Name | File |  Type | Label |
|  --- | --- | --- | --- |
|  interview__id | F1 | discrete | Unique 32-character long identifier of the interview |
|  interview__key | F1 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  assignment__id | F1 | discrete | Assignment id (identifier in numeric format) |
|  sssys_irnd | F1 | discrete | Random number in the range 0..1 associated with interview |
|  has__errors | F1 | discrete | Errors count in the interview |
|  interview__status | F1 | discrete | Status of the interview |
|  school_name_preload | F1 | discrete | school_name_preload |
|  school_address_preload | F1 | discrete | school_address_preload |
|  school_province_preload | F1 | discrete | school_province_preload |
|  school_district_preload | F1 | discrete | school_district_preload |
|  school_code_preload | F1 | discrete | school_code_preload |
|  school_emis_preload | F1 | discrete | school_emis_preload |
|  enumerators_preload__0 | F1 | discrete | Preloaded Enumerators:0 |
|  enumerators_preload__1 | F1 | discrete | Preloaded Enumerators:1 |
|  enumerators_preload__2 | F1 | discrete | Preloaded Enumerators:2 |
|  enumerators_preload__3 | F1 | discrete | Preloaded Enumerators:3 |
|  enumerators_preload__4 | F1 | discrete | Preloaded Enumerators:4 |
|  enumerators_preload__5 | F1 | discrete | Preloaded Enumerators:5 |
|  enumerators_preload__6 | F1 | discrete | Preloaded Enumerators:6 |
|  enumerators_preload__7 | F1 | discrete | Preloaded Enumerators:7 |
|  enumerators_preload__8 | F1 | discrete | Preloaded Enumerators:8 |
|  enumerators_preload__9 | F1 | discrete | Preloaded Enumerators:9 |
|  enumerators_preload__10 | F1 | discrete | Preloaded Enumerators:10 |
|  enumerators_preload__11 | F1 | discrete | Preloaded Enumerators:11 |
|  enumerators_preload__12 | F1 | discrete | Preloaded Enumerators:12 |
|  enumerators_preload__13 | F1 | discrete | Preloaded Enumerators:13 |
|  enumerators_preload__14 | F1 | discrete | Preloaded Enumerators:14 |
|  enumerators_preload__15 | F1 | discrete | Preloaded Enumerators:15 |
|  enumerators_preload__16 | F1 | discrete | Preloaded Enumerators:16 |
|  enumerators_preload__17 | F1 | discrete | Preloaded Enumerators:17 |
|  enumerators_preload__18 | F1 | discrete | Preloaded Enumerators:18 |
|  enumerators_preload__19 | F1 | discrete | Preloaded Enumerators:19 |
|  enumerators_preload__20 | F1 | discrete | Preloaded Enumerators:20 |
|  enumerators_preload__21 | F1 | discrete | Preloaded Enumerators:21 |
|  enumerators_preload__22 | F1 | discrete | Preloaded Enumerators:22 |
|  enumerators_preload__23 | F1 | discrete | Preloaded Enumerators:23 |
|  enumerators_preload__24 | F1 | discrete | Preloaded Enumerators:24 |
|  enumerators_preload__25 | F1 | discrete | Preloaded Enumerators:25 |
|  enumerators_preload__26 | F1 | discrete | Preloaded Enumerators:26 |
|  enumerators_preload__27 | F1 | discrete | Preloaded Enumerators:27 |
|  enumerators_preload__28 | F1 | discrete | Preloaded Enumerators:28 |
|  enumerators_preload__29 | F1 | discrete | Preloaded Enumerators:29 |
|  enumerators_preload__30 | F1 | discrete | Preloaded Enumerators:30 |
|  enumerators_preload__31 | F1 | discrete | Preloaded Enumerators:31 |
|  enumerators_preload__32 | F1 | discrete | Preloaded Enumerators:32 |
|  enumerators_preload__33 | F1 | discrete | Preloaded Enumerators:33 |
|  enumerators_preload__34 | F1 | discrete | Preloaded Enumerators:34 |
|  enumerators_preload__35 | F1 | discrete | Preloaded Enumerators:35 |
|  enumerators_preload__36 | F1 | discrete | Preloaded Enumerators:36 |
|  enumerators_preload__37 | F1 | discrete | Preloaded Enumerators:37 |
|  enumerators_preload__38 | F1 | discrete | Preloaded Enumerators:38 |
|  enumerators_preload__39 | F1 | discrete | Preloaded Enumerators:39 |
|  enumerators_preload__40 | F1 | discrete | Preloaded Enumerators:40 |
|  enumerators_preload__41 | F1 | discrete | Preloaded Enumerators:41 |
|  enumerators_preload__42 | F1 | discrete | Preloaded Enumerators:42 |
|  enumerators_preload__43 | F1 | discrete | Preloaded Enumerators:43 |
|  enumerators_preload__44 | F1 | discrete | Preloaded Enumerators:44 |
|  enumerators_preload__45 | F1 | discrete | Preloaded Enumerators:45 |
|  enumerators_preload__46 | F1 | discrete | Preloaded Enumerators:46 |
|  enumerators_preload__47 | F1 | discrete | Preloaded Enumerators:47 |
|  enumerators_preload__48 | F1 | discrete | Preloaded Enumerators:48 |
|  enumerators_preload__49 | F1 | discrete | Preloaded Enumerators:49 |
|  enumerators_preload__50 | F1 | discrete | Preloaded Enumerators:50 |
|  enumerators_preload__51 | F1 | discrete | Preloaded Enumerators:51 |
|  enumerators_preload__52 | F1 | discrete | Preloaded Enumerators:52 |
|  enumerators_preload__53 | F1 | discrete | Preloaded Enumerators:53 |
|  enumerators_preload__54 | F1 | discrete | Preloaded Enumerators:54 |
|  enumerators_preload__55 | F1 | discrete | Preloaded Enumerators:55 |
|  enumerators_preload__56 | F1 | discrete | Preloaded Enumerators:56 |
|  enumerators_preload__57 | F1 | discrete | Preloaded Enumerators:57 |
|  enumerators_preload__58 | F1 | discrete | Preloaded Enumerators:58 |
|  enumerators_preload__59 | F1 | discrete | Preloaded Enumerators:59 |
|  enumerators_preload__60 | F1 | discrete | Preloaded Enumerators:60 |
|  enumerators_preload__61 | F1 | discrete | Preloaded Enumerators:61 |
|  enumerators_preload__62 | F1 | discrete | Preloaded Enumerators:62 |
|  enumerators_preload__63 | F1 | discrete | Preloaded Enumerators:63 |
|  enumerators_preload__64 | F1 | discrete | Preloaded Enumerators:64 |
|  enumerators_preload__65 | F1 | discrete | Preloaded Enumerators:65 |
|  enumerators_preload__66 | F1 | discrete | Preloaded Enumerators:66 |
|  enumerators_preload__67 | F1 | discrete | Preloaded Enumerators:67 |
|  enumerators_preload__68 | F1 | discrete | Preloaded Enumerators:68 |
|  enumerators_preload__69 | F1 | discrete | Preloaded Enumerators:69 |
|  enumerators_preload__70 | F1 | discrete | Preloaded Enumerators:70 |
|  enumerators_preload__71 | F1 | discrete | Preloaded Enumerators:71 |
|  enumerators_preload__72 | F1 | discrete | Preloaded Enumerators:72 |
|  enumerators_preload__73 | F1 | discrete | Preloaded Enumerators:73 |
|  enumerators_preload__74 | F1 | discrete | Preloaded Enumerators:74 |
|  enumerators_preload__75 | F1 | discrete | Preloaded Enumerators:75 |
|  enumerators_preload__76 | F1 | discrete | Preloaded Enumerators:76 |
|  enumerators_preload__77 | F1 | discrete | Preloaded Enumerators:77 |
|  enumerators_preload__78 | F1 | discrete | Preloaded Enumerators:78 |
|  enumerators_preload__79 | F1 | discrete | Preloaded Enumerators:79 |
|  enumerators_preload__80 | F1 | discrete | Preloaded Enumerators:80 |
|  enumerators_preload__81 | F1 | discrete | Preloaded Enumerators:81 |
|  enumerators_preload__82 | F1 | discrete | Preloaded Enumerators:82 |
|  enumerators_preload__83 | F1 | discrete | Preloaded Enumerators:83 |
|  enumerators_preload__84 | F1 | discrete | Preloaded Enumerators:84 |
|  enumerators_preload__85 | F1 | discrete | Preloaded Enumerators:85 |
|  enumerators_preload__86 | F1 | discrete | Preloaded Enumerators:86 |
|  enumerators_preload__87 | F1 | discrete | Preloaded Enumerators:87 |
|  enumerators_preload__88 | F1 | discrete | Preloaded Enumerators:88 |
|  enumerators_preload__89 | F1 | discrete | Preloaded Enumerators:89 |
|  enumerators_preload__90 | F1 | discrete | Preloaded Enumerators:90 |
|  enumerators_preload__91 | F1 | discrete | Preloaded Enumerators:91 |
|  enumerators_preload__92 | F1 | discrete | Preloaded Enumerators:92 |
|  enumerators_preload__93 | F1 | discrete | Preloaded Enumerators:93 |
|  enumerators_preload__94 | F1 | discrete | Preloaded Enumerators:94 |
|  enumerators_preload__95 | F1 | discrete | Preloaded Enumerators:95 |
|  enumerators_preload__96 | F1 | discrete | Preloaded Enumerators:96 |
|  enumerators_preload__97 | F1 | discrete | Preloaded Enumerators:97 |
|  enumerators_preload__98 | F1 | discrete | Preloaded Enumerators:98 |
|  enumerators_preload__99 | F1 | discrete | Preloaded Enumerators:99 |
|  m1s0q1_name | F1 | discrete | Enumerator Name |
|  m1s0q1_name_other | F1 | discrete | Enumerator Name |
|  m1s0q1_comments | F1 | discrete | Enumerator Comments |
|  school_info_correct | F1 | discrete | Is the school information displayed correct? |
|  m1s0q2_name | F1 | discrete | Please enter the School Name |
|  m1s0q2_code | F1 | discrete | Please enter the Survey Code |
|  m1s0q2_emis | F1 | discrete | Please enter the EMIS Code/School Number |
|  m1s0q1 | F1 | discrete | Is School Open |
|  m1s0q8 | F1 | discrete | current time |
|  m1s0q9__Latitude | F1 | contin | Current Location: Latitude |
|  m1s0q9__Longitude | F1 | contin | Current Location: Longitude |
|  m1s0q9__Accuracy | F1 | contin | Current Location: Accuracy |
|  m1s0q9__Altitude | F1 | contin | Current Location: Altitude |
|  m1s0q9__Timestamp | F1 | contin | Current Location: Timestamp |
|  modules__2 | F1 | discrete | Which modules will you be completing in this school?:Module 1 - Rosters |
|  modules__1 | F1 | discrete | Which modules will you be completing in this school?:Module 2 - (Principal) School Information |
|  modules__7 | F1 | discrete | Which modules will you be completing in this school?:Module 3 - (Principal) School Management |
|  modules__3 | F1 | discrete | Which modules will you be completing in this school?:Module 4 - Teacher Questionnaire |
|  modules__5 | F1 | discrete | Which modules will you be completing in this school?:Module 5 - Teacher Assessment |
|  modules__6 | F1 | discrete | Which modules will you be completing in this school?:Module 6 - Early Childhood Direct Assessment (Grade 1) |
|  modules__4 | F1 | discrete | Which modules will you be completing in this school?:Module 7 - 4th Grade Classroom Observation |
|  modules__8 | F1 | discrete | Which modules will you be completing in this school?:Module 8 - 4th Grade Student Assessment |
|  m2saq1 | F1 | contin | How many teachers (permanent or privately/locally recruited) work in this school |
|  m2saq2__0 | F1 | discrete | teacher list:0 |
|  m2saq2__1 | F1 | discrete | teacher list:1 |
|  m2saq2__2 | F1 | discrete | teacher list:2 |
|  m2saq2__3 | F1 | discrete | teacher list:3 |
|  m2saq2__4 | F1 | discrete | teacher list:4 |
|  m2saq2__5 | F1 | discrete | teacher list:5 |
|  m2saq2__6 | F1 | discrete | teacher list:6 |
|  m2saq2__7 | F1 | discrete | teacher list:7 |
|  m2saq2__8 | F1 | discrete | teacher list:8 |
|  m2saq2__9 | F1 | discrete | teacher list:9 |
|  m2saq2__10 | F1 | discrete | teacher list:10 |
|  m2saq2__11 | F1 | discrete | teacher list:11 |
|  m2saq2__12 | F1 | discrete | teacher list:12 |
|  m2saq2__13 | F1 | discrete | teacher list:13 |
|  m2saq2__14 | F1 | discrete | teacher list:14 |
|  m2saq2__15 | F1 | discrete | teacher list:15 |
|  m2saq2__16 | F1 | discrete | teacher list:16 |
|  m2saq2__17 | F1 | discrete | teacher list:17 |
|  m2saq2__18 | F1 | discrete | teacher list:18 |
|  m2saq2__19 | F1 | discrete | teacher list:19 |
|  m2saq2__20 | F1 | discrete | teacher list:20 |
|  m2saq2__21 | F1 | discrete | teacher list:21 |
|  m2saq2__22 | F1 | discrete | teacher list:22 |
|  m2saq2__23 | F1 | discrete | teacher list:23 |
|  m2saq2__24 | F1 | discrete | teacher list:24 |
|  m2saq2__25 | F1 | discrete | teacher list:25 |
|  m2saq2__26 | F1 | discrete | teacher list:26 |
|  m2saq2__27 | F1 | discrete | teacher list:27 |
|  m2saq2__28 | F1 | discrete | teacher list:28 |
|  m2saq2__29 | F1 | discrete | teacher list:29 |
|  numEligible | F1 | contin | numEligible |
|  i1 | F1 | contin | i1 |
|  i2 | F1 | contin | i2 |
|  i3 | F1 | contin | i3 |
|  i4 | F1 | contin | i4 |
|  i5 | F1 | contin | i5 |
|  name1 | F1 | discrete | name1 |
|  name2 | F1 | discrete | name2 |
|  name3 | F1 | discrete | name3 |
|  name4 | F1 | discrete | name4 |
|  name5 | F1 | discrete | name5 |
|  grade1 | F1 | discrete | grade1 |
|  grade2 | F1 | discrete | grade2 |
|  grade3 | F1 | discrete | grade3 |
|  grade4 | F1 | discrete | grade4 |
|  grade5 | F1 | discrete | grade5 |
|  available1 | F1 | contin | available1 |
|  available2 | F1 | contin | available2 |
|  available3 | F1 | contin | available3 |
|  available4 | F1 | contin | available4 |
|  available5 | F1 | contin | available5 |
|  teacher_phone_number1 | F1 | contin | phone number for 1st teacher |
|  teacher_phone_number2 | F1 | contin | phone number for 2nd teacher |
|  teacher_phone_number3 | F1 | contin | phone number for third teacher |
|  teacher_phone_number4 | F1 | contin | phone number for 4th teacher |
|  teacher_phone_number5 | F1 | contin | phone number for 5thteacher |
|  m1s0q2_infr | F1 | discrete | Is the road leading to the school accessible to a student in wheelchair? |
|  m1s0q3_infr | F1 | discrete | Are there steps leading up to the main entrance? |
|  m1s0q4_infr | F1 | discrete | Is there a proper ramp in good condition usable by a person in a wheelchair? |
|  m1s0q5_infr | F1 | discrete | Is the main entrance to the school wide enough for a person in a wheelchair to e |
|  m1s0q6 | F1 | discrete | Did the respondent agree to be interviewed |
|  m1s0q7 | F1 | discrete | If refused, reason for refusal |
|  m1saq1_first | F1 | discrete | What is your first name? |
|  m1saq1_last | F1 | discrete | What is your last name? |
|  m1saq2 | F1 | contin | Mobile Phone Number |
|  m1saq2b | F1 | contin | Please, can we have the school landline number? |
|  m1saq3 | F1 | discrete | Position at school |
|  m1saq3_other | F1 | discrete | Specify other |
|  m1saq4 | F1 | discrete | school type |
|  m1saq5 | F1 | discrete | What is the school category? |
|  m1saq6a | F1 | discrete | Language of instruction |
|  m1saq6a_other | F1 | discrete | Specified language if other |
|  m1saq6b | F1 | discrete | Language of instruction |
|  m1saq6b_other | F1 | discrete | Specified language if other |
|  m1saq7 | F1 | contin | Number of students |
|  m1saq8 | F1 | contin | How many of them are boys? |
|  m1saq8a_etri | F1 | contin | How many grade 5 students are currently enrolled in this school? |
|  m1saq9_lnut | F1 | discrete | Is there a public school feeding program at this school? |
|  m1sbq1_infr | F1 | discrete | What is the main pupil toilet facility used at the school? |
|  m1sbq2_infr | F1 | discrete | Are the toilets/latrines separate for girls and boys? |
|  m1sbq3_infr | F1 | discrete | Are the pupil's toilets clean? |
|  m1sbq4_infr | F1 | discrete | Are the pupils' toilets private |
|  m1sbq5_infr | F1 | discrete | Are the pupils' toilets useable |
|  m1sbq6_infr | F1 | discrete | Are the toilets accessible to a student with physical disabilities? |
|  m1sbq7_infr | F1 | discrete | Are there handwashing facilities at the school? |
|  m1sbq8_infr | F1 | discrete | Are both, soap and water, currently available |
|  m1sbq9_infr | F1 | discrete | What is the main source of drinking water |
|  m1sbq9_other_infr | F1 | discrete | Specify other |
|  m1sbq10_infr | F1 | discrete | Is drinking water from the main source currently available |
|  m1sbq11_infr | F1 | discrete | Does the school have access to electricity? |
|  m1sbq12_inpt | F1 | contin | How many PCs, laptops, and/or tablets available |
|  m1sbq12a_inpt_etri | F1 | contin | How many of the devices are in working condition at this school? |
|  m1sbq13_inpt | F1 | discrete | Are the PCs, laptops, and/or tablets functional |
|  m1sbq13a_inpt_etri | F1 | contin | how many are available for students to use in learning activities? |
|  m1sbq13b_inpt_etri | F1 | discrete | digital devices adapted for students with disabilities |
|  m1sbq15_inpt | F1 | discrete | Does at least one computer(s)/tablet(s) have internet connectivity? |
|  m1sbq15a_inpt_etri | F1 | contin | how many digital devices are connected to the Internet? |
|  m1sbq16_infr__1 | F1 | discrete | Compared with children of the same age, do some children enrolled in your school:seeing, even if wearing glasses? |
|  m1sbq16_infr__2 | F1 | discrete | Compared with children of the same age, do some children enrolled in your school:hearing, even if using a hearing aid? |
|  m1sbq16_infr__3 | F1 | discrete | Compared with children of the same age, do some children enrolled in your school:walking or climbing steps? |
|  m1sbq16_infr__4 | F1 | discrete | Compared with children of the same age, do some children enrolled in your school:in communicating, for example understanding or being understood by others? |
|  m1sbq16_infr__5 | F1 | discrete | Compared with children of the same age, do some children enrolled in your school:in learning because of a learning disability such as dyslexia, dyscalculia, attention deficit disorder, etc.? |
|  m1sbq17_infr__1 | F1 | discrete | Do you have a process to screen students at your school for the following diffic:seeing? |
|  m1sbq17_infr__2 | F1 | discrete | Do you have a process to screen students at your school for the following diffic:hearing? |
|  m1sbq17_infr__3 | F1 | discrete | Do you have a process to screen students at your school for the following diffic:learning disabilities such as dyslexia, dyscalculia, attention deficit disorder, etc.? |
|  m1sbq17_infr__97 | F1 | discrete | Do you have a process to screen students at your school for the following diffic:other (specify) |
|  m1sbq17_infr__98 | F1 | discrete | Do you have a process to screen students at your school for the following diffic:None of the above |
|  m1sbq17_other_infr | F1 | discrete | Specify Other |
|  m1sbq18_infr | F1 | discrete | Does your school have learning material accessible for all students (such as bra |
|  m1scq1_imon | F1 | discrete | Is there someone monitoring that all basic inputs are available to the students |
|  m1scq2_imon | F1 | discrete | Who has responsibility for monitoring basic inputs? |
|  m1scq2_other_imon | F1 | discrete | specify other |
|  m1scq4_imon__1 | F1 | discrete | What are the inputs that are being monitored?:functioning blackboard and chalk |
|  m1scq4_imon__6 | F1 | discrete | What are the inputs that are being monitored?:pens and pencils |
|  m1scq4_imon__4 | F1 | discrete | What are the inputs that are being monitored?:basic classroom furniture |
|  m1scq4_imon__5 | F1 | discrete | What are the inputs that are being monitored?:access to functioning digital devices (PCs, laptops, tablets, mobiles, etc.) |
|  m1scq4_imon__2 | F1 | discrete | What are the inputs that are being monitored?:textbooks |
|  m1scq4_imon__3 | F1 | discrete | What are the inputs that are being monitored?:exercise books |
|  m1scq4_imon__7 | F1 | discrete | What are the inputs that are being monitored?:use of digital devices and connectivity by the students |
|  m1scq5_imon | F1 | discrete | Does the school have a school inventory to monitor availability of basic inputs |
|  m1scq6_imon__1 | F1 | discrete | Please select the inputs that are being monitored through school inventory::blackboard and chalk |
|  m1scq6_imon__6 | F1 | discrete | Please select the inputs that are being monitored through school inventory::pens and pencils |
|  m1scq6_imon__4 | F1 | discrete | Please select the inputs that are being monitored through school inventory::basic classroom furniture |
|  m1scq6_imon__5 | F1 | discrete | Please select the inputs that are being monitored through school inventory::digital devices (PCs, laptops, tablets, mobiles, etc.) |
|  m1scq6_imon__2 | F1 | discrete | Please select the inputs that are being monitored through school inventory::textbooks |
|  m1scq6_imon__3 | F1 | discrete | Please select the inputs that are being monitored through school inventory::exercise books |
|  m1scq3_imon | F1 | discrete | Are parents or community members involved in the monitoring of availability of b |
|  m1scq7_imon | F1 | discrete | Is there someone monitoring that all basic infrastructure is available |
|  m1scq8_imon | F1 | discrete | Who has responsibility for monitoring basic infrastructure? |
|  m1scq8_other_imon | F1 | discrete | Specify Other |
|  m1scq9_imon__1 | F1 | discrete | What infrastructure items are being monitored?:toilets |
|  m1scq9_imon__2 | F1 | discrete | What infrastructure items are being monitored?:electricity |
|  m1scq9_imon__3 | F1 | discrete | What infrastructure items are being monitored?:drinking water |
|  m1scq9_imon__4 | F1 | discrete | What infrastructure items are being monitored?:accessibility for people with disabilities |
|  m1scq9_imon__5 | F1 | discrete | What infrastructure items are being monitored?:internet connectivity |
|  m1scq9a_imon_etri | F1 | discrete | Is there government legislation that assigns responsibility for maintaining ICT? |
|  m1scq10_imon | F1 | discrete | Are parents or community members involved in the monitoring of availability of b |
|  m1scq11_imon | F1 | discrete | Is there a system to monitor availability of basic infrastructure in all public |
|  m1scq12_imon__1 | F1 | discrete | Please select the infrastructure that are being monitored through school invento:functioning toilets |
|  m1scq12_imon__2 | F1 | discrete | Please select the infrastructure that are being monitored through school invento:electricity |
|  m1scq12_imon__3 | F1 | discrete | Please select the infrastructure that are being monitored through school invento:drinking water |
|  m1scq12_imon__4 | F1 | discrete | Please select the infrastructure that are being monitored through school invento:accessibility for people with disabilities |
|  m1scq13_imon__1 | F1 | discrete | Do you know if there are standards in place to require that students in all publ:blackboard and chalk |
|  m1scq13_imon__6 | F1 | discrete | Do you know if there are standards in place to require that students in all publ:pens and pencils |
|  m1scq13_imon__4 | F1 | discrete | Do you know if there are standards in place to require that students in all publ:basic classroom furniture |
|  m1scq13_imon__5 | F1 | discrete | Do you know if there are standards in place to require that students in all publ:functioning digital devices (PCs, laptops, tablets, mobiles, etc.) |
|  m1scq13_imon__2 | F1 | discrete | Do you know if there are standards in place to require that students in all publ:textbooks |
|  m1scq13_imon__3 | F1 | discrete | Do you know if there are standards in place to require that students in all publ:exercise books |
|  m1scq14_imon__1 | F1 | discrete | Do you know if there are standards in place to require all schools to have…?:toilets |
|  m1scq14_imon__2 | F1 | discrete | Do you know if there are standards in place to require all schools to have…?:electricity |
|  m1scq14_imon__3 | F1 | discrete | Do you know if there are standards in place to require all schools to have…?:drinking water |
|  m1scq14_imon__4 | F1 | discrete | Do you know if there are standards in place to require all schools to have…?:accessibility for people with disabilities |
|  m1scq14_imon__5 | F1 | discrete | Do you know if there are standards in place to require all schools to have…?:Internet connectivity |
|  m7saq1 | F1 | discrete | A1) What is your position in the school?  (most senior position) |
|  m7saq1_other | F1 | discrete | Specify Other |
|  m7saq2 | F1 | discrete | Have you ever taught in a school? |
|  m7saq3 | F1 | contin | What year did you begin teaching? |
|  m7saq4 | F1 | discrete | Do you presently teach at this school? |
|  m7saq5__1 | F1 | discrete | Which grades do you teach this academic year?:Grade 1 |
|  m7saq5__2 | F1 | discrete | Which grades do you teach this academic year?:Grade 2 |
|  m7saq5__3 | F1 | discrete | Which grades do you teach this academic year?:Grade 3 |
|  m7saq5__4 | F1 | discrete | Which grades do you teach this academic year?:Grade 4 |
|  m7saq5__5 | F1 | discrete | Which grades do you teach this academic year?:Grade 5 |
|  m7saq5__6 | F1 | discrete | Which grades do you teach this academic year?:Grade 6 |
|  m7saq5__7 | F1 | discrete | Which grades do you teach this academic year?:Grade 7 |
|  m7saq5__8 | F1 | discrete | Which grades do you teach this academic year?:Pre-School |
|  m7saq5__9 | F1 | discrete | Which grades do you teach this academic year?:Special needs |
|  m7saq6__1 | F1 | discrete | Which subjects did you teach this academic year?:Language |
|  m7saq6__2 | F1 | discrete | Which subjects did you teach this academic year?:Mathematics |
|  m7saq6__3 | F1 | discrete | Which subjects did you teach this academic year?:All subjects |
|  m7saq6__97 | F1 | discrete | Which subjects did you teach this academic year?:Other (Specify) |
|  m7saq6_other | F1 | discrete | Specify Other |
|  m7saq7 | F1 | discrete | What is the highest level of education that you have completed? |
|  m7saq7_other | F1 | discrete | Specify Other |
|  m7saq8 | F1 | contin | In what year did you achieve your present position in this school? |
|  m7saq9 | F1 | contin | What is your age? |
|  m7saq10 | F1 | discrete | What is your gender |
|  m7saq11 | F1 | discrete | Nationality |
|  m7saq11_other | F1 | discrete | Other nationality |
|  m7sbq1_opmn | F1 | discrete | Would your school be responsible for fixing the problem? |
|  m7sbq2_opmn | F1 | discrete | How would you address the problem? |
|  m7sbq2_other_opmn | F1 | discrete | Specify Other |
|  m7sbq3_opmn | F1 | discrete | Do you feel that your school could address the problem within a one-year time fr |
|  m7sbq3_other_opmn | F1 | discrete | Specify Other |
|  m7sbq4_opmn | F1 | discrete | If the problem would not be addressed by your school, who would be responsible f |
|  m7sbq4_other_opmn | F1 | discrete | Specify Other |
|  m7sbq5_opmn | F1 | discrete | Do you feel that the authorities who are responsible will address the problem wi |
|  m7sbq5_other_opmn | F1 | discrete | Specify Other |
|  m7scq1_opmn | F1 | discrete | Who is responsible for providing students with textbooks in your school? |
|  m7scq1_other_opmn | F1 | discrete | Specify Other |
|  m7scq2_opmn | F1 | discrete | If the school formally communicated a need for books to the authority responsibl |
|  m7scq3_opmn | F1 | discrete | Please think back to the first month of this school year. How many students in y |
|  m7scq4_opmn | F1 | discrete | Did the school do anything to provide some access to textbooks to the students w |
|  m7scq5_opmn__1 | F1 | discrete | What steps did your school take to provide some textbook access to students who:School bought or acquired more textbooks from school budget |
|  m7scq5_opmn__2 | F1 | discrete | What steps did your school take to provide some textbook access to students who:School asked donors / school community for help to purchase textbooks |
|  m7scq5_opmn__3 | F1 | discrete | What steps did your school take to provide some textbook access to students who:Students shared textbooks in class |
|  m7scq5_opmn__4 | F1 | discrete | What steps did your school take to provide some textbook access to students who:The school has a textbook lending program |
|  m7scq5_opmn__5 | F1 | discrete | What steps did your school take to provide some textbook access to students who:Teachers copy the relevant parts of the textbooks to give  to students |
|  m7scq5_opmn__97 | F1 | discrete | What steps did your school take to provide some textbook access to students who:Other is responsible : Specify |
|  m7scq5_opmn__98 | F1 | discrete | What steps did your school take to provide some textbook access to students who:Don’t know |
|  m7scq5_other_opmn | F1 | discrete | Specify Other |
|  m7sdq1_pman | F1 | discrete | Does your school have any specific goals established for this academic year? |
|  m7sdq2_pman | F1 | discrete | Were these goals established by your school or determined by a higher authority? |
|  m7sdq3_pman__1 | F1 | discrete | Who in the school community has a clear idea on what the school goals are for th:The school director or person responsible for school management |
|  m7sdq3_pman__2 | F1 | discrete | Who in the school community has a clear idea on what the school goals are for th:The school teachers |
|  m7sdq3_pman__3 | F1 | discrete | Who in the school community has a clear idea on what the school goals are for th:The students |
|  m7sdq3_pman__4 | F1 | discrete | Who in the school community has a clear idea on what the school goals are for th:The parents |
|  m7sdq3_pman__5 | F1 | discrete | Who in the school community has a clear idea on what the school goals are for th:Other members of the school community |
|  m7sdq4_pman__1 | F1 | discrete | Can you please let us know if your school goals for this academic year are?:improving student scores on standardized tests (IF THEY EXIST IN YOUR SYSTEM?) |
|  m7sdq4_pman__2 | F1 | discrete | Can you please let us know if your school goals for this academic year are?:improve exam passing rates |
|  m7sdq4_pman__3 | F1 | discrete | Can you please let us know if your school goals for this academic year are?:reducing students being absent from classes |
|  m7sdq4_pman__4 | F1 | discrete | Can you please let us know if your school goals for this academic year are?:reducing student drop-out during the year |
|  m7sdq4_pman__5 | F1 | discrete | Can you please let us know if your school goals for this academic year are?:reducing teacher absenteeism |
|  m7sdq4_pman__6 | F1 | discrete | Can you please let us know if your school goals for this academic year are?:supporting teachers to improve their pedagogical (teaching)  practices |
|  m7sdq4_pman__7 | F1 | discrete | Can you please let us know if your school goals for this academic year are?:getting more financial resources to fund school infrastructure |
|  m7sdq4_pman__8 | F1 | discrete | Can you please let us know if your school goals for this academic year are?:getting more financial resources to fund materials needed for learning, such as textbooks or technology |
|  m7sdq4_pman__97 | F1 | discrete | Can you please let us know if your school goals for this academic year are?:Other, Specify |
|  m7sdq4_other_pman | F1 | discrete | Specify Other |
|  m7sdq5_pman | F1 | discrete | How are you planning to measure if your school can achieve the goals that it has |
|  m7sdq5_other_pman | F1 | discrete | Specify Other |
|  m7seq1_pman | F1 | discrete | What is the first thing you would do? |
|  m7seq1_other_pman | F1 | discrete | Specify Other |
|  m7seq2_pman__1 | F1 | discrete | How would you go about collecting the information that might help you understand:Talk to parents |
|  m7seq2_pman__2 | F1 | discrete | How would you go about collecting the information that might help you understand:Talk to students |
|  m7seq2_pman__3 | F1 | discrete | How would you go about collecting the information that might help you understand:Talk to local authorities/ community leaders |
|  m7seq2_pman__4 | F1 | discrete | How would you go about collecting the information that might help you understand:Talk to teachers and/or other school staff |
|  m7seq2_pman__97 | F1 | discrete | How would you go about collecting the information that might help you understand:Other , specify |
|  m7seq2_pman__98 | F1 | discrete | How would you go about collecting the information that might help you understand:Don’t know |
|  m7seq2_other_pman | F1 | discrete | Specify Other |
|  m7seq3_pman | F1 | discrete | Which one of the following options do you think would probably be the most effec |
|  m7seq3_other_pman | F1 | discrete | Specify Other |
|  m7sfq1_pknw | F1 | contin | How many new teachers have been hired to work at this school in the past 2 years |
|  m7sfq2_pknw | F1 | contin | How many of those teachers had completed a practicum prior to starting employmen |
|  m7sfq3_pknw | F1 | discrete | Are new teachers required to undergo a probationary period? |
|  m7sfq4_pknw | F1 | discrete | Since you started working as principal, has there been any case of a teacher’s c |
|  m7sb_troster_pknw__0 | F1 | discrete | teacher questionnaire list:0 |
|  m7sb_troster_pknw__1 | F1 | discrete | teacher questionnaire list:1 |
|  m7sb_troster_pknw__2 | F1 | discrete | teacher questionnaire list:2 |
|  m7sb_troster_pknw__3 | F1 | discrete | teacher questionnaire list:3 |
|  m7sb_troster_pknw__4 | F1 | discrete | teacher questionnaire list:4 |
|  m7sb_troster_pknw__5 | F1 | discrete | teacher questionnaire list:5 |
|  m7sb_troster_pknw__6 | F1 | discrete | teacher questionnaire list:6 |
|  m7sb_troster_pknw__7 | F1 | discrete | teacher questionnaire list:7 |
|  m7_teach_count | F1 | contin | m7_teach_count |
|  m7sfq5_pknw__0 | F1 | discrete | None |
|  m7sfq5_pknw__1 | F1 | discrete | None |
|  m7sfq5_pknw__2 | F1 | discrete | None |
|  m7sfq5_pknw__3 | F1 | discrete | None |
|  m7sfq5_pknw__4 | F1 | discrete | None |
|  m7sfq5_pknw__5 | F1 | discrete | None |
|  m7sfq5_pknw__6 | F1 | discrete | None |
|  m7sfq5_pknw__7 | F1 | discrete | None |
|  m7sfq6_pknw__0 | F1 | discrete | None |
|  m7sfq6_pknw__1 | F1 | discrete | None |
|  m7sfq6_pknw__2 | F1 | discrete | None |
|  m7sfq6_pknw__3 | F1 | discrete | None |
|  m7sfq6_pknw__4 | F1 | discrete | None |
|  m7sfq6_pknw__5 | F1 | discrete | None |
|  m7sfq6_pknw__6 | F1 | discrete | None |
|  m7sfq6_pknw__7 | F1 | discrete | None |
|  m7sfq7_pknw__0 | F1 | discrete | None |
|  m7sfq7_pknw__1 | F1 | discrete | None |
|  m7sfq7_pknw__2 | F1 | discrete | None |
|  m7sfq7_pknw__3 | F1 | discrete | None |
|  m7sfq7_pknw__4 | F1 | discrete | None |
|  m7sfq7_pknw__5 | F1 | discrete | None |
|  m7sfq7_pknw__6 | F1 | discrete | None |
|  m7sfq7_pknw__7 | F1 | discrete | None |
|  m7sfq9_pknw_filter | F1 | discrete | correctly match opposite words. For instance, how many can match the word “under |
|  m7sfq9_pknw__0 | F1 | discrete | None |
|  m7sfq9_pknw__1 | F1 | discrete | None |
|  m7sfq9_pknw__2 | F1 | discrete | None |
|  m7sfq9_pknw__3 | F1 | discrete | None |
|  m7sfq9_pknw__4 | F1 | discrete | None |
|  m7sfq9_pknw__5 | F1 | discrete | None |
|  m7sfq9_pknw__6 | F1 | discrete | None |
|  m7sfq9_pknw__7 | F1 | discrete | None |
|  m7sfq10_pknw | F1 | contin | In the selected 4th grade classroom, how many of the pupils have the relevant te |
|  m7sfq11_pknw | F1 | discrete | In the selected 4th grade classroom, is there a functioning blackboard? |
|  m7sfq12_pknw | F1 | discrete | Students deserve more attention if they attend school regularly |
|  m7sfq13_pknw | F1 | discrete | Students deserve more attention if they come to school with materials |
|  m7sfq14_pknw | F1 | discrete | Students deserve more attention if they are motivated to learn |
|  m7sfq15a_pknw__0 | F1 | discrete | Maintenance and expansion of school infrastructure:No responsibility assigned |
|  m7sfq15a_pknw__1 | F1 | discrete | Maintenance and expansion of school infrastructure:National |
|  m7sfq15a_pknw__2 | F1 | discrete | Maintenance and expansion of school infrastructure:Provinces |
|  m7sfq15a_pknw__3 | F1 | discrete | Maintenance and expansion of school infrastructure:Local |
|  m7sfq15a_pknw__4 | F1 | discrete | Maintenance and expansion of school infrastructure:School |
|  m7sfq15a_pknw__98 | F1 | discrete | Maintenance and expansion of school infrastructure:Don't Know |
|  m7sfq15b_pknw__0 | F1 | discrete | Procurement of materials:No responsibility assigned |
|  m7sfq15b_pknw__1 | F1 | discrete | Procurement of materials:National |
|  m7sfq15b_pknw__2 | F1 | discrete | Procurement of materials:State |
|  m7sfq15b_pknw__3 | F1 | discrete | Procurement of materials:Local |
|  m7sfq15b_pknw__4 | F1 | discrete | Procurement of materials:School |
|  m7sfq15b_pknw__98 | F1 | discrete | Procurement of materials:Don't Know |
|  m7sfq15c_pknw__0 | F1 | discrete | Teacher hiring and assignment:No responsibility assigned |
|  m7sfq15c_pknw__1 | F1 | discrete | Teacher hiring and assignment:National |
|  m7sfq15c_pknw__2 | F1 | discrete | Teacher hiring and assignment:State |
|  m7sfq15c_pknw__3 | F1 | discrete | Teacher hiring and assignment:Local |
|  m7sfq15c_pknw__4 | F1 | discrete | Teacher hiring and assignment:School |
|  m7sfq15c_pknw__98 | F1 | discrete | Teacher hiring and assignment:Don't Know |
|  m7sfq15d_pknw__0 | F1 | discrete | Teacher supervision, training, and coaching of teachers:No responsibility assigned |
|  m7sfq15d_pknw__1 | F1 | discrete | Teacher supervision, training, and coaching of teachers:National |
|  m7sfq15d_pknw__2 | F1 | discrete | Teacher supervision, training, and coaching of teachers:State |
|  m7sfq15d_pknw__3 | F1 | discrete | Teacher supervision, training, and coaching of teachers:Local |
|  m7sfq15d_pknw__4 | F1 | discrete | Teacher supervision, training, and coaching of teachers:School |
|  m7sfq15d_pknw__98 | F1 | discrete | Teacher supervision, training, and coaching of teachers:Don't Know |
|  m7sfq15e_pknw__0 | F1 | discrete | Student learning assessments:No responsibility assigned |
|  m7sfq15e_pknw__1 | F1 | discrete | Student learning assessments:National |
|  m7sfq15e_pknw__2 | F1 | discrete | Student learning assessments:State |
|  m7sfq15e_pknw__3 | F1 | discrete | Student learning assessments:Local |
|  m7sfq15e_pknw__4 | F1 | discrete | Student learning assessments:School |
|  m7sfq15e_pknw__98 | F1 | discrete | Student learning assessments:Don't Know |
|  m7sfq15f_pknw__0 | F1 | discrete | Principal hiring and assignment:No responsibility assigned |
|  m7sfq15f_pknw__1 | F1 | discrete | Principal hiring and assignment:National |
|  m7sfq15f_pknw__2 | F1 | discrete | Principal hiring and assignment:State |
|  m7sfq15f_pknw__3 | F1 | discrete | Principal hiring and assignment:Local |
|  m7sfq15f_pknw__4 | F1 | discrete | Principal hiring and assignment:School |
|  m7sfq15f_pknw__98 | F1 | discrete | Principal hiring and assignment:Don't Know |
|  m7sfq15g_pknw__0 | F1 | discrete | Principal supervision and training:No responsibility assigned |
|  m7sfq15g_pknw__1 | F1 | discrete | Principal supervision and training:National |
|  m7sfq15g_pknw__2 | F1 | discrete | Principal supervision and training:State |
|  m7sfq15g_pknw__3 | F1 | discrete | Principal supervision and training:Local |
|  m7sfq15g_pknw__4 | F1 | discrete | Principal supervision and training:School |
|  m7sfq15g_pknw__98 | F1 | discrete | Principal supervision and training:Don't Know |
|  m7sgq1_ssld__1 | F1 | discrete | In this district, what factors are considered when selecting a Principal? Please:Years of experience |
|  m7sgq1_ssld__2 | F1 | discrete | In this district, what factors are considered when selecting a Principal? Please:Quality of teaching |
|  m7sgq1_ssld__3 | F1 | discrete | In this district, what factors are considered when selecting a Principal? Please:Demonstrated management qualities |
|  m7sgq1_ssld__4 | F1 | discrete | In this district, what factors are considered when selecting a Principal? Please:Good relationship with the owner of the school (if private) |
|  m7sgq1_ssld__5 | F1 | discrete | In this district, what factors are considered when selecting a Principal? Please:Good relationship with the Education Department |
|  m7sgq1_ssld__6 | F1 | discrete | In this district, what factors are considered when selecting a Principal? Please:Political affiliations |
|  m7sgq1_ssld__7 | F1 | discrete | In this district, what factors are considered when selecting a Principal? Please:Ethnic group |
|  m7sgq1_ssld__8 | F1 | discrete | In this district, what factors are considered when selecting a Principal? Please:Knowledge of the local community |
|  m7sgq1_ssld__97 | F1 | discrete | In this district, what factors are considered when selecting a Principal? Please:Other (specify) |
|  m7sgq1_other_ssld | F1 | discrete | Specify other |
|  m7sgq2_ssld | F1 | discrete | Which one of the previously mentioned do you think is the most important? |
|  m7sgq3_ssup | F1 | discrete | Have you ever received formal training on how to manage a school? |
|  m7sgq4_ssup__1 | F1 | discrete | What type of training have you received?:Management training for new principals |
|  m7sgq4_ssup__2 | F1 | discrete | What type of training have you received?:In-service training for principals |
|  m7sgq4_ssup__3 | F1 | discrete | What type of training have you received?:Mentoring/Coaching by experienced principals |
|  m7sgq4_ssup__4 | F1 | discrete | What type of training have you received?:Other (specify) |
|  m7sgq4_other_ssup | F1 | discrete | Specify Other |
|  m7sgq5_ssup | F1 | discrete | have you used the skills you gained at that training? |
|  m7sgq6_ssup__1 | F1 | discrete | What are those skills that you have used?:How to prepare a budget |
|  m7sgq6_ssup__2 | F1 | discrete | What are those skills that you have used?:How to manage the financial resources of the school |
|  m7sgq6_ssup__3 | F1 | discrete | What are those skills that you have used?:How to manage the relationship with the parents and the community |
|  m7sgq6_ssup__4 | F1 | discrete | What are those skills that you have used?:How to provide feedback and mentoring to teachers |
|  m7sgq6_ssup__5 | F1 | discrete | What are those skills that you have used?:How to motivate teachers |
|  m7sgq6_ssup__6 | F1 | discrete | What are those skills that you have used?:How to develop a lesson plan |
|  m7sgq6_ssup__7 | F1 | discrete | What are those skills that you have used?:Pedagogical skills |
|  m7sgq6_ssup__8 | F1 | discrete | What are those skills that you have used?:How to report data on the school |
|  m7sgq6_ssup__9 | F1 | discrete | What are those skills that you have used?:How to ask for material needed for school |
|  m7sgq6_ssup__97 | F1 | discrete | What are those skills that you have used?:Other (to specify) |
|  m7sgq6_ssup__98 | F1 | discrete | What are those skills that you have used?:Don't know |
|  m7sgq6_other_ssup | F1 | discrete | Specify Other |
|  m7sgq7_ssup | F1 | discrete | Thinking of the past year, how many trainings and professional development cours |
|  m7sgq7a_ssup_etri | F1 | discrete | did you attend any training on the use of ICT? |
|  m7sgq7b_ssup_etri | F1 | discrete | How was this training delivered? |
|  m7sgq7c_ssup_etri | F1 | discrete | Did you find this training effective? |
|  m7sgq8_sevl | F1 | discrete | During the last school year did any authority evaluate your work? |
|  m7sgq9_sevl__1 | F1 | discrete | During the last school year which authority evaluated your work?:Ministry of Education - Central level |
|  m7sgq9_sevl__2 | F1 | discrete | During the last school year which authority evaluated your work?:Ministry of Education in Province |
|  m7sgq9_sevl__3 | F1 | discrete | During the last school year which authority evaluated your work?:District Education Office |
|  m7sgq9_sevl__4 | F1 | discrete | During the last school year which authority evaluated your work?:Heads of subject departments |
|  m7sgq9_sevl__5 | F1 | discrete | During the last school year which authority evaluated your work?:Parents’ association |
|  m7sgq10_sevl__1 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Teaching material availability |
|  m7sgq10_sevl__2 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Student discipline or classroom management |
|  m7sgq10_sevl__3 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Teachers’ knowledge |
|  m7sgq10_sevl__4 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Teaching methods |
|  m7sgq10_sevl__5 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Teacher attendance |
|  m7sgq10_sevl__6 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Student attendance |
|  m7sgq10_sevl__7 | F1 | discrete | What specific aspects of your work did they evaluate you on?:School facilities and equipment |
|  m7sgq10_sevl__8 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Student assessment results |
|  m7sgq10_sevl__9 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Parent assessment |
|  m7sgq10_sevl__10 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Integration of ICT in teaching and learning practices |
|  m7sgq10_sevl__97 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Other (specify) |
|  m7sgq10_sevl__98 | F1 | discrete | What specific aspects of your work did they evaluate you on?:Don’t know |
|  m7sgq10_other_sevl | F1 | discrete | Specify Other |
|  m7sgq11_sevl__1 | F1 | discrete | What would happen if a principal received 2 or more negative evaluations?:The principal would be dismissed |
|  m7sgq11_sevl__2 | F1 | discrete | What would happen if a principal received 2 or more negative evaluations?:The principal’s salary would be reduced |
|  m7sgq11_sevl__3 | F1 | discrete | What would happen if a principal received 2 or more negative evaluations?:The principal would be required to partake in professional development |
|  m7sgq11_sevl__4 | F1 | discrete | What would happen if a principal received 2 or more negative evaluations?:The principal would be supervised/ monitored more closely by someone at the school or the district |
|  m7sgq11_sevl__97 | F1 | discrete | What would happen if a principal received 2 or more negative evaluations?:Other (specify) |
|  m7sgq11_sevl__98 | F1 | discrete | What would happen if a principal received 2 or more negative evaluations?:Don’t know |
|  m7sgq11_sevl__7 | F1 | discrete | What would happen if a principal received 2 or more negative evaluations?:No consequences |
|  m7sgq11_other_sevl | F1 | discrete | Specify Other |
|  m7sgq12_sevl__1 | F1 | discrete | What would happen if a principal received 2 or more positive evaluations?:The principal would be promoted |
|  m7sgq12_sevl__2 | F1 | discrete | What would happen if a principal received 2 or more positive evaluations?:The principal’s salary would be increased |
|  m7sgq12_sevl__3 | F1 | discrete | What would happen if a principal received 2 or more positive evaluations?:The principal would be offered more professional development opportunities |
|  m7sgq12_sevl__4 | F1 | discrete | What would happen if a principal received 2 or more positive evaluations?:The principal would be publicly recognized |
|  m7sgq12_sevl__97 | F1 | discrete | What would happen if a principal received 2 or more positive evaluations?:Other (specify) |
|  m7sgq12_sevl__98 | F1 | discrete | What would happen if a principal received 2 or more positive evaluations?:Don’t know |
|  m7sgq12_sevl__7 | F1 | discrete | What would happen if a principal received 2 or more positive evaluations?:No consequences |
|  m7sgq12_other_sevl | F1 | discrete | Specify Other |
|  m7shq1_satt | F1 | discrete | How satisfied or dissatisfied are you with your social status in the community a |
|  m7shq2_satt | F1 | contin | What is your monthly salary as a public-school principal? |
|  m7shq3_currency_satt | F1 | discrete | Currency |
|  m7siq1a_etri | F1 | discrete | there is a plan/strategy to incorporate the use of technology (a) |
|  m7siq1b_etri | F1 | discrete | there is a plan/strategy to incorporate the use of technology (b) |
|  m7siq1c_etri | F1 | discrete | there is a plan/strategy to incorporate the use of technology (c) |
|  m7siq1d_etri | F1 | discrete | there is a plan/strategy to incorporate the use of technology (d) |
|  m7siq2a_etri | F1 | discrete | how important is it to ensure students have the skills to use ICT (a) |
|  m7siq2b_etri | F1 | discrete | how important is it to ensure students have the skills to use ICT (b) |
|  m7siq2c_etri | F1 | discrete | how important is it to ensure students have the skills to use ICT (c) |
|  m7siq2d_etri | F1 | discrete | how important is it to ensure students have the skills to use ICT (d) |
|  m7siq3_etri | F1 | discrete | Who is responsible for ICT strategic plan? |
|  m7siq4_etri | F1 | discrete | Do you have guidelines to integrate ICT into learning? |
|  m7sjq1a_etri | F1 | discrete | Number of digital devices supporting teaching (a) |
|  m7sjq1b_etri | F1 | discrete | Number of digital devices supporting teaching (b) |
|  m7sjq1c_etri | F1 | discrete | Number of digital devices supporting teaching (c) |
|  m7sjq1d_etri | F1 | discrete | Number of digital devices supporting teaching (d) |
|  m7sjq1e_etri | F1 | discrete | Number of digital devices supporting teaching (e) |
|  m7sjq2_etri | F1 | discrete | Do you have problem with internet? |
|  m7skq1a_etri | F1 | discrete | Using digital education resources (a) |
|  m7skq1b_etri | F1 | discrete | Using digital education resources (b) |
|  m7skq1c_etri | F1 | discrete | Using digital education resources (c) |
|  m7skq1d_etri | F1 | discrete | Using digital education resources (d) |
|  m7skq1e_etri | F1 | discrete | Using digital education resources (e) |
|  m7skq2a_etri | F1 | discrete | Policy about digital education (a) |
|  m7skq2b_etri | F1 | discrete | Policy about digital education (b) |
|  m7skq2c_etri | F1 | discrete | Policy about digital education (c) |
|  m7skq2d_etri | F1 | discrete | Policy about digital education (d) |
|  m7skq2e_etri | F1 | discrete | Policy about digital education (e) |
|  m7covq1 | F1 | discrete | how long the school was closed to students? |
|  m7covq2 | F1 | discrete | How long were teachers working from home? |
|  m7covq3 | F1 | discrete | During this time, were some students still attending in person? |
|  m7covq4__1 | F1 | discrete | Which type of students was still attending in person?:Some grades (specify) |
|  m7covq4__2 | F1 | discrete | Which type of students was still attending in person?:Students with special needs |
|  m7covq4__3 | F1 | discrete | Which type of students was still attending in person?:Students at risk of dropping out |
|  m7covq4__4 | F1 | discrete | Which type of students was still attending in person?:Lower performing students |
|  m7covq4__5 | F1 | discrete | Which type of students was still attending in person?:Children of essential workers |
|  m7covq4__97 | F1 | discrete | Which type of students was still attending in person?:Other, specify |
|  m7covq4__99 | F1 | discrete | Which type of students was still attending in person?:Don't know |
|  m7covq4_other | F1 | discrete | Other specify |
|  m7covq5 | F1 | discrete | Did the school offer remote learning opportunities to students over this period? |
|  m7covq6__1 | F1 | discrete | What type of remote learning opportunities were offered?:paper-based resources and exercises |
|  m7covq6__2 | F1 | discrete | What type of remote learning opportunities were offered?:radio |
|  m7covq6__3 | F1 | discrete | What type of remote learning opportunities were offered?:TV |
|  m7covq6__4 | F1 | discrete | What type of remote learning opportunities were offered?:resources shared by phone (text, WhatsApp, etc.) |
|  m7covq6__5 | F1 | discrete | What type of remote learning opportunities were offered?:Resources online |
|  m7covq6__6 | F1 | discrete | What type of remote learning opportunities were offered?:Virtual/online lessons (asynchronous) |
|  m7covq6__7 | F1 | discrete | What type of remote learning opportunities were offered?:Virtual/online lessons (synchronous) |
|  m7covq6__97 | F1 | discrete | What type of remote learning opportunities were offered?:Other (specify) |
|  m7covq6_other | F1 | discrete | Other specify |
|  m7covq7 | F1 | discrete | Were remote learning opportunities offered to all grades or only specific grades |
|  m7covq7_other | F1 | discrete | Other specify |
|  m7covq8 | F1 | discrete | Were remote learning opportunities offered in all subjects or only some subjects |
|  m7covq8_other | F1 | discrete | Other specify |
|  m7covq9__1 | F1 | discrete | What type of actions were taken to support teachers in providing remote learning:None |
|  m7covq9__2 | F1 | discrete | What type of actions were taken to support teachers in providing remote learning:Paper-based resources |
|  m7covq9__3 | F1 | discrete | What type of actions were taken to support teachers in providing remote learning:resources shared by phone (text, WhatsApp, etc.) |
|  m7covq9__4 | F1 | discrete | What type of actions were taken to support teachers in providing remote learning:Online resources, |
|  m7covq9__5 | F1 | discrete | What type of actions were taken to support teachers in providing remote learning:Virtual training (asynchronous) |
|  m7covq9__6 | F1 | discrete | What type of actions were taken to support teachers in providing remote learning:Virtual training (synchronous) |
|  m7covq9__7 | F1 | discrete | What type of actions were taken to support teachers in providing remote learning:In-person training |
|  m7covq9__97 | F1 | discrete | What type of actions were taken to support teachers in providing remote learning:Other (specify) |
|  m7covq9_other | F1 | discrete | Other specify |
|  m7covq10__1 | F1 | discrete | what has changed in the way schooling and learning takes place?:Schedule (e.g. start time, breaks, duration of the school day, duration of the school week) |
|  m7covq10__2 | F1 | discrete | what has changed in the way schooling and learning takes place?:Hygiene and cleaning protocols (e.g. washing basin, soap, etc.) |
|  m7covq10__3 | F1 | discrete | what has changed in the way schooling and learning takes place?:Monitoring health and safety (e.g. testing) |
|  m7covq10__4 | F1 | discrete | what has changed in the way schooling and learning takes place?:Social distancing protocols (between adults, between students i.e., spacing of desks or otherwise) |
|  m7covq10__5 | F1 | discrete | what has changed in the way schooling and learning takes place?:Use of blended learning |
|  m7covq10__6 | F1 | discrete | what has changed in the way schooling and learning takes place?:Revised curriculum |
|  m7covq10__7 | F1 | discrete | what has changed in the way schooling and learning takes place?:Additional nutrition support (e.g. breakfast, lunch, snacks) |
|  m7covq10__8 | F1 | discrete | what has changed in the way schooling and learning takes place?:Additional socio-emotional support |
|  m7covq10__9 | F1 | discrete | what has changed in the way schooling and learning takes place?:Closer monitoring of students’ attendance |
|  m7covq10__10 | F1 | discrete | what has changed in the way schooling and learning takes place?:Use of grade repetition |
|  m7covq10__11 | F1 | discrete | what has changed in the way schooling and learning takes place?:Use of grade skipping |
|  m7covq10__97 | F1 | discrete | what has changed in the way schooling and learning takes place?:Other (specify) |
|  m7covq10_other | F1 | discrete | Other specify |
|  numEligible4th | F1 | contin | numEligible4th |
|  m3sb_troster__0 | F1 | discrete | teacher questionnaire list:0 |
|  m3sb_troster__1 | F1 | discrete | teacher questionnaire list:1 |
|  m3sb_troster__2 | F1 | discrete | teacher questionnaire list:2 |
|  m3sb_troster__3 | F1 | discrete | teacher questionnaire list:3 |
|  m3sb_troster__4 | F1 | discrete | teacher questionnaire list:4 |
|  grade5_yesno | F1 | discrete | Existence of at least one class of grade 5 in the school |
|  randomization | F1 | discrete | random selection teacher grade 5 |
|  teacher_etri_list_photo | F1 | discrete | picture of list of Grade 5 teachers |
|  list_total | F1 | contin | How many public officials are on the list? |
|  needed_total | F1 | contin | How many Grade 5 teachers need to be selected? |
|  numEligible5th | F1 | contin | numEligible5th |
|  m3sb_etri_roster__0 | F1 | discrete | EdTech list:0 |
|  m5sb_troster__0 | F1 | discrete | teacher questionnaire list:0 |
|  m5sb_troster__1 | F1 | discrete | teacher questionnaire list:1 |
|  m5sb_troster__2 | F1 | discrete | teacher questionnaire list:2 |
|  m5sb_troster__3 | F1 | discrete | teacher questionnaire list:3 |
|  m5sb_troster__4 | F1 | discrete | teacher questionnaire list:4 |
|  m6_teacher_name | F1 | discrete | What is the name of the teacher instructing the students? |
|  m6_teacher_code | F1 | contin | What is the teachers code |
|  m6_class_count | F1 | contin | How many students are in the class? |
|  m6_instruction_time | F1 | contin | How much time per day is dedicated to reading practice and/or instruction in rea |
|  m6s1q1__0 | F1 | discrete | Students Taking Assessment:0 |
|  m6s1q1__1 | F1 | discrete | Students Taking Assessment:1 |
|  m6s1q1__2 | F1 | discrete | Students Taking Assessment:2 |
|  m6s1q1__3 | F1 | discrete | Students Taking Assessment:3 |
|  m6s1q1__4 | F1 | discrete | Students Taking Assessment:4 |
|  m6s1q1__5 | F1 | discrete | Students Taking Assessment:5 |
|  m4saq1 | F1 | discrete | Please enter the name of the teacher that is being recorded |
|  m4saq1_number | F1 | contin | Please enter the teacher's code that is being observed |
|  class_start_sched | F1 | discrete | SCHEDULED: Class Start Time |
|  class_end_sched | F1 | discrete | SCHEDULED: Class End Time |
|  Date_time | F1 | discrete | ACTUAL: Class Start Time |
|  subject_test | F1 | discrete | Domain under classroom observation |
|  s1_0_1_1 | F1 | discrete | 0.1. Teacher provides learning activity to most students - 1st Snapshot (4-5m) |
|  s1_0_1_2 | F1 | discrete | 0.2. Students are on task - 1st Snapshot (4-5m) |
|  s1_0_2_1 | F1 | discrete | 0.1. Teacher provides learning activity to most students - 2nd Snapshot (9-10m) |
|  s1_0_2_2 | F1 | discrete | 0.2. Students are on task - 2nd Snapshot (9-10m) |
|  s1_0_3_1 | F1 | discrete | 0.1. Teacher provides learning activity to most students - 3rd Snapshot (14-15m) |
|  s1_0_3_2 | F1 | discrete | 0.2. Students are on task - 3rd Snapshot (14-15m) |
|  s1_a1 | F1 | discrete | SUPPORTIVE LEARNING ENVIRONMENT: Cumulative Code |
|  s1_a1_1 | F1 | discrete | 1.1 The teacher treats all students respectfully |
|  s1_a1_2 | F1 | discrete | 1.2 The teacher uses positive language with students |
|  s1_a1_3 | F1 | discrete | 1.3 The teacher responds to students' needs |
|  s1_a1_4a | F1 | discrete | 1.4 The teacher does not exhibit gender bias and challenges gender stereotypes i |
|  s1_a1_4b | F1 | discrete | 1.4 The teacher does not exhibit gender bias and challenges gender stereotypes i |
|  s1_a2 | F1 | discrete | POSITIVE BEHAVIORAL EXPECTATIONS: Cumulative Code |
|  s1_a2_1 | F1 | discrete | 2.1 The teacher sets clear behavioral expectations for classroom activities |
|  s1_a2_2 | F1 | discrete | 2.2 The teacher acknowledges positive student behavior |
|  s1_a2_3 | F1 | discrete | 2.3 The teacher redirects misbehavior and focuses on the expected behavior, rath |
|  s1_b3 | F1 | discrete | LESSON FACILITATION: Cumulative Code |
|  s1_b3_1 | F1 | discrete | 3.1 The teacher explicitly articulates the objectives of the lesson and relates |
|  s1_b3_2 | F1 | discrete | 3.2 The teacher's explanation of content is clear |
|  s1_b3_3 | F1 | discrete | 3.3 The teacher makes connections in the lesson that relate to other content kno |
|  s1_b3_4 | F1 | discrete | 3.4 The teacher models by enacting, or thinking aloud |
|  s1_b4 | F1 | discrete | CHECKS FOR UNDERSTANDING: Cumulative Code |
|  s1_b4_1 | F1 | discrete | 4.1 The teacher uses questions, prompts or other strategies to determine student |
|  s1_b4_2 | F1 | discrete | 4.2 The teacher monitors most students during independent/group work |
|  s1_b4_3 | F1 | discrete | 4.3 The teacher adjusts teaching to the level of the students |
|  s1_b5 | F1 | discrete | 5. FEEDBACK: Cumulative Code |
|  s1_b5_1 | F1 | discrete | 5.1 The teacher provides specific comments or prompts that help clarify students |
|  s1_b5_2 | F1 | discrete | 5.2 The teacher provides specific comments or prompts that help identify student |
|  s1_b6 | F1 | discrete | 6. CRITICAL THINKING: Cumulative Code |
|  s1_b6_1 | F1 | discrete | 6.1 The teacher asks open-ended questions |
|  s1_b6_2 | F1 | discrete | 6.2 The teacher provides thinking tasks |
|  s1_b6_3 | F1 | discrete | 6.3 The students ask open-ended questions or perform thinking tasks |
|  s1_c7 | F1 | discrete | 7. AUTONOMY: Cumulative Code |
|  s1_c7_1 | F1 | discrete | 7.1 The teacher provides students with choices |
|  s1_c7_2 | F1 | discrete | 7.2 The teacher provides students with opportunities to take on roles in the cla |
|  s1_c7_3 | F1 | discrete | 7.3 The students volunteer to participate in the classroom |
|  s1_c8 | F1 | discrete | 8. PERSEVERANCE: Cumulative Code |
|  s1_c8_1 | F1 | discrete | 8.1 The teacher acknowledges students' effort |
|  s1_c8_2 | F1 | discrete | 8.2 The teacher has a positive attitude towards students' challenges |
|  s1_c8_3 | F1 | discrete | 8.3 The teacher encourages goal-setting |
|  s1_c9 | F1 | discrete | 9. SOCIAL AND COLLABORATIVE SKILLS: Cumulative Code |
|  s1_c9_1 | F1 | discrete | 9.1 The teacher promotes students’ collaboration through peer interaction |
|  s1_c9_2 | F1 | discrete | 9.2 The teacher promotes students' interpersonal skills |
|  s1_c9_3 | F1 | discrete | 9.3 Students collaborate with one another through peer interaction |
|  s2_0_1_1 | F1 | discrete | 0.1. Teacher provides learning activity to most students - 1st Snapshot (4-5m) |
|  s2_0_1_2 | F1 | discrete | 0.2. Students are on task - 1st Snapshot (4-5m) |
|  s2_0_2_1 | F1 | discrete | 0.1. Teacher provides learning activity to most students - 2nd Snapshot (9-10m) |
|  s2_0_2_2 | F1 | discrete | 0.2. Students are on task - 2nd Snapshot (9-10m) |
|  s2_0_3_1 | F1 | discrete | 0.1. Teacher provides learning activity to most students - 3rd Snapshot (14-15m) |
|  s2_0_3_2 | F1 | discrete | 0.2. Students are on task - 3rd Snapshot (14-15m) |
|  s2_a1 | F1 | discrete | SUPPORTIVE LEARNING ENVIRONMENT: Cumulative Code |
|  s2_a1_1 | F1 | discrete | 1.1 The teacher treats all students respectfully |
|  s2_a1_2 | F1 | discrete | 1.2 The teacher uses positive language with students |
|  s2_a1_3 | F1 | discrete | 1.3 The teacher responds to students' needs |
|  s2_a1_4 | F1 | discrete | 1.4 The teacher does not exhibit gender bias and challenges gender stereotypes i |
|  s2_a2 | F1 | discrete | POSITIVE BEHAVIORAL EXPECTATIONS: Cumulative Code |
|  s2_a2_1 | F1 | discrete | 2.1 The teacher sets clear behavioral expectations for classroom activities |
|  s2_a2_2 | F1 | discrete | 2.2 The teacher acknowledges positive student behavior |
|  s2_a2_3 | F1 | discrete | 2.3 The teacher redirects misbehavior and focuses on the expected behavior, rath |
|  s2_b3 | F1 | discrete | LESSON FACILITATION: Cumulative Code |
|  s2_b3_1 | F1 | discrete | 3.1 The teacher explicitly articulates the objectives of the lesson and relates |
|  s2_b3_2 | F1 | discrete | 3.2 The teacher's explanation of content is clear |
|  s2_b3_3 | F1 | discrete | 3.3 The teacher makes connections in the lesson that relate to other content kno |
|  s2_b3_4 | F1 | discrete | 3.4 The teacher models by enacting, or thinking aloud |
|  s2_b4 | F1 | discrete | CHECKS FOR UNDERSTANDING: Cumulative Code |
|  s2_b4_1 | F1 | discrete | 4.1 The teacher uses questions, prompts or other strategies to determine student |
|  s2_b4_2 | F1 | discrete | 4.2 The teacher monitors most students during independent/group work |
|  s2_b4_3 | F1 | discrete | 4.3 The teacher adjusts teaching to the level of the students |
|  s2_b5 | F1 | discrete | 5. FEEDBACK: Cumulative Code |
|  s2_b5_1 | F1 | discrete | 5.1 The teacher provides specific comments or prompts that help clarify students |
|  s2_b5_2 | F1 | discrete | 5.2 The teacher provides specific comments or prompts that help identify student |
|  s2_b6 | F1 | discrete | 6. CRITICAL THINKING: Cumulative Code |
|  s2_b6_1 | F1 | discrete | 6.1 The teacher asks open-ended questions |
|  s2_b6_2 | F1 | discrete | 6.2 The teacher provides thinking tasks |
|  s2_b6_3 | F1 | discrete | 6.3 The students ask open-ended questions or perform thinking tasks |
|  s2_c7 | F1 | discrete | 7. AUTONOMY: Cumulative Code |
|  s2_c7_1 | F1 | discrete | 7.1 The teacher provides students with choices |
|  s2_c7_2 | F1 | discrete | 7.2 The teacher provides students with opportunities to take on roles in the cla |
|  s2_c7_3 | F1 | discrete | 7.3 The students volunteer to participate in the classroom |
|  s2_c8 | F1 | discrete | 8. PERSEVERANCE: Cumulative Code |
|  s2_c8_1 | F1 | discrete | 8.1 The teacher acknowledges students' effort |
|  s2_c8_2 | F1 | discrete | 8.2 The teacher has a positive attitude towards students' challenges |
|  s2_c8_3 | F1 | discrete | 8.3 The teacher encourages goal-setting |
|  s2_c9 | F1 | discrete | 9. SOCIAL AND COLLABORATIVE SKILLS: Cumulative Code |
|  s2_c9_1 | F1 | discrete | 9.1 The teacher promotes students’ collaboration through peer interaction |
|  s2_c9_2 | F1 | discrete | 9.2 The teacher promotes students' interpersonal skills |
|  s2_c9_3 | F1 | discrete | 9.3 Students collaborate with one another through peer interaction |
|  m4scq1_infr | F1 | discrete | Are there steps leading up to the classroom? |
|  m4scq2_infr | F1 | discrete | Is there a proper ramp in good condition usable by a person in a wheelchair to a |
|  m4scq3_infr | F1 | discrete | Is the main entrance to the classroom wide enough for a person in a wheelchair t |
|  m4scq4_inpt | F1 | contin | How many pupils are in the room? |
|  m4scq4n_girls | F1 | contin | How many of them are boys? |
|  m4scq5_inpt | F1 | contin | How many total pupils have the textbook for the class (English or mathematics)? |
|  m4scq6_inpt | F1 | contin | How many total pupils in the class have a pencil or pen? |
|  m4scq7_inpt | F1 | contin | How many total pupils in the class have an exercise book? |
|  m4scq8_inpt | F1 | discrete | Is there a blackboard and/or whiteboard in the class? |
|  m4scq9_inpt | F1 | discrete | Is there chalk or marker to write on the board available during the lesson? |
|  m4scq10_inpt | F1 | discrete | Does the blackboard have sufficient light and contrast for reading what is writt |
|  m4scq11_inpt | F1 | contin | How many pupils were not sitting on desks? |
|  m4scq12_inpt | F1 | contin | How many students are in the class, according to the class list? |
|  m4scq13_girls | F1 | contin | How many students on the class list are boys? |
|  m4scq14_see | F1 | contin | problems to see even if they wear glasses |
|  m4scq14_sound | F1 | contin | problems hearing sounds such as people's voices or music |
|  m4scq14_walk | F1 | contin | Compared to children of the same age, how many children have problems with walki |
|  m4scq14_comms | F1 | contin | problems communicating, e.g., understanding or being understood by others |
|  m4scq14_learn | F1 | contin | learning disability. For example, dyslexia, dyscalculia, attention deficit disor |
|  m4scq14_behav | F1 | contin | behavioral problems. For example, hitting students repeatedly, disrespecting the |
|  m4scq15_lang | F1 | discrete | kids language at home |
|  m8_teacher_name | F1 | discrete | What is the name of the teacher instructing the students? |
|  m8_teacher_code | F1 | contin | What is the teacher's code? |
|  m8_bilingual_school | F1 | discrete | Is the school bilingual? |
|  m8_bilingual_class | F1 | discrete | Is the Grade 4 class bilingual? |
|  m8_refugee | F1 | discrete | Is it a refugee school? |
|  m8s1q1__0 | F1 | discrete | Students Taking Assessment:0 |
|  m8s1q1__1 | F1 | discrete | Students Taking Assessment:1 |
|  m8s1q1__2 | F1 | discrete | Students Taking Assessment:2 |
|  m8s1q1__3 | F1 | discrete | Students Taking Assessment:3 |
|  m8s1q1__4 | F1 | discrete | Students Taking Assessment:4 |
|  m8s1q1__5 | F1 | discrete | Students Taking Assessment:5 |
|  m8s1q1__6 | F1 | discrete | Students Taking Assessment:6 |
|  m8s1q1__7 | F1 | discrete | Students Taking Assessment:7 |
|  m8s1q1__8 | F1 | discrete | Students Taking Assessment:8 |
|  m8s1q1__9 | F1 | discrete | Students Taking Assessment:9 |
|  m8s1q1__10 | F1 | discrete | Students Taking Assessment:10 |
|  m8s1q1__11 | F1 | discrete | Students Taking Assessment:11 |
|  m8s1q1__12 | F1 | discrete | Students Taking Assessment:12 |
|  m8s1q1__13 | F1 | discrete | Students Taking Assessment:13 |
|  m8s1q1__14 | F1 | discrete | Students Taking Assessment:14 |
|  m8s1q1__15 | F1 | discrete | Students Taking Assessment:15 |
|  m8s1q1__16 | F1 | discrete | Students Taking Assessment:16 |
|  m8s1q1__17 | F1 | discrete | Students Taking Assessment:17 |
|  m8s1q1__18 | F1 | discrete | Students Taking Assessment:18 |
|  m8s1q1__19 | F1 | discrete | Students Taking Assessment:19 |
|  m8s1q1__20 | F1 | discrete | Students Taking Assessment:20 |
|  m8s1q1__21 | F1 | discrete | Students Taking Assessment:21 |
|  m8s1q1__22 | F1 | discrete | Students Taking Assessment:22 |
|  m8s1q1__23 | F1 | discrete | Students Taking Assessment:23 |
|  m8s1q1__24 | F1 | discrete | Students Taking Assessment:24 |
|  m8s1q1__25 | F1 | discrete | Students Taking Assessment:25 |
|  m8s1q1__26 | F1 | discrete | Students Taking Assessment:26 |
|  m8s1q1__27 | F1 | discrete | Students Taking Assessment:27 |
|  m8s1q1__28 | F1 | discrete | Students Taking Assessment:28 |
|  m8s1q1__29 | F1 | discrete | Students Taking Assessment:29 |
|  m8s1q1__30 | F1 | discrete | Students Taking Assessment:30 |
|  m8s1q1__31 | F1 | discrete | Students Taking Assessment:31 |
|  m8s1q1__32 | F1 | discrete | Students Taking Assessment:32 |
|  m8s1q1__33 | F1 | discrete | Students Taking Assessment:33 |
|  m8s1q1__34 | F1 | discrete | Students Taking Assessment:34 |
|  m8s1q1__35 | F1 | discrete | Students Taking Assessment:35 |
|  m8s1q1__36 | F1 | discrete | Students Taking Assessment:36 |
|  m8s1q1__37 | F1 | discrete | Students Taking Assessment:37 |
|  m8s1q1__38 | F1 | discrete | Students Taking Assessment:38 |
|  m8s1q1__39 | F1 | discrete | Students Taking Assessment:39 |
|  m8s1q1__40 | F1 | discrete | Students Taking Assessment:40 |
|  m8s1q1__41 | F1 | discrete | Students Taking Assessment:41 |
|  m8s1q1__42 | F1 | discrete | Students Taking Assessment:42 |
|  m8s1q1__43 | F1 | discrete | Students Taking Assessment:43 |
|  m8s1q1__44 | F1 | discrete | Students Taking Assessment:44 |
|  m8s1q1__45 | F1 | discrete | Students Taking Assessment:45 |
|  m8s1q1__46 | F1 | discrete | Students Taking Assessment:46 |
|  m8s1q1__47 | F1 | discrete | Students Taking Assessment:47 |
|  m8s1q1__48 | F1 | discrete | Students Taking Assessment:48 |
|  m8s1q1__49 | F1 | discrete | Students Taking Assessment:49 |
|  comments | F1 | discrete | Comments: |
|  questionnaire_roster__id | F2 | discrete | Id in questionnaire_roster |
|  interview__key | F2 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3sb_tnumber | F2 | contin | Please enter Teacher's roster number |
|  m3s0q1 | F2 | discrete | Is the rostertitle available for interview? |
|  m3s0q1_other | F2 | discrete | Specify Other |
|  teacher_count | F2 | contin | teacher_count |
|  m3saq1 | F2 | discrete | What is your position in the school?  (most senior position) |
|  m3saq2__99 | F2 | discrete | Which grades do you teach this academic year?:Pre-School |
|  m3saq2__1 | F2 | discrete | Which grades do you teach this academic year?:Grade 1 |
|  m3saq2__2 | F2 | discrete | Which grades do you teach this academic year?:Grade 2 |
|  m3saq2__3 | F2 | discrete | Which grades do you teach this academic year?:Grade 3 |
|  m3saq2__4 | F2 | discrete | Which grades do you teach this academic year?:Grade 4 |
|  m3saq2__5 | F2 | discrete | Which grades do you teach this academic year?:Grade 5 |
|  m3saq2__6 | F2 | discrete | Which grades do you teach this academic year?:Grade 6 |
|  m3saq2__7 | F2 | discrete | Which grades do you teach this academic year?:Grade 7 |
|  m3saq2__98 | F2 | discrete | Which grades do you teach this academic year?:Special needs |
|  m3saq3__1 | F2 | discrete | Which subjects did you teach this academic year?:Language |
|  m3saq3__2 | F2 | discrete | Which subjects did you teach this academic year?:Mathematics |
|  m3saq3__3 | F2 | discrete | Which subjects did you teach this academic year?:Both/All Subjects |
|  m3saq3__97 | F2 | discrete | Which subjects did you teach this academic year?:Other (Specify) |
|  m3saq3_other | F2 | discrete | Other (Specify) |
|  m3saq4 | F2 | discrete | What is the highest level of education that you have completed? |
|  m3saq4_other | F2 | discrete | Other (Specify) |
|  m3saq5 | F2 | contin | What year did you begin teaching? |
|  m3saq6 | F2 | contin | What is your age? |
|  m3saq7 | F2 | contin | How much time per day is dedicated to reading practice and/or instruction in rea |
|  m3sbq1_tatt__1 | F2 | discrete | Over the past year, did you have to miss at least one day of class because of an:Collect paycheck? |
|  m3sbq1_tatt__2 | F2 | discrete | Over the past year, did you have to miss at least one day of class because of an:School administrative procedure? |
|  m3sbq1_tatt__3 | F2 | discrete | Over the past year, did you have to miss at least one day of class because of an:Errands or request of the school district office? |
|  m3sbq1_tatt__97 | F2 | discrete | Over the past year, did you have to miss at least one day of class because of an:Other administrative task? Please specify |
|  m3sbq1_other_tatt | F2 | discrete | Specify Other |
|  m3sbq2_tmna__1 | F2 | discrete | What happens if a teacher is absent over 30% of the time without proper justific:Teacher can be dismissed |
|  m3sbq2_tmna__2 | F2 | discrete | What happens if a teacher is absent over 30% of the time without proper justific:Salary can be reduced |
|  m3sbq2_tmna__3 | F2 | discrete | What happens if a teacher is absent over 30% of the time without proper justific:Teacher can be assigned additional monitoring |
|  m3sbq2_tmna__4 | F2 | discrete | What happens if a teacher is absent over 30% of the time without proper justific:Teacher promotion can be delayed |
|  m3sbq2_tmna__5 | F2 | discrete | What happens if a teacher is absent over 30% of the time without proper justific:Teacher would be temporarily suspended |
|  m3sbq2_tmna__6 | F2 | discrete | What happens if a teacher is absent over 30% of the time without proper justific:Written or oral call for attention |
|  m3sbq2_tmna__7 | F2 | discrete | What happens if a teacher is absent over 30% of the time without proper justific:No consequence |
|  m3sbq2_tmna__97 | F2 | discrete | What happens if a teacher is absent over 30% of the time without proper justific:Other (specify) |
|  m3sbq2_tmna__98 | F2 | discrete | What happens if a teacher is absent over 30% of the time without proper justific:Don’t know |
|  m3sbq2_other_tmna | F2 | discrete | Specify Other |
|  m3sbq4_inpt | F2 | discrete | Have you used a PC, laptop, tablet, or other computing device to explain and/or |
|  m3sbq5_pedg__1 | F2 | discrete | What do you do when you notice that some of your students are falling behind?:Group the students in the class according to level |
|  m3sbq5_pedg__2 | F2 | discrete | What do you do when you notice that some of your students are falling behind?:Offer after-school support or remedial classes |
|  m3sbq5_pedg__3 | F2 | discrete | What do you do when you notice that some of your students are falling behind?:Use computer-assisted  learning programs that adapt to the student’s learning level |
|  m3sbq5_pedg__4 | F2 | discrete | What do you do when you notice that some of your students are falling behind?:Provide individualized and targeted instruction during ordinary lessons |
|  m3sbq5_pedg__97 | F2 | discrete | What do you do when you notice that some of your students are falling behind?:Other (Specify) |
|  m3sbq5_other_pedg | F2 | discrete | specify other |
|  m3sbq6_tmna | F2 | discrete | During the last school year, were you formally evaluated? |
|  m3sbq7_tmna__1 | F2 | discrete | During the last school year which authority evaluated your work?:Ministry of Education - Central level |
|  m3sbq7_tmna__2 | F2 | discrete | During the last school year which authority evaluated your work?:Ministry of Education in Province |
|  m3sbq7_tmna__3 | F2 | discrete | During the last school year which authority evaluated your work?:District Education Office |
|  m3sbq7_tmna__4 | F2 | discrete | During the last school year which authority evaluated your work?:Heads of subject departments |
|  m3sbq7_tmna__5 | F2 | discrete | During the last school year which authority evaluated your work?:Parents’ association |
|  m3sbq7_tmna__6 | F2 | discrete | During the last school year which authority evaluated your work?:Principal or senior staff at school |
|  m3sbq7_tmna__97 | F2 | discrete | During the last school year which authority evaluated your work?:Other (Specify) |
|  m3sbq7_tmna_other | F2 | discrete | During the last school year which authority evaluated your work? |
|  m3sbq8_tmna__1 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Attendance |
|  m3sbq8_tmna__2 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Knowledge of subject matter |
|  m3sbq8_tmna__3 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Pedagogical skills in the classroom |
|  m3sbq8_tmna__4 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Compliance with the curriculum |
|  m3sbq8_tmna__5 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Students’ academic achievement |
|  m3sbq8_tmna__6 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Students’ socio-emotional development |
|  m3sbq8_tmna__7 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Parent views |
|  m3sbq8_tmna__8 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Student views |
|  m3sbq8_tmna__9 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Use of ICT in my teaching |
|  m3sbq8_tmna__10 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Use of ICT by students |
|  m3sbq8_tmna__97 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Other |
|  m3sbq8_tmna__98 | F2 | discrete | What specific aspects of your work did they evaluate you on?:Don’t know |
|  m2sbq8_other_tmna | F2 | discrete | Specify Other |
|  m3sbq9_tmna__1 | F2 | discrete | What would happen if a teacher received 2 or more negative evaluations?:The teacher would be dismissed |
|  m3sbq9_tmna__2 | F2 | discrete | What would happen if a teacher received 2 or more negative evaluations?:The teacher’s salary would be reduced |
|  m3sbq9_tmna__3 | F2 | discrete | What would happen if a teacher received 2 or more negative evaluations?:The teacher would be required to partake in professional development |
|  m3sbq9_tmna__4 | F2 | discrete | What would happen if a teacher received 2 or more negative evaluations?:The teacher would be supervised/ monitored more closely by someone at the school or the district |
|  m3sbq9_tmna__7 | F2 | discrete | What would happen if a teacher received 2 or more negative evaluations?:No consequences |
|  m3sbq9_tmna__97 | F2 | discrete | What would happen if a teacher received 2 or more negative evaluations?:Other (specify) |
|  m3sbq9_tmna__98 | F2 | discrete | What would happen if a teacher received 2 or more negative evaluations?:Don’t know |
|  m3sbq9_other_tmna | F2 | discrete | Specify Other |
|  m3bq10_tmna__1 | F2 | discrete | What would happen if a teacher received 2 or more positive evaluations?:The teacher would be promoted |
|  m3bq10_tmna__2 | F2 | discrete | What would happen if a teacher received 2 or more positive evaluations?:The teacher’s salary would be increased |
|  m3bq10_tmna__3 | F2 | discrete | What would happen if a teacher received 2 or more positive evaluations?:The teacher would be offered more professional development opportunities |
|  m3bq10_tmna__4 | F2 | discrete | What would happen if a teacher received 2 or more positive evaluations?:The teacher would be publicly recognized |
|  m3bq10_tmna__7 | F2 | discrete | What would happen if a teacher received 2 or more positive evaluations?:No consequences |
|  m3bq10_tmna__97 | F2 | discrete | What would happen if a teacher received 2 or more positive evaluations?:Other, specify |
|  m3bq10_tmna__98 | F2 | discrete | What would happen if a teacher received 2 or more positive evaluations?:Don't know |
|  m3sbq10_other_tmna | F2 | discrete | Specify Other |
|  m3scq1_tinm | F2 | discrete | It is acceptable for a teacher to be absent if the assigned curriculum has been |
|  m3scq2_tinm | F2 | discrete | It is acceptable for a teacher to be absent if students are left with work to do |
|  m3scq3_tinm | F2 | discrete | It is acceptable for a teacher to be absent if the teacher is doing something us |
|  m3scq4_tinm | F2 | discrete | Students deserve more attention if they attend school regularly. |
|  m3scq5_tinm | F2 | discrete | Students deserve more attention if they come to school with materials |
|  m3scq6_tinm | F2 | discrete | Students deserve more attention if they are motivated to learn |
|  m3scq7_tinm | F2 | discrete | Students have a certain amount of intelligence and cannot do much to change it |
|  m3scq10_tinm | F2 | discrete | To be honest, students can’t really change how intelligent they are |
|  m3scq11_tinm | F2 | discrete | 11. Students can always substantially change how intelligent they are. |
|  m3scq14_tinm | F2 | discrete | Students can change even their basic intelligence level considerably |
|  m3scq15_tinm__1 | F2 | discrete | What is your main motivation to come to school? Ranking:I have always wanted to be a teacher |
|  m3scq15_tinm__2 | F2 | discrete | What is your main motivation to come to school? Ranking:I like teaching |
|  m3scq15_tinm__3 | F2 | discrete | What is your main motivation to come to school? Ranking:Teaching will offer a steady career path |
|  m3scq15_tinm__4 | F2 | discrete | What is your main motivation to come to school? Ranking:Teaching will allow me to shape child and adolescent values |
|  m3scq15_tinm__5 | F2 | discrete | What is your main motivation to come to school? Ranking:Teaching will allow me to benefit the socially disadvantaged |
|  m3sdq1_tsdp__1 | F2 | discrete | Which of the following are taken into account during the recruitment process of:Completed required coursework |
|  m3sdq1_tsdp__2 | F2 | discrete | Which of the following are taken into account during the recruitment process of:Achieved a specific educational qualification |
|  m3sdq1_tsdp__3 | F2 | discrete | Which of the following are taken into account during the recruitment process of:Graduated from any tertiary education degree program |
|  m3sdq1_tsdp__4 | F2 | discrete | Which of the following are taken into account during the recruitment process of:Graduated from a tertiary degree program specifically designed to prepare teachers |
|  m3sdq1_tsdp__5 | F2 | discrete | Which of the following are taken into account during the recruitment process of:Passed a subject content knowledge written test |
|  m3sdq1_tsdp__6 | F2 | discrete | Which of the following are taken into account during the recruitment process of:Passed an interview-stage assessment |
|  m3sdq1_tsdp__7 | F2 | discrete | Which of the following are taken into account during the recruitment process of:Had a minimum amount of practical professional experience |
|  m3sdq1_tsdp__8 | F2 | discrete | Which of the following are taken into account during the recruitment process of:Passed an assessment conducted by a supervisor based on the practical professional experience |
|  m3sdq1_tsdp__9 | F2 | discrete | Which of the following are taken into account during the recruitment process of:The conduct during  mockup class |
|  m3sdq2_tmna | F2 | discrete | Is there a probationary period for new teachers? |
|  m3sdq3_tsup | F2 | discrete | When you started your job as a teacher, did you participate in an induction and/ |
|  m3sdq4_tsup | F2 | discrete | Have you applied any of the skills you gained while participating in the inducti |
|  m3sdq5_tsup__1 | F2 | discrete | If yes, what are some of those skills?:LESSON PLANNING |
|  m3sdq5_tsup__2 | F2 | discrete | If yes, what are some of those skills?:INCREASING ENROLLMENT AND ATTENDANCE: how to retain more students in school |
|  m3sdq5_tsup__3 | F2 | discrete | If yes, what are some of those skills?:CONTENT KNOWLEDGE: e.g., learn better math skills or better language skills |
|  m3sdq5_tsup__4 | F2 | discrete | If yes, what are some of those skills?:GENERAL PEDAGOGICAL SKILLS: e.g. how to engage students with content, how to help students work in groups, how to lead an effective classroom discussion |
|  m3sdq5_tsup__5 | F2 | discrete | If yes, what are some of those skills?:PEDAGOGICAL SKILLS FOR A SPECIFIC CONTENT AREA: e.g. how to teach fractions or how to teach English grammar |
|  m3sdq5_tsup__6 | F2 | discrete | If yes, what are some of those skills?:CLASSROOM MANAGEMENT: how to avoid wasting time, how to discipline students |
|  m3sdq5_tsup__7 | F2 | discrete | If yes, what are some of those skills?:INCLUSIVE EDUCATION PEDAGOGY: e.g. specialized training on inclusive education pedagogy, diverse learning needs and support/enrichment for learning |
|  m3sdq5_tsup__8 | F2 | discrete | If yes, what are some of those skills?:USE OF ICT IN MY TEACHING |
|  m3sdq5_tsup__97 | F2 | discrete | If yes, what are some of those skills?:Other (specify) |
|  m3sdq5_tsup_other | F2 | discrete | Specify Other |
|  m3sdq5a_tsup_etri | F2 | discrete | ICT elements included in training (b) |
|  m3sdq5b_tsup_etri | F2 | discrete | ICT elements included in training (b) |
|  m3sdq6_tsup | F2 | discrete | Were you required to have a teaching practicum as part of your pre-service train |
|  m3sdq7_tsup | F2 | contin | If yes, how long did the (latest) teaching practicum last? |
|  m3sdq8_tsup | F2 | contin | During this period how many hours a day approximately did you actually teach to |
|  m3sdq9_tsup | F2 | discrete | Did you attend any in-service trainings (other than induction) specifically for |
|  m3sdq10_tsup | F2 | contin | Approximately how many total days did the training last? |
|  m3sdq11_tsup | F2 | contin | Over how many weeks was this training and any follow-ups associated with it spre |
|  m3sdq12_tsup | F2 | discrete | What was the main topic of the training? |
|  m3sdq12_other_tsup | F2 | discrete | Specify Other |
|  m3sdq13_tsup | F2 | discrete | How much of the training took place in your classroom (if any)? |
|  m3sdq13a_tsup_etri | F2 | discrete | Grade 5 teachers participated in professional development activities on ICT? |
|  m3sdq13b1_tsup_etri | F2 | discrete | Use of computer based information in teaching |
|  m3sdq13b2_tsup_etri | F2 | discrete | Use of digital resources in teaching |
|  m3sdq13b3_tsup_etri | F2 | discrete | Use of digital learning games in teaching |
|  m3sdq13b4_tsup_etri | F2 | discrete | Use of collaborative software in teaching |
|  m3sdq13b5_tsup_etri | F2 | discrete | Use of graphing in teaching |
|  m3sdq13b6_tsup_etri | F2 | discrete | Use of word processor in teaching |
|  m3sdq13b7_tsup_etri | F2 | discrete | Use of presentation software in teaching |
|  m3sdq14_ildr | F2 | discrete | Are there opportunities for teachers to come together regularly to share ways of |
|  m3sdq15_ildr | F2 | discrete | Has your classroom ever been observed? |
|  m3sdq16_ildr | F2 | contin | If yes, how many months have gone by since the last time it was observed |
|  m3sdq17_ildr__1 | F2 | discrete | If yes, who observed you?:Principal / head teacher |
|  m3sdq17_ildr__2 | F2 | discrete | If yes, who observed you?:Pedagogical coordinator |
|  m3sdq17_ildr__3 | F2 | discrete | If yes, who observed you?:Department head |
|  m3sdq17_ildr__4 | F2 | discrete | If yes, who observed you?:Another teacher |
|  m3sdq17_ildr__5 | F2 | discrete | If yes, who observed you?:Ministry of Education - central level |
|  m3sdq17_ildr__6 | F2 | discrete | If yes, who observed you?:Ministry of Education - province/regional level |
|  m3sdq17_ildr__7 | F2 | discrete | If yes, who observed you?:District education office |
|  m3sdq17_ildr__97 | F2 | discrete | If yes, who observed you?:Other (specify) |
|  m3sdq17_other_ildr | F2 | discrete | Specify Other |
|  m3sdq18_ildr__1 | F2 | discrete | What was the purpose of the classroom observation?:Evaluation |
|  m3sdq18_ildr__2 | F2 | discrete | What was the purpose of the classroom observation?:Professional Development |
|  m3sdq18_ildr__3 | F2 | discrete | What was the purpose of the classroom observation?:Monitoring |
|  m3sdq18_ildr__97 | F2 | discrete | What was the purpose of the classroom observation?:Other (Specify) |
|  m3sdq18_other_ildr | F2 | discrete | Specify Other |
|  m3sdq19_ildr | F2 | discrete | After the observation, did you discuss the results of your observation? |
|  m3sdq20_ildr | F2 | discrete | If yes, how long did it last? |
|  m3sdq21_ildr | F2 | discrete | Did s/he provide you any feedback? |
|  m3sdq22_ildr__1 | F2 | discrete | Did the person who conducted the observation do any of the following activities:S/he asked me to reflect on my own teaching practice |
|  m3sdq22_ildr__2 | F2 | discrete | Did the person who conducted the observation do any of the following activities:S/he praised one specific aspect of your teaching s/he observed during the observation |
|  m3sdq22_ildr__3 | F2 | discrete | Did the person who conducted the observation do any of the following activities:S/he discussed one (and only one) thing you can do to improve your teaching |
|  m3sdq22_ildr__4 | F2 | discrete | Did the person who conducted the observation do any of the following activities:S/he practiced with you how to improve that specific aspect of your teaching during the meeting |
|  m3sdq22_ildr__5 | F2 | discrete | Did the person who conducted the observation do any of the following activities:S/he scheduled the follow up day and time for the next observation |
|  m3sdq23_ildr | F2 | discrete | Think about last week at school – did you have written lesson plans for last wee |
|  m3sdq24_ildr | F2 | discrete | Did you discuss the lesson plans for that week with anyone before teaching them? |
|  m3sdq25_ildr | F2 | discrete | If yes, with whom? |
|  m3sdq25_other_ildr | F2 | discrete | Specify Other |
|  m3seq1_tatt | F2 | discrete | How satisfied or dissatisfied are you with your job as a teacher? |
|  m3seq2_tatt | F2 | discrete | How satisfied or dissatisfied are you with your social status in the community? |
|  m3seq3_tatt | F2 | discrete | If two people became public teachers five years ago and one was much better at t |
|  m3seq4_tatt | F2 | discrete | During the last academic year (20XX- 20XX), have you received any bonuses, in ad |
|  m3seq5_tatt__1 | F2 | discrete | If yes, for what?:Regular attendance |
|  m3seq5_tatt__2 | F2 | discrete | If yes, for what?:Children performance in examination |
|  m3seq5_tatt__3 | F2 | discrete | If yes, for what?:Extra responsibility in school (specify) |
|  m3seq5_tatt__4 | F2 | discrete | If yes, for what?:Teaching in schools that are hard to staff (for instance they might be in remote areas) |
|  m3seq5_tatt__5 | F2 | discrete | If yes, for what?:Subject or grade shortage |
|  m3seq5_tatt__6 | F2 | discrete | If yes, for what?:Obtaining additional qualifications |
|  m3seq5_tatt__7 | F2 | discrete | If yes, for what?:School good performance |
|  m3seq5_tatt__97 | F2 | discrete | If yes, for what?:Other (Specify) |
|  m3seq5_other_tatt | F2 | discrete | Specify Other |
|  m3seq6_tatt | F2 | discrete | Was your  salary delayed in the last academic year? |
|  m3seq7_tatt | F2 | contin | How many months was your  salary delayed in the last academic year (200XX- 200XX |
|  m3seq8_tsdp__1 | F2 | discrete | What criteria/factors are used to determine which teacher would be assigned to f:Years of experience |
|  m3seq8_tsdp__2 | F2 | discrete | What criteria/factors are used to determine which teacher would be assigned to f:Job title hierarchy |
|  m3seq8_tsdp__3 | F2 | discrete | What criteria/factors are used to determine which teacher would be assigned to f:Performance as assessed by a school authority or colleagues |
|  m3seq8_tsdp__4 | F2 | discrete | What criteria/factors are used to determine which teacher would be assigned to f:Performance as assessed by external evaluators |
|  m3seq8_tsdp__5 | F2 | discrete | What criteria/factors are used to determine which teacher would be assigned to f:Results of an interview |
|  m3seq8_tsdp__6 | F2 | discrete | What criteria/factors are used to determine which teacher would be assigned to f:Teacher's own request |
|  m3seq8_tsdp__7 | F2 | discrete | What criteria/factors are used to determine which teacher would be assigned to f:Director's own request |
|  m3seq8_tsdp__97 | F2 | discrete | What criteria/factors are used to determine which teacher would be assigned to f:Other (please specify) |
|  m3seq8_tsdp__99 | F2 | discrete | What criteria/factors are used to determine which teacher would be assigned to f:Don't know |
|  m3seq8_other_tsdp | F2 | discrete | Specify Other |
|  m3covq1 | F2 | discrete | While school was closed to students, were you in contact with your students? |
|  m3covq2__1 | F2 | discrete | What type of communication channel did you use with your students?:In-person (e.g. when delivering paper, doing small group work, etc.) |
|  m3covq2__2 | F2 | discrete | What type of communication channel did you use with your students?:using phone calls |
|  m3covq2__3 | F2 | discrete | What type of communication channel did you use with your students?:using text/SMS (phone) |
|  m3covq2__4 | F2 | discrete | What type of communication channel did you use with your students?:using social media (e.g. WhatsApp) or chat |
|  m3covq2__5 | F2 | discrete | What type of communication channel did you use with your students?:using email |
|  m3covq2__6 | F2 | discrete | What type of communication channel did you use with your students?:using online platform (e.g. zoom, google meet, Teams, etc.) |
|  m3covq2__97 | F2 | discrete | What type of communication channel did you use with your students?:Other (Specify) |
|  m3covq2_other | F2 | discrete | Other specify |
|  m3covq3 | F2 | discrete | How often did you communicate/interact remotely with each student? |
|  m3covq4 | F2 | discrete | What proportion of your students participated in remote learning activities? |
|  m3covq5__1 | F2 | discrete | What were the main constraints?:Students lacked the necessary devices (e.g., laptop or tablet) |
|  m3covq5__2 | F2 | discrete | What were the main constraints?:Students lacked reliable Internet access (Wi-Fi connectivity) |
|  m3covq5__3 | F2 | discrete | What were the main constraints?:I encountered technical issues and couldn’t connect with them |
|  m3covq5__4 | F2 | discrete | What were the main constraints?:Students had other responsibilities at home |
|  m3covq5__5 | F2 | discrete | What were the main constraints?:Students had other basic needs that were not being met |
|  m3covq5__6 | F2 | discrete | What were the main constraints?:Parents/guardians had other responsibilities and could not always provide students with needed assistance |
|  m3covq5__7 | F2 | discrete | What were the main constraints?:Students didn’t receive the printed materials |
|  m3covq5__97 | F2 | discrete | What were the main constraints?:Other (specify) |
|  m3covq5_other | F2 | discrete | Other specify |
|  m3covq6__1 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:Less group work |
|  m3covq6__2 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:More group work |
|  m3covq6__3 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:After school tutoring (with struggling students) |
|  m3covq6__4 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:Remedial (revisions of skills that should have previously been acquired) |
|  m3covq6__5 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:More learning assessments (to identify individual student’s skills and needs) |
|  m3covq6__6 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:Grouping/differentiating instruction |
|  m3covq6__7 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:Use blended approaches (i.e. using other than in-person approaches) |
|  m3covq6__97 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:Other (specify) |
|  m3covq6_other | F2 | discrete | Other specify |
|  m3covq7__1 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:Focusing on specific parts of the curriculum |
|  m3covq7__2 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:Assessing students’ learning |
|  m3covq7__3 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:Adjusting pedagogy to the students’ learning levels |
|  m3covq7__4 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:Using new lesson guides/etc. |
|  m3covq7__97 | F2 | discrete | have you changed the way you teach (focusing on pedagogical approaches)?:Other (specify) |
|  m3covq7_other | F2 | discrete | Other specify |
|  m3covq9 | F2 | discrete | How has your level of motivation changed since then? |
|  m3_clim_q3 | F2 | discrete | schools/teachers should be required to incorporate climate related topics |
|  m3_clim_q4 | F2 | discrete | If no, what is the biggest reason why not: |
|  m3_clim_q4_other | F2 | discrete | Please specify |
|  m3_clim_q5 | F2 | discrete | Do you think climate education should be incorporated into the curriculum? |
|  m3_clim_q6 | F2 | discrete | Maximum amount of EXTRA class time per month  to spend teaching climate topics |
|  m3sb_troster | F2 | discrete | Roster list question |
|  interview__id | F2 | discrete | Unique 32-character long identifier of the interview |
|  teacher_assessment_answers__id | F3 | discrete | Id in teacher_assessment_answers |
|  interview__key | F3 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m5sb_tnum | F3 | contin | Please enter Teacher's roster number |
|  typetest | F3 | discrete | typeoftest |
|  m5s1q1a_grammer | F3 | discrete | (Unless, If, Perhaps, Although) you tidy up your room, you won’t get candy. |
|  m5s1q1b_grammer | F3 | discrete | (When, If, Because, Although) I was telling the truth, my mother didn’t believe |
|  m5s1q1c_grammer | F3 | discrete | A person    who          (which, who, when, may) flies an airplane is a pilot. |
|  m5s1q1d_grammer | F3 | discrete | My sister likes to read,    so         (so, although, perhaps, when) I have boug |
|  m5s1q1e_grammer | F3 | discrete | If I were a doctor, I    shall          (will, would, shall, am able to) work i |
|  m5s1q1f_grammer | F3 | discrete | The accident     had seen         (see, saw, had seen, was seen) by three people |
|  m5s1q2a_cloze | F3 | discrete | Javid, it is (a)   half         past seven. |
|  m5s1q2b_cloze | F3 | discrete | Get (b)                         . |
|  m5s1q2c_cloze | F3 | discrete | Today there is a (c)    big          football match at school. |
|  m5s1q2d_cloze | F3 | discrete | Juma:    Father, I (d)    want       not go to school. |
|  m5s1q2e_cloze | F3 | discrete | I am (e)                       scared to go. |
|  m5s1q2f_cloze | F3 | discrete | Everyone (f)    hates          me. |
|  m5s1q2g_cloze | F3 | discrete | The players want to beat (g)                    . |
|  m5s1q2h_cloze | F3 | discrete | (h)  Where              do I have to go to school? |
|  m5s1q2i_cloze | F3 | discrete | Father: You are going and that is final. I will give you two  (i) |
|  m5s1q2j_cloze | F3 | discrete | have to go to school today. First, you are 40 (j)   years         old. |
|  m5s1q2k_cloze | F3 | discrete | Javid, it is (a)   half         past seven. |
|  m5s1q4a_passage | F3 | discrete | 4a. Why did the animals huddle together beneath the bushes? |
|  m5s1q4b_passage | F3 | discrete | 4b. “His big eyes widened like saucers.” What do these words from the story tell |
|  m5s1q4c_passage | F3 | discrete | 4c. What made the roaring sound in the distance? |
|  m5s2q1a_number | F3 | discrete | 1a. 5/8  +1/4=  6/12 |
|  m5s2q1b_number | F3 | discrete | 1b. √36- √9= √27 |
|  m5s2q1c_number | F3 | discrete | 1c. 343+215+127= 685 |
|  m5s2q1d_number | F3 | discrete | 1d. 72÷9= 7 |
|  m5s2q1e_number | F3 | discrete | 1e. 37×13 = 3711 |
|  m5s2q2_number | F3 | discrete | 2. Which two numbers add up to make 0.81? |
|  m5s2q3_number | F3 | discrete | 3. Circle the one that gives the smallest answer? |
|  m5s2q4a_number | F3 | discrete | 4a. Complete these fractions so that they are equivalent |
|  m5s2q4b_number | F3 | discrete | 4b. Complete these fractions so that they are equivalent |
|  m5s2q5_number | F3 | discrete | 5. 2 exercise books cost 14 Kips. What is the cost of 15 exercise books? |
|  m5s2q6_geometric | F3 | discrete | 6. How many sides does a triangle have? |
|  m5s2q7_geometric | F3 | discrete | 7. Lines that cannot meet are lines |
|  m5s2q8_data | F3 | discrete | 8. What time did Chanla arrive? |
|  m5s2q9a_data | F3 | discrete | 9a. How many people had cats? |
|  m5s2q9b_data | F3 | discrete | 9b. Which animal was the least popular? |
|  m5s2q10a_data | F3 | discrete | 10a. Look at the graph. How far has Joe ridden after 6 hours? |
|  m5s2q10b_data | F3 | discrete | 10b. Chan started riding at 8.30 in the morning. How far had he gone at 12.00pm? |
|  m5s2q11a_number | F3 | discrete | 11a. √(144= )12 |
|  m5s2q11b_number | F3 | discrete | 11b. 12.15-11.83= 0.32 |
|  m5s2q11c_number | F3 | discrete | 11c. 3/4÷7/8= 21/32 |
|  m5s2q12_number | F3 | discrete | 12. What is n? |
|  m5s2q13a_geometric | F3 | discrete | 13a. (a)	Perimeter: |
|  m5s2q13b_geometric | F3 | discrete | 13b. (b)	Area: 90 cm2 |
|  m5sb_troster | F3 | discrete | Roster list question |
|  interview__id | F3 | discrete | Unique 32-character long identifier of the interview |
|  TEACHERS__id | F4 | discrete | Id in TEACHERS |
|  interview__key | F4 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  w1 | F4 | contin | w1 |
|  w2 | F4 | contin | w2 |
|  nationality_teacher_gbn | F4 | discrete | Nationality |
|  nationality_teacher_gbn_other | F4 | discrete | Other nationality |
|  m2saq3 | F4 | discrete | Sex |
|  m2saq4 | F4 | discrete | Position in the school |
|  m2saq4_other | F4 | discrete | Specify Other |
|  m2saq5 | F4 | discrete | Contract Status |
|  m2saq5_other | F4 | discrete | Specify Other |
|  m2saq6 | F4 | discrete | Full-time/Part-time |
|  m2saq7__99 | F4 | discrete | Which grades did {Teacher} teach this year:Pre-School |
|  m2saq7__1 | F4 | discrete | Which grades did {Teacher} teach this year:Grade 1 |
|  m2saq7__2 | F4 | discrete | Which grades did {Teacher} teach this year:Grade 2 |
|  m2saq7__3 | F4 | discrete | Which grades did {Teacher} teach this year:Grade 3 |
|  m2saq7__4 | F4 | discrete | Which grades did {Teacher} teach this year:Grade 4 |
|  m2saq7__5 | F4 | discrete | Which grades did {Teacher} teach this year:Grade 5 |
|  m2saq7__6 | F4 | discrete | Which grades did {Teacher} teach this year:Grade 6 |
|  m2saq7__7 | F4 | discrete | Which grades did {Teacher} teach this year:Grade 7 |
|  m2saq7__98 | F4 | discrete | Which grades did {Teacher} teach this year:Special needs |
|  m2saq7__n77 | F4 | discrete | Which grades did {Teacher} teach this year:Not Applicable - principal not teaching |
|  grade_joined | F4 | discrete | grade_joined |
|  m2saq8__1 | F4 | discrete | Which subjects did {Teacher} teach this year:Language |
|  m2saq8__2 | F4 | discrete | Which subjects did {Teacher} teach this year:Mathematics |
|  m2saq8__3 | F4 | discrete | Which subjects did {Teacher} teach this year:Both/All Subjects |
|  m2saq8__97 | F4 | discrete | Which subjects did {Teacher} teach this year:Other (Specify) |
|  m2saq8__n77 | F4 | discrete | Which subjects did {Teacher} teach this year:Not Applicable - principal not teaching |
|  subject_joined | F4 | discrete | subject_joined |
|  m2saq8_other | F4 | discrete | Specify Other |
|  teacher_available | F4 | discrete | Is the teacher available for interview |
|  teacher_available_other | F4 | discrete | Specify Other |
|  fourthgrade | F4 | contin | fourthgrade |
|  fifthgrade | F4 | contin | fifthgrade |
|  thirdgrade | F4 | contin | thirdgrade |
|  secondgrade | F4 | contin | secondgrade |
|  sixthgrade | F4 | contin | sixthgrade |
|  seventgrade | F4 | contin | seventgrade |
|  firstgrade | F4 | contin | firstgrade |
|  teachcodedisplay | F4 | contin | teachcodedisplay |
|  principalcode | F4 | contin | principalcode |
|  m2sbq3_efft | F4 | discrete | What was the Principal doing when you located him/ her on the visit? |
|  teachcode | F4 | contin | teachcode |
|  m2sbq6_efft | F4 | discrete | What was the teacher doing when you located him/ her on the visit? |
|  questionnaireteachcode2 | F4 | contin | questionnaireteachcode2 |
|  m2saq2 | F4 | discrete | Roster list question |
|  interview__id | F4 | discrete | Unique 32-character long identifier of the interview |
|  etri_roster__id | F5 | discrete | Id in etri_roster |
|  interview__key | F5 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3s0q1_etri | F5 | discrete | Is the rostertitle available for interview? |
|  m3s0q1_etri_other | F5 | discrete | Specify Other |
|  teacher_count_etri | F5 | contin | teacher_count_etri |
|  m3sfq4_prac_etri | F5 | discrete | Are there guidelines defining teachers' digital competences? |
|  m3sgq1_stprac_etri | F5 | discrete | How often did the grade 5 students use these digital devices? |
|  m3sgq5_stprac_etri | F5 | discrete | Does the educational curriculum recommend using ICT in the teaching of grade 5 ? |
|  m3sgq6_stprac_etri | F5 | discrete | G6) Is there a framework or set of guidelines defining the digital competences* that a student is expected to have or develop? |
|  m3sgq7_stprac_etri | F5 | discrete | were the digital competencies of the grade 5 digital competencies evaluated? |
|  m3sb_etri_roster | F5 | discrete | Roster list question |
|  interview__id | F5 | discrete | Unique 32-character long identifier of the interview |
|  ecd_assessment__id | F6 | discrete | Id in ecd_assessment |
|  interview__key | F6 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m6s1q2 | F6 | contin | ECD student age |
|  m6s1q3 | F6 | discrete | What is the student's gender? |
|  m6s1kg | F6 | discrete | Did you attend KG? |
|  m6s1q4 | F6 | discrete | Did the child provide verbal consent? |
|  m6s2q1_vocabn | F6 | contin | Count: 1a. Name as many things that you can eat as you can. |
|  m6s2q1b_vocabn | F6 | contin | Count 1b. Tell me the names of all the animals that you know. |
|  m6s2q5a_comprehension | F6 | discrete | 2a. Now I am going to ask you some questions about the story. |
|  m6s2q5b_comprehension | F6 | discrete | 2b. Now I am going to ask you some questions about the story. |
|  m6s2q5c_comprehension | F6 | discrete | 2c. Now I am going to ask you some questions about the story. |
|  m6s2q5d_comprehension | F6 | discrete | 2d. Now I am going to ask you some questions about the story. |
|  m6s2q5e_comprehension | F6 | discrete | 2e. Now I am going to ask you some questions about the story. |
|  m6s2q2a_letters | F6 | discrete | 3a. Here are some letters. Point to each letter and tell me the name of the lett |
|  m6s2q2b_letters | F6 | discrete | 3b. Here are some letters. Point to each letter and tell me the name of the lett |
|  m6s2q2c_letters | F6 | discrete | 3c. Here are some letters. Point to each letter and tell me the name of the lett |
|  m6s2q2d_letters | F6 | discrete | 3d. Here are some letters. Point to each letter and tell me the name of the lett |
|  m6s2q2e_letters | F6 | discrete | 3e. Here are some letters. Point to each letter and tell me the name of the lett |
|  m6s2q2f_letters | F6 | discrete | 3f. Here are some letters. Point to each letter and tell me the name of the lett |
|  m6s2q2g_letters | F6 | discrete | 3g. Here are some letters. Point to each letter and tell me the name of the lett |
|  m6s2q2h_letters | F6 | discrete | 3h. Here are some letters. Point to each letter and tell me the name of the lett |
|  m6s2q3a_words | F6 | discrete | 4a. Here are some words.  Point to each word and then read each word. |
|  m6s2q3b_words | F6 | discrete | 4b. Here are some words.  Point to each word and then read each word. |
|  m6s2q3c_words | F6 | discrete | 4c. Here are some words.  Point to each word and then read each word. |
|  m6s2q4a_sentence | F6 | discrete | What is this sentence? I like to run. |
|  m6s2q4b_sentence | F6 | discrete | 5b What is this sentence? Javier kicked the ball. |
|  m6s2q4c_sentence | F6 | discrete | 5c What is this sentence? The dog sleeps on the blanket |
|  m6s2q6a_name_writing | F6 | discrete | 6a. Name Writing |
|  m6s2q6b_name_writing | F6 | discrete | 6b. Name Writing |
|  m6s2q7a_print | F6 | discrete | 7a. Print Awareness |
|  m6s2q7b_print | F6 | discrete | 7b. Print Awareness |
|  m6s2q7c_print | F6 | discrete | 7c. Print Awareness |
|  m6s2q8_counting | F6 | contin | 8a. Verbal Counting |
|  m6s2q9a_produce_set | F6 | discrete | 9a. Producing A Set |
|  m6s2q9b_produce_set | F6 | discrete | 9b. Producing A Set |
|  m6s2q10a_number_ident | F6 | discrete | 10a. Number Identification |
|  m6s2q10b_number_ident | F6 | discrete | 10b. Number Identification |
|  m6s2q10c_number_ident | F6 | discrete | 10c. Number Identification |
|  m6s2q10d_number_ident | F6 | discrete | 10d. Number Identification |
|  m6s2q10e_number_ident | F6 | discrete | 10e. Number Identification |
|  m6s2q10f_number_ident | F6 | discrete | 10f. Number Identification |
|  m6s2q10g_number_ident | F6 | discrete | 10g. Number Identification |
|  m6s2q10h_number_ident | F6 | discrete | 10h. Number Identification |
|  m6s2q10i_number_ident | F6 | discrete | 10i. Number Identification |
|  m6s2q10j_number_ident | F6 | discrete | 10j. Number Identification |
|  m6s2q11a_number_compare | F6 | discrete | 11a. Number Comparison |
|  m6s2q11b_number_compare | F6 | discrete | 11b. Number Comparison |
|  m6s2q11c_number_compare | F6 | discrete | 11c. Number Comparison |
|  m6s2q12a_simple_add | F6 | discrete | 12a. Simple Addition |
|  m6s2q12b_simple_add | F6 | discrete | 12b. Simple Addition |
|  m6s2q12c_simple_add | F6 | discrete | 12c. Simple Addition |
|  m6s2q13prac_backward_digit | F6 | discrete | 13p1. Backward Digit Span |
|  m6s2q13prac2_backward_digit | F6 | discrete | 13p2. Backward Digit Span |
|  m6s2q13a_backward_digit | F6 | discrete | 13a. Backward Digit Span |
|  m6s2q13b_backward_digit | F6 | discrete | 13b. Backward Digit Span |
|  m6s2q13c_backward_digit | F6 | discrete | 13c. Backward Digit Span |
|  m6s2q13d_backward_digit | F6 | discrete | 13d. Backward Digit Span |
|  m6s2q14prac1_head_shoulders | F6 | discrete | 14p1. Head, Toes, Knees, Shoulders Task |
|  m6s2q14prac2_head_shoulders | F6 | discrete | 14p2. Head, Toes, Knees, Shoulders Task |
|  m6s2q14prac3_head_shoulders | F6 | discrete | 14p3. Head, Toes, Knees, Shoulders Task |
|  m6s2q14a_head_shoulders | F6 | discrete | 14a. Head, Toes, Knees, Shoulders Task |
|  m6s2q14b_head_shoulders | F6 | discrete | 14b. Head, Toes, Knees, Shoulders Task |
|  m6s2q14c_head_shoulders | F6 | discrete | 14c. Head, Toes, Knees, Shoulders Task |
|  m6s2q14d_head_shoulders | F6 | discrete | 14d. Head, Toes, Knees, Shoulders Task |
|  m6s2q14e_head_shoulders | F6 | discrete | 14e. Head, Toes, Knees, Shoulders Task |
|  m6s2q14prac1b_head_shoulders | F6 | discrete | 14p1b. Head, Toes, Knees, Shoulders Task |
|  m6s2q14prac2b_head_shoulders | F6 | discrete | 14p2b. Head, Toes, Knees, Shoulders Task |
|  m6s2q14prac3b_head_shoulders | F6 | discrete | 14p3b. Head, Toes, Knees, Shoulders Task |
|  m6s2q14f_head_shoulders | F6 | discrete | 14f. Head, Toes, Knees, Shoulders Task |
|  m6s2q14g_head_shoulders | F6 | discrete | 14g. Head, Toes, Knees, Shoulders Task |
|  m6s2q14h_head_shoulders | F6 | discrete | 14h. Head, Toes, Knees, Shoulders Task |
|  m6s2q14i_head_shoulders | F6 | discrete | 14i. Head, Toes, Knees, Shoulders Task |
|  m6s2q14j_head_shoulders | F6 | discrete | 14j. Head, Toes, Knees, Shoulders Task |
|  m6s2q14k_head_shoulders | F6 | discrete | 14k. Head, Toes, Knees, Shoulders Task |
|  m6s2q14l_head_shoulders | F6 | discrete | 14l. Head, Toes, Knees, Shoulders Task |
|  m6s2q14m_head_shoulders | F6 | discrete | 14m. Head, Toes, Knees, Shoulders Task |
|  m6s2q14n_head_shoulders | F6 | discrete | 14n. Head, Toes, Knees, Shoulders Task |
|  m6s2q14o_head_shoulders | F6 | discrete | 14o. Head, Toes, Knees, Shoulders Task |
|  m6s2q15a_perspective | F6 | discrete | 15a. Perspective-Taking/Empathy |
|  m6s2q15a_perspective_response | F6 | discrete | Please write in child's response |
|  m6s2q15b_perspective | F6 | discrete | 15b. Perspective-Taking/Empathy |
|  m6s2q15b_perspective_response | F6 | discrete | 15b. Please write in child's response |
|  m6s2q15c_perspective | F6 | discrete | 15c. Perspective-Taking/Empathy |
|  m6s2q15c_perspective_response | F6 | discrete | 15c. Please write in child's response |
|  m6s2q16a_conflict_resol | F6 | discrete | 16a. Conflict Resolution |
|  m6s2q16a_conflict_resol_response | F6 | discrete | 16a. Please write in child's response |
|  m6s2q16b_conflict_resol | F6 | discrete | 16b. Conflict Resolution |
|  m6s2q16b_conflict_resol_response | F6 | discrete | 16b. Please write in child's response |
|  language_g1 | F6 | discrete | 17. What language was used to administer the direct assessment? |
|  language_g1_other | F6 | discrete | 18. Please specify |
|  refugee_g1 | F6 | discrete | 18. Is the children a refugee (either international or internally displaced)? |
|  notekid | F6 | discrete | notekid |
|  m6s1q1 | F6 | discrete | Roster list question |
|  interview__id | F6 | discrete | Unique 32-character long identifier of the interview |
|  fourth_grade_assessment__id | F7 | discrete | Id in fourth_grade_assessment |
|  interview__key | F7 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m8s1q2 | F7 | contin | ECD student age |
|  m8s1q3 | F7 | discrete | What is the student's gender? |
|  m8_language_assessment | F7 | discrete | What is the language of assessment? |
|  m8_covid_yn | F7 | discrete | Did the student respond to the Covid questions? |
|  m8ssbq1_ses | F7 | discrete | 1.	Did one of your parents/caregivers go to university? |
|  m8ssbq2_ses | F7 | contin | 2.	How many people live in your house with you? |
|  m8ssbq3_ses | F7 | contin | 3.	How many times did you eat yesterday? |
|  m8ssbq4_ses | F7 | contin | 4.	How many pairs of shoes do you have? |
|  m8ssbq5_ses | F7 | discrete | 5.	Which bathroom looks more like the one at home? |
|  m8ssbq6_ses | F7 | discrete | 6. How many books do you and your family have at home? |
|  m8ssbq7_ses__1 | F7 | discrete | Language spoken at home:French |
|  m8ssbq7_ses__99 | F7 | discrete | Language spoken at home:Other (please specify)` |
|  language_other | F7 | discrete | Other language spoken at home |
|  m8saq2_id__1 | F7 | discrete | 2 Record the number of letters correctly identified in the box.:L |
|  m8saq2_id__2 | F7 | discrete | 2 Record the number of letters correctly identified in the box.:e |
|  m8saq2_id__3 | F7 | discrete | 2 Record the number of letters correctly identified in the box.:h |
|  m8saq2_id__4 | F7 | discrete | 2 Record the number of letters correctly identified in the box.:F |
|  m8saq2_id__5 | F7 | discrete | 2 Record the number of letters correctly identified in the box.:u |
|  m8saq2_id__6 | F7 | discrete | 2 Record the number of letters correctly identified in the box.:v |
|  m8saq2_id__7 | F7 | discrete | 2 Record the number of letters correctly identified in the box.:A |
|  m8saq2_id__8 | F7 | discrete | 2 Record the number of letters correctly identified in the box.:s |
|  m8saq2_id__9 | F7 | discrete | 2 Record the number of letters correctly identified in the box.:c |
|  m8saq2_id__99 | F7 | discrete | 2 Record the number of letters correctly identified in the box.:No response |
|  m8saq3_id__1 | F7 | discrete | 3 Record the number of words correctly identified in the box.:under |
|  m8saq3_id__2 | F7 | discrete | 3 Record the number of words correctly identified in the box.:respect |
|  m8saq3_id__3 | F7 | discrete | 3 Record the number of words correctly identified in the box.:story |
|  m8saq3_id__4 | F7 | discrete | 3 Record the number of words correctly identified in the box.:bananas |
|  m8saq3_id__5 | F7 | discrete | 3 Record the number of words correctly identified in the box.:green |
|  m8saq3_id__6 | F7 | discrete | 3 Record the number of words correctly identified in the box.:greet |
|  m8saq3_id__7 | F7 | discrete | 3 Record the number of words correctly identified in the box.:fruit |
|  m8saq3_id__8 | F7 | discrete | 3 Record the number of words correctly identified in the box.:father |
|  m8saq3_id__9 | F7 | discrete | 3 Record the number of words correctly identified in the box.:outside |
|  m8saq3_id__99 | F7 | discrete | 3 Record the number of words correctly identified in the box.:No response |
|  m8saq4_id | F7 | contin | 4 Record the number of pictures correctly named. |
|  m8saq5_story | F7 | discrete | (6a) Where did Sam and Nakato meet? |
|  m8saq6_story | F7 | discrete | (6b) What animal was sleeping next to Nakato? |
|  m8saq7_word_choice | F7 | discrete | 7 Choose the correct word from the box and fill in the blank spaces to complete |
|  m8saq7a_gir | F7 | discrete | 13. What did the animals talk about every morning? |
|  m8saq7b_gir | F7 | discrete | 14. Why didn’t anyone listen to the giraffe? |
|  m8saq7c_gir | F7 | discrete | 15. Which leaves did the giraffe eat? |
|  m8saq7d_gir | F7 | discrete | 16. Why were the animals on the ground afraid of the giraffe? |
|  m8saq7e_gir | F7 | discrete | 17. What did the giraffe stop doing over the summer? |
|  m8saq7f_gir | F7 | discrete | 18. Why did the animals huddle together beneath the bushes? |
|  m8saq7g_gir | F7 | discrete | 19. “His big eyes widened like saucers.” What do these words from the story tell |
|  m8saq7h_gir | F7 | discrete | 20. What made the roaring sound in the distance? |
|  m8saq7i_gir | F7 | discrete | 21. Who told the animals to climb to the treetops? |
|  m8saq7j_gir | F7 | discrete | 22. Why were the animals trying to climb to the treetops? |
|  m8saq7k_gir | F7 | discrete | 23. Why couldn’t some of the animals climb up the slippery tree trunks? |
|  m8sbq1_number_sense__1 | F7 | discrete | 1 Please circle the numbers indicated by the teacher.:55 |
|  m8sbq1_number_sense__2 | F7 | discrete | 1 Please circle the numbers indicated by the teacher.:3 |
|  m8sbq1_number_sense__3 | F7 | discrete | 1 Please circle the numbers indicated by the teacher.:23 |
|  m8sbq1_number_sense__4 | F7 | discrete | 1 Please circle the numbers indicated by the teacher.:4 |
|  m8sbq1_number_sense__5 | F7 | discrete | 1 Please circle the numbers indicated by the teacher.:12 |
|  m8sbq1_number_sense__6 | F7 | discrete | 1 Please circle the numbers indicated by the teacher.:6 |
|  m8sbq1_number_sense__7 | F7 | discrete | 1 Please circle the numbers indicated by the teacher.:34 |
|  m8sbq1_number_sense__8 | F7 | discrete | 1 Please circle the numbers indicated by the teacher.:21 |
|  m8sbq1_number_sense__9 | F7 | discrete | 1 Please circle the numbers indicated by the teacher.:9 |
|  m8sbq1_number_sense__99 | F7 | discrete | 1 Please circle the numbers indicated by the teacher.:No response |
|  m8sbq2_number_sense | F7 | discrete | 2 Please put these numbers in the right order, from lower to higher: |
|  m8sbq3a_arithmetic | F7 | discrete | 3a Please provide the correct answers to the following equations: 8+7 |
|  m8sbq3b_arithmetic | F7 | discrete | 3b Please provide the correct answers to the following equations: 28+27 |
|  m8sbq3c_arithmetic | F7 | discrete | 3c Please provide the correct answers to the following equations: 335+145 |
|  m8sbq3d_arithmetic | F7 | discrete | 3d Please provide the correct answers to the following equations: 8-5 |
|  m8sbq3e_arithmetic | F7 | discrete | 3e Please provide the correct answers to the following equations: 57-49 |
|  m8sbq3f_arithmetic | F7 | discrete | 3f Please provide the correct answers to the following equations: 7x8 |
|  m8sbq3g_arithmetic | F7 | discrete | 3g Please provide the correct answers to the following equations: 37x40 |
|  m8sbq3h_arithmetic | F7 | discrete | 3h Please provide the correct answers to the following equations: 214x104 |
|  m8sbq3i_arithmetic | F7 | discrete | 3i Please provide the correct answers to the following equations: 6/3 |
|  m8sbq3j_arithmetic | F7 | discrete | 3j Please provide the correct answers to the following equations: 75/5 |
|  m8sbq4_arithmetic | F7 | discrete | 4 Which gives smallest answer |
|  m8sbq5_word_problem | F7 | discrete | 5 A box contains 26 oranges. How many oranges are contained in 10 boxes? |
|  m8sbq6_sequences | F7 | discrete | 6 48     →      24     →       12     →       6 |
|  m8_cov_q1 | F7 | discrete | how long was school closed for attendance due to Covid or other emergencies? |
|  m8_cov_q3 | F7 | discrete | During this period, did you have access to ICT equipment? |
|  m8_cov_q4 | F7 | discrete | Did you have access to a working internet connection (wifi connectivity)? |
|  m8_cov_q5 | F7 | discrete | How often were you able to use one of these connected devices? |
|  m8_cov_q6a | F7 | discrete | Were some of your family/household members able to help with schoolwork? |
|  m8_cov_q6b__1 | F7 | discrete | How did your family/household members help with schoolwork?:Helped with reading and writing |
|  m8_cov_q6b__2 | F7 | discrete | How did your family/household members help with schoolwork?:Helped with mathematics |
|  m8_cov_q6b__3 | F7 | discrete | How did your family/household members help with schoolwork?:Asked what students was learning |
|  m8_cov_q6b__4 | F7 | discrete | How did your family/household members help with schoolwork?:Helped create a learning timetable |
|  m8_cov_q6b__5 | F7 | discrete | How did your family/household members help with schoolwork?:Helped access learning materials |
|  m8_cov_q6b__6 | F7 | discrete | How did your family/household members help with schoolwork?:Checked student was completing schoolwork |
|  m8_cov_q6b__7 | F7 | discrete | How did your family/household members help with schoolwork?:Explained new topics to you |
|  m8_cov_q6b__8 | F7 | discrete | How did your family/household members help with schoolwork?:Helped use digital device for schoolwork |
|  m8_cov_q6b__97 | F7 | discrete | How did your family/household members help with schoolwork?:Other (Specify) |
|  m8_cov_q6b_other | F7 | discrete | Other specify |
|  m8_cov_q7 | F7 | discrete | Since the COVID closure, have you attended additional classes with a tutor? |
|  m8_cov_q8a | F7 | discrete | Have you changed schools over the last 2 years? |
|  m8_cov_q8b | F7 | discrete | If yes, did your previous school have to close due to Covid? |
|  m8_cov_9__1 | F7 | discrete | Did your family face special difficulties?:Parents/guardians lost their job(s) |
|  m8_cov_9__2 | F7 | discrete | Did your family face special difficulties?:Family had to be more careful with money |
|  m8_cov_9__3 | F7 | discrete | Did your family face special difficulties?:Parents/guardians had to work from home |
|  m8_cov_9__4 | F7 | discrete | Did your family face special difficulties?:Family had to move to a new location |
|  m8_cov_9__5 | F7 | discrete | Did your family face special difficulties?:You had to live away from parents/guardians |
|  m8_cov_9__6 | F7 | discrete | Did your family face special difficulties?:Someone in household was very sick |
|  m8_cov_9__7 | F7 | discrete | Did your family face special difficulties?:Other (Specify) |
|  m8_cov_9_other | F7 | discrete | Other specify |
|  m8_cov_q10a | F7 | discrete | Did you have more worries and concerns than usual? |
|  m8_cov_q10b__1 | F7 | discrete | What were your additional worries and concerns?:Worried about changes in schooling |
|  m8_cov_q10b__2 | F7 | discrete | What were your additional worries and concerns?:Worried how school closures affected learning |
|  m8_cov_q10b__3 | F7 | discrete | What were your additional worries and concerns?:Scared/worried about difficulties faced by family/friends |
|  m8_cov_q10b__4 | F7 | discrete | What were your additional worries and concerns?:Scared/Worried about getting sick |
|  m8_cov_q10b__5 | F7 | discrete | What were your additional worries and concerns?:Difficult to concentrate on schoolwork |
|  m8_cov_q10b__6 | F7 | discrete | What were your additional worries and concerns?:More lonely than usual |
|  m8_cov_q10b__7 | F7 | discrete | What were your additional worries and concerns?:Upset about things would not normally bother |
|  m8_cov_q10b__8 | F7 | discrete | What were your additional worries and concerns?:Felt angry more often than usual |
|  m8_cov_q10b__97 | F7 | discrete | What were your additional worries and concerns?:Other (Specify) |
|  m8_cov_q10b_other | F7 | discrete | Other specify |
|  m8s1q1 | F7 | discrete | Roster list question |
|  interview__id | F7 | discrete | Unique 32-character long identifier of the interview |
|  random_list__id | F8 | discrete | Id in random_list |
|  interview__key | F8 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  random_weight | F8 | contin | random_weight |
|  random_weight_min | F8 | contin | random_weight_min |
|  public_official_code | F8 | contin | public_official_code |
|  interview__id | F8 | discrete | Unique 32-character long identifier of the interview |
|  roster_english_p_gbn__id | F9 | discrete | Id in roster_english_p_gbn |
|  interview__key | F9 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m7saq12_gbn | F9 | discrete | How well do you : |
|  interview__id | F9 | discrete | Unique 32-character long identifier of the interview |
|  roster_english_t_gbn__id | F10 | discrete | Id in roster_english_t_gbn |
|  interview__key | F10 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3saq8_gbn | F10 | discrete | How well do you : |
|  interview__id | F10 | discrete | Unique 32-character long identifier of the interview |
|  questionnaire_roster__id | F10 | discrete | Id in "questionnaire_roster" |
|  roster_bullying_gbn__id | F11 | discrete | Id in roster_bullying_gbn |
|  interview__key | F11 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3saq9_gbn | F11 | discrete | class stolen something from each other |
|  interview__id | F11 | discrete | Unique 32-character long identifier of the interview |
|  questionnaire_roster__id | F11 | discrete | Id in "questionnaire_roster" |
|  before_after_closure__id | F12 | discrete | Id in before_after_closure |
|  interview__key | F12 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3covq8 | F12 | discrete | Returned to school but were not ready to learn the expected curriculum/content? |
|  interview__id | F12 | discrete | Unique 32-character long identifier of the interview |
|  questionnaire_roster__id | F12 | discrete | Id in "questionnaire_roster" |
|  climatebeliefs__id | F13 | discrete | Id in climatebeliefs |
|  interview__key | F13 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3_clim_q1 | F13 | discrete | G1) Which of the following statements are true or false in your opinion? |
|  interview__id | F13 | discrete | Unique 32-character long identifier of the interview |
|  questionnaire_roster__id | F13 | discrete | Id in "questionnaire_roster" |
|  teacherimpact__id | F14 | discrete | Id in teacherimpact |
|  interview__key | F14 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3_clim_q2 | F14 | discrete | G2) To what extent do you agree with each statement: |
|  interview__id | F14 | discrete | Unique 32-character long identifier of the interview |
|  questionnaire_roster__id | F14 | discrete | Id in "questionnaire_roster" |
|  direct_instruction_etri__id | F15 | discrete | Id in direct_instruction_etri |
|  interview__key | F15 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3sfq1_prac_etri | F15 | discrete | F1) Considering the last 3 months, to what extent did you do the following activities at any time during your direct class instruction? |
|  interview__id | F15 | discrete | Unique 32-character long identifier of the interview |
|  etri_roster__id | F15 | discrete | Id in "etri_roster" |
|  planning_lesson_etri__id | F16 | discrete | Id in planning_lesson_etri |
|  interview__key | F16 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3sfq2_prac_etri | F16 | discrete | F2) During the last 3 months, to what extent did you do the following activities using digital devices (e.g. computer, tablet, smartphone, etc.) while preparing or planning your lessons? |
|  interview__id | F16 | discrete | Unique 32-character long identifier of the interview |
|  etri_roster__id | F16 | discrete | Id in "etri_roster" |
|  ability_to_use_etri__id | F17 | discrete | Id in ability_to_use_etri |
|  interview__key | F17 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3sfq3_prac_etri | F17 | discrete | F3) How confident are you in your ability to perform the following tasks using ICT? |
|  interview__id | F17 | discrete | Unique 32-character long identifier of the interview |
|  etri_roster__id | F17 | discrete | Id in "etri_roster" |
|  digital_use_inschool_etri__id | F18 | discrete | Id in digital_use_inschool_etri |
|  interview__key | F18 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3sgq2_stprac_etri | F18 | discrete | G2) Thinking about the last 3 months, how often do your grade 5 students use digital devices for the following activities while in school? |
|  interview__id | F18 | discrete | Unique 32-character long identifier of the interview |
|  etri_roster__id | F18 | discrete | Id in "etri_roster" |
|  use_outsideschool_etri__id | F19 | discrete | Id in use_outsideschool_etri |
|  interview__key | F19 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3sgq3_stprac_etri | F19 | discrete | G3) Thinking about the last 3 months, how often do your grade 5 students use digital devices for the following activities outside of school? |
|  interview__id | F19 | discrete | Unique 32-character long identifier of the interview |
|  etri_roster__id | F19 | discrete | Id in "etri_roster" |
|  proficiency_ict_etri__id | F20 | discrete | Id in proficiency_ict_etri |
|  interview__key | F20 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m3sgq4_stprac_etri | F20 | discrete | G4) Approximately what proportion of your grade 5 students do you think can perform the following activities independently (without assistance)? |
|  interview__id | F20 | discrete | Unique 32-character long identifier of the interview |
|  etri_roster__id | F20 | discrete | Id in "etri_roster" |
|  schoolcovid_roster__id | F21 | discrete | Id in schoolcovid_roster |
|  interview__key | F21 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  m8_cov_q2 | F21 | discrete | When school was closed to students and you were studying from home, how often did your school or teachers ... |
|  interview__id | F21 | discrete | Unique 32-character long identifier of the interview |
|  fourth_grade_assessment__id | F21 | discrete | Id in "fourth_grade_assessment" |

### Survey of Public Officials Codebook

| Name | File |  Type | Label |
|  --- | --- | --- | --- |
|  interview__id | F1 | discrete | Unique 32-character long identifier of the interview |
|  interview__key | F1 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  assignment__id | F1 | discrete | Assignment id (identifier in numeric format) |
|  sssys_irnd | F1 | discrete | Random number in the range 0..1 associated with interview |
|  has__errors | F1 | discrete | Errors count in the interview |
|  interview__status | F1 | discrete | Status of the interview |
|  m1s0q2_name | F1 | discrete | Tier of government |
|  office_preload | F1 | discrete | The school district office to be visited |
|  position_preload | F1 | discrete | What is your position |
|  location | F1 | discrete | Organization location |
|  m1s0q1_name_other | F1 | discrete | Enumerator Name |
|  m1s0q1_number_other | F1 | contin | Please enter the Enumerator's Number |
|  info_correct | F1 | discrete | Is the above information correct? |
|  m1s0q2_name_incorrect | F1 | discrete | Tier of government |
|  office_preload_incorrect | F1 | discrete | The school district office to be visited |
|  m1s0q8 | F1 | discrete | current time |
|  m1s0q9__Latitude | F1 | contin | Current Location: Latitude |
|  m1s0q9__Longitude | F1 | contin | Current Location: Longitude |
|  m1s0q9__Accuracy | F1 | contin | Current Location: Accuracy |
|  m1s0q9__Altitude | F1 | contin | Current Location: Altitude |
|  m1s0q9__Timestamp | F1 | contin | Current Location: Timestamp |
|  randomization | F1 | discrete | Please select whether you need a set of random numbers for selecting public offi |
|  public_officials_list_photo | F1 | discrete | picture of list of public officials |
|  list_total | F1 | contin | How many public officials are on the list? |
|  needed_total | F1 | contin | How many public officials need to be selected? |
|  inter_officials | F1 | discrete | Interviewed Officials |
|  m1s2q2 | F1 | discrete | Did the respondent agree to be interviewed |
|  respondent_phone_number | F1 | contin | Respondent Phone Number |
|  m1s2q3 | F1 | discrete | If refused, reason for refusal |
|  director_hr | F1 | discrete | Are you the director of Human Resources |
|  info_position_correct | F1 | discrete | Is the information listed above on the position correct? |
|  DEM1q2 | F1 | discrete | What is your position |
|  DEM1q1 | F1 | discrete | What is your occupational category? |
|  DEM1q4__1 | F1 | discrete | Which of the following activities is your organization responsible for, if any?:Finance and planning |
|  DEM1q4__2 | F1 | discrete | Which of the following activities is your organization responsible for, if any?:Hiring of principals and teachers |
|  DEM1q4__3 | F1 | discrete | Which of the following activities is your organization responsible for, if any?:Monitoring of school performance |
|  DEM1q5__1 | F1 | discrete | Which of the following activities are you responsible for, if any?:Finance and planning |
|  DEM1q5__2 | F1 | discrete | Which of the following activities are you responsible for, if any?:Hiring of principals and teachers |
|  DEM1q5__3 | F1 | discrete | Which of the following activities are you responsible for, if any?:Monitoring of school performance |
|  DEM1q5__4 | F1 | discrete | Which of the following activities are you responsible for, if any?:None of the above |
|  DEM1q6 | F1 | contin | What is your age? |
|  DEM1q7 | F1 | contin | How many years have you been in your current position? |
|  DEM1q8 | F1 | contin | How many years have you been in your current organization? |
|  DEM1q9 | F1 | contin | How many years have you been in the civil service? |
|  DEM1q10 | F1 | contin | How many organizations have you worked in in the civil service |
|  DEM1q11n | F1 | discrete | On what type of contract are you employed? |
|  DEM1q12n | F1 | discrete | Which of the following best describes your rank and responsibilities? |
|  DEM1q13n | F1 | contin | How many full-time staff members that you manage directly report to you? |
|  DEM1q14n | F1 | contin | What is your monthly net salary? |
|  DEM1q11 | F1 | discrete | What is the highest educational qualification you have attained? |
|  DEM1q15n | F1 | discrete | Have you ever worked in the private sector? |
|  DEM1q12 | F1 | discrete | Would you like to move into the private sector in the next two years? |
|  DEM1q13 | F1 | discrete | If your total public sector wage is represented as 100, what relative number wou |
|  DEM1q14__1 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Wage |
|  DEM1q14__2 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Conditions of service apart from wage (e.g. holiday allowance or leave, health insurance provision, or transportation allowance) |
|  DEM1q14__3 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Culture |
|  DEM1q14__4 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Office space/working environment |
|  DEM1q14__5 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Work is not interesting |
|  DEM1q14__6 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Role does not match skill set |
|  DEM1q14__7 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Poor training and development opportunities |
|  DEM1q14__8 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Limited promotion opportunities |
|  DEM1q14__9 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Limited responsibility/opportunity to have impact |
|  DEM1q14__10 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Political interference |
|  DEM1q14__97 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Other (don’t specify) |
|  DEM1q14__900 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Don’t know |
|  DEM1q14__998 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:Refused to answer |
|  DEM1q14__12 | F1 | discrete | Which of the following issues are most likely to make you want to change jobs?:None of the above |
|  DEM1q15 | F1 | discrete | What is the gender of the respondent? |
|  NLG1q1 | F1 | discrete | Does your organization have a clear set of performance indicators and targets th |
|  NLG1q2 | F1 | discrete | Do you think your organisation’s targets are measurable? |
|  NLG1q3 | F1 | discrete | To what extent are your daily tasks derived from, and consistent with, your orga |
|  NLG2q1 | F1 | discrete | Does your organization track how well schools are performing towards achieving t |
|  NLG2q2 | F1 | discrete | Do you regularly have access to a functioning (electronic or equivalent) integra |
|  NLG2q3 | F1 | discrete | How is the overall performance of schools reviewed (using MIS data or other mean |
|  NLG3q1 | F1 | discrete | Does your unit/department receive rewards (financially or non-financially, such |
|  NLG3q2 | F1 | discrete | Does your organization reward its employees (financially or non-financially, suc |
|  NLG3q3 | F1 | discrete | Does information on school performance inform the ultimate budgets (or more broa |
|  NLG4q1 | F1 | discrete | What is the most common means through which you or your organisation receive fee |
|  NLG4q2 | F1 | discrete | To what extent is feedback from parents/teachers/other stakeholders used in eval |
|  NLG4q3 | F1 | discrete | To what extent is feedback from parents/teachers/other stakeholders used in maki |
|  ACM2q1 | F1 | discrete | In your experience, is the organizational responsibility for student learning as |
|  ACM2q2 | F1 | discrete | In your experience, is the organizational responsibility for teacher supervision |
|  ACM2q3 | F1 | discrete | In your experience, is the organizational responsibility for procuring inputs cl |
|  ACM3q1 | F1 | discrete | Does your organization make public its achievements of its performance targets? |
|  ACM3q2 | F1 | discrete | To what extent does your organization have a culture of making its activities tr |
|  ACM3q3 | F1 | discrete | To what extent do you think transparency is beneficial? Do the benefits outweigh |
|  ACM4q1 | F1 | discrete | What would happen if an official reported false information about a school’s lea |
|  ACM4q2 | F1 | discrete | What would happen if an official helped hire a teacher for private gain rather t |
|  ACM4q3 | F1 | discrete | What would happen if an official distorted the procurement process for private b |
|  QB1q2 | F1 | contin | What is the average class size in a typical 4th-grade class of the country? |
|  QB1q1 | F1 | contin | What percent of their time do you think teachers are absent without providing ju |
|  QB1q3 | F1 | discrete | To what extent do you agree that any gaps in your knowledge and skills are being |
|  QB2q1 | F1 | discrete | In your view, how often do employees of this organization trust one another to f |
|  QB2q2 | F1 | discrete | If a member of the public offered an officer a large amount of money or an expen |
|  QB2q3 | F1 | discrete | How does your organization encourage innovation and the adoption of new practice |
|  QB3q1 | F1 | discrete | Which of the following methods were used in the selection process for your curre |
|  QB3q2 | F1 | discrete | How would you characterize recent promotions into your organization? |
|  QB3q3 | F1 | discrete | To what extent do you feel that the financial or non-financial (e.g. recognition |
|  QB4q1 | F1 | discrete | To what extent would you say you are satisfied with your experience of working i |
|  QB4q2 | F1 | contin | Imagine that when you started your motivation was 100. What number would you say |
|  QB4q4a | F1 | discrete | It is acceptable for a teacher to be absent if the assigned curriculum has been |
|  QB4q4b | F1 | discrete | It is acceptable for a teacher to be absent if students are left with work to do |
|  QB4q4c | F1 | discrete | It is acceptable for a teacher to be absent if the teacher is doing something us |
|  QB4q4d | F1 | discrete | Students deserve more attention if they attend school regularly. |
|  QB4q4e | F1 | discrete | Students deserve more attention if they come to school with materials. |
|  QB4q4f | F1 | discrete | Students deserve more attention if they are motivated to learn. |
|  QB4q4g | F1 | discrete | To be honest, students can’t really change how intelligent they are. |
|  QB4q4h | F1 | discrete | Students can always substantially change how intelligent they are. |
|  IDM1q1 | F1 | discrete | To what extent would you agree that hiring decisions in your organization are mo |
|  IDM1q2 | F1 | discrete | To what extent would you agree that promotion decisions in your organization are |
|  IDM1q3 | F1 | contin | In what proportion of cases is the underperformance of teachers and mismanagemen |
|  IDM2q1 | F1 | discrete | How are policy decisions taken on where to build more schools or which schools t |
|  IDM2q2 | F1 | discrete | How much would you say politics affects the design and development of the school |
|  IDM2q3 | F1 | discrete | How are policy decisions on how many teachers to hire taken? |
|  IDM3q1 | F1 | contin | In the past 12 months, on what proportion of the programs or projects at your or |
|  IDM3q2 | F1 | contin | In the past 12 months, on what proportion of contracts issued by your organizati |
|  IDM3q3 | F1 | contin | In your organization, what proportion of public procurements is subject to polit |
|  IDM4q1 | F1 | discrete | To what extent would you say that being a union member affects a teacher’s abili |
|  IDM4q2 | F1 | discrete | To what extent would you say that public servants who are members of a union rec |
|  IDM4q3 | F1 | discrete | To what extent would you say the development of new educational practices that a |
|  ORG1q1a | F1 | discrete | Head of the Education Ministry/Department |
|  ORG1q1b | F1 | discrete | Finance director |
|  ORG1q1c | F1 | discrete | Planning director |
|  ORG1q1d | F1 | discrete | School supervision director |
|  ORG1q1e | F1 | discrete | M&amp;E director |
|  ORG1q2a | F1 | discrete | Head of the Education Ministry/Department |
|  ORG1q2a_other | F1 | discrete | Specify Other |
|  ORG1q2b | F1 | discrete | Finance director |
|  ORG1q2b_other | F1 | discrete | Specify Other |
|  ORG1q2c | F1 | discrete | Planning director |
|  ORG1q2c_other | F1 | discrete | Specify Other |
|  ORG1q2d | F1 | discrete | School supervision director |
|  ORG1q2d_other | F1 | discrete | Specify Other |
|  ORG1q2e | F1 | discrete | M&amp;E director |
|  ORG1q2e_other | F1 | discrete | Specify Other |
|  ORG1q3__1 | F1 | discrete | Are the following positions in the administration currently filled?:Head of the Education Ministry/Department |
|  ORG1q3__2 | F1 | discrete | Are the following positions in the administration currently filled?:Finance director |
|  ORG1q3__3 | F1 | discrete | Are the following positions in the administration currently filled?:Planning director |
|  ORG1q3__4 | F1 | discrete | Are the following positions in the administration currently filled?:School supervision director |
|  ORG1q3__5 | F1 | discrete | Are the following positions in the administration currently filled?:M&amp;E director |
|  ORG1q4a | F1 | contin | Head of the Education Ministry/Department |
|  ORG1q4b | F1 | contin | Finance director |
|  ORG1q4c | F1 | contin | Planning director |
|  ORG1q4d | F1 | contin | School supervision director |
|  ORG1q4e | F1 | contin | M&amp;E director |
|  ORG1q5 | F1 | contin | How many vacancies are open for non-director positions? |
|  ORG1q6 | F1 | contin | How long do non-director vacancies usually stay open for before they are filled? |
|  ORG2q1 | F1 | contin | During a typical working day (8 hours from 9am to 5pm), how many hours is there |
|  ORG2q2 | F1 | contin | Out of the five [5] working days, how many days is the phone network working for |
|  ORG2q3 | F1 | contin | During a typical working day (8 hours from 9am to 5pm), how many hours is thereO |
|  ORG2q4 | F1 | contin | Out of every ten [10] officers, how many have access to a computer (desktop or l |
|  ORG2q5 | F1 | contin | Out of every ten [10] officers, how many can use a computer to write a memo? |
|  ORG2q6 | F1 | contin | Out of every ten [10] officers, how many can use a computer to create a PowerPoi |
|  ORG2q7 | F1 | contin | Out of every ten [10] officers, how many can use a computer to create an Excel s |
|  ORG2q8 | F1 | contin | Out of every ten [10] officers, how many have access to a vehicle (privately own |
|  ORG3q1 | F1 | discrete | Is there someone monitoring that all basic inputs are available to the students |
|  ORG3q2 | F1 | discrete | Who has responsibility for monitoring basic inputs to schools ? |
|  ORG3q3 | F1 | discrete | Is there someone monitoring that all basic infrastructure is available in school |
|  ORG3q4 | F1 | discrete | Who has responsibility for monitoring basic infrastructure in schools in your di |
|  ORG4q1__1 | F1 | discrete | Which of the following public consultation and/or communication methods does you:No public consultation/communication methods |
|  ORG4q1__2 | F1 | discrete | Which of the following public consultation and/or communication methods does you:Social networks, chat rooms, online forums etc. |
|  ORG4q1__3 | F1 | discrete | Which of the following public consultation and/or communication methods does you:Meetings, forum, focus groups with members of the public |
|  ORG4q1__4 | F1 | discrete | Which of the following public consultation and/or communication methods does you:Publications or management reports |
|  ORG4q1__5 | F1 | discrete | Which of the following public consultation and/or communication methods does you:Public hearings |
|  ORG4q1__900 | F1 | discrete | Which of the following public consultation and/or communication methods does you:Don’t know |
|  ORG4q1__998 | F1 | discrete | Which of the following public consultation and/or communication methods does you:Refused to answer |
|  ORG4q2__1 | F1 | discrete | How is information relating to your organization made publicly available? (Selec:School web site |
|  ORG4q2__2 | F1 | discrete | How is information relating to your organization made publicly available? (Selec:Government web site |
|  ORG4q2__3 | F1 | discrete | How is information relating to your organization made publicly available? (Selec:Publications (paper) |
|  ORG4q2__4 | F1 | discrete | How is information relating to your organization made publicly available? (Selec:Publications (electronic) |
|  ORG4q2__5 | F1 | discrete | How is information relating to your organization made publicly available? (Selec:Public meetings |
|  ORG4q2__97 | F1 | discrete | How is information relating to your organization made publicly available? (Selec:Other (please specify) |
|  ORG4q2__900 | F1 | discrete | How is information relating to your organization made publicly available? (Selec:Don’t know |
|  ORG4q2__998 | F1 | discrete | How is information relating to your organization made publicly available? (Selec:Refused to answer |
|  ORG4q2_other | F1 | discrete | Specify Other |
|  ORG4q3 | F1 | discrete | How often is this information updated? |
|  ENUMq1 | F1 | contin | Calculate the total duration of the interview. |
|  ENUMq2 | F1 | discrete | Where was the interview conducted? |
|  ENUMq3 | F1 | discrete | Was the interview completely private, or was there somebody else in the room dur |
|  ENUMq4 | F1 | discrete | Did the respondent appear knowledgeable about the work environment, and their or |
|  ENUMq5 | F1 | discrete | To what extent was the respondent willing to reveal basic and confidential/sensi |
|  ENUMq6 | F1 | discrete | During the interview, did the respondent seem patient? |
|  ENUMq7 | F1 | discrete | How do you think the interview went? |
|  ENUMq8 | F1 | discrete | Note any particular challenge encountered whilst conducting the interview. |
|  random_list__id | F2 | discrete | Id in random_list |
|  interview__key | F2 | discrete | Interview key (identifier in XX-XX-XX-XX format) |
|  random_weight | F2 | contin | random_weight |
|  random_weight_min | F2 | contin | random_weight_min |
|  public_official_code | F2 | contin | public_official_code |
|  interview__id | F2 | discrete | Unique 32-character long identifier of the interview |
