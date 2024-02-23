{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, rustPlatform
, stdenv
, libiconv
, brotli
, hypothesis
, lz4
, memory-profiler
, numpy
, py
, pytest-benchmark
, pytestCheckHook
, python-snappy
, zstd
}:

buildPythonPackage rec {
  pname = "cramjam";
  version = "2.8.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "milesgranger";
    repo = "pyrus-cramjam";
    rev = "refs/tags/v${version}";
    hash = "sha256-uYPuEUFbNVHuyzoh9cM/SZSItgtob+H5z3lYaMSCErc=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/milesgranger/cramjam/commit/2b90ebbf2c85be6e47248fd482590335aa245bc4.diff";
      hash = "sha256-qaXtd91I0A+hWl40USGxUykGlwRh3gHUZG/Ingo1m4g=";
    })
  ];

  cargoRoot = "cramjam-python";
  buildAndTestSubdir = "cramjam-python";

  preBuild = ''
    cargo metadata --offline # https://github.com/NixOS/nixpkgs/issues/261412
    _cargoRoot="$cargoRoot"
    cargoRoot=""
  '';

  postBuild = ''
    cargoRoot="$_cargoRoot"
    unset _cargoRoot
  '';

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src patches;
    postPatch = "cd ${cargoRoot}";
    hash = "sha256-fm/OGG/Ih5eBMEfnteK5XdFnsc/2PH4p+dgmkWB/Ro0=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  buildInputs = lib.optional stdenv.isDarwin libiconv;

  nativeCheckInputs = [
    brotli
    hypothesis
    lz4
    memory-profiler
    numpy
    py
    pytest-benchmark
    pytestCheckHook
    python-snappy
    zstd
  ];

  disabledTestPaths = [
    "benchmarks/test_bench.py"
  ];

  pytestFlagsArray = [
    "--benchmark-disable"
  ];

  preCheck = ''
    pushd "$cargoRoot"
  '';

  postCheck = ''
    popd
  '';

  pythonImportsCheck = [
    "cramjam"
  ];

  meta = with lib; {
    description = "Thin Python bindings to de/compression algorithms in Rust";
    homepage = "https://github.com/milesgranger/pyrus-cramjam";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ veprbl ];
  };
}
