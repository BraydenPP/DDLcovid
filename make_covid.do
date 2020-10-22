/* This makefile runs all the data construction steps in the repo */

/* globals that need to be set:
$tmp -- a temporary folder
$ccode -- this root folder for this repo
$covidpub -- processed data used as inputs for COVID variable construction
*/

global fast 1

/*****************************/
/* PART 1 -- DDL SERVER ONLY */
/*****************************/

/* match DLHS4 to PC11 districts */
/* in: $health/DLHS4, $keys/pc11_district_key.  out: $health/DLHS4 */
do $ccode/b/create_dlhs4_pc11_district_key

/* collapse raw DLHS4 data to district level */
/* in: $health/DLHS4, pc11_pca_district.  out: $health/hosp/dlhs4_hospitals_dist, $covidpub/dhls4_hospitals_dist */
do $ccode/b/prep_dlhs4_district

/* prepare short village/town directory and PCA to save in public repo */
/* in: TD/VD.  out: $covidpub/pc11r_hosp, pc11r_hosp */
do $ccode/b/prep_hosp_pca_vd

/* generate demographic data and save in public repo */
do $ccode/b/gen_lgd_pc11_demographics

/* prepare EC microdata on hospitals */
/* in: raw economic census 2013.  out: $covidpub/ec_hosp_microdata */
do $ccode/b/prep_ec_hosp_microdata

/* build age distribution by district/subdistrict, using SECC + PC */
if "$fast" != "1" {
  do $ccode/b/gen_age_distribution
}

/* Process and generate HMIS distirct data*/
do $core/hmis/b/create_hmis_district_yearly.do
do $core/hmis/b/create_hmis_district_clean.do
do $core/hmis/b/create_hmis_district_keys.do

/* Process and generate HMIS subdistrict data*/
do $core/hmis/b/create_hmis_subdistrict_yearly.do
do $core/hmis/b/create_hmis_subdistrict_clean.do
do $core/hmis/b/create_hmis_subdistrict_keys.do

/* download latest district-level case data (runs in py3 conda env) */
do $ccode/b/get_case_data

/* build NSS deaths data */
do $ccode/b/gen_nss_district_key.do
do $ccode/b/prep_nss75.do

/* copy and process keys */
do $ccode/b/copy_keys.do

/* process NFHS data */
// note: this is not executable (sourced from collaborators) but included for reference
// do $ccode/b/ddl_nfhs_poll_hmis.do

/***********************************************/
/* PART 2 -- RUNS FROM DATA LINKED IN GIT REPO */
/***********************************************/

/* aggregate case data into a district file with confirmed + deaths */
do $ccode/b/aggregate_case_data

/* prepare PC11 hospital/clinic data */
do $ccode/b/prep_pc_hosp.do

/* prepare economic census (2013) hospital data */
do $ccode/b/prep_ec_hosp.do

/* clean migration data and transform to LGD */
do $ccode/b/clean_migration.do

/* clean agmark mandi price data */
do $ccode/b/clean_agmark.do

/* prepare SECC district-level poverty data [unfinished] */
// do $ccode/b/prep_secc.do

/* subdistrict-level urbanization */
// gen_urbanization_subdist -- subdistrict PCA urbanization


/***************************************/
/* PART 3 ANALYTICAL RESULTS/ESTIMATES */
/***************************************/

/* predict district and subdistrict mortality distribution based on age distribution */
/* out: estimates/(sub)district_age_dist_cfr */
do $ccode/a/predict_age_cfr

/* combine PC and DLHS hospital capacity */
do $ccode/a/estimate_hosp_capacity

/* export some additional stats that were asked for into a combined file */
do $ccode/a/impute_additional_fields


/*****************************/
/* PART 4 -- DDL SERVER ONLY */
/*****************************/

/* push data and metadata to production. metadata will be included in
data download links as well. */
// shell source $ccode/b/push_data.sh
