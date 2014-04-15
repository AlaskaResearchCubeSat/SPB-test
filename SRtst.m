function [meas]=SRtst(com,baud)
    if(nargin<2)
        baud=57600;
    end
    if(nargin<1)
        com='COM3';
    end
    try
        cc=cage_control();
        cc.loadCal('calibration.cal');
        %open serial port
        ser=serial(com,'BaudRate',baud);
        %set timeout to 15s
        set(ser,'Timeout',15);
        %set terminator to LF
        set(ser,'Terminator','LF');
        %open port
        fopen(ser);

        %print ^C to stop running commands
        fprintf(ser,'%c',03);
        %set to machine readable opperation
        fprintf(ser,'log error');
        %wait for 
        if ~waitReady(ser)
            error('Could Not Communicate with Device');
        end
        
        %theta=linspace(0,2*pi,60);

        %Bs=0.5*[sin(theta);cos(theta);0*theta];
        
        %theta=linspace(0,2*pi,);
        %Bs=0.5*[sin(theta);cos(theta);0*theta];
        
        theta=linspace(0,17*pi,400);
        Bs=0.01*[theta.*sin(theta);theta.*cos(theta);0*theta];
        
        %allocate for sensor
        sensor=zeros(size(Bs));
        %allocate for prototype
        meas=zeros(4,length(Bs));
        %set initial field
        cc.Bs=Bs(:,1);
        %give extra settaling time
        pause(1);
        
        for k=1:length(Bs)
            cc.Bs=Bs(:,k);
            %pause to let the supply settle
            pause(0.01);
            %tell prototype to take a single measurment
            fprintf(ser,'SR');
            %make measurment using sensor
            sensor(:,k)=cc.Bm';
            %read echoed line
            fgetl(ser);
            %read measurments from prototype
            l=fgetl(ser);
            dat=sscanf(l,'%i %i %i %i');
            meas(1:4,k)=dat;
        end
        
        figure(1);
        plot(180/pi*theta,meas(1,:),180/pi*theta,meas(2,:),180/pi*theta,meas(3,:),180/pi*theta,meas(4,:));
        legend('set1','set2','reset1','reset2');
        
        figure(2);
        offset=meas(1:2,:)+meas(3:4,:);
        plot(180/pi*theta,offset(1,:),180/pi*theta,offset(2,:));
        legend('offset 1','offset 2');
        
        figure(3);
        field=meas(1:2,:)-meas(3:4,:);
        plot(180/pi*theta,field(1,:),180/pi*theta,field(2,:));
        legend('offset 1','offset 2');
        
    catch err
        if exist('ser','var')
            if strcmp(ser.Status,'open')
                fclose(ser);
            end
            delete(ser);
        end
        if exist('cc','var')
            delete(cc);
        end
        rethrow(err);
    end
    if exist('ser','var')
        if strcmp(ser.Status,'open')
            while ser.BytesToOutput
            end
            fclose(ser);
        end
        delete(ser);
    end
    if exist('cc','var')
        delete(cc);
    end
end

function [success]=waitReady(sobj,timeout,output)
    if nargin<3
        output=false;
    end
    if nargin<2
        timeout=5;
    end
    msg=0;
    count=0;
    while msg(end)~='>'
        len=sobj.BytesAvailable;
        if len==0
            if count*3>=timeout
                success=false;
                return
            end
            pause(3);
            count=count+1;
            continue;
        end
        [msg,~,~]=fread(sobj,len);
        if output
            fprintf('%s\n',char(msg'));
        end
    end
    success=true;
end