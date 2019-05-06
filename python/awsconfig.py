#!/usr/bin/env python3
"""
Utility created to update the AWS credentials for the Terraform Academy.
"""

import configparser
import sys
import os
from os.path import expanduser
import argparse
import subprocess
import boto3

def error(msg, exitsts=1):
    """
    Formats errors and provides exit status 1.
    """
    sys.stderr.write(msg + "\n")
    sys.exit(exitsts)

def update_aws_credentials(profile, aws_access_key, aws_secret_key, aws_session_token):
    """Update AWS credentials in ~/.aws/credentials default file.
    :param profile: AWS profile name
    :param aws_access_key: AWS access key
    :param aws_secret_key: AWS secret access key
    :param aws_session_token: Session token
    :return:
    """
    home = expanduser("~")
    cred_file = home + '/.aws/credentials'
    config = configparser.RawConfigParser()
    if os.path.isfile(cred_file):
        config.read(cred_file)
    if not config.has_section(profile):
        config.add_section(profile)
    config.set(profile, 'aws_access_key_id', aws_access_key)
    config.set(profile, 'aws_secret_access_key', aws_secret_key)
    if aws_session_token != '':
        config.set(profile, 'aws_session_token', aws_session_token)
    with open(cred_file, 'w+') as new_cred_file:
        config.write(new_cred_file)

def update_aws_config(profile, output, region):
    """Update AWS config file in ~/.aws/config file.
    :param profile: profile
    :param output: aws output
    :param region: aws region
    :return:
    """
    home = expanduser("~")
    config_file = home + '/.aws/config'
    # Prepend the word profile the the profile name
    profile = 'profile ' + profile
    config = configparser.RawConfigParser()
    if os.path.isfile(config_file):
        config.read(config_file)
    if not config.has_section(profile):
        config.add_section(profile)
    config.set(profile, 'output', output)
    config.set(profile, 'region', region)
    with open(config_file, 'w+') as new_config_file:
        config.write(new_config_file)

def get_aws_user(aws_key, aws_secret):
    """
    Gets aws user name depending on the aws access key id.
    :param aws_key: AWS access key id
    :return: Username
    """
    return boto3.client('iam',
                        aws_access_key_id=aws_key,
                        aws_secret_access_key=aws_secret,
                       ).get_user()['User']['Arn'].split(":")[5][5:]

def terraform_init(aws_key, aws_sec, lesson, env="dev"):
    """
    Parses aws_user to configure the backend key and perform terraform init.
    :param aws_user: AWS username obtained from function get_aws_user
    :return:
    """
    aws_username = get_aws_user(aws_key, aws_sec)
    backend_key_lesson = "{aws_user}/terraform-academy/" \
                             "{lesson}/{env}-terraform.tfstate".format(
                                 aws_user=aws_username,
                                 lesson=lesson,
                                 env=env)
    lesson = '../{lesson}/'.format(lesson=lesson)
    os.chdir(lesson)
    command = 'terraform init -backend-config="key={bkl}" \
         -input=false'.format(bkl=backend_key_lesson)
    try:
        command_exec = subprocess.run(command, capture_output=True, shell=True)
        print(command_exec.stdout.decode("utf-8"))
    except RuntimeError as err:
        error(err, command_exec.returncode)
    except AttributeError as err:
        error(err, command_exec.returncode)
    print("Backend initialized successfully")
    sys.exit(command_exec.returncode)



def main(options):
    """
    Main function, updates credentials in the ~/.aws/credentials and ~/.aws/config files.
    """
    aws_key = options.awskey
    aws_sec = options.awssecret
    prof = options.awsprofile
    update_aws_credentials(prof, aws_key, aws_sec, '')
    update_aws_config(prof, 'json', 'us-east-2')
    print("Profile updated successfully")
    sys.exit(0)

if __name__ == '__main__':
    # get cmd line opts
    PARSER = argparse.ArgumentParser()
    PARSER.add_argument("-k", "--awskey", dest="awskey",
                        help="AWS access key", metavar="awskey",
                        default=None)

    PARSER.add_argument("-s", "--secret", dest="awssecret",
                        help="AWS secret key", metavar="awssecret",
                        default=None)

    PARSER.add_argument("-p", "--profile", dest="awsprofile",
                        help="AWS profile to set", metavar="awsprofile",
                        default=None)

    PARSER.add_argument("-i", "--init", dest="init",
                        help="Init terraform backend of a lesson",
                        action='store_true')

    PARSER.add_argument("-l", "--lesson", dest="lesson",
                        help="Lesson to initialize backend, accepted values are lesson01,\
                              lesson02 or lesson03", metavar="lesson",
                        default=None)

    PARSER.add_argument("-e", "--env", dest="environment",
                        help="Environment to initialize", metavar="environment",
                        default=None)

    ARGS = PARSER.parse_args()

    if not ARGS.awskey:
        PARSER.print_help()
        error("-k, --awskey is required")

    if not ARGS.awssecret:
        PARSER.print_help()
        error("-s, --secret is required")

    if not ARGS.awsprofile:
        PARSER.print_help()
        error("-p, --profile is required")

    if ARGS.init:
        if ARGS.lesson not in ["lesson01", "lesson02", "lesson03"]:
            PARSER.print_help()
            error("-l, --lesson is required")
        if not ARGS.environment:
            error("-e, --env is required")
        terraform_init(ARGS.awskey, ARGS.awssecret, ARGS.lesson, ARGS.environment)

    main(ARGS)
