import json
import signal
import sys
import threading
from azure.iot.device import IoTHubModuleClient

output_name = 'output2'

def process_input_message(input_message_json):
    print('Processing incoming message')
    inference_data = input_message_json['NEURAL_NETWORK']
    print('Extracted data {}'.format(inference_data))
    filtered_data = [ {'label':inference_entry['label'], 'confidence':inference_entry['confidence']}  for inference_entry in inference_data ]
    
    print("Number of elements detected: {}".format(len(filtered_data)))
    output_data = filtered_data
    
    print("Sending: {}".format(output_data))

    return output_data


def create_client():
    client = IoTHubModuleClient.create_from_edge_environment()

    def receive_message_handler(message):
        
        print("Message received on input {}".format(message.input_name))
        print( "    Data: <<{}>>".format(message.data) )
        print( "    Properties: {}".format(message.custom_properties))
        
        output_message = process_input_message(json.loads(message.data))

        print("Forwarding message to output {}".format(output_name))
        client.send_message_to_output(json.dumps(output_message), output_name)
        print("Message forwarded")

    try:
        # Set handler
        client.on_message_received = receive_message_handler
    except:
        # Cleanup
        client.shutdown()

    return client


def main():
    print ( "IoT Edge Data Parser" )

    # Event indicating sample stop
    stop_event = threading.Event()

    # Define a signal handler that will indicate Edge termination of the Module
    def module_termination_handler(signal, frame):
        print ("IoTHubClient sample stopped")
        stop_event.set()

    # Attach the signal handler
    signal.signal(signal.SIGTERM, module_termination_handler)

    # Create the client
    client = create_client()

    try:
        # This will be triggered by Edge termination signal
        stop_event.wait()
    except Exception as e:
        print("Unexpected error %s " % e)
        raise
    finally:
        # Graceful exit
        print("Shutting down client")
        client.shutdown()

if __name__ == '__main__':
    main()