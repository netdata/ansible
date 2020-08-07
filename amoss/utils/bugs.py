import getpass
import pickle
import requests
import requests.auth
import subprocess as sp
import sys

username = "amoss"
password = ""

issues = []
def update():
    global issues, password
    print("Enter password/PAT for {user}")
    password = getpass.getpass()
    page = 1
    while True:
        r = requests.get(f'https://api.github.com/repos/netdata/netdata/issues?page={page}&per_page=100&status=open&labels=bug',
                         auth=requests.auth.HTTPBasicAuth(username,password))
        j = r.json()
        if len(j)==0:
            break
        print(page,len(j))
        page += 1
        issues.extend(j)

def save():
    pickle.dump(issues,open("issues.pickle","wb"))

def load():
    global issues
    issues = pickle.load(open("issues.pickle","rb"))


def fetch(include=None, exclude=None):
    count = 0
    result = []
    for issue in issues:
        labels = [l["name"] for l in issue["labels"]]
        lset = set(labels)
        if include is None:
            iset = set()
        else:
            iset = set(include)
        if exclude is None:
            eset = set()
        else:
            eset = set(exclude)
        if len(iset.intersection(lset)) != len(iset):
            continue
        if len(eset.intersection(lset)) > 0:
            continue
        result.append(issue)
    return result
    #print(f"{count} issues")

def triage_count(bugs):
    count = 0
    for b in bugs:
        labels = [l["name"] for l in b["labels"]]
        if "needs triage" in labels:
            count += 1
    return count

def summary():
    print(f"Total bugs: {len(issues)}")

    buckets = { "Packaging"  : "area/packaging",
                "CI"         : "area/ci",
                "Build"      : "area/build",
                "Web"        : "area/web",
                "Low pri"    : "priority/low",
                "Database"   : "area/database",
                "Health"     : "area/health",
                "Streaming"  : "area/streaming",
                "Python.d"   : "area/external/python",
                "Collectors" : "area/collectors",
                "Backends"   : "area/backends",
                "Cloud"      : "cloud",
                "Docs"       : "area/docs",
                "Daemon"     : "area/daemon" }

    for k,v in buckets.items():
        bugs = fetch(include=[v])
        print(f"{k}: {len(bugs)}-bugs of which {triage_count(bugs)} need triage")

    other_inv = [ v for _,v in buckets.items() ]

    other = fetch(exclude=other_inv)
    print(f"Other: {len(other)}")
    for bug in other:
        labels = [l["name"] for l in bug["labels"]]
        print(f'{bug["number"]} {bug["title"]} {labels}')

