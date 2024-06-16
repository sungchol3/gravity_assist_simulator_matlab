%%% Gravity Assist Simulator ink Matlab
%%% This is the Term Project of AE280, KAIST
%%% Author : Sungcheol Ha
%%% E-mail : sungchol3@kaist.ac.kr
close; clear; clc;
%% Define the parameter
param.G = 1; % Gravitational constant
param.M = 100; % Mass of planet
param.radius = 1; % Radius of planet
param.vel = 2; % Velocity of planet
param.m = 1; % Mass of craft
param.r_SOI = param.radius*(param.m/param.M)^0.4;
time_range = [0 20];

X0 = [0; 0]; % The position of planet
R = [10; -5]; % Distance from planet to craft
R_dot = [-4; 0]; % Velocity of craft
dt = 1.e-1; % Time rate
ang = linspace(0,2*pi,100);
%% Calculate the trajectory and plot

% trajectory figure
ax1 = subplot(2,4,[1,2,5,6]);
title("Trajectory");
xlabel('x');
ylabel('y');
xlim([-100,100]);
ylim([-100,100]);
traj = animatedline('Color','b');
circle = animatedline('Color','k');
X = [R; R_dot];

ax2 = subplot(2,4,3);
title("Phase Diagram(x)");
xlabel('x');
ylabel('v_x');
phase_x = animatedline('Color','b');

ax3 = subplot(2,4,4);
title("Phase Diagram(y)");
xlabel('y');
ylabel('v_y');
phase_y = animatedline('Color','r');

ax4 = subplot(2,4,[7,8]);
title("Total energy");
xlabel('time');
ylabel('total energy');
xlim(time_range);
energy = animatedline('Color','g');

pause(5);
for t=time_range(1):dt:time_range(end)
    clearpoints(circle);
    X0 = [param.vel.*t; 0];
    % draw circle
    xc = param.radius.*cos(ang) + X0(1);
    yc = param.radius.*sin(ang) + X0(2);
    addpoints(circle,xc,yc);
    % trajectory
    X = RK4(X,dt,param);
    if condition(X,param)
        break
    end
    X_space = X(1:2) + X0;
    V_space = X(3:4) + [param.vel,0];
    addpoints(traj,X_space(1),X_space(2));
    % draw phase diagram
    addpoints(phase_x,X_space(1),V_space(1));
    addpoints(phase_y,X_space(2),V_space(2));
    % draw total energy graph
    E = norm(V_space).^2./2 - param.G*param.M./norm(X(1:2));
    addpoints(energy,t,E);
    % updata
    drawnow limitrate
    pause(0.05)
end

[time,Energy] = getpoints(energy);
fprintf("Ei: %.1f, Ef: %.1f, E gain: %.1f \n",Energy(1),Energy(end),Energy(end)-Energy(1));

writeAnimation("prototype_test.gif");

%% Functions
function dxdv = dydx(X, param)
    x = X(1:2);
    v = X(3:4);
    dx = v;
    dv = - (param.G .* param.M)./(norm(x))^3 .*x;
    dxdv = [dx; dv];
end
function X_next = RK4(X,dt,param)
    % X = [x;v];
    K1 = dt.*dydx(X, param);
    K2 = dt.*dydx(X+K1./2, param);
    K3 = dt.*dydx(X+K2./2, param);
    K4 = dt.*dydx(X+K3, param);

    X_next = X + (K1 +2.*K2 +2.*K3 +K4)./6;
end
function cond = condition(X,param)
    if norm(X(1:2)) <= param.radius
        cond = true;
        msgbox("Collapse!");
    else
        cond = false;
    end
end