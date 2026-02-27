close all
clear

% 1. Get a list of all CSV files in the current folder
files = dir('*.csv');

% 2. Loop through each file found
for i = 1:length(files)
    % Get the full filename
    plotsimulationdata(files(i).name);
end