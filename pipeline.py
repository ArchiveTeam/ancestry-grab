# encoding=utf8
import datetime
from distutils.version import StrictVersion
import hashlib
import os.path
import random
from seesaw.config import realize, NumberConfigValue
from seesaw.item import ItemInterpolation, ItemValue
from seesaw.task import SimpleTask, LimitConcurrent
from seesaw.tracker import GetItemFromTracker, PrepareStatsForTracker, \
    UploadWithTracker, SendDoneToTracker
import shutil
import socket
import subprocess
import sys
import time
import string

import seesaw
from seesaw.externalprocess import WgetDownload
from seesaw.pipeline import Pipeline
from seesaw.project import Project
from seesaw.util import find_executable


# check the seesaw version
if StrictVersion(seesaw.__version__) < StrictVersion("0.1.5"):
    raise Exception("This pipeline needs seesaw version 0.1.5 or higher.")


###########################################################################
# Find a useful Wget+Lua executable.
#
# WGET_LUA will be set to the first path that
# 1. does not crash with --version, and
# 2. prints the required version string
WGET_LUA = find_executable(
    "Wget+Lua",
    ["GNU Wget 1.14.lua.20130523-9a5c"],
    [
        "./wget-lua",
        "./wget-lua-warrior",
        "./wget-lua-local",
        "../wget-lua",
        "../../wget-lua",
        "/home/warrior/wget-lua",
        "/usr/bin/wget-lua"
    ]
)

if not WGET_LUA:
    raise Exception("No usable Wget+Lua found.")


###########################################################################
# The version number of this pipeline definition.
#
# Update this each time you make a non-cosmetic change.
# It will be added to the WARC files and reported to the tracker.
VERSION = "20140924.01"
USER_AGENT = 'ArchiveTeam'
TRACKER_ID = 'ancestry'
TRACKER_HOST = 'tracker.archiveteam.org'


###########################################################################
# This section defines project-specific tasks.
#
# Simple tasks (tasks that do not need any concurrency) are based on the
# SimpleTask class and have a process(item) method that is called for
# each item.
class CheckIP(SimpleTask):
    def __init__(self):
        SimpleTask.__init__(self, "CheckIP")
        self._counter = 0

    def process(self, item):
        # NEW for 2014! Check if we are behind firewall/proxy

        if self._counter <= 0:
            item.log_output('Checking IP address.')
            ip_set = set()

            ip_set.add(socket.gethostbyname('twitter.com'))
            ip_set.add(socket.gethostbyname('facebook.com'))
            ip_set.add(socket.gethostbyname('youtube.com'))
            ip_set.add(socket.gethostbyname('microsoft.com'))
            ip_set.add(socket.gethostbyname('icanhas.cheezburger.com'))
            ip_set.add(socket.gethostbyname('archiveteam.org'))

            if len(ip_set) != 6:
                item.log_output('Got IP addresses: {0}'.format(ip_set))
                item.log_output(
                    'Are you behind a firewall/proxy? That is a big no-no!')
                raise Exception(
                    'Are you behind a firewall/proxy? That is a big no-no!')

        # Check only occasionally
        if self._counter <= 0:
            self._counter = 10
        else:
            self._counter -= 1


class PrepareDirectories(SimpleTask):
    def __init__(self, warc_prefix):
        SimpleTask.__init__(self, "PrepareDirectories")
        self.warc_prefix = warc_prefix

    def process(self, item):
        item_name = item["item_name"]
        escaped_item_name = item_name.replace(':', '_').replace('/', '_').replace('~', '_')
        dirname = "/".join((item["data_dir"], escaped_item_name))

        if os.path.isdir(dirname):
            shutil.rmtree(dirname)

        os.makedirs(dirname)

        item["item_dir"] = dirname
        item["warc_file_base"] = "%s-%s-%s" % (self.warc_prefix, escaped_item_name,
            time.strftime("%Y%m%d-%H%M%S"))

        open("%(item_dir)s/%(warc_file_base)s.warc.gz" % item, "w").close()


class MoveFiles(SimpleTask):
    def __init__(self):
        SimpleTask.__init__(self, "MoveFiles")

    def process(self, item):
        # NEW for 2014! Check if wget was compiled with zlib support
        if os.path.exists("%(item_dir)s/%(warc_file_base)s.warc"):
            raise Exception('Please compile wget with zlib support!')

        os.rename("%(item_dir)s/%(warc_file_base)s.warc.gz" % item,
              "%(data_dir)s/%(warc_file_base)s.warc.gz" % item)

        shutil.rmtree("%(item_dir)s" % item)


def get_hash(filename):
    with open(filename, 'rb') as in_file:
        return hashlib.sha1(in_file.read()).hexdigest()


CWD = os.getcwd()
PIPELINE_SHA1 = get_hash(os.path.join(CWD, 'pipeline.py'))
LUA_SHA1 = get_hash(os.path.join(CWD, 'ancestry.lua'))


