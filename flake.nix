# flake.nix
#
# This file packages pythoneda-runtime-infrastructure/eventstoredb-infrastructure as a Nix flake.
#
# Copyright (C) 2024-today rydnr's pythoneda-runtime-infrastructure-def/eventstoredb-infrastructure
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description =
    "Nix flake for pythoneda-runtime-infrastructure/eventstoredb";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixos.url = "github:NixOS/nixpkgs/24.05";
    pythoneda-runtime-infrastructure-eventstoredb = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-runtime-infrastructure-def/eventstoredb/0.0.27";
    };
    pythoneda-shared-pythonlang-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:pythoneda-shared-pythonlang-def/banner/0.0.71";
    };
    pythoneda-shared-pythonlang-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      url = "github:pythoneda-shared-pythonlang-def/domain/0.0.92";
    };
    pythoneda-shared-pythonlang-infrastructure = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-shared-pythonlang-def/infrastructure/0.0.69";
    };
    pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure =
      {
        inputs.flake-utils.follows = "flake-utils";
        inputs.nixos.follows = "nixos";
        inputs.pythoneda-shared-pythonlang-banner.follows =
          "pythoneda-shared-pythonlang-banner";
        inputs.pythoneda-shared-pythonlang-domain.follows =
          "pythoneda-shared-pythonlang-domain";
        url =
          "github:pythoneda-shared-runtime-infra-def/eventstoredb-events-infrastructure/0.0.16";
      };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        org = "pythoneda-runtime-infrastructure";
        repo = "eventstoredb-infrastructure";
        version = "0.0.3";
        sha256 = "1qphaplb4vnisa05133k91w4y5jinqh3j2wqzipqmzawp7z6h8mc";
        pname = "${org}-${repo}";
        pythonpackage =
          "pythoneda.runtime.infrastructure.eventstoredb.infrastructure";
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        pkgs = import nixos { inherit system; };
        description =
          "Provides the infrastructure to https://github.com/pythoneda-runtime-infrastructure/eventstoredb";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = with pkgs.lib.maintainers;
          [ "rydnr <github@acm-sl.org>" ];
        archRole = "B";
        space = "R";
        layer = "I";
        nixosVersion = builtins.readFile "${nixos}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixos-${nixosVersion}";
        shared = import "${pythoneda-shared-pythonlang-banner}/nix/shared.nix";
        pythoneda-runtime-infrastructure-eventstoredb-infrastructure-for =
          { python, pythoneda-runtime-infrastructure-eventstoredb
          , pythoneda-shared-pythonlang-domain
          , pythoneda-shared-pythonlang-infrastructure
          , pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure
          }:
          let
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTomlTemplate = ./templates/pyproject.toml.template;
            pyprojectToml = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage package pname pythonMajorMinorVersion
                pythonpackage version;
              pythonedaRuntimeInfrastructureEventstoredbVersion =
                pythoneda-runtime-infrastructure-eventstoredb.version;
              pythonedaSharedPythonlangDomainVersion =
                pythoneda-shared-pythonlang-domain.version;
              pythonedaSharedPythonlangInfrastructureVersion =
                pythoneda-shared-pythonlang-infrastructure.version;
              pythonedaSharedRuntimeInfraEventstoredbEventsInfrastructureVersion =
                pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure.version;
              src = pyprojectTomlTemplate;
            };
            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-runtime-infrastructure-eventstoredb
              pythoneda-shared-pythonlang-domain
              pythoneda-shared-pythonlang-infrastructure
              pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure
            ];

            # pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod -R +w $sourceRoot
              cat ${pyprojectToml}
              cp ${pyprojectToml} $sourceRoot/pyproject.toml
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        defaultPackage = packages.default;
        devShells = rec {
          default = pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python312;
          pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python39 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python39;
              python = pkgs.python39;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python310 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python310;
              python = pkgs.python310;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python311 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python311;
              python = pkgs.python311;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python312 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python312;
              python = pkgs.python312;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python313 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python313;
              python = pkgs.python313;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python313;
              inherit archRole layer org pkgs repo space;
            };
        };
        packages = rec {
          default = pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python312;
          pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python39 =
            pythoneda-runtime-infrastructure-eventstoredb-infrastructure-for {
              python = pkgs.python39;
              pythoneda-runtime-infrastructure-eventstoredb =
                pythoneda-runtime-infrastructure-eventstoredb.packages.${system}.pythoneda-runtime-infrastructure-eventstoredb-python39;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
              pythoneda-shared-pythonlang-infrastructure =
                pythoneda-shared-pythonlang-infrastructure.packages.${system}.pythoneda-shared-pythonlang-infrastructure-python39;
              pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure =
                pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure.packages.${system}.pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure-python39;
            };
          pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python310 =
            pythoneda-runtime-infrastructure-eventstoredb-infrastructure-for {
              python = pkgs.python310;
              pythoneda-runtime-infrastructure-eventstoredb =
                pythoneda-runtime-infrastructure-eventstoredb.packages.${system}.pythoneda-runtime-infrastructure-eventstoredb-python310;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
              pythoneda-shared-pythonlang-infrastructure =
                pythoneda-shared-pythonlang-infrastructure.packages.${system}.pythoneda-shared-pythonlang-infrastructure-python310;
              pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure =
                pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure.packages.${system}.pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure-python310;
            };
          pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python311 =
            pythoneda-runtime-infrastructure-eventstoredb-infrastructure-for {
              python = pkgs.python311;
              pythoneda-runtime-infrastructure-eventstoredb =
                pythoneda-runtime-infrastructure-eventstoredb.packages.${system}.pythoneda-runtime-infrastructure-eventstoredb-python311;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
              pythoneda-shared-pythonlang-infrastructure =
                pythoneda-shared-pythonlang-infrastructure.packages.${system}.pythoneda-shared-pythonlang-infrastructure-python311;
              pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure =
                pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure.packages.${system}.pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure-python311;
            };
          pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python312 =
            pythoneda-runtime-infrastructure-eventstoredb-infrastructure-for {
              python = pkgs.python312;
              pythoneda-runtime-infrastructure-eventstoredb =
                pythoneda-runtime-infrastructure-eventstoredb.packages.${system}.pythoneda-runtime-infrastructure-eventstoredb-python312;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
              pythoneda-shared-pythonlang-infrastructure =
                pythoneda-shared-pythonlang-infrastructure.packages.${system}.pythoneda-shared-pythonlang-infrastructure-python312;
              pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure =
                pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure.packages.${system}.pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure-python312;
            };
          pythoneda-runtime-infrastructure-eventstoredb-infrastructure-python313 =
            pythoneda-runtime-infrastructure-eventstoredb-infrastructure-for {
              python = pkgs.python313;
              pythoneda-runtime-infrastructure-eventstoredb =
                pythoneda-runtime-infrastructure-eventstoredb.packages.${system}.pythoneda-runtime-infrastructure-eventstoredb-python313;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python313;
              pythoneda-shared-pythonlang-infrastructure =
                pythoneda-shared-pythonlang-infrastructure.packages.${system}.pythoneda-shared-pythonlang-infrastructure-python313;
              pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure =
                pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure.packages.${system}.pythoneda-shared-runtime-infra-eventstoredb-events-infrastructure-python313;
            };
        };
      });
}
