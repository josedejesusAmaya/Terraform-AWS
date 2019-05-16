# Configuration Steps
These steps helps you configure your AWS credentials into the requiered files and initialize terraform backends.

1. Change directory to the root of your git repo
2. Run the following command `docker run -it -v ${PWD}:/terraform wizelineacademy/wz_terraform:latest`
3. Run `cd python`
4. Create a `variables.ini` file, following the same format as the `variables.ini.example`. Here, you'll add your AWS credentials, profile name and environment.
5. Configure your AWS credentials run: `python3 awsconfig.py`
6. Export your AWS configuration as env variables `source ./export.sh`
7. Initialize a Terraform backend on a specific lesson run:
`python3 awsconfig.py -i -l <lesson-folder>`

Lesson accepted values are `lesson01`, `lesson02` or `lesson03`.
