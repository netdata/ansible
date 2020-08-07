import requests
import subprocess as sp
import sys

git_dir = sys.argv[1]
old_tag = sys.argv[2]

raw_log = sp.Popen(f"git --git-dir={git_dir} log --pretty=format:%s {old_tag}..HEAD | grep -o '(#[0-9][0-9]*)' | sort -u", shell=True, stdout=sp.PIPE).stdout
for line in raw_log:
    print(f"Line: {line}")
    pr = int(line[2:-2])
    r = requests.get(f'https://api.github.com/repos/netdata/netdata/pulls/{pr}')
    j = r.json()
    print(f"- {j['title']} ([#{pr}](j['url']), [{j['user']['login']}] {j['labels']}")
