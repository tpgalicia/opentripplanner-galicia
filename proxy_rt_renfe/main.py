# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "flask",
#     "protobuf",
#     "requests",
# ]
# ///

from flask import Flask, Response
import requests

from gtfsrt_pb2 import FeedEntity, FeedHeader, FeedMessage, TripDescriptor, TripUpdate


def download_rt_json():
    resp = requests.get("https://gtfsrt.renfe.com/trip_updates_LD.json")

    return resp.json()


def rt_json_to_proto(rt_json):
    header = FeedHeader(
        gtfs_realtime_version=rt_json["header"]["gtfsRealtimeVersion"],
        timestamp=int(rt_json["header"]["timestamp"]),
    )

    entities = []
    for entity_json in rt_json["entity"]:
        json_trip_update = entity_json.get("tripUpdate")
        if not json_trip_update:
            print(f"Skipping entity without tripUpdate: {entity_json['id']}")
            continue

        if not json_trip_update.get("delay"):
            print(f"Skipping entity without delay: {entity_json['id']}")
            continue

        trip_descriptor = TripDescriptor(
            trip_id=json_trip_update["trip"]["tripId"],
            schedule_relationship=TripDescriptor.SCHEDULED,
        )
        stu = TripUpdate.StopTimeUpdate(
            stop_sequence=1,
            arrival=TripUpdate.StopTimeEvent(delay=int(json_trip_update["delay"])),
            departure=TripUpdate.StopTimeEvent(delay=int(json_trip_update["delay"])),
        )
        trip_update = TripUpdate(
            trip=trip_descriptor,
            stop_time_update=[stu],
            delay=int(json_trip_update.get("delay", "0")),
        )
        entity = FeedEntity(id=entity_json["id"], trip_update=trip_update)
        entities.append(entity)

    feed = FeedMessage(header=header, entity=entities)

    return feed.SerializeToString()


app = Flask(__name__)


@app.route("/proto", methods=["GET"])
def proto():
    rt_json = download_rt_json()
    proto_data = rt_json_to_proto(rt_json)
    return Response(proto_data, mimetype="application/x-protobuf")

if __name__ == "__main__":
    app.run(host="localhost", port=5000)
