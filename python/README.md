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

After this, you need to create a `variables.ini` file, following the same format as the `variables.ini.example`. Here, you'll add your AWS credentials, profile name and environment.

To configure your AWS credentials run:
`python3 awsconfig.py`

After running this command, you need to run the following command:
`source ./source.sh`

To initialize a Terraform backend on a specific lesson run:
`python3 awsconfig.py -i -l <lesson-folder>`

Lesson accepted values are `lesson01`, `lesson02` or `lesson03`.