def stats_id_function(item):
    # NEW for 2014! Some accountability hashes and stats.
    d = {
        'pipeline_hash': PIPELINE_SHA1,
        'lua_hash': LUA_SHA1,
        'python_version': sys.version,
    }

    return d


class WgetArgs(object):
    def realize(self, item):
        wget_args = [
            WGET_LUA,
            "-U", USER_AGENT,
            "-nv",
            "--lua-script", "ancestry.lua",
            "-o", ItemInterpolation("%(item_dir)s/wget.log"),
            "--no-check-certificate",
            "--output-document", ItemInterpolation("%(item_dir)s/wget.tmp"),
            "--truncate-output",
            "-e", "robots=off",
            "--rotate-dns",
            "--recursive", "--level=inf",
            "--no-parent",
            "--page-requisites",
            "--timeout", "30",
            "--tries", "inf",
            "--domains", "mundia.com,muncn.com,genealogy.com,familyorigins.com,genforum.com,myfamily.com",
            "--span-hosts",
            "--waitretry", "30",
            "--warc-file", ItemInterpolation("%(item_dir)s/%(warc_file_base)s"),
            "--warc-header", "operator: Archive Team",
            "--warc-header", "ancestry-dld-script-version: " + VERSION,
            "--warc-header", ItemInterpolation("ancestry-user: %(item_name)s"),
        ]
        
        #example item: genealogy:users:c:o:x:Helen-Cox-NJ
        #example item: familytreemaker:users:s:c:h:Aaron-J-Schwartz
        #example item: familyorigins:users:s:c:h:Beverly-G-Schweppe
        item_name = item['item_name']
        assert ':' in item_name
        item_type, item_value = item_name.split(':', 1)
        
        item['item_type'] = item_type
        item['item_value'] = item_value
        
        assert item_type in ("mundiasurnames", "genealogy", "familytreemaker", "familyorigins", "genforum", "myfamily", "genealogysite")
        
        if item_type == 'mundiasurnames':
            assert ':' in item_value
            item_lang, item_surname = item_value.split(':', 1)
            assert item_lang
            assert item_surname
            item['item_lang'] = item_lang
            item['item_surname'] = item_surname
            wget_args.append('http://www.mundia.com/{0}/surnames/{1}'.format(item_lang, item_surname))
            wget_args.extend(["--load-cookies", "cookies.txt"])
            
            url_kind = "a"
            url_first = "b"
            url_second = "c"
            url_third = "d"
            url_name = "e"
            assert url_kind
            assert url_first
            assert url_second
            assert url_third
            assert url_name
            item['url_kind'] = url_kind
            item['url_first'] = url_first
            item['url_second'] = url_second
            item['url_third'] = url_third
            item['url_name'] = url_name
        elif item_type == "genealogy":
            if "users" in item_value:
                assert ':' in item_name
                url_kind, url_first, url_second, url_third, url_name = item_value.split(":")
                assert url_kind
                assert url_first
                assert url_second
                assert url_third
                assert url_name
                item['url_kind'] = url_kind
                item['url_first'] = url_first
                item['url_second'] = url_second
                item['url_third'] = url_third
                item['url_name'] = url_name
                wget_args.append('http://www.genealogy.com/genealogy/{0}/{1}/{2}/{3}/{4}/'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.append('http://www.genealogy.com/{0}/{1}/{2}/{3}/{4}/'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.append('http://www.genealogy.com/genealogy/{0}/{1}/{2}/{3}/{4}/index.html'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.append('http://www.genealogy.com/{0}/{1}/{2}/{3}/{4}/index.html'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.extend(["--no-cookies"])
            else:
                raise Exception('Unknown item')
        elif item_type == "familytreemaker":
            if "users" in item_value:
                assert ':' in item_name
                url_kind, url_first, url_second, url_third, url_name = item_value.split(":")
                assert url_kind
                assert url_first
                assert url_second
                assert url_third
                assert url_name
                item['url_kind'] = url_kind
                item['url_first'] = url_first
                item['url_second'] = url_second
                item['url_third'] = url_third
                item['url_name'] = url_name
                wget_args.append('http://familytreemaker.genealogy.com/{0}/{1}/{2}/{3}/{4}/'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.append('http://familytreemaker.genealogy.com/genealogy/{0}/{1}/{2}/{3}/{4}/'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.append('http://familytreemaker.genealogy.com/{0}/{1}/{2}/{3}/{4}/index.html'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.append('http://familytreemaker.genealogy.com/genealogy/{0}/{1}/{2}/{3}/{4}/index.html'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.extend(["--no-cookies"])
            else:
                raise Exception('Unknown item')
        elif item_type == "familyorigins":
            if "users" in item_value:
                assert ':' in item_name
                url_kind, url_first, url_second, url_third, url_name = item_value.split(":")
                assert url_kind
                assert url_first
                assert url_second
                assert url_third
                assert url_name
                item['url_kind'] = url_kind
                item['url_first'] = url_first
                item['url_second'] = url_second
                item['url_third'] = url_third
                item['url_name'] = url_name
                wget_args.append('http://www.familyorigins.com/{0}/{1}/{2}/{3}/{4}/'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.append('http://www.familyorigins.com/genealogy/{0}/{1}/{2}/{3}/{4}/'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.append('http://www.familyorigins.com/{0}/{1}/{2}/{3}/{4}/index.html'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.append('http://www.familyorigins.com/genealogy/{0}/{1}/{2}/{3}/{4}/index.html'.format(url_kind, url_first, url_second, url_third, url_name))
                wget_args.extend(["--no-cookies"])
            else:
                raise Exception('Unknown item')
        elif item_type == "genforum":
            wget_args.append('http://genforum.genealogy.com/{0}/'.format(item_value))
            wget_args.append('http://genforum.com/{0}/'.format(item_value))
            wget_args.extend(["--no-cookies"])
        elif item_type == "myfamily":
            wget_args.extend(["--no-cookies"])
            
            suffixesa = string.digits
            suffixesb = string.digits
            
            for args in [('http://www.myfamily.com/user/{0}{1}{2}'.format(item_value, a, b), \
                          'http://www.myfamily.com/blog/{0}{1}{2}'.format(item_value, a, b), \
                          'http://www.myfamily.com/blog/{0}{1}{2}?start=0'.format(item_value, a, b)) for a in suffixesa for b in suffixesb]:
                wget_args.append(args[0])
                wget_args.append(args[1])
                wget_args.append(args[2])
                
                url_kind = "a"
                url_first = "b"
                url_second = "c"
                url_third = "d"
                url_name = "e"
                assert url_kind
                assert url_first
                assert url_second
                assert url_third
                assert url_name
                item['url_kind'] = url_kind
                item['url_first'] = url_first
                item['url_second'] = url_second
                item['url_third'] = url_third
                item['url_name'] = url_name
                
        elif item_type == "genealogysite":
            wget_args.append('http://www.familyorigins.com/')
            wget_args.append('http://www.genealogy.com/')
            wget_args.append('http://familytreemaker.genealogy.com/')
            wget_args.extend(["--no-cookies"])
        else:
            raise Exception('Unknown item')
        
        if 'bind_address' in globals():
            wget_args.extend(['--bind-address', globals()['bind_address']])
            print('')
            print('*** Wget will bind address at {0} ***'.format(
                globals()['bind_address']))
            print('')
            
        return realize(wget_args, item)

###########################################################################
# Initialize the project.
#
# This will be shown in the warrior management panel. The logo should not
# be too big. The deadline is optional.
project = Project(
    title="Ancestry",
    project_html="""
        <img class="project-logo" alt="Project logo" src="http://archiveteam.org/images/d/de/Ancestry_Logo.jpg" height="50px" title=""/>
        <h2>www.ancestry.com <span class="links"><a href="http://www.ancestry.com/">Website</a> &middot; <a href="http://tracker.archiveteam.org/ancestry/">Leaderboard</a></span></h2>
        <p>Archiving websites shutdown by ancestry.com.</p>
    """,
    utc_deadline=datetime.datetime(2014, 9, 30, 23, 59, 0)
)

pipeline = Pipeline(
    CheckIP(),
    GetItemFromTracker("http://%s/%s" % (TRACKER_HOST, TRACKER_ID), downloader,
        VERSION),
    PrepareDirectories(warc_prefix="ancestry"),
    WgetDownload(
        WgetArgs(),
        max_tries=2,
        accept_on_exit_code=[0, 4, 8],
        env={
            "item_dir": ItemValue("item_dir"),
            "item_value": ItemValue("item_value"),
            "item_type": ItemValue("item_type"),
            "url_name": ItemValue("url_name"),
            "url_kind": ItemValue("url_kind"),
            "url_first": ItemValue("url_first"),
            "url_second": ItemValue("url_second"),
            "url_third": ItemValue("url_third"),
        }
    ),
    PrepareStatsForTracker(
        defaults={"downloader": downloader, "version": VERSION},
        file_groups={
            "data": [
                ItemInterpolation("%(item_dir)s/%(warc_file_base)s.warc.gz")
            ]
        },
        id_function=stats_id_function,
    ),
    MoveFiles(),
    LimitConcurrent(NumberConfigValue(min=1, max=4, default="1",
        name="shared:rsync_threads", title="Rsync threads",
        description="The maximum number of concurrent uploads."),
        UploadWithTracker(
            "http://%s/%s" % (TRACKER_HOST, TRACKER_ID),
            downloader=downloader,
            version=VERSION,
            files=[
                ItemInterpolation("%(data_dir)s/%(warc_file_base)s.warc.gz")
            ],
            rsync_target_source_path=ItemInterpolation("%(data_dir)s/"),
            rsync_extra_args=[
                "--recursive",
                "--partial",
                "--partial-dir", ".rsync-tmp",
            ]
            ),
    ),
    SendDoneToTracker(
        tracker_url="http://%s/%s" % (TRACKER_HOST, TRACKER_ID),
        stats=ItemValue("stats")
    )
)
