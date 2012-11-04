GAE_VERSION=1.7.2
# Name of you application in Google Appengine
APPID?=%APPNAME%
# Name of your github repository
REPOSNAME?=%APPNAME%

# Varnames you accept although ney are not PEP8 compliant
GOOD_NAMES=FooBar_IllEgaLVar
# pyLint
#   W0142 = *args and **kwargs support
# Pointless whinging
#   W0603 = Using the global statement
#   R0201 = Method could be a function
#   W0212 = Accessing protected attribute of client class
#   W0232 = Class has no __init__ method
#   W0212 = Access to a protected member _rev of a client class
# Mistakes in Parsing the AppEngine Source
#   E1103: %s %r has no %r member (but some types could not be inferred)
# Usually makes sense for webapp.Handlers & Friends.
#   W0221 Arguments number differs from %s method
# In Python versions < 2.6 all Exceptions inherited from Exception. py2.6 introduced BaseException
# On AppEngine we do not care much about the "serious" Exception like KeyboardInterrupt etc.
#   W0703 Catch "Exception"
#   R0903 Too few public methods - pointless for db.Models
# Unused Reports
#   RP0401 External dependencies
#   RP0402 Modules dependencies graph
#   RP0101 Statistics by type
#   RP0701 Raw metrics
PYLINT_ARGS= --output-format=parseable -rn -iy --ignore=config.py \
             --deprecated-modules=regsub,string,TERMIOS,Bastion,rexec,husoftm \
             --max-args=6 \
             --max-public-methods=30 \
             --max-locals=25 \
             --max-line-length=110 \
             --min-similarity-lines=6 \
             --ignored-classes=Struct,Model,google.appengine.api.memcache \
             --dummy-variables-rgx="_|dummy|abs_url" \
             --good-names=_,setUp,fd,application,$(GOOD_NAMES) \
             --generated-members=request,response \
             --disable=W0142,W0212,E1103,R0201,W0201

PYLINT_FILES=modules/

check: lib/google_appengine/google/__init__.py checknodeps fixup

# check without updating dependencies
checknodeps:
	@# pyflakes & pep8
	pyflakes $(PYLINT_FILES)
	pep8 -r --max-line-length=110 $(PYLINT_FILES)  # --show-pep8 hilft
	sh -c 'PYTHONPATH=lib/google_appengine/ pylint $(PYLINT_ARGS) $(PYLINT_FILES)'
	# clonedigger *.py modules/

fixup:
	# Tailing Whitespace
	find ablage -name '*.py' -print0 | xargs -0 perl -pe 's/[\t ]+$$//g' -i
	perl -pe 's/[\t ]+$$//g' -i templates/*.html
	# Tabs in Templates
	perl -MText::Tabs -ne 'print expand $$_' -i templates/*.html

# Install AppEngine SDK locally so pyLint und pyFlakes find it
lib/google_appengine/google/__init__.py:
	curl -s -O http://googleappengine.googlecode.com/files/google_appengine_$(GAE_VERSION).zip
	unzip -q google_appengine_$(GAE_VERSION).zip
	rm -Rf lib/google_appengine
	mv google_appengine lib/
	rm google_appengine_$(GAE_VERSION).zip

deploy:
	echo open http://dev-`whoami`.$(APPID).appspot.com/
	appcfg.py update -V dev-`whoami` -A $(APPID) .
	echo open http://dev-`whoami`.$(APPID).appspot.com/
	#TESTHOST=dev-`whoami`.$(APPID).appspot.com make resttest
	#echo open http://dev-`whoami`.$(APPID).appspot.com/
	#open http://dev-`whoami`.$(APPID).appspot.com/

deploy_production:
	echo open http://production.$(APPID).appspot.com/
	appcfg.py update -V production -A $(APPID) .
	echo open http://production.$(APPID).appspot.com/
	#TESTHOST=dev-`whoami`.$(APPID).appspot.com make resttest
	echo open http://production.$(APPID).appspot.com/
	open http://production.$(APPID).appspot.com/

openlogs:
	open "https://appengine.google.com/logs?app_id=s%7E$(APPID)&version_id=dev-`whoami`"

opendev:
	open http://dev-`whoami`.$(APPID).appspot.com/

next_production:
	# differences to next production deploy
	git fetch origin
	git log --color --pretty=oneline --abbrev-commit 'origin/production..' | sed 's/^/  /'

clean:
	find . -name '*.pyc' -or -name '*.pyo' -delete
	git submodule foreach "make clean||:"

dependencies: clean
	git submodule update --init

resttest:
	sh -c "PYTHONPATH=.:lib/huTools python tests/resttest.py --hostname=$(TESTHOST) --credentials-user=$(CREDENTIALS_USER)"
    .PHONY: deploy pylint dependencies_for_check_target clean check dependencies

