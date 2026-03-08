close all
clear

% 1. Get a list of all CSV files in the current folder
files = dir('*.csv');

intersectiontimes = zeros(length(files),2);
crashdata = zeros(length(files),2);
withoutsolution = 0;
withsolution = 0;

% 2. Loop through each file found
for i = 1:length(files)
    fprintf('Processing file %d of %d: %s\n', i, length(files), files(i).name);
    
    % Get the full filename
    [Data, crashbymode, averagetime, gamemode] = plotsimulationdata(files(i).name);
    
    % Store the results
    intersectiontimes(i,:) = averagetime;
    crashdata(i,:) = crashbymode;

    if gamemode == 1
        withsolution = withsolution+1;
    else
        withoutsolution = withoutsolution+1;
    end

end

% 3. Calculate Final Averages (ignoring the zeros from other modes)

fprintf('\nANALYSIS COMPLETE.\n');

fprintf('\nNumber of Runs (With Solution): %.0f', withsolution);
fprintf('\nNumber of Runs (Without Solution): %.0f\n', withoutsolution);

final_avg_time_mode0 = mean(intersectiontimes(intersectiontimes(:,1) ~= 0, 1));
final_avg_time_mode1 = mean(intersectiontimes(intersectiontimes(:,2) ~= 0, 2));

fprintf('\nAvg Time To Clear Intersection (With Solution): %.2fs\n', final_avg_time_mode0);
fprintf('Avg Time To Clear Intersection (Without Solution): %.2fs\n', final_avg_time_mode1);

fprintf('\nCollisions Rate (With Solution): %.2f%%', sum(crashdata(:,2))/withsolution * 100);
fprintf('\nCollisions Rate (Without Solution): %.2f%%\n', sum(crashdata(:,1))/withoutsolution * 100);


