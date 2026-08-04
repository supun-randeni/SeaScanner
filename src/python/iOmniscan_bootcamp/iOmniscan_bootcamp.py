#!/home/seabeaver/SB3_Py3.8.10/bin/python3
from pathlib import Path
import sys

# Always import brping from the ping-python clone beside this application.
PING_PYTHON_DIR = Path(__file__).resolve().parent.parent / "ping-python"
sys.path.insert(0, str(PING_PYTHON_DIR))

import pymoos
import time

from brping import Omniscan450
from brping import definitions
import threading
import signal

shutdown_event = threading.Event() # global program termination
sensor_shutdown_event = threading.Event() # sensor-only shutdown

# Create MOOS comms object
comms = pymoos.comms()
sensor_enable_requested = False
values_received = False

# Temporary known fix used to verify that an NMEA_WRAPPER message is embedded
# in both sonar logs. Replace this with the live MOOS GPS solution afterward.
FAKE_GPS_FIX = {
    "latitude": 42.3601,
    "longitude": -71.0942,
    "altitude": 3.0,
    "hdop": 0.8,
    "geoid_separation": -28.0,
    "reference_id": 0,
    "quality": 1,
    "satellites": 10,
}

active_sensors = []

# --- Signal handlers for clean shutdown ---
def handle_sigterm(signum, frame):
    print("Signal received — shutting down")
    shutdown_event.set()

signal.signal(signal.SIGTERM, handle_sigterm)
signal.signal(signal.SIGINT, handle_sigterm)

# SENSOR STUFF
def create_sensor(ip,directory):
    sensor = Omniscan450(logging=True, log_directory=directory)

    sensor_ip = ip
    port = 51200

    sensor.connect_tcp(sensor_ip, port)

    if sensor.initialize() is False:
        exit(1)

    # miliseconds / ping from ping rate
    ping_rate = 20 # 20 Hz
    my_msec_per_ping = Omniscan450.calc_msec_per_ping(ping_rate)

    # pulse length
    percent = 0.2 # 0.2 %
    my_pulse_length = Omniscan450.calc_pulse_length_pc(percent)

    sensor.control_os_ping_params(
        start_mm=0,
        length_mm=5000,                    # Set range to 5m
        msec_per_ping=my_msec_per_ping,
        pulse_len_percent=my_pulse_length,
        gain_index=-1,                       # Auto gain
        enable=1                             # Enable pinging
    )

    sensor.start_logging()

    return sensor

def hydroman_data_parser(data):
    lat_start = data.find("lat") + len("lat: ")
    lat_end = lat_start + data[lat_start:].find(" ")
    lat = data[lat_start:lat_end]

    lon_start = data.find("lon") + len("lon: ")
    lon_end = lon_start + data[lon_start:].find(" ")
    lon = data[lon_start:lon_end]

    time_start = data.find("time") + len("time: ")
    time_end = time_start + data[time_start:].find(" ")
    time = data[time_start:time_end]

    return (lat, lon, time)

def listen_to_sensor(sensor, label):
    try:
        while not sensor_shutdown_event.is_set() and not shutdown_event.is_set():
            data = sensor.wait_message([definitions.OMNISCAN450_OS_MONO_PROFILE])
            if data:
                print(f"{label} Ping Number: {data.ping_number}")
            else:
                print(f"{label} Bad Packet")
    finally:
        print(f"{label} Stopping pinging and shutting down")
        sensor.control_os_ping_params(enable=0)
        sensor.stop_logging()
        try:
            sensor.iodev.close()
            print(f"{label} Socket closed successfully")
        except Exception as e:
            print(f"{label} Failed to close socket: {e}")


last_msg_time = None

def on_connect():
    """Subscribe to these MOOS variables when connected."""
    # comms.register('RAW_GPS', 0)
    # comms.register('RAW_IMU', 0)
    # comms.register('RAW_DEPTH', 0)
    # comms.register('DEPTH_VALUE',0)
    comms.register('FSM_ENABLE_ACOMMS',0)
    comms.register('HYDROMAN_NAV_DATA', 0)
    return True

# def queue_callback(msg):
#     """Callback for messages arriving in the active queue."""
#     global values_received, last_msg_time
#     values_received = True #queue callback is only called if messages are received
#     last_msg_time = time.time()
#     msg.trace()
#     return True

