function device = find_hardware_trigger_M()

serial_devs = serialportlist;  %%List of serial ports connected to your system

serial_found = false;
serial_iter = 1;

baudrate = 115200;
%terminator_str = "CR/LF";
timeout_time = 5;

% else if (inputString == "CAMERA") {
%       Serial.println("TRIGGER");
find_str = "<CAM>";
cam_str = "TRIG";

while ~serial_found && serial_iter <= length(serial_devs)
    
    port_str = serial_devs(serial_iter);
    
    device = serialport(port_str,baudrate); %%serialport(PORT,BAUDRATE) constructs a serialport object associated with port value PORT
                                            %%and a baud rate of BAUDRATE, andautomatically connects to the serial port.
    device.Timeout = timeout_time;
    
    %    configureTerminator(device,terminator_str);
    
    %pause(.5);
    %end_write_str = find_str + newline;
    
    flush(device);
    pause(timeout_time);
    
    writeline(device,find_str);
    pause(timeout_time/2);
    
    if ~device.NumBytesAvailable
        writeline(device,find_str);
        pause(timeout_time/2);
    end
    
    if device.NumBytesAvailable > 0
        response = read(device,device.NumBytesAvailable,'string');
        
        if contains(response,cam_str)
            serial_found = true;
        end
    else
        serial_iter = serial_iter + 1;
        clear device
    end
    
    if serial_iter > length(serial_devs)
        disp('No controller found');
        device = [];
        
    end
    
end











