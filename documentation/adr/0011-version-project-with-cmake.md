[<-previous](0010-package-dependencies-in-repo.md) | next->

# 11 - Version project using CMake

Date: 2020-Mar-25

## Status

Accepted

## Context

Every instance of the project should carry an up-to-date version number. This
version number should be accessible from within the Matlab and C++ code.

## Decision

The version will be defined in the top-level CMakeLists.txt file, within the
`project()` call. Template Matlab and C++ files will be written, these
templates will be formatted and copied into the Matlab/C++ source tree by
CMake at configure time.

The version will have format \<major\>.\<minor\>.\<patch\>[.\<git-sha\>].
The Git SHA will be excluded from builds created via the release pipeline;
builds generated locally by developers and in pull request/nightly Jenkins jobs
will include the SHA.

## Consequences

- The version number for the project will be defined in one place.
- The version number will be accessible from within Matlab and C++.
- The version number will be correct for every build.
- The version returned by the Matlab version will not be updated until CMake is
  run. If CMake has not been run, the version returned by the Matlab code will
  be `0.0.0.dev` indicating that this is a developer copy that is yet to be
  built.