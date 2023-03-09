# (1) download and run the AWS Command Line Interface installer: https://aws.amazon.com/cli/
# (2) run: 
# aws configure
# with these read-only credentials:
# AWS Access Key ID: HIDDEN
# AWS Secret Access Key: HIDDEN
# Default region name: us-east-1
# output format: json

# (3) create a directory for backup
cd "/Users/olivier/Documents/Consultances/ACORN/Backup AWS"
d=`date +%Y-%m-%d`
mkdir acornamr-aws_$d

# (4) move into the directory that has just been created
cd acornamr-aws_$d

# (5) copy the content of all buckets
aws s3 cp s3://acornamr-demo ./demo --recursive
aws s3 cp s3://shared-acornamr ./shared-acornamr --recursive
aws s3 cp s3://acornamr-gh001 ./gh001 --recursive
aws s3 cp s3://acornamr-gh002 ./gh002 --recursive
aws s3 cp s3://acornamr-id001 ./id001 --recursive
aws s3 cp s3://acornamr-id002 ./id002 --recursive
aws s3 cp s3://acornamr-id003 ./id003 --recursive
aws s3 cp s3://acornamr-ke001 ./ke001 --recursive
aws s3 cp s3://acornamr-ke002 ./ke002 --recursive
aws s3 cp s3://acornamr-kh001 ./kh001 --recursive
aws s3 cp s3://acornamr-la001 ./la001 --recursive
aws s3 cp s3://acornamr-la002 ./la002 --recursive
aws s3 cp s3://acornamr-mw001 ./mw001 --recursive
aws s3 cp s3://acornamr-ng001 ./ng001 --recursive
aws s3 cp s3://acornamr-ng002 ./ng002 --recursive
aws s3 cp s3://acornamr-ng003 ./ng003 --recursive
aws s3 cp s3://acornamr-np001 ./np001 --recursive
aws s3 cp s3://acornamr-vn001 ./vn001 --recursive
aws s3 cp s3://acornamr-vn002 ./vn002 --recursive
aws s3 cp s3://acornamr-vn003 ./vn003 --recursive

# (6) check the latest modified file in one folder (e.g. kh001)
cd kh001
ls -t | head -n1