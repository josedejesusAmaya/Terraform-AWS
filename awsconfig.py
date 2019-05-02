#!/usr/bin/env python3
"""
Utility created to update the AWS credentials for the Terraform Academy.
"""

import configparser
import sys
import os
from os.path import expanduser
from optparse import OptionParser, Option

def error(msg):
    """
    Formats errors and provides exit status 1.
    """
    sys.stderr.write(msg + "\n")
    sys.exit(1)

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


def main(options):
    """
    Main function, updates credentials in the ~/.aws/credentials and ~/.aws/config files.
    """
    aws_key = options.awskey
    aws_sec = options.awssecret
    prof = options.awsprofile
    update_aws_credentials(prof, aws_key, aws_sec, '')
    update_aws_config(prof, 'json', 'us-east-2')

if __name__ == '__main__':
    # get cmd line opts
    PARSER = OptionParser()
    PARSER.add_option(Option("-k", "--awskey", dest="awskey",
                             help="the aws access key", metavar="awskey",
                             default=None))

    PARSER.add_option(Option("-s", "--secret", dest="awssecret",
                             help="the aws secret key ", metavar="awssecret",
                             default=None))

    PARSER.add_option(Option("-p", "--profile", dest="awsprofile",
                             help="the aws profile to set ", metavar="awsprofile",
                             default=None))

    OPTIONS, ARGS = PARSER.parse_args()

    if not OPTIONS.awskey:
        error("--awskey is required!")

    if not OPTIONS.awssecret:
        error("--secret is required")

    if not OPTIONS.awsprofile:
        error("--profile is required")

    main(OPTIONS)
