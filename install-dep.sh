#!/bin/bash

apt-get update

apt-get install -y python3-virtualenv python3-venv python3-pip
update-alternatives --install /usr/bin/python python /usr/bin/python3.7 3

python -m venv venv
source ./venv/bin/activate
pip install --upgrade pip
python -m pip install -r requirements.txt
