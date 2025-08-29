FROM contiker/contiki-ng:latest

RUN apt-get update && apt-get install -y netcat iputils-ping

# Set the IP of the other device (change this later as needed)
ENV RECEIVER_IP=192.168.0.11

# Auto-send UDP packets every 5 seconds to node B (receiver)
CMD while true; do echo "Hi from Contiki Node A" | nc -u -w1 $RECEIVER_IP 9001; sleep 5; done
