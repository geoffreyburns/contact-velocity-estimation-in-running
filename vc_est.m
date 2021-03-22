function [v_c, v_f, v_ms, F_h, Imp_h, F_h_adj, Imp_h_adj] = vc_est(t_c, t_f, v, m, h)
%% Simple hGRF Estimation

% Author:
% Geoffrey Burns
% Michigan Performance Research Laboratory
% University of Michigan
% December 2019

% Inputs:
% t_f -- flight time (s)
% t_c -- contact time (s)
% m   -- subject's mass (kg)
% h   -- subject's height (m)
% v   -- subject's average running speed (m/s)

% Outputs:
% v_c       -- average horz. speed during contact (m/s)
% v_f       -- average horz. speed during flight (m/s)
% v_ms      -- minimum horz. speed at midstance (m/s)
% F_h       -- peak hGRF (N) (negative in braking/positive in propulsion)
% Imp_h     -- hGRF impulse (N-s) (negative in braking/positive in propulsion)
% F_h_adj   -- speed-corrected peak hGRF
% Imp_h_adj -- speed-corrected hGRF impulse
    
%% Set Constants
    
    L = 0.53*h; %Leg length approximation per Winter (2005)
    g = 9.80665; %acceration due to gravity (m/s^2)
    
    F_v = m*g*(pi/2)*(t_f/t_c+1); %vGRF max estimate per Morin et al. (2005)
    d_y = (F_v*t_c^2)/(m*pi^2)-g/8*(t_c)^2; %vertical CoM disp. at midstance per Morin et al. (2005)
    
%% Numerically Solve for v_c

syms z

v_c = vpasolve(0 == (v-z*(t_c/(t_c+t_f)))*((t_c+t_f)/t_f)...
    -(1/(2*m*z))*(2*m*z^2+m*g*d_y-(m/8)*t_f^2*g^2+(F_v*(L-sqrt(L^2-(z*t_c/2)^2))^2+d_y)/(2*(L-sqrt(L^2-(z*t_c/2)^2)+d_y))), z, [0.8*v,v]);

v_c = double(v_c);

%% Solve for v_f and v_ms

% Flight Velocity
v_f = (v-v_c*(t_c/(t_f+t_c)))*((t_c+t_f)/t_f);
% Midstance Velocity
v_ms = 2*v_c-v_f;

%% Approximate F_h

% Peak hGRF (Braking and Propulsion)
F_h = (2*pi/t_c)*(v_f-v_c)*m;
% hGRF Impulse
Imp_h = F_h*(t_c/pi);

%% Speed-Corrected hGRF

% Model Coefficients
v_center = 4.417989;
vel_c = v_c - v_center;
B_0 = -27.14884;
B_v = -41.71226;
%Estimate-Actual
Fh_diff = B_0 + B_v*vel_c;
%Speed-corrected hGRF and Impulse
F_h_adj = F_h - Fh_diff;
Imp_h_adj = F_h.adj*(t_c/pi);

    end