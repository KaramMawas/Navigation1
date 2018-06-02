function [SV, numEpochs] = readObs(SV, fileObs, numEpochs)

    if (fileObs ~= -1)
        while( feof(fileObs) == 0)
            
            line = fgets(fileObs);
                          
            if(line(61:63) == 'END')
               break;
            end;                     
        end;
        
        count2 = 1;

        while( feof(fileObs) == 0)
        
            line = fgets(fileObs);
            
            year = 2000 + str2double(line(1,1:4));       
            month = str2double(line(1,4:7)); 
            day = str2double(line(1,7:10)); 
            hour = str2double(line(1,10:13));       
            minute = str2double(line(1,13:16)); 
            second = str2double(line(1,16:27)); 
              
            numSV = str2double(line(1,30:32));                                  % Anzahl der Satelliten
        
            count = 0;
        
            for(i=1:numSV)
                sv(i,1) = str2double(line(1,(32+i*2+count):(33+i*2+count)));    % Festlegung der vorhandenen Satelliten
                count = count + 1;
            end;
        
            for(i=1:numSV)
               
                SV(sv(i,1)).obs(count2,1) = year; 
                SV(sv(i,1)).obs(count2,2) = month; 
                SV(sv(i,1)).obs(count2,3) = day; 
                SV(sv(i,1)).obs(count2,4) = hour; 
                SV(sv(i,1)).obs(count2,5) = minute; 
                SV(sv(i,1)).obs(count2,6) = second; 
                
                line = fgets(fileObs);
              
                v1 = str2double(line(1,1:14));
                v2 = str2double(line(1,18:30));
                v3 = str2double(line(1,36:46));
                v4 = str2double(line(1,50:62));
                
                if(isfinite(v1) == 0) 
                    SV(sv(i,1)).obs(count2,7) = 0; 
                else
                    SV(sv(i,1)).obs(count2,7) = v1;
                end;
                          
                if(isfinite(v2) == 0) 
                    SV(sv(i,1)).obs(count2,8) = 0;
                else
                    SV(sv(i,1)).obs(count2,8) = v2;
                end;
               
                if(isfinite(v3) == 0) 
                    SV(sv(i,1)).obs(count2,9) = 0;
                else
                    SV(sv(i,1)).obs(count2,9) = v3;
                end;
                
                if(isfinite(v4) == 0) 
                    SV(sv(i,1)).obs(count2,10) = 0;
                else
                    SV(sv(i,1)).obs(count2,10) = v4;
                end;
                
            end;
        
            count2 = count2 + 1;
        
            
            numEpochs = numEpochs + 1;
        end;
        
    end;
        
    fclose(fileObs);

end