import asyncio
import websockets
import json

async def main():
    uri = "ws://localhost:6123"

    async with websockets.connect(uri) as websocket:
        await websocket.send("sub -e window_managed")
        await websocket.send("sub -e focus_changed")
        await websocket.send("sub -e focused_container_moved")
        
        while True:
            response = await websocket.recv()
            json_response = json.loads(response)
            
            if json_response["messageType"] == "client_response":
                print(f"Event subscription: {json_response['success']}")
            elif json_response["messageType"] == "event_subscription":
                window_data =  json_response['data'].get('managedWindow') or json_response['data'].get('focusedContainer')
                
                width = window_data['width']
                height = window_data['height']
                
                print(f"Width: {width}, Height: {height}")
                if width != None and height != None:
                    if width > height:
                        await websocket.send('c set-tiling-direction horizontal')
                    elif width < height:
                        await websocket.send('c set-tiling-direction vertical')
                                     
if __name__ == "__main__":
    asyncio.run(main())