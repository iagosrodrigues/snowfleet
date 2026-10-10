{ lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "honcho-ai";
  # Match the optional SDK pin in the installed Hermes release.
  version = "2.2.0";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "honcho_ai";
    inherit version;
    hash = "sha256-FuFoJa+sUfL91ZZw3UpuRNBKP6LI60ZrF2fcyWcGt6A=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];
  dependencies = with python3Packages; [
    httpx
    pydantic
  ];
  pythonImportsCheck = [
    "honcho"
    "honcho.aio"
  ];

  meta = {
    description = "Official Python SDK for Plastic Labs Honcho memory";
    homepage = "https://github.com/plastic-labs/honcho";
    license = lib.licenses.asl20;
  };
}
