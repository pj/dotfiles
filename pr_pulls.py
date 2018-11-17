import os
import pprint
import re
import sys
from github import Github

with open(os.path.expanduser('~/.github_token'), 'r') as f:
    # or using an access token
    g = Github(f.read())
    repo = g.get_repo('revfluence/backend_server')
    pr_number = sys.argv[1]
    pr = repo.get_pull()
