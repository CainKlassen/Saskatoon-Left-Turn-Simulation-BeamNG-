function [Data, crashbymode, averagetime, gamemode_raw] = plotsimulationdata(filename)
    % PLOTSIMULATIONDATA - Processes and visualizes BeamNG vehicle log files.
    
    crashbymode = zeros(1,2);
    averagetime = zeros(1,2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% COLLECT DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    Data = readtable(filename);
    time = Data{2:end,1}';
    
    x = (Data{2:end,7} - Data{2,7})';
    y = (Data{2:end,8} - Data{2,8})';
    z = (Data{2:end,9} - Data{2,9})';
    
    wheelspeed = Data{2:end,2}';
    airspeed = Data{2:end,3}';
    
    acceleratorposition = (Data{2:end,4}*100)';
    brakeposition = (Data{2:end,5}*100)';
    
    % Determine PlayMode and ensure it is an integer (1 or 2) for indexing
    gamemode_raw = max(Data{2:end,13});
    mode_idx = round(gamemode_raw) + 1; 

    % Time in intersection logic
    idx1 = find(x < -15, 1);
    idx2 = find(y > 20, 1);
    
    % Get time values from indices (default to 0 if empty)
    t1_val = 0; if ~isempty(idx1), t1_val = time(idx1); end
    t2_val = 0; if ~isempty(idx2), t2_val = time(idx2); end
    
    % Store the result in the correct mode slot
    averagetime(mode_idx) = t1_val - t2_val;

    if gamemode_raw >= 0.5
        gamemodetext = "(With Solution)";
    else
        gamemodetext = "(Without Solution)";
    end 
    
    % Check for Crash status
    crashed = max(Data{2:end,14});
    if crashed >= 0.5
        % Corrected crashtime extraction
        idx_crash = find(diff(Data{2:end,14}) == 1, 1) + 1;
        if ~isempty(idx_crash)
            crashtime = time(idx_crash);
            gamemodetext = gamemodetext + " - Crash Occured At " + num2str(crashtime) + "s";
        end
        crashbymode(mode_idx) = 1; 
    else
        gamemodetext = gamemodetext + " - No Crash Occured ";
    end 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fig = figure('WindowState', 'maximized');
    tiledlayout(3,1);

    nexttile
    hold on
    I = imread('street.png');
    I_rot = imrotate(I, 90); 
    [rows, cols, ~] = size(I_rot);
    mpp = 0.022; % Adjust this if the car looks too big/small for the road
    xOffset = -37.2;  % Moving image left by 40 meters
    yOffset = -51.4;  % Moving image down by 10 meters
    xImgLimits = [0, cols * mpp] + xOffset;
    yImgLimits = [0, rows * mpp] + yOffset;
    h = imagesc(xImgLimits, yImgLimits, I_rot);
    set(gca, 'YDir', 'normal'); 
    plot(x, y, 'r', 'LineWidth', 3); 
    % This forces the window to focus only on the car's path
    pad = 10;
    axis([min(x)-pad, max(x)+pad, min(y)-pad, max(y)+pad]);
    axis equal; % Keeps the image from stretching
    uistack(h, 'bottom');
    title("Vehicle Position During Simulation" + newline + gamemodetext)
    xlabel("X Position (x)")
    ylabel("Y Position (y)")
    xlim([-35, 20])
    ylim([-5, 45])
    
    nexttile
    hold on
    plot(time, wheelspeed)
    plot(time, airspeed, "--")
    title("Vehicle Speed During Simulation" + newline + gamemodetext)
    xlabel("Time (s)")
    ylabel("Speed (m/s)")
    legend("Airspeed", "Wheelspeed")
    
    nexttile
    hold on
    plot(time, acceleratorposition)
    plot(time, brakeposition, "--")
    title("Accelerator/Brake Pedal Positions During Simulation" + newline + gamemodetext)
    xlabel("Time (s)")
    ylabel("Application (%)")
    legend("Accelerator Position", "Brake Position")
    
    % Pause briefly to see the plot, then close it to save memory
    %pause(0.5); 
    %close(fig);

end