cc=cage_control();
err=cc.calibrate()
if err<1
    cc.saveCal('calibration.cal');
end
delete(cc);