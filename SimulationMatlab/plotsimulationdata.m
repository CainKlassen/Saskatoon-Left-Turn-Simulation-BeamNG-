function Data = plotsimulationdata(filename)
    % PLOTSIMULATIONDATA - Processes and visualizes BeamNG vehicle log files.
    % Input: filename (string) - Path to the CSV data log.
    % Output: Data (table) - The raw table data extracted from the file.

    %%%%%%%%%%%%%%%%%%%%%%%%%% COLLECT DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    % Import the CSV file into a MATLAB table
    Data = readtable(filename);
    
    % Extract Time (Column 1)
    time = Data{2:end,1}';
    
    % Calculate relative X, Y, Z positions (Columns 7, 8, 9)
    % Subtracts the first data point to start the trajectory at (0,0,0)
    x = (Data{2:end,7} - Data{2,7})';
    y = (Data{2:end,8} - Data{2,8})';
    z = (Data{2:end,9} - Data{2,9})';
    
    % Extract Speed data (Columns 2 and 3)
    wheelspeed = Data{2:end,2}';
    airspeed = Data{2:end,3}';
    
    % Convert Pedal positions (Columns 4 and 5) from 0.0-1.0 to 0-100%
    acceleratorposition = (Data{2:end,4}*100)';
    brakeposition = (Data{2:end,5}*100)';
    
    % Determine PlayMode status (Column 13)
    % If the maximum value is 0.5 or higher, the "Solution" mode was active
    gamemode = max(Data{2:end,13});
    if gamemode >= 0.5
        gamemodetext = "(With Solution)";
    else
        gamemodetext = "(Without Solution)";
    end 
    
    % Check for Crash status (Column 14)
    crashed = max(Data{2:end,14});
    if crashed >= 0.5
        % Use Rising Edge Detection to find the exact timestamp where HasCrashed flipped to 1
        crashtime = time(find(diff(Data{2:end,14}) == 1) + 1);
        gamemodetext = gamemodetext + " - Crash Occured At " ...
            + crashtime + "s";
    else
        gamemodetext = gamemodetext + " - No Crash Occured ";
    end 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure ('WindowState', 'maximized')
    tiledlayout(3,1);

    % Plot 1: 2D Top-Down Trajectory (X vs Y)
    nexttile
    hold on
    axis equal % Ensures the scale of X and Y meters is visually consistent
    plot(x, y)
    title("Vehicle Position" + newline + gamemodetext)
    xlabel("x Position (m)")
    ylabel("y Position (m)")
    
    % Plot 2: Speed Comparison over Time
    nexttile
    hold on
    plot(time, wheelspeed)
    plot(time, airspeed, "--")
    title("Vehicle Speed During Simulation" + newline + gamemodetext)
    xlabel("Time (s)")
    ylabel("Speed (m/s)")
    legend("Airspeed", "Wheelspeed")
    
    % Plot 3: Pedal Inputs over Time
    nexttile
    hold on
    plot(time, acceleratorposition)
    plot(time, brakeposition, "--")
    title("Accelerator/Brake Pedal Positions During Simulation" + newline + gamemodetext)
    xlabel("Time (s)")
    ylabel("Application (%)")
    legend("Accelerator Position", "Brake Position")
end