def gps_callback(msg):
    """callback for logging GPS data"""
    if msg.is_string():
        # parse data from hydroman data received from SeaBeaver
        lat, long, time = hydroman_data_parser(msg.string())
        for sensor in active_sensors:
            sensor.log_gps_location(time, lat, long)


def queue_callback(msg):
    """Callback for messages arriving in the active queue."""
    global sensor_enable_requested

    msg.trace()

#    if msg.is_bool():
#        sensor_enable_requested = msg.bool()
    if msg.is_string():
        text = msg.string().strip().lower()
        sensor_enable_requested = text in ["true", "1", "yes", "on"]
    elif msg.is_double():
        sensor_enable_requested = msg.double() != 0.0
    else:
        print("Unsupported MOOS message type for OMNISCAN_ENABLE")

    print(f"OMNISCAN_ENABLE = {sensor_enable_requested}")
    return True


def main():
    global values_received, last_msg_time
    # Set up connection and subscriptions
    comms.set_on_connect_callback(on_connect)
    comms.add_active_queue('the_queue', queue_callback)
    comms.add_active_queue('gps_queue', gps_callback)
    # comms.add_message_route_to_active_queue('the_queue', 'RAW_GPS')
    # comms.add_message_route_to_active_queue('the_queue', 'RAW_IMU')
    # comms.add_message_route_to_active_queue('the_queue', 'RAW_DEPTH')
    comms.add_message_route_to_active_queue('the_queue', 'DEPTH_VALUE')
    comms.add_message_route_to_active_queue('the_queue', 'FSM_ENABLE_ACOMMS')
    comms.add_message_route_to_active_queue('gps_queue', 'HYDROMAN_NAV_DATA')

    # Connect to MOOSDB (update host/port as needed)
    #comms.run('localhost', 9000, 'pymoos_test')
    comms.run('localhost', 9000, 'VAL')

    Omniscan_Left = None
    Omniscan_Right = None
    t1 = None
    t2 = None
    is_sensors_on = False

    try:
        # Keep the program alive to process incoming messages
        while not shutdown_event.is_set():

            if sensor_enable_requested is False:
                if is_sensors_on is True:
                    print("FSM_ENABLE_ACOMMS is false — stopping sensors")

                    sensor_shutdown_event.set()

                    if t1 is not None:
                        t1.join()
                        t1 = None

                    if t2 is not None:
                        t2.join()
                        t2 = None

                    Omniscan_Left = None
                    Omniscan_Right = None
                    is_sensors_on = False
                    sensor_shutdown_event.clear()

            else:
                if is_sensors_on is False:
                    print("FSM_ENABLE_ACOMMS is true — starting sensors")

                    Omniscan_Left = create_sensor("192.168.2.90", "Omniscan_Left_logs")
                    Omniscan_Right = create_sensor("192.168.2.92", "Omniscan_Right_logs")

                    # add the created sensors to the active sensors list (global var)
                    # this allows them to be accessed from gps_callback
                    active_sensors = [Omniscan_Left, Omniscan_Right]

                    fake_fix_time = time.time()
                    for sensor in (Omniscan_Left, Omniscan_Right):
                        sensor.log_gps_location(
                            utc_time=fake_fix_time,
                            **FAKE_GPS_FIX)
                    print(f"Logged fake GPS fix at UTC {fake_fix_time}")

                    t1 = threading.Thread(target=listen_to_sensor, args=(Omniscan_Left, "Sensor 1"))
                    t2 = threading.Thread(target=listen_to_sensor, args=(Omniscan_Right, "Sensor 2"))

                    t1.start()
                    t2.start()

                    is_sensors_on = True

            time.sleep(0.1)
    finally:
        print("Main loop exiting — shutting down")
        shutdown_event.set()
        if t1 is not None:
            t1.join()
        if t2 is not None:
            t2.join()
        try:
            comms.close()   # or comms.stop() depending on your pymoos version
            print("MOOS comms closed successfully")
        except Exception as e:
            print(f"Failed to close MOOS comms: {e}")
        print("Shutdown complete")

if __name__ == "__main__":
    main()
