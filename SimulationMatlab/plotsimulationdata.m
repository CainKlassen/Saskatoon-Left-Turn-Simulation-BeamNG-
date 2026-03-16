function [Data, crashbymode, averagetime, gamemode_raw] = plotsimulationdata(filename, draw)
    % PLOTSIMULATIONDATA - Processes and visualizes BeamNG vehicle log files.
    
    crashbymode = zeros(1,2);
    averagetime = zeros(1,2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% COLLECT DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    Data_raw = readtable(filename);
    
    % --- TRIMMING LOGIC ---
    % Find the first index where the car is actually moving (> 0.1 m/s)
    % We use Data_raw{:,3} which is Airspeed
    move_idx = find(Data_raw{1:end,8} > -64.085, 1) + 1; 
    
    if isempty(move_idx)
        % If the car never moved, we can't process it effectively
        Data = Data_raw; 
    else
        % Trim the table to start from the first movement
        Data = Data_raw(move_idx:end, :);
    end
    % -----------------------

    % Extracting time and normalizing coordinates
    % Subtracting Data{1,1} ensures the 'trimmed' time starts at 0 seconds
    time = (Data{:,1} - Data{1,1})'; 
    
    % Normalize X, Y, Z relative to the start of movement
    x = (Data{:,7} - Data{1,7})';
    y = (Data{:,8} - Data{1,8})';
    z = (Data{:,9} - Data{1,9})';
    
    wheelspeed = Data{:,2}';
    airspeed = Data{:,3}';
    
    acceleratorposition = (Data{:,4}*100)';
    brakeposition = (Data{:,5}*100)';
    
    % Determine PlayMode (0 or 1) and map to index (1 or 2)
    gamemode_raw = max(Data{:,13});
    mode_idx = round(gamemode_raw) + 1; 
    
    %%%%%%%%%%%%%%%%%%%%%% INTERSECTION LOGIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Note: Indices are now relative to the trimmed 'Data' table
    idx_end = find(x < -13, 1);
    idx_start = find(y > 25, 1);
    
    if ~isempty(idx_start) && ~isempty(idx_end)
        entry_time = time(idx_start);
        exit_time = time(idx_end);
        averagetime(mode_idx) = exit_time - entry_time;
    else
        averagetime(mode_idx) = 0; 
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%% CRASH DETECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if gamemode_raw >= 0.5
        gamemodetext = "(With Solution)";
    else
        gamemodetext = "(Without Solution)";
    end 
    
    crashed = max(Data{:,14});
    if crashed >= 0.5
        % Find crash relative to trimmed data
        idx_crash = find(diff(Data{:,14}) == 1, 1) + 1;
        if ~isempty(idx_crash)
            crashtime = time(idx_crash);
            gamemodetext = gamemodetext + " - Crash Occurred At " + num2str(crashtime) + "s";
        end
        crashbymode(mode_idx) = 1; 
    else
        gamemodetext = gamemodetext + " - No Crash Occurred ";
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if draw == 1
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
        title("Vehicle Position During Simulation" + newline + gamemodetext + filename)
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
        
    end

end