clear all;
close all;
clc;

format long;

% opening the rinex files
fileObs = fopen([pwd '/INPUT/test.11o']);                                          % observation file
fileNav = fopen([pwd '/INPUT/test.11n']);                                          % navigation message file
   
% structure of SV 
SV(1:37) = struct(...
                        'navData', ...
                                struct(...
                                    'year',0,...                            % [year]
                                    'month',0,...                           % [month]
                                    'day',0,...                             % [day]    
                                    'hour',0,...                            % [h]
                                    'minute',0,...                          % [min]
                                    'second',0,...                          % [sec]
                                    'af0',0,...                             % [sec]
                                    'af1',0,...                             % [sec/sec]    
                                    'af2',0,...                             % [sec/sec^2]
                                    'IODE',0,...                            % [-]
                                    'Crs',0,...                             % [m]
                                    'DeltaN',0,...                          % [rad/sec]
                                    'M0',0,...                              % [rad]
                                    'Cuc',0,...                             % [rad]
                                    'e',0,...                               % [eccentricity]
                                    'Cus',0,...                             % [rad]
                                    'sqrtA',0,...                           % [rad]
                                    'TOE',0,...                             % [sec of GPS week], time of ephemeris
                                    'Cic',0,...                             % [rad]
                                    'OMEGA0',0,...                          % [rad]
                                    'Cis',0,...                             % [rad]
                                    'i0',0,...                              % [rad]
                                    'Crc',0,...                             % [m]
                                    'omega',0,...                           % [rad]
                                    'OMEGA_DOT',0,...                       % [rad/sec]
                                    'IDOT',0,...                            % [rad]
                                    'CodesOnL2Channel',0,...                % [m]
                                    'GPSWeek',0,...                         % [-]
                                    'GPSWeek2',0,...                        % [-]
                                    'SVaccuracy',0,...                      %
                                    'SVhealth',0,...                        %
                                    'TGD',0,...                             % [sec], time group delay
                                    'IODCIssueOfData',0,...                 %
                                    'TransmissionTimeOfMessage',0,...       % [sec]
                                    'Spare1',0,...                          %
                                    'Spare2',0,...                          %
                                    'Spare3',0,...
                                    'Ek',0, ...
                                    'Ek_dot',0),...
                        'obs',zeros(3600, 10),...                           % [year, month, day, hour, minute, second, C1[m], L1[cycle], D1[Hz], SN1[dBHz]]   
                        'POSITION',zeros(3600,3));                          % [X[m], Y[m], Z[m]], ECEF coordinates 
                    

numEpochs = 0;
                    
% reading the observation file:
[SV, numEpochs] = readObs(SV, fileObs, numEpochs);
% reading the navigation message file
[SV] = readNav(SV, fileNav);

%% Task 2
%**************     Part1       *************************

GPSWeekSecond = 511200;     % [Sec]
OMEGA_dot_e = 7.2921151467e-5;    % [rad/sec] WGS 84 value of the earth's rotation rate
[x_17_ref y_17_ref z_17_ref] = Satellite_Position(SV,17,GPSWeekSecond,1);


%**************     Part2       *************************
% to cover the total orbital period, we need sidereal day
Sidereal_day = 23*3600+56*60;   % [Sec] one Sidereal day
t_sid = (0:100:Sidereal_day);
[x_17 y_17 z_17] = Satellite_Position(SV,17,t_sid,1);

figure
plot3(x_17,y_17,z_17); % The Satellite trajectory
hold on; grid on
% The Earth
r_e=1e7;
% b = a*sqrt(1-e^2); % minor axis for ellipse
% x_e = sqrt(a^2-b^2); y_e = sqrt(abs(b^2-a^2)); % coordinates of the Earth
% [x,y,z]=ellipsoid(x_e,y_e,0,r,r,r,20);  % Earth placed in the focal length of the Satellite
[x_e,y_e,z_e]=ellipsoid(0,0,0,r_e,r_e,r_e,20); % Earth at the center 0,0,0
surf(x_e, y_e, z_e,'FaceColor','y', 'FaceAlpha', 0.2);
axis equal;
% box on; 
xlabel('x-axis (m)'); ylabel('y-axis (m)'); zlabel('z-axis (m)');

% The Satellite
[x_s,y_s,z_s] = sphere(20);
r_s = 3e6;
surf( r_s*(x_s)+x_17_ref, r_s*(y_s)+y_17_ref, r_s*(z_s)+z_17_ref ) % satellite with radius r centred at GPSWeekSeconds time ref.
colormap([1  0  0; 1  0  0])
str1 = '\leftarrow Satellite at ref. Time = 511200';
text(x_17_ref,y_17_ref,z_17_ref,str1);
title 'The trajectory of the Satellite with respect to the EC-inertial coordinates system';
legend ('Trajectory','Earth', 'Satellite');

% plot in 2D
longitude = linspace(0,180,length(x_17));
latitude = linspace(-90,90,length(y_17));
figure
plot(longitude,x_17)
hold on; grid on
xlabel('Longitude [Deg]'); ylabel('X Coord. [m]');
title 'The Longitude against the X coordinates';
legend ('Longitude [Deg]','X Coord. [m]');

figure
plot(y_17,latitude)
hold on; grid on
xlabel('Y Coord. [m]'); ylabel('Latitude [Deg]');
title 'The Latitude against the Y coordinates';
legend ('Y Coordinates','Latitude');

%% Task 3
rot = 0;
t_sid_half = (0:100:Sidereal_day/2);
[x_17_rot_0 y_17_rot_0 z_17_rot_0] = Satellite_Position(SV,17,t_sid_half,0);

figure
plot3(x_17_rot_0,y_17_rot_0,z_17_rot_0); % The Satellite trajectory
hold on; grid on

% The Earth
surf(x_e, y_e, z_e,'FaceColor','y', 'FaceAlpha', 0.2);
axis equal;
% box on; 
xlabel('x-axis (m)'); ylabel('y-axis (m)'); zlabel('z-axis (m)');

% The Satellite
surf( r_s*(x_s)+x_17_rot_0(1), r_s*(y_s)+y_17_rot_0(1), r_s*(z_s)+z_17_rot_0(1) ) % satellite with radius r centred at GPSWeekSeconds time ref.
colormap([1  0  0; 1  0  0])
str1 = '\leftarrow Satellite num.17';
text(x_17_ref,y_17_ref,z_17_ref,str1);
title 'The trajectory of the Satellite with respect to the EC-inertial coordinates system';
legend ('Trajectory','Earth', 'Satellite');
%% Task 4
figure
for i=1:37
    [x y z] = Satellite_Position(SV,i,t_sid_half,0);
    
    plot3(x,y,z); % The Satellite trajectory
    hold on; grid on

    % The Earth
    surf(x_e, y_e, z_e,'FaceColor','y', 'FaceAlpha', 0.2);
    axis equal;
    % box on; 
    xlabel('x-axis (m)'); ylabel('y-axis (m)'); zlabel('z-axis (m)');

%     % The Satellite
%     surf( r_s*(x_s)+x_17_rot_0(1), r_s*(y_s)+y_17_rot_0(1), r_s*(z_s)+z_17_rot_0(1) ) % satellite with radius r centred at GPSWeekSeconds time ref.
%     colormap([1  0  0; 1  0  0])
%     str1 = '\leftarrow Satellite num.17';
%     text(x_17_ref,y_17_ref,z_17_ref,str1);
    title 'The Orbits of the Satellite with respect to the EC-inertial coordinates system and the rotational is zero';
    legend ('Earth','Orbit');
end

