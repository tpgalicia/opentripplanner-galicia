# https://just.systems
OTP_JAR := "otp-shaded-2.9.0.jar"
JAVA_ARGS := "-Xms3G -Xmx6G"

default:
    just --list

download-otp:
    curl -sLo {{OTP_JAR}} https://github.com/opentripplanner/OpenTripPlanner/releases/download/v2.9.0/otp-shaded-2.9.0.jar

[group('maps')]
download-osm:
    curl -sLO https://download.geofabrik.de/europe/spain/galicia-latest.osm.pbf
    uv --directory build_xunta run ./gen_parroquias.py --pbf ../galicia-latest.osm.pbf

[group('maps')]
build-osm:
    java -Xmx4G -jar {{OTP_JAR}} --buildStreet .

[group('transit')]
download-xunta NAP_API_KEY:
    uv --directory build_xunta run ./build_static_feed.py  {{NAP_API_KEY}}
    cp build_xunta/gtfs_xunta.zip feeds/xunta.zip

[group('transit')]
download-renfe NAP_API_KEY:
    uv --directory build_renfe run ./build_static_feed.py {{NAP_API_KEY}} --merge
    cp build_renfe/gtfs_renfe_galicia_merged.zip feeds/renfe.zip

[group('transit')]
download-tranvias NAP_API_KEY:
    uv --directory build_tranvias run ./build_static_feed.py {{NAP_API_KEY}}
    cp build_tranvias/gtfs_coruna.zip feeds/tranvias.zip

[group('transit')]
download-vitrasa:
    uv --directory build_vitrasa run ./build_static_feed.py --match-days match_days.json
    cp build_vitrasa/gtfs_vigo.zip feeds/vitrasa.zip

[group('transit')]
download-feeds NAP_API_KEY:
    just download-xunta {{NAP_API_KEY}}
    just download-renfe {{NAP_API_KEY}}
    just download-tranvias {{NAP_API_KEY}}
    just download-vitrasa

[group('transit')]
build-transit:
    java {{JAVA_ARGS}} -jar {{OTP_JAR}} --loadStreet --save .

[group('aio')]
setup NAP_API_KEY:
    just download-otp
    just download-osm
    just download-feeds NAP_API_KEY

[group('aio')]
build:
    just build-osm
    just build-tranist

[group('aio')]
serve:
    java {{JAVA_ARGS}} -jar {{OTP_JAR}} --load . --serve
