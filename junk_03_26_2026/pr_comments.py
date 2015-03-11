import os
import pprint
import re
import sys
import textwrap
from github import Github

with open(os.path.expanduser('~/.github_token'), 'r') as f:
    # or using an access token
    g = Github(f.read())
    repo = g.get_repo('revfluence/backend_server')
    pr_number = sys.argv[1]
    pr = repo.get_pull(int(pr_number))
    for comment in pr.get_comments():
        # pprint.pprint(comment.__dict__)
        # check date of comment vs last commit update
        m = re.match("@@ -\d+,\d+ \+(\d+),\d+ @@", comment.diff_hunk)
        if m:
            linenumber = int(m.groups()[0])
        else:
            linenumber = 0
        if comment.position:
            lines = comment.diff_hunk.splitlines()
            lineCount = 0
            for i in xrange(1, len(lines)):
                line = lines[i]
                if line.startswith('+') or not line.startswith('-'):
                    lineCount += 1

            # print(linenumber, comment.position)
            # print(comment.diff_hunk)
            # print(
            #     "%s|%s| %s - by %s (%s)" % (
            #         # os.getcwd(),
            #         comment.path,
            #         linenumber + lineCount,
            #         comment.body,
            #         comment.user.name,
            #         comment.user.login,
            #     )
            # )
            print(
                "%s|%s| %s (%s)" % (
                    # os.getcwd(),
                    comment.path,
                    linenumber + lineCount - 1,
                    comment.user.name,
                    comment.user.login,
                )
            )
            print('\n'.join(textwrap.wrap(comment.body)))
            print(' ')
            # print(line, comment.position)
