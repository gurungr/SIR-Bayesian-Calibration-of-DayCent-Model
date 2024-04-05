# SIR-Bayesian-Calibration-of-DayCent-Model
This repository contains R scripts to perfome Global Sensitivity Analysis and Bayesian Calibration (SIR) for Process-Based DayCent Model based on [Gurung et al. (2020)]( [https://www.sciencedirect.com/science/article/pii/S0016706120310375?via%3Dihub). The license only apply to the following R scripts. 
1. GSA.R -- R script for performing Glogal Sensitivity Analysis with [sensitivity](https://cran.r-project.org/web/packages/sensitivity/index.html) package.   
2. RunDayCent.R -- R function to run DayCent for Broadbalk site and return log-likelihood value.
3. SIR.R -- R script to perform Bayesian Calibrarion of selected DayCent parameters using Sampling Importance Resampling (SIR) algorithm with Latin hypercube sampling using [lhs](https://cran.r-project.org/web/packages/lhs/index.html) package. 
4. change_cult100Parameters.R -- R function to change DayCent cult.100
5. change_fix100Parameters.R -- R function to change DayCent fix.100

Site example from Rothamsted Long-term Experiments (Broadbalk) is included for illustrative purpose only, for license agreement refer to Rothamsted's [web site](https://www.era.rothamsted.ac.uk/). 

The DayCent executable included here belongs to Colorado State University. Any use of DayCent should follow the license agreement issued by Colorado State University.

Shield: [![CC BY-SA 4.0][cc-by-sa-shield]][cc-by-sa]

This work is licensed under a
[Creative Commons Attribution-ShareAlike 4.0 International License][cc-by-sa].

[![CC BY-SA 4.0][cc-by-sa-image]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-image]: https://licensebuttons.net/l/by-sa/4.0/88x31.png
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg

Question or comments regarding this scripts should be sent to Ram.Gurung@colostate.edu or Stephen.Ogle@colostate.edu
