#!/usr/bin/env python

from setuptools import find_packages, setup

setup(name='galleri',
      version='0.0.1',
      description='galleri common lib',
      author='Liam Tengelis',
      author_email='liam@tengelisconsulting.com',
      packages=find_packages(),
      package_data={
          '': ['*.yaml'],
      },
)
