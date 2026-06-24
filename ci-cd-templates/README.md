# CI/CD Templates host

## SAST Template
Gitlab CI template for SAST. Including this pipeline will run Gitlab SAST in test stage at merge request pipeline.
Findings from Gitlab SAST will be pushed to Defectdojo and shown as MR comment

Pre-requisite:
1. Product in defectdojo already created with the name same as Gitlab project name
2. Engagement in defectdojo for previously mentioned product already created with name gitlab-sast
3. DEFECTDOJO_TOKEN, DEFECTDOJO_HOSTNAME, DEFECTDOJO_BASE_API_URL already added in the CI/CD Variables
