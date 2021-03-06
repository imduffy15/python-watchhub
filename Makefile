.PHONY: release
release:
	rm -rf dist
	rm -rf build
	scripts/git_tag.sh
	python setup.py sdist bdist_wheel
	twine upload dist/*

.PHONY: docs
docs:
	@cd docs/source && rm -f watchhub*.rst
	@cd docs && sphinx-apidoc -f -e -o source/ ../watchhub/
	@cd docs && make html && make html

SYNCTESTS := $(shell cd tests && ls test*.py | grep -v async)

.PHONY: test
test:
	python --version 2>&1 | grep -q "Python 2" && (for synctest in $(SYNCTESTS); do python -m unittest discover -s tests/ -t . -p "$$synctest"; done) || true
	python --version 2>&1 | grep -q "Python 3" && python -m unittest discover -s tests/ -t . || true

.PHONY: coverage
coverage:
	coverage run --source watchhub -m unittest discover -s tests/ -t . && coverage html && coverage report -m

.PHONY: tdd
tdd:
	coverage run --source watchhub -m unittest discover -s tests/ -t . && coverage report -m

.PHONY: lint
lint:
	flake8 watchhub/ && pylint watchhub/

.PHONY: alltests
alltests:
	flake8 watchhub/ && pylint watchhub/ && coverage run --source watchhub -m unittest discover -s tests/ -t . && coverage report -m
