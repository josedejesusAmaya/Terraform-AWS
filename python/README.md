# Configuration Script
This script helps you configure your AWS credentials into the requiered files and initialize terraform backends.

To run this script you need to configure first a virtual environment:

```
cd terraform-academy/python
pip3 install virtualenv
python3 -m venv .
source bin/activate
pip3 install -r requirements.txt
```


To configure your AWS credentials run:
`python3 awsconfig.py -k <aws_access_key> -s "<aws_secret_access_key>" -p "<profile-name>"`

To initialize a Terraform backend on a specific lesson run:
`python3 awsconfig.py -k <aws_access_key> -s "<aws_secret_access_key>" -p "<profile-name> -i -l <lesson-folder> -e <environment>`

Lesson accepted values are `lesson01`, `lesson02` or `lesson03`.