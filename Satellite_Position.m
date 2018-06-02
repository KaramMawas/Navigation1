function [Xk, Yk, Zk] = Satellite_Position(SV, PRN, GPSWeekSecond, rotation)
    meu = 3.986005e14;                                                     
if rotation ==0;
    OmegaE = 0;                                                           
else 
    OmegaE = 7.2921151467e-5;                                             
end
    
    % semi-major axis
    a= (SV(PRN).navData.sqrtA)^2; 
    % mean motion(rad/sec)
    n0 = sqrt(meu/a^3);
    % time 
    tk = GPSWeekSecond - SV(PRN).navData.TOE;
    % corrected mean motion
    n = n0 + SV(PRN).navData.DeltaN; 
    % mean anomaly [rad or unitless]
    Mk = SV(PRN).navData.M0 +n*tk; 
   
    
    % Solution of the Kepler equ.
    % eccentric anomaly E:
    Ek = Mk; 
    diff_E = 1; 
        while abs(diff_E) > 1e-12
            Eold = Ek;
            Ek = Mk+SV(PRN).navData.e*sin(Ek); 
            diff_E = Ek-Eold;    
        end
        
        
    % true anomaly
%     vK = atan2(sqrt((1-SV(PRN).navData.e^2))*sin(Ek),(cos(Ek)-SV(PRN).navData.e));
    numerator = (sqrt(1-(SV(PRN).navData.e)^2)*sin(Ek))./(1-SV(PRN).navData.e*cos(Ek));
    denominator = (cos(Ek)-SV(PRN).navData.e)./(1-SV(PRN).navData.e*cos(Ek));
    vK = atan2(numerator,denominator);
    
    % Eccentric anomaly
    Ek = acos((SV(PRN).navData.e + cos(vK)) ./ (1 + SV(PRN).navData.e * cos(vK))); 
    
    % argument of latitude
    phiK = SV(PRN).navData.omega + vK;
    
    % Second Harmonic Perturbations
    % Argument of Latitude Correction 
    duk = SV(PRN).navData.Cus*sin(2*phiK) + SV(PRN).navData.Cuc*cos(2*phiK);
    % Radius Correction 
    drk = SV(PRN).navData.Crs*sin(2*phiK) + SV(PRN).navData.Crc*cos(2*phiK);
    % Inclination Correction
    dik = SV(PRN).navData.Cis*sin(2*phiK) + SV(PRN).navData.Cic*cos(2*phiK);
    
    
    % corrected argument of latitude
    uk = phiK+duk;
    % corrected radius
    rk = a*(1-SV(PRN).navData.e *cos(Ek))+drk;
    % corrected inclination
    ik = SV(PRN).navData.i0+dik+SV(PRN).navData.IDOT *tk;
    % corrected longitude of ascending node
    OMEGAk = SV(PRN).navData.OMEGA0 + ( SV(PRN).navData.OMEGA_DOT - OmegaE).* tk - (OmegaE * SV(PRN).navData.TOE); 

    % position in orbital plane
    Xk_orbit = rk.*cos(uk);
    Yk_orbit = rk.*sin(uk);
    
    % Earth Fixed Coordinates
    Xk = Xk_orbit.*cos(OMEGAk) - Yk_orbit.*cos(ik).*sin(OMEGAk);
    Yk = Xk_orbit.*sin(OMEGAk) + Yk_orbit.*cos(ik).*cos(OMEGAk);
    Zk = Yk_orbit.*sin(ik);


    

    end
    
    
  



