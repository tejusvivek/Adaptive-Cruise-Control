%Author: Tejus Vivek
%Date: 03-30-2023
%% Arduino Object Setup
clear;
clc;
a=arduino('COM3','Uno','Libraries',{'Ultrasonic','ExampleLCD/LCDAddon'},'Forcebuild',true );
ultrasonic_o = ultrasonic(a,'D13','D12'); %Ultrasonic sensor object
lcd=addon(a,'ExampleLCD/LCDAddon','RegisterSelectPin','D7','EnablePin','D6','DataPins',{'D5','D4','D3','D2'}); %Defining data pins for LCD
initializeLCD(lcd, 'Rows', 2, 'Columns', 16); %initialized LCD
%% Button Definitions
% Speed decrease button = 'A0'
% Speed increase = 'A1'
% Cruise Control Button = 'A2'
% Adaptive Cruise Control Button = 'A3'
% Cancel Button = 'A4'
%% Variable Initialization
global button
global speed
global CC
global ACC
global ACCSpeed
global NORM
global mode
NORM = 1
speed=0;
CC = 0
ACC=0
mode ='NORMAL';
writeDigitalPin(a,'D8',0) %Turn on LCD backlight
set_speed=0;
printLCD(lcd,'   ADAPTIVE  ');
printLCD(lcd,'CRUISE CONTROL');
pause(2);
clearLCD(lcd);
printLCD(lcd,'GROUP 28');
pause(2);
clearLCD(lcd);
printLCD(lcd,['Speed: ',num2str(speed)])
printLCD(lcd,'Mode: NORMAL');
%% Logic Implementation
while true
    while true
        if (readVoltage(a, 'A0')>4.5)
            button = 0
            break;
        elseif (readVoltage(a, 'A1')>4.5)
            button = 1
            break;
        elseif(readVoltage(a, 'A2')>4.5)
            button = 2;
            mode = 'CC'
            CC=1
            NORM = 0
            break;
        elseif (readVoltage(a, 'A3')>4.5)
            button = 3;
            mode = 'ACC'
            ACC=1
            NORM = 0
            break;
        elseif(readVoltage(a, 'A4')>4.5)
            button = 4;
            mode = 'NORMAL'
            NORM = 1
            break;
        end
    end
    switch button
        case 0 
            while(speed>0)
                while((ACC~=1)&(CC~=1)&(readVoltage(a,'A0')>4.5))
                    speed = speed-1;
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    printLCD(lcd,'Mode: NORMAL');
                    pause(1)
                end                
                    while(speed>0)
                     if (readVoltage(a, 'A0')>4.5)
                        button = 0
                        if(CC == 1|ACC==1)
                            ACCSpeed = speed;
                            NORM = 0
                            break;
                        else
                        speed = decreaseSpeedNormal(speed,a,lcd)
                        end
                        %break;
                     elseif (readVoltage(a, 'A1')>4.5)
                        button = 1
                        if(CC == 1|ACC==1)
                            NORM = 1
                            ACCSpeed = speed;
                            break;
                        else
                            speed = increaseSpeedNormal(speed,a,lcd)
                        end
                        %break;
                    elseif(readVoltage(a, 'A2')>4.5)
                        button = 2;
                        CC = 1
                        NORM = 0
                        mode = 'CC'
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        printLCD(lcd,'Mode: CC');                        
                        break;
                    elseif (readVoltage(a, 'A3')>4.5)
                        button = 3;
                        mode = 'ACC'
                        ACC=1
                        ACCSpeed = speed;
                        NORM = 0
                        CC=0
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        printLCD(lcd,'Mode: ACC');  
                        break;
                    elseif(readVoltage(a, 'A4')>4.5)
                        button = 4;
                        NORM = 1
                        mode = 'NORMAL'
                        break;
                    end
                    if(speed>0)
                        speed = speed-1;
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        printLCD(lcd,'Mode: NORMAL');
                        pause(3)       
                    end
                    end                 
            end                  
        case 1
            while((ACC~=1)&(CC~=1)&(readVoltage(a,'A1')>4.5))
                speed = speed+1;
                printLCD(lcd,['Speed: ',num2str(speed)])
                printLCD(lcd,'Mode: NORMAL');
                pause(1)
            end             
            while(speed>0)
                if (readVoltage(a, 'A0')>4.5)
                    button = 0
                    speed = decreaseSpeedNormal(speed,a,lcd);                    
                elseif (readVoltage(a, 'A1')>4.5)
                    button = 1
                    speed = increaseSpeedNormal(speed,a,lcd);                   
                elseif(readVoltage(a, 'A2')>4.5)
                    button = 2
                    CC = 1
                    ACC= 0
                    NORM = 0
                    mode = 'CC'
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    printLCD(lcd,'Mode: CC');
                    break;                    
                elseif (readVoltage(a, 'A3')>4.5)
                    button = 3;
                    ACC=1
                    ACCSpeed = speed;
                    CC=0
                    NORM = 0
                    mode = 'ACC'
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    printLCD(lcd,'Mode: ACC');
                    break;                   
                elseif(readVoltage(a, 'A4')>4.5)
                    button = 4;
                    mode = 'NORMAL'
                    NORM = 1                    
                end               
                if(speed>0)
                    speed = speed-1;
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    printLCD(lcd,'Mode: NORMAL');
                    pause(3)                  
                end
            end                   
        case 2           
            button = 2
            NORM = 0
            CC = 1
            ACC=0
            while(CC==1)
                printLCD(lcd,['Speed: ',num2str(speed)])
                printLCD(lcd,'Mode: CC');
                if((readVoltage(a,'A4')>4.5))
                    NORM = 1
                    CC= 0
                    button = 4
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    printLCD(lcd,'Mode: NORMAL');
                    break;
                end
                if((readVoltage(a,'A3')>4.5))
                    button =3
                    ACC=1
                    ACCSpeed = speed;
                    CC=0
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    printLCD(lcd,'Mode: ACC');
                    break;
                end
                if((readVoltage(a,'A1')>4.5))
                    %speed = increaseSpeedCC(speed,a,lcd,CC);
                    speed = speed+1;
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    printLCD(lcd,'Mode: CC');                    
                elseif(speed>0&(readVoltage(a,'A0')>4.5))
                    %speed = decreaseSpeedCC(speed,a,lcd,CC);
                    speed = speed-1
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    printLCD(lcd,'Mode: CC');
                end
            end
        case 3
            button = 3
            ACC = 1
            ACCSpeed = speed;
            CC=0
            while(ACC==1)
                distance = readDistance(ultrasonic_o);
                if((readVoltage(a,'A4')>4.5))
                    NORM = 1
                    ACC= 0
                    button = 4
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    printLCD(lcd,'Mode: NORMAL');
                    break;
                end
                if(distance<0.4&speed>0)               
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    writePWMVoltage(a,'D9',2)
                    printLCD(lcd,'Mode: ACC');
                    pause(0.15)
                    writePWMVoltage(a,'D9',4.5)
                    speed = speed-1;
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    writePWMVoltage(a,'D9',2)
                    printLCD(lcd,'Mode: ACC');
                    pause(0.15)
                    writePWMVoltage(a,'D9',4.5)
                    if(readVoltage(a,'A1')>4.5)
                        speed = speed+1;
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        writePWMVoltage(a,'D9',2)
                        printLCD(lcd,'Mode: ACC');
                        pause(0.75)
                        writePWMVoltage(a,'D9',4.5)
                        speed = speed-1
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        writePWMVoltage(a,'D9',2)
                        printLCD(lcd,'Mode: ACC');
                        pause(0.25)
                        writePWMVoltage(a,'D9',4.5)
                    elseif(speed>0&(readVoltage(a,'A0')>4.5))
                        speed = speed-1
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        writePWMVoltage(a,'D9',2)
                        printLCD(lcd,'Mode: ACC');
                        pause(0.75)
                        writePWMVoltage(a,'D9',4.5)
                        speed = speed+1
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        writePWMVoltage(a,'D9',2)
                        printLCD(lcd,'Mode: ACC');
                        pause(0.25)
                        writePWMVoltage(a,'D9',4.5)
                    end
                end
                    if(distance>0.4&speed<ACCSpeed)
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        writePWMVoltage(a,'D9',2)
                        printLCD(lcd,'Mode: ACC');
                        pause(0.25)
                        writePWMVoltage(a,'D9',4.5)
                        speed = speed+1;
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        writePWMVoltage(a,'D9',2)
                        printLCD(lcd,'Mode: ACC');
                        pause(0.25)
                        writePWMVoltage(a,'D9',4.5)
                        if(readVoltage(a,'A1')>4.5)
                            speed = speed+1;
                            printLCD(lcd,['Speed: ',num2str(speed)])
                            writePWMVoltage(a,'D9',2)
                            printLCD(lcd,'Mode: ACC');
                            pause(0.65)
                            writePWMVoltage(a,'D9',4.5)
                            speed = speed-1
                            printLCD(lcd,['Speed: ',num2str(speed)])
                            writePWMVoltage(a,'D9',2)
                            printLCD(lcd,'Mode: ACC');
                            pause(0.25)
                            writePWMVoltage(a,'D9',4.5)
                        elseif(speed>0&(readVoltage(a,'A0')>4.5))
                            speed = speed-1
                            printLCD(lcd,['Speed: ',num2str(speed)])
                            writePWMVoltage(a,'D9',2)
                            printLCD(lcd,'Mode: ACC');
                            pause(0.65)
                            writePWMVoltage(a,'D9',4.5)
                            speed = speed+1
                            printLCD(lcd,['Speed: ',num2str(speed)])
                            writePWMVoltage(a,'D9',2)
                            printLCD(lcd,'Mode: ACC');
                            pause(0.25)
                            writePWMVoltage(a,'D9',4.5)
                        end 
                    end
                    if(readVoltage(a,'A1')>4.5)
                            speed = speed+1;
                            printLCD(lcd,['Speed: ',num2str(speed)])
                            writePWMVoltage(a,'D9',2)
                            printLCD(lcd,'Mode: ACC');
                            pause(0.65)
                            writePWMVoltage(a,'D9',4.5)
                            speed = speed-1
                            printLCD(lcd,['Speed: ',num2str(speed)])
                            writePWMVoltage(a,'D9',2)
                            printLCD(lcd,'Mode: ACC');
                            pause(0.25)
                            writePWMVoltage(a,'D9',4.5)
                        elseif(speed>0&(readVoltage(a,'A0')>4.5))
                            speed = speed-1
                            printLCD(lcd,['Speed: ',num2str(speed)])
                            writePWMVoltage(a,'D9',2)
                            printLCD(lcd,'Mode: ACC');
                            pause(0.65)
                            writePWMVoltage(a,'D9',4.5)
                            speed = speed+1
                            printLCD(lcd,['Speed: ',num2str(speed)])
                            writePWMVoltage(a,'D9',2)
                            printLCD(lcd,'Mode: ACC');
                            pause(0.25)
                            writePWMVoltage(a,'D9',4.5)
                    end
                    printLCD(lcd,['Speed: ',num2str(speed)])
                    writePWMVoltage(a,'D9',2)
                    printLCD(lcd,'Mode: ACC');
                    pause(0.25)
                    writePWMVoltage(a,'D9',4.5)
            end
        case 4
            ACC = 0
            CC = 0
            NORM =1
            printLCD(lcd,['Speed: ',num2str(speed)])
            printLCD(lcd,'Mode: NORMAL');
            while(speed>0)
                     if (readVoltage(a, 'A0')>4.5)
                        button = 0
                        speed = decreaseSpeedNormal(speed,a,lcd);                        
                     elseif (readVoltage(a, 'A1')>4.5)
                        button = 1
                        speed = increaseSpeedNormal(speed,a,lcd);                       
                     elseif(readVoltage(a, 'A2')>4.5)
                        button = 2
                        CC = 1
                        mode = 'CC'
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        printLCD(lcd,'Mode: CC');
                        break;                            
                     elseif (readVoltage(a, 'A3')>4.5)
                        button = 3;
                        ACC=1
                        ACCSpeed = speed;
                        CC=0
                        mode = 'ACC'
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        printLCD(lcd,'Mode: ACC');
                        break;                       
                     elseif(readVoltage(a, 'A4')>4.5)
                        button = 4;
                        mode = 'NORMAL'                      
                     end
                     if(speed>0)
                        speed = speed-1;
                        printLCD(lcd,['Speed: ',num2str(speed)])
                        printLCD(lcd,'Mode: NORMAL');
                        pause(3)                   
                     end
            end
    end
end
%% Function Definitions

function speed = increaseSpeedNormal(speed,a,lcd)
while(speed>=0&(readVoltage(a,'A1')>4.5))
speed = speed+1;
printLCD(lcd,['Speed: ',num2str(speed)])
printLCD(lcd,'Mode: NORMAL');
%CC =1
pause(1)
end
return;
end

function speed = decreaseSpeedNormal(speed,a,lcd)
while(speed>0&(readVoltage(a,'A0')>4.5))
speed = speed-1;
printLCD(lcd,['Speed: ',num2str(speed)])
printLCD(lcd,'Mode: NORMAL');
%CC = 1
pause(1)
end
return;
end

function speed = increaseSpeedCC(speed,a,lcd,CC)
speed = speed+1;
printLCD(lcd,['Speed: ',num2str(speed)])
printLCD(lcd,'Mode: CC');
return
end

function speed = decreaseSpeedCC(speed,a,lcd,CC)
speed = speed-1;
printLCD(lcd,['Speed: ',num2str(speed)])
printLCD(lcd,'Mode: CC');
return
end
