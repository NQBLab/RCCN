## Contents

[Overview]( #Overview)

[Repo Contents]( #Repo Contents)

[System Requirements]( #System Requirements)

[Installation Guide]( #Installation Guide)

[Demo and Instructions For Use]( #Demo and Instructions For Use)

# Overview

The RCCN (Randomly Connected Cycles Network) model is a model for the intracellular network between the different cellular compounds (proteins, metabolites, RNAs, etc.). The compounds are treated as Boolean variables (spins), and the a-symmetric connections matrix is the network structure. In the simulation, the model first evolves freely, then it is subjected to an external 'stress' - a field that operates on all the spins for a certain period denoted Tw. Then the stress is stopped and the model relaxes to it's base levels. The time it takes for the model to relax back to it's base level is analogous for the time required for bacteria to resume their growth after abrupt stress. This is simulated for many realizations of initial conditions and network structures, to receive a survival curve. 

# Repo Contents

## Files for Running the Simulation
- RunSimulationExperiments.m - this is the main script to run the simulation. The results of this script are the state of each spins over all the timesteps, for different Tws. These are saved as matlab .mat files inside the Experiments folder, under 'Spins'. This Script uses the following functions/scripts:

  - initParams.m - returns the following parameters: number of spins in the network, number of timesteps to simulate, gamma and H (parameters of the network, as described in the theoretical overview of the model).
  -  initJij.m - returns the connectivity matrix between the spins, as a gpuArray.
  - getShiftMat.m - used for initJIj.
  - initSpins.m - returns empty arrays for the spins, and the spins history over all the timesteps of the simulation.
  - dynamicExperiment.m - runs the dynamics of the simulation, here is where the simulation loop is situated.

- getObservablesForMultipleTw.m - this script takes the state of all the spins from a single simulation, and calculates the mean magnetization of the spins over the timesteps. The script does this for the different Tw's that where simulated, and saves the results in the Experiments folder, under 'Observables'. This script uses the following function:

  - getObservables.m - calculates the magnetization for a single Tw.

  

## Files for Analyzing and Plotting Results

- ShowSimulationData.m - this script is used for calculating and plotting the survival curves from the results,  for plotting the mean magnetization, for plotting the theoretical prediction for survival curves, and for analyzing the Rise of the magnetization. This script uses the following functions:
  - fitMagRise.m - returns the parameters to fit the magnetization rising.
  - fitMagRelaxB15.m - returns the parameters to fit the magnetization relaxing.
  - getMagRelax.m - uses the above parameters to obtain the theoretical prediction for the relaxation of the magnetization.
  - getCDF.m - returns the CDF of the results.
  - survivalTheory.m - returns the theoretical prediction for the survival curves.
  - viridis.m -  a colormap generating function, from Ander Biguri (2021). [Perceptually uniform colormaps](https://www.mathworks.com/matlabcentral/fileexchange/51986-perceptually-uniform-colormaps), MATLAB Central File Exchange. Retrieved August 28, 2021.
- NumericData folder - contains the main data for the figures in the article. This data can be viewed with ShowSimulationData.

# System Requirements

To run the scripts you will need Matlab. We tested on version R2020b, and other recent versions should suffice.

Moreover, you will need a GPU for the scripts that runs the simulation. The GPU is not needed for plotting the results.

# Installation Guide

No Installation is needed. To run the code, simply:

1. Clone the Repository
2. Open the files with Matlab
3. Run according to the following Instructions

# Demo and Instructions For Use

## Running the Simulation

The result of running the simulation is the mean magnetization over time, of an ensemble of different realizations of network architecture, and for several different Tw's. In order to obtain this:

1. Make sure you have an 'Experiments' folder in the code directory, and inside it two subfolders: 'Spins' and 'Observables'. Of course, you can modify the required names and locations, by modifying their use in the code. Inside each of the subfolders create another subfolder for your new experiment, and give it a name.
2. Open the runSimulationExperiments script.
3. Go over the parameters in the first few lines of code:
   1. Specify the destination folder 
   2. Specify if you wish your ensemble to be over different initial conditions of the spins, or different realizations of the architecture. The default is the second option.
   3. Specify which Tw's you wish to simulate, and what is the ensemble size for each one. The default ensemble size is 900 realizations.
4. Run the Script, the spins results will be stored in the 'Spins' subfolder.
5. Open the script getObservablesForMultipleTw, and review the parameters in the first lines of code. Specify again the Tw's you simulated, the ensemble size, and the file locations prefixes. Run the script. The final results will be stored in the Observable folder.

The expected output in the Observable folder should be similar to that in the NumericData folder - several .mat files, each corresponding to a different Tw, and each contains a single variable called mag, which consists of the mean magnetization in each of the simulated realizations over time, i.e. a matrix of number_of_realizations X number_of_timesteps.

This takes about a minute to run for a single realization a single Tw, and default parameters.

## Analyzing and Plotting the Results

To analyze the results, First, open the script and specify the data folder. You can use your own simulated data, or the data obtained during our simulations, located in the 'NumericData' folder.

There are several things we might be interested in, which could be done from the script, by choosing the respective action_id.

1. Calculate and plot the survival curves for different Tw's, i.e. reproducing Fig 3. (B), this is done by choosing "plot_survival" under action_id.
2. Calculate and plot the mean magnetization curves and the theoretical predictions for them, i.e. reproducing figure S2. (B), this is done by choosing "plot_mean_magnetization_and_theory".
3. Find the tau_0 parameter and the saturation of the magnetization parameter. This is done by choosing "find_tau0_and_sat_mat".

