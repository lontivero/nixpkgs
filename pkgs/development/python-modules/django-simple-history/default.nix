{ lib
, buildPythonPackage
, django
, fetchFromGitHub
, pytest-django
, python
, pythonOlder
, setuptools-scm
}:

buildPythonPackage rec {
  pname = "django-simple-history";
  version = "3.5.0";
  format = "setuptools";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-simple-history";
    rev = "refs/tags/${version}";
    hash = "sha256-BW/F+RBf1KvwGRY9IK00+n69Jtx/ndEuvpHSi8/odSE=";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    django
  ];

  checkPhase = ''
    ${python.interpreter} runtests.py
  '';

  pythonImportsCheck = [
    "simple_history"
  ];

  meta = with lib; {
    description = "django-simple-history stores Django model state on every create/update/delete";
    homepage = "https://github.com/jazzband/django-simple-history/";
    changelog = "https://github.com/jazzband/django-simple-history/releases/tag/${version}";
    license = licenses.bsd3;
    maintainers = with maintainers; [ derdennisop ];
  };
}
