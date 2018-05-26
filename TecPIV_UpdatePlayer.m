function [ ImgNumber, Time, SliderMin, SliderMax, SliderStep , SliderVal ] = TecPIV_UpdatePlayer(TrigType,TrigVal,DataSets,DataSetNumber)
%UNTITLED2 Summary of this function goes here
%   Update image number, time, slider
% Trig: event that triggered the update
TimeInc=DataSets{DataSetNumber,7};
NumberImages=DataSets{DataSetNumber,4};
ImgInc=DataSets{DataSetNumber,8}; % ImageIncrement
StartImg = DataSets{DataSetNumber,9}; % StartImage
%EndImg = DataSets{DataSetNumber,10}; % EndImage

    if NumberImages ==1
        ImgNumber=1;
        Time=1;
        SliderMax=1;
        SliderMin=1;
        SliderStep=0;
        SliderVal=0;
    
    else
        
        SliderStep=1/(ceil(NumberImages/ImgInc)-1);
        SliderStep=[SliderStep SliderStep];
        SliderMax=ceil(NumberImages/ImgInc);
        SliderMin=1;

        switch TrigType
            case 'FrameNum' % the frame number has been changed in box
                ImgNumber=str2num(TrigVal);% frame number to be returned
                Time=(ImgNumber-1)*TimeInc; %time to be returned
                ImInSeq=1+(ImgNumber-StartImg)/ImgInc;
                SliderVal= SliderMin+(ImInSeq-1)/SliderMax;
                

            case 'Time'     % the time has been changed in box
                Time=round(TrigValue);
                ImgNumber=round(Time/TimeInc)+1;
                SliderVal=ImgNumber;

            case 'Silder'   % the sider has been moved
                SliderVal=TrigVal;
                ImgNumber=num2str(StartImg+(TrigVal-1)*ImgInc);
                Time=num2str((str2double(ImgNumber)-1)*TimeInc);
        end
    end
end

