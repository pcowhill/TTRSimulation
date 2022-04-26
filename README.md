# TTR Simulation
This program was designed to simulate multiple games of the board game "Ticket
to Ride" using synthetic actors as players.  In addition to performing
simulations of the default game, alternate rulesets and player strategies are
available to substitute for the default rules of the American version of the
game.  The goal of this program is to explore how changing the features and
of a board game can influing the enjoyment the players received from it.



# References
Luke Winslow (2022). log4m - A powerful and simple logger for matlab
(https://www.mathworks.com/matlabcentral/fileexchange/37701-log4m-a-powerful-and-simple-logger-for-matlab), MATLAB Central File Exchange. Retrieved April 4, 2022.
MathWorks. (2022). Control Random Number Streams on Workers. Retrieved from MathWorks: https://www.mathworks.com/help/parallel-computing/control-random-number-streams-on-workers.html
MathWorks. (2022). corrcoef. Retrieved from MathWorks: https://www.mathworks.com/help/matlab/ref/corrcoef.html
MathWorks. (2022). rng. Retrieved from MathWorks: https://www.mathworks.com/help/matlab/ref/rng.html
MathWorks Support Team. (2022). How can I add xlabel and ylabel to the individual subplots of plotmatrix? Retrieved from MathWorks: %https://www.mathworks.com/matlabcentral/answers/363444-how-can-i-add-xlabel-and-ylabel-to-the-individual-subplots-of-plotmatrix
NIST. (n.d.). NIST SEMATECH. Retrieved from Comparing multiple proportions: The Marascuillo procedure: https://www.itl.nist.gov/div898/handbook/prc/section4/prc464.htm



# 3rd Party Code
The Simulation/Utilities/log4m.m file is a modified form of an open source
class by Like Windslow.  The appropriate references to the original author is
present within the file itself.



# Requirements
All code is written and executed in MATLAB R2021b.  Both the Parallel
Computing Toolbox and the Statistics and Machine Learning Toolbox must be
installed through the MATLAB Add-On Manager in order to execute the TTR
Simulation Code.



# Setting up MATLAB Project and Environment
To set environment variables, the `TTRSimulation.prj` MATLAB Project file
should be opened in an instance of MATLAB.



# Running The Simulation Loop
To open the MATLAB App GUI, run `TTRSimulation` within the MATLAB command
window.  Various adjustable options are available for the user to customize a
particular set of simulations.  Once all of the parameters are set, the `Run`
button will begin the simulation loop to completion.  Results will be
displayed in the spaces contained within the app, will open in new windows,
will be displayed in the MATLAB command window, and will be saved out to
appropriately named files.  The `Reset` button can be used to reset the fields
in the app back to their default options.



# Utilizing the CompareResults.m function
You can compare results from different runs on the simulator using the
CompareResults.m function. When using the simulator, checkmark the box to
indicate that you want to export the results from that simulation to a
.MAT file. Once you have exported the results of at least two simulator
runs (and produced at least 2 .MAT files), you can run the .MAT files
through the CompareResults.m function to compare the results and
statistics of those simulations.



CompareResults(varargin)
The CompareResults function compiles the results tables of separate runs on
the simulator to allow for easier side-by-side comparison. Check that all
arguments passed into the function are .MAT file character arrays
(using '' instead of "") that are variables in the workspace.



Sample Call (compares two results structs):
CompareResults('738628.0539Consistent2DummyDummyDestinationTicketLongRoute6DefaultRules.mat', '738628.0432Shuffle1DummyDummy6DefaultRules.mat')



# Unit Testing
Portions of the code are covered by unittests.  These tests are contained
within the tests folder in the top directory and utilize the MATLAB unit
testing framework.  As such, these tests can be run by calling the `runtests`
function within the MATLAB command window.



NOTE: From the command line, you can also pass an entire
directory to the CompareResults function instead of entering
file names individually.
ENTER:
fileDir = dir('*.mat');
CompareResults(fileDir(:).name);