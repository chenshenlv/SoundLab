function az_mirror = reflect(az)
%REFLECT Reflects the azimuth across the median plane.
%   Used in front/back confusion

az_mirror = az;

if az > 180
    reflect = abs(az - 270);
    if az > 270
        az_mirror = 270 - reflect;
    end
    if az < 270
        az_mirror = 270 + reflect;
    end
end

if az < 180
    reflect = abs(az - 90);
    if az > 90
        az_mirror = 90 - reflect;
    end
    if az < 90
        az_mirror = 90 + reflect;
    end    
end

if az == 180
    az_mirror = 0;
end
end

