## Submission
Previously the package was trying to install a couple of packages - httr and mockr, if they weren't installed before on the system. In this version I have removed such instances.

## Test environments
* local Ubuntu Linux 16.04 LTS, R 3.4.3
* r-hub Debian Linux, R-release, GCC
* r-hub Ubuntu Linux 16.04 LTS, R-devel, GCC
* r-hub Windows Server 2008 R2 SP1, R-devel, 32/64 bit

## R CMD check results
There were no ERRORs, WARNINGs and NOTEs

## Downstream dependencies

I have also run R CMD check on downstream dependencies, and the checks passed for all of them.
