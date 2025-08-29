FROM contiker/contiki-ng:latest

RUN apt-get update && apt-get install -y iputils-ping netcat

# NodeB just listens on port 9001 and prints incoming messages
CMD ["bash", "-c", "nc -klu 9001"]
