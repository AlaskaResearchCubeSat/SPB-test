function parm=mag_parm(cor,gain)
    s=size(cor);
    if(s(2)~=6)
        error('cor must have 6 columns');
    end

    %calcualte values
    parm(:,1)=1e3*cor(:,5)./(cor(:,1).*cor(:,5)-cor(:,4).*cor(:,2))/gain/(2*2^16-1);
    parm(:,2)=-100*cor(:,2)./cor(:,5);
    parm(:,3)=1e3*(cor(:,2).*cor(:,6)-cor(:,5).*cor(:,3))./(cor(:,1).*cor(:,5)-cor(:,4).*cor(:,2))/gain/(2*2^16-1);
    
    parm(:,4)=1e3*cor(:,1)./(cor(:,1).*cor(:,5)-cor(:,4).*cor(:,2))/gain/(2*2^16-1);
    parm(:,5)=-100*cor(:,4)./cor(:,1);
    parm(:,6)=1e3*(cor(:,3).*cor(:,4)-cor(:,1).*cor(:,6))./(cor(:,1).*cor(:,5)-cor(:,4).*cor(:,2))/gain/(2*2^16-1);
end