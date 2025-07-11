FROM osrm/osrm-backend

WORKDIR /data

COPY jakarta-jabar.pbf .
COPY profiles/car.lua /opt/car.lua
COPY profiles/lib /opt/lib

RUN osrm-extract -p /opt/car.lua /data/jakarta-jabar.pbf && \
    osrm-partition /data/jakarta-jabar.osrm && \
    osrm-customize /data/jakarta-jabar.osrm

CMD ["osrm-routed", "--algorithm", "mld", "/data/jakarta-jabar.osrm"